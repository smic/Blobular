//
//  BlobularAppController.h
//  Blobular
//
//  Created by Stephan Michels on 17.06.09.
//  Copyright 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BlobularView.h"


@interface BlobularAppController : NSObject <NSApplicationDelegate>

@property (nonatomic, retain) IBOutlet BlobularView *view;
@property (nonatomic, retain) IBOutlet NSMenuItem *probeSizeMenuItem;
@property (nonatomic, retain) IBOutlet NSView *probeSizeView;

@end
