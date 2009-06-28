//
//  BlobularView.m
//  Blobular
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
		circle_count = 3;
		circles[0].center = NSMakePoint(200, 200); circles[0].radius = 50;
		circles[1].center = NSMakePoint(400, 200); circles[1].radius = 25;
		circles[2].center = NSMakePoint(300, 50); circles[2].radius = 35;
		
		probe_radius = 100;
		
		showProbes = NO;
		
		NSTrackingArea *trackingArea = [[[NSTrackingArea alloc] initWithRect:frame
													options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow )
													  owner:self userInfo:nil] autorelease];
		[self addTrackingArea:trackingArea];
    }
    return self;
}

- (int)circleUnderPoint:(NSPoint)point {
	int selectedPoint = -1;
	for(int i=0; i<circle_count; i++) {
		float dx = circles[i].center.x-point.x;
		float dy = circles[i].center.y-point.y;
		float radius = hypot(dx, dy);
		if (radius<=circles[i].radius) {
			selectedPoint = i;
			break;
		}
	}
	return selectedPoint;
}

- (void)mouseDown:(NSEvent *)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	int selectedPoint = [self circleUnderPoint:point];
	if (selectedPoint<0) return;
	
	[[NSCursor closedHandCursor] set];
	NSRect bounds = self.bounds;
	while ([event type]!=NSLeftMouseUp) {
		event = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
		NSPoint currentPoint = [self convertPoint:[event locationInWindow] fromView:nil];
		currentPoint.x = fminf(fmaxf(currentPoint.x, bounds.origin.x), bounds.size.width);
		currentPoint.y = fminf(fmaxf(currentPoint.y, bounds.origin.y), bounds.size.height);
	
		circles[selectedPoint].center.x += currentPoint.x-point.x;
		circles[selectedPoint].center.y += currentPoint.y-point.y;
		point = currentPoint;
		self.needsDisplay = YES;
	}
	[[NSCursor openHandCursor] set];
}

- (void)mouseMoved:(NSEvent *)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	int selectedPoint = [self circleUnderPoint:point];
	if (selectedPoint<0) {
		[[NSCursor arrowCursor] set];
	} else {
		[[NSCursor openHandCursor] set];
	}
}

- (void)mouseEntered:(NSEvent *)event {
	[[NSCursor arrowCursor] push];
}

- (void)mouseExited:(NSEvent *)event {
	[NSCursor pop];
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
		NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(circles[i].x-radii[i], circles[i].y-radii[i], 2*radii[i], 2*radii[i])];
		[[NSColor redColor] set];
		[path fill];
		[[NSColor blackColor] set];
		[path stroke];
	}*/
	
	for(int i=0; i<circle_count; i++) {
		BlobCircle circle1 = circles[i];
		
		// test if circle is connected to other circles
		BOOL connected = NO;		
		for(int j=0; j<circle_count; j++) {
			BlobCircle circle2 = circles[j];
			if (i!=j && distanceOf(circle1.center, circle2.center)<circle1.radius+circle2.radius+2*probe_radius && distanceOf(circle1.center, circle2.center)>abs(circle1.radius-circle2.radius)) {
				connected = YES;
			}
		}
	
		for(int j=i+1; j<circle_count; j++) {
			/*[[NSColor blackColor] set];
			[NSBezierPath strokeLineFromPoint:circles[i] toPoint:circles[j]];*/
			BlobCircle circle2 = circles[j];
		
			NSPoint c1, c2;
			if (distanceOf(circle1.center, circle2.center)>abs(circle1.radius-circle2.radius) && circle_circle_intersection(circle1.center, circle1.radius+probe_radius, circle2.center, circle2.radius+probe_radius, &c1, &c2)/* && projection_on_segment(circles[i], circles[j], c1)*/) {
			
				// draw line between circles
				[NSGraphicsContext saveGraphicsState];		
				[shadow set];
				[strokeColor set];
				[NSBezierPath strokeLineFromPoint:circle1.center toPoint:circle2.center];
				[NSGraphicsContext restoreGraphicsState];
	
				if (showProbes) {
					NSBezierPath* probePath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(c1.x-probe_radius, c1.y-probe_radius, 2*probe_radius, 2*probe_radius)];
					[[NSColor redColor] set];
					[probePath stroke];
		
					probePath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(c2.x-probe_radius, c2.y-probe_radius, 2*probe_radius, 2*probe_radius)];
					[[NSColor redColor] set];
					[probePath stroke];
				}
		
				/*[NSBezierPath strokeLineFromPoint:circles[0] toPoint:c1];
				[NSBezierPath strokeLineFromPoint:circles[1] toPoint:c1];
				[NSBezierPath strokeLineFromPoint:circles[0] toPoint:c2];
				[NSBezierPath strokeLineFromPoint:circles[1] toPoint:c2];*/
		
				float angle1 = angle(c1, circle1.center);
				float angle2 = angle(c1, circle2.center);
				float angle3 = angle(c2, circle1.center);
				float angle4 = angle(c2, circle2.center);
				
				NSBezierPath* path = [NSBezierPath bezierPath];
		
				// test if the connecting shape cut the middle line
				NSPoint m1, m2;
				if (distanceOf(circle1.center, circle2.center)>circle1.radius+circle2.radius && circle_circle_intersection(c2, probe_radius, c1, probe_radius, &m1, &m2)) {
					// draw two shapes, because the connecting shape intersects with the middle line 
					float angle5 = angle(c1, m1);
					float angle6 = angle(c1, m2);
					float angle7 = angle(c2, m1);
					float angle8 = angle(c2, m2);
					
					// draw two shapes
					[path appendBezierPathWithArcWithCenter:c1 radius:probe_radius startAngle:angle5 endAngle:angle1 clockwise:YES];
					[path appendBezierPathWithArcWithCenter:circle1.center radius:circle1.radius startAngle:rotate_angle(angle1) endAngle:rotate_angle(angle3) clockwise:NO];
					[path appendBezierPathWithArcWithCenter:c2 radius:probe_radius startAngle:angle3 endAngle:angle7 clockwise:YES];
					[path closePath];
					
					[path moveToPoint:m2];
					[path appendBezierPathWithArcWithCenter:c2 radius:probe_radius startAngle:angle8 endAngle:angle4 clockwise:YES];
					[path appendBezierPathWithArcWithCenter:circle2.center radius:circle2.radius startAngle:rotate_angle(angle4) endAngle:rotate_angle(angle2) clockwise:NO];
					[path appendBezierPathWithArcWithCenter:c1 radius:probe_radius startAngle:angle2 endAngle:angle6 clockwise:YES];
					[path closePath];
				} else {
					//NSLog(@"angle1=%f angle2=%f angle3=%f angle4=%f", angle1, angle2, angle3, angle4);
				
					[path appendBezierPathWithArcWithCenter:circle1.center radius:circle1.radius startAngle:rotate_angle(angle1) endAngle:rotate_angle(angle3) clockwise:NO];
					[path appendBezierPathWithArcWithCenter:c2 radius:probe_radius startAngle:angle3 endAngle:angle4 clockwise:YES];
					[path appendBezierPathWithArcWithCenter:circle2.center radius:circle2.radius startAngle:rotate_angle(angle4) endAngle:rotate_angle(angle2) clockwise:NO];
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
			NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(circle1.center.x-circle1.radius, circle1.center.y-circle1.radius, 2*circle1.radius, 2*circle1.radius)];
		
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


