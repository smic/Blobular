//
//  CircleView.m
//  delaunay
//
//  Created by Stephan Michels on 14.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BlobularView.h"
#import "Geometry.h"


@implementation BlobularView

@synthesize showProbes;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		point_count = 3;
		points[0] = NSMakePoint(200, 200); radii[0] = 50;
		points[1] = NSMakePoint(400, 200); radii[1] = 25;
		points[2] = NSMakePoint(300, 50); radii[2] = 35;
		
		probe_radius = 100;
		
		showProbes = NO;
		
		NSTrackingArea *trackingArea = [[[NSTrackingArea alloc] initWithRect:frame
													options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow )
													  owner:self userInfo:nil] autorelease];
		[self addTrackingArea:trackingArea];
    }
    return self;
}

- (void)awakeFromNib {
	NSLog(@"Awake from NIB");
	[self.window setAcceptsMouseMovedEvents:YES];
}

- (void)mouseDown:(NSEvent *)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	
	int selectedPoint = -1;
	for(int i=0; i<point_count; i++) {
		float dx = points[i].x-point.x;
		float dy = points[i].y-point.y;
		float radius = hypot(dx, dy);
		if (radius<=radii[i]) {
			selectedPoint = i;
			break;
		}
	}
	
	if (selectedPoint<0) return;
	
	while ([event type]!=NSLeftMouseUp) {
		event = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
		NSPoint currentPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	
		points[selectedPoint].x += currentPoint.x-point.x;
		points[selectedPoint].y += currentPoint.y-point.y;
		point = currentPoint;
		self.needsDisplay = YES;
	}
}

- (void)mouseMoved:(NSEvent *)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	NSLog(@"mouse move point=%@", NSStringFromPoint(point));
}

- (void)drawRect:(NSRect)rect {

	// draw background
	[[NSColor colorWithDeviceRed:28.0/255.0 green:60.0/255.0 blue:121.0/255.0 alpha:1.0] set];
	[NSBezierPath fillRect:rect];
		
	NSShadow* shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowOffset:NSMakeSize(0, 0)];
	[shadow setShadowBlurRadius:7.0];
	[shadow setShadowColor:[[NSColor whiteColor] colorWithAlphaComponent:1.0]];
	
	NSColor* fillColor = [NSColor colorWithDeviceRed:152.0/255.0 green:180.0/255.0 blue:227.0/255.0 alpha:1.0];
	NSColor* strokeColor = [[NSColor whiteColor] colorWithAlphaComponent:0.6];
	
	/*for(int i=0; i<point_count; i++) {
		NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(points[i].x-radii[i], points[i].y-radii[i], 2*radii[i], 2*radii[i])];
		[[NSColor redColor] set];
		[path fill];
		[[NSColor blackColor] set];
		[path stroke];
	}*/
	
	for(int i=0; i<point_count; i++) {
		// test if circle is connected to other circles
		BOOL connected = NO;		
		for(int j=0; j<point_count; j++) {
			if (i!=j && distanceOf(points[i], points[j])<radii[i]+radii[j]+2*probe_radius && distanceOf(points[i], points[j])>abs(radii[i]-radii[j])) {
				connected = YES;
			}
		}
	
		for(int j=i+1; j<point_count; j++) {
			/*[[NSColor blackColor] set];
			[NSBezierPath strokeLineFromPoint:points[i] toPoint:points[j]];*/
			
		
			NSPoint c1, c2;
			if (distanceOf(points[i], points[j])>abs(radii[i]-radii[j]) && circle_circle_intersection(points[i], radii[i]+probe_radius, points[j], radii[j]+probe_radius, &c1, &c2)/* && projection_on_segment(points[i], points[j], c1)*/) {
			
				// draw line between circles
				[NSGraphicsContext saveGraphicsState];		
				[shadow set];
				[strokeColor set];
				[NSBezierPath strokeLineFromPoint:points[i] toPoint:points[j]];
				[NSGraphicsContext restoreGraphicsState];
	
				if (showProbes) {
					NSBezierPath* probePath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(c1.x-probe_radius, c1.y-probe_radius, 2*probe_radius, 2*probe_radius)];
					[[NSColor redColor] set];
					[probePath stroke];
		
					probePath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(c2.x-probe_radius, c2.y-probe_radius, 2*probe_radius, 2*probe_radius)];
					[[NSColor redColor] set];
					[probePath stroke];
				}
		
				/*[NSBezierPath strokeLineFromPoint:points[0] toPoint:c1];
				[NSBezierPath strokeLineFromPoint:points[1] toPoint:c1];
				[NSBezierPath strokeLineFromPoint:points[0] toPoint:c2];
				[NSBezierPath strokeLineFromPoint:points[1] toPoint:c2];*/
		
				float angle1 = angle(c1, points[i]);
				float angle2 = angle(c1, points[j]);
				float angle3 = angle(c2, points[i]);
				float angle4 = angle(c2, points[j]);
				
				NSBezierPath* path = [NSBezierPath bezierPath];
		
				// test if the connecting shape cut the middle line
				NSPoint m1, m2;
				if (distanceOf(points[i], points[j])>radii[i]+radii[j] && circle_circle_intersection(c2, probe_radius, c1, probe_radius, &m1, &m2)) {
					// draw two shapes, because the connecting shape intersects with the middle line 
					float angle5 = angle(c1, m1);
					float angle6 = angle(c1, m2);
					float angle7 = angle(c2, m1);
					float angle8 = angle(c2, m2);
					
					// draw two shapes
					[path appendBezierPathWithArcWithCenter:c1 radius:probe_radius startAngle:angle5 endAngle:angle1 clockwise:YES];
					[path appendBezierPathWithArcWithCenter:points[i] radius:radii[i] startAngle:rotate_angle(angle1) endAngle:rotate_angle(angle3) clockwise:NO];
					[path appendBezierPathWithArcWithCenter:c2 radius:probe_radius startAngle:angle3 endAngle:angle7 clockwise:YES];
					[path closePath];
					
					[path moveToPoint:m2];
					[path appendBezierPathWithArcWithCenter:c2 radius:probe_radius startAngle:angle8 endAngle:angle4 clockwise:YES];
					[path appendBezierPathWithArcWithCenter:points[j] radius:radii[j] startAngle:rotate_angle(angle4) endAngle:rotate_angle(angle2) clockwise:NO];
					[path appendBezierPathWithArcWithCenter:c1 radius:probe_radius startAngle:angle2 endAngle:angle6 clockwise:YES];
					[path closePath];
				} else {
					//NSLog(@"angle1=%f angle2=%f angle3=%f angle4=%f", angle1, angle2, angle3, angle4);
				
					[path appendBezierPathWithArcWithCenter:points[i] radius:radii[i] startAngle:rotate_angle(angle1) endAngle:rotate_angle(angle3) clockwise:NO];
					[path appendBezierPathWithArcWithCenter:c2 radius:probe_radius startAngle:angle3 endAngle:angle4 clockwise:YES];
					[path appendBezierPathWithArcWithCenter:points[j] radius:radii[j] startAngle:rotate_angle(angle4) endAngle:rotate_angle(angle2) clockwise:NO];
					[path appendBezierPathWithArcWithCenter:c1 radius:probe_radius startAngle:angle2 endAngle:angle1 clockwise:YES];
					[path closePath];
				}
				
				// fill the shape
				[fillColor set];
				[path fill];
				
				// stroke the shape
				[NSGraphicsContext saveGraphicsState];		
				[shadow set];
				[strokeColor set];
				[path setLineWidth:1];
				[path stroke];
				[NSGraphicsContext restoreGraphicsState];
			}
		}
		
		// if the circle is not connected draw a single circle
		if (!connected) {
			NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(points[i].x-radii[i], points[i].y-radii[i], 2*radii[i], 2*radii[i])];
		
			[fillColor set];
			[path fill];
				
			[NSGraphicsContext saveGraphicsState];		
			[shadow set];
			[strokeColor set];
			[path setLineWidth:1];
			[path stroke];
			[NSGraphicsContext restoreGraphicsState];
		}
	}
}

@end


