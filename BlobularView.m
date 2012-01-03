//
//  BlobularView.m
//  Blobular
//
//  Created by Stephan Michels on 14.11.08.
//  Copyright 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "BlobularView.h"
#import "Blob.h"
#import "Geometry.h"


static char BlobularViewObservationContext;

@implementation BlobularView

@synthesize blobs = _blobs;
@synthesize probeRadius = _probeRadius;
@synthesize showProbes = _showProbes;

#pragma mark - Initialization / Deallocation

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
        
        [self addObserver:self 
               forKeyPath:@"probeRadius" 
                  options:(NSKeyValueObservingOptionNew) 
                  context:&BlobularViewObservationContext];
        [self addObserver:self 
               forKeyPath:@"showProbes" 
                  options:(NSKeyValueObservingOptionNew) 
                  context:&BlobularViewObservationContext];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self 
              forKeyPath:@"probeRadius" 
                 context:&BlobularViewObservationContext];
    [self removeObserver:self 
              forKeyPath:@"showProbes" 
                 context:&BlobularViewObservationContext];
    
    self.blobs = nil;
    
    [super dealloc];
}

#pragma mark - User interaction

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

#pragma mark - Drawing

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
	
	for(NSUInteger blobIndex1 = 0; blobIndex1 < [self.blobs count]; blobIndex1++) {
		Blob *blob1 = [self.blobs objectAtIndex:blobIndex1];
		
		// test if circle is connected to other circles
		BOOL connected = NO;		
		for(NSUInteger blobIndex2 = 0; blobIndex2 < [self.blobs count]; blobIndex2++) {
			Blob *blob2 = [self.blobs objectAtIndex:blobIndex2];
			if (blobIndex1 != blobIndex2 && 
                distanceOf(blob1.center, blob2.center) < blob1.radius + blob2.radius + 2 * self.probeRadius &&
                distanceOf(blob1.center, blob2.center) > fabs(blob1.radius - blob2.radius)) {
				connected = YES;
			}
		}
	
		for(NSUInteger blobIndex2 = blobIndex1 + 1; blobIndex2 < [self.blobs count]; blobIndex2++) {
			Blob *blob2 = [self.blobs objectAtIndex:blobIndex2];
		
			NSPoint c1, c2;
			if (distanceOf(blob1.center, blob2.center) > fabs(blob1.radius - blob2.radius) &&
                circle_circle_intersection(blob1.center, blob1.radius + self.probeRadius, blob2.center, blob2.radius + self.probeRadius, &c1, &c2)) {
				
                // show probe circles for debugging purposes
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
                    
                    // draw line between circles
                    [NSBezierPath strokeLineFromPoint:blob1.center toPoint:blob2.center];
                    
                    [NSBezierPath strokeLineFromPoint:blob1.center toPoint:c1];
                    [NSBezierPath strokeLineFromPoint:blob2.center toPoint:c1];
                    [NSBezierPath strokeLineFromPoint:blob1.center toPoint:c2];
                    [NSBezierPath strokeLineFromPoint:blob2.center toPoint:c2];
				}
		
		
                // determine various angles for the calculate the arc segments
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
				
                    // draw one single shape by connecting the various arc segments
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
			NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(blob1.center.x - blob1.radius, 
                                                                                   blob1.center.y - blob1.radius, 
                                                                                   2.0f * blob1.radius, 
                                                                                   2.0f * blob1.radius)];
		
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

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath 
                     ofObject:(id)object 
                       change:(NSDictionary *)change 
                      context:(void *)context {
    if (context != &BlobularViewObservationContext) {
        [super observeValueForKeyPath:keyPath 
                             ofObject:object 
                               change:change 
                              context:context];
        return;
    }
    
    NSLog(@"keyPath: %@, value: %f", keyPath, self.probeRadius);
    
    if ([keyPath isEqualToString:@"probeRadius"]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqualToString:@"showProbes"]) {
        [self setNeedsDisplay:YES];
    }
}

@end


