//
//  BlobularView.h
//  Blobular
//
//  Created by Stephan Michels on 14.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BlobularView : NSView

@property (nonatomic, retain) NSArray *blobs;
@property (nonatomic, assign) CGFloat probeRadius;
@property (nonatomic, assign) BOOL showProbes;

@end

