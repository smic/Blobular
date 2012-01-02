//
//  BlobularView.m
//  Blobular
//
//  Created by Stephan Michels on 14.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BlobularView.h"
#import "Blob.h"
#import "Geometry.h"


@implementation BlobularView

@synthesize blobs = _blobs;
@synthesize probeRadius = _probeRadius;
@synthesize showProbes = _showProbes;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        Blob *blob1 = [[[Blob alloc] initWithCenter:NSMakePoint(150.0f, 120.0f) radius:50.0f] autorelease];
        Blob *blob2 = [[[Blob alloc] initWithCenter:NSMakePoint(300.0f, 200.0f) radius:25.0f] autorelease];
        self.blobs = [NSArray arrayWithObjects:blob1, blob2, nil];
		
		self.probeRadius = 100.0f;
		
		self.showProbes = NO;
		
		NSTrackingArea *trackingArea = [[[NSTrackingArea alloc] initWithRect:frame
													options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow )
													  owner:self userInfo:nil] autorelease];
		[self addTrackingArea:trackingArea];
    }
    return self;
}

- (NSUInteger)blobUnderPoint:(NSPoint)point {
	NSUInteger selectedPoint = NSNotFound;
	for(NSUInteger i = 0; i < [self.blobs count]; i++) {
        Blob *blob = [self.blobs objectAtIndex:i];
		CGFloat dx = blob.center.x - point.x;
		CGFloat dy = blob.center.y - point.y;
		CGFloat radius = hypotf(dx, dy);
		if (radius <= blob.radius) {
			selectedPoint = i;
			break;
		}
	}
	return selectedPoint;
}

- (void)mouseDown:(NSEvent *)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	NSUInteger selectedBlobIndex = [self blobUnderPoint:point];
	if (selectedBlobIndex == NSNotFound) return;
    Blob *selectedBlob = [self.blobs objectAtIndex:selectedBlobIndex];
	
	[[NSCursor closedHandCursor] set];
	NSRect bounds = self.bounds;
	while ([event type]!=NSLeftMouseUp) {
		event = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
		NSPoint currentPoint = [self convertPoint:[event locationInWindow] fromView:nil];
		currentPoint.x = fminf(fmaxf(currentPoint.x, bounds.origin.x), bounds.size.width);
		currentPoint.y = fminf(fmaxf(currentPoint.y, bounds.origin.y), bounds.size.height);

        selectedBlob.center = NSMakePoint(selectedBlob.center.x + currentPoint.x - point.x, 
                                          selectedBlob.center.y + currentPoint.y - point.y);
		point = currentPoint;
		self.needsDisplay = YES;
	}
	[[NSCursor openHandCursor] set];
}

- (void)mouseMoved:(NSEvent *)event {
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	NSUInteger selectedBlobIndex = [self blobUnderPoint:point];
	if (selectedBlobIndex == NSNotFound) {
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
	
	for(NSUInteger i = 0; i < [self.blobs count]; i++) {
		Blob *blob1 = [self.blobs objectAtIndex:i];
		
		// test if circle is connected to other circles
		BOOL connected = NO;		
		for(NSUInteger j = 0; j < [self.blobs count]; j++) {
			Blob *blob2 = [self.blobs objectAtIndex:j];
			if (i != j && 
                distanceOf(blob1.center, blob2.center) < blob1.radius + blob2.radius + 2 * self.probeRadius &&
                distanceOf(blob1.center, blob2.center) > abs(blob1.radius - blob2.radius)) {
				connected = YES;
			}
		}
	
		for(NSUInteger j = i+1; j < [self.blobs count]; j++) {
			/*[[NSColor blackColor] set];
			[NSBezierPath strokeLineFromPoint:circles[i] toPoint:circles[j]];*/
			Blob *blob2 = [self.blobs objectAtIndex:j];
		
			NSPoint c1, c2;
			if (distanceOf(blob1.center, blob2.center) > abs(blob1.radius - blob2.radius) &&
                circle_circle_intersection(blob1.center, blob1.radius + self.probeRadius, blob2.center, blob2.radius + self.probeRadius, &c1, &c2)
            /* && projection_on_segment(circles[i], circles[j], c1)*/) {
			
				// draw line between circles
				[NSGraphicsContext saveGraphicsState];		
				[shadow set];
				[strokeColor set];
				[NSBezierPath strokeLineFromPoint:blob1.center toPoint:blob2.center];
				[NSGraphicsContext restoreGraphicsState];
	
				if (self.showProbes) {
					NSBezierPath* probePath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(c1.x - self.probeRadius, 
                                                                                                c1.y - self.probeRadius, 
                                                                                                2.0f * self.probeRadius, 
                                                                                                2.0f * self.probeRadius)];
					[[NSColor redColor] set];
					[probePath stroke];
		
					probePath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(c2.x - self.probeRadius, 
                                                                                  c2.y - self.probeRadius, 
                                                                                  2.0f * self.probeRadius, 
                                                                                  2.0f * self.probeRadius)];
					[[NSColor redColor] set];
					[probePath stroke];
				}
		
				/*[NSBezierPath strokeLineFromPoint:circles[0] toPoint:c1];
				[NSBezierPath strokeLineFromPoint:circles[1] toPoint:c1];
				[NSBezierPath strokeLineFromPoint:circles[0] toPoint:c2];
				[NSBezierPath strokeLineFromPoint:circles[1] toPoint:c2];*/
		
				float angle1 = angle(c1, blob1.center);
				float angle2 = angle(c1, blob2.center);
				float angle3 = angle(c2, blob1.center);
				float angle4 = angle(c2, blob2.center);
				
				NSBezierPath* path = [NSBezierPath bezierPath];
		
				// test if the connecting shape cut the middle line
				NSPoint m1, m2;
				if (distanceOf(blob1.center, blob2.center) > blob1.radius + blob2.radius && 
                    circle_circle_intersection(c2, self.probeRadius, c1, self.probeRadius, &m1, &m2)) {
					// draw two shapes, because the connecting shape intersects with the middle line 
					float angle5 = angle(c1, m1);
					float angle6 = angle(c1, m2);
					float angle7 = angle(c2, m1);
					float angle8 = angle(c2, m2);
					
					// draw two shapes
					[path appendBezierPathWithArcWithCenter:c1 
                                                     radius:self.probeRadius 
                                                 startAngle:angle5 
                                                   endAngle:angle1 
                                                  clockwise:YES];
					[path appendBezierPathWithArcWithCenter:blob1.center 
                                                     radius:blob1.radius 
                                                 startAngle:rotate_angle(angle1) 
                                                   endAngle:rotate_angle(angle3) 
                                                  clockwise:NO];
					[path appendBezierPathWithArcWithCenter:c2 
                                                     radius:self.probeRadius 
                                                 startAngle:angle3 
                                                   endAngle:angle7 
                                                  clockwise:YES];
					[path closePath];
					
					[path moveToPoint:m2];
					[path appendBezierPathWithArcWithCenter:c2 
                                                     radius:self.probeRadius 
                                                 startAngle:angle8 
                                                   endAngle:angle4 
                                                  clockwise:YES];
					[path appendBezierPathWithArcWithCenter:blob2.center 
                                                     radius:blob2.radius 
                                                 startAngle:rotate_angle(angle4) 
                                                   endAngle:rotate_angle(angle2) 
                                                  clockwise:NO];
					[path appendBezierPathWithArcWithCenter:c1 
                                                     radius:self.probeRadius 
                                                 startAngle:angle2 
                                                   endAngle:angle6 
                                                  clockwise:YES];
					[path closePath];
				} else {
					//NSLog(@"angle1=%f angle2=%f angle3=%f angle4=%f", angle1, angle2, angle3, angle4);
				
					[path appendBezierPathWithArcWithCenter:blob1.center 
                                                     radius:blob1.radius 
                                                 startAngle:rotate_angle(angle1) 
                                                   endAngle:rotate_angle(angle3) 
                                                  clockwise:NO];
					[path appendBezierPathWithArcWithCenter:c2 
                                                     radius:self.probeRadius 
                                                 startAngle:angle3 
                                                   endAngle:angle4 
                                                  clockwise:YES];
					[path appendBezierPathWithArcWithCenter:blob2.center 
                                                     radius:blob2.radius 
                                                 startAngle:rotate_angle(angle4) 
                                                   endAngle:rotate_angle(angle2) 
                                                  clockwise:NO];
					[path appendBezierPathWithArcWithCenter:c1 
                                                     radius:self.probeRadius 
                                                 startAngle:angle2 
                                                   endAngle:angle1 
                                                  clockwise:YES];
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
			NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(blob1.center.x-blob1.radius, blob1.center.y-blob1.radius, 2*blob1.radius, 2*blob1.radius)];
		
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


