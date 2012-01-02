//
//  Blob.h
//  Blobular
//
//  Created by Stephan Michels on 02.01.12.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Blob : NSObject

@property (nonatomic, assign) NSPoint center;
@property (nonatomic, assign) CGFloat radius;

- (id)initWithCenter:(NSPoint)center radius:(CGFloat)radius;

@end
