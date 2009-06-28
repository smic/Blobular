//
//  CircleView.h
//  delaunay
//
//  Created by Stephan Michels on 14.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BlobularView : NSView {
	int point_count;
	NSPoint points[3];
	float radii[3];
	
	float probe_radius;
	
	BOOL showProbes;
}

@property BOOL showProbes;

@end

