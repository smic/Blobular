//
//  BlobularView.h
//  Blobular
//
//  Created by Stephan Michels on 14.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef struct {
	NSPoint center;
	float radius;
} BlobCircle;

@interface BlobularView : NSView {
	int circle_count;
	BlobCircle circles[3];
	
	float probe_radius;
	
	BOOL showProbes;
}

@property BOOL showProbes;

@end

