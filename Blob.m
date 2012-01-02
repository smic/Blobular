//
//  Blob.m
//  Blobular
//
//  Created by Stephan Michels on 02.01.12.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "Blob.h"

/*@interface Blob () {
@private
    NSPoint _center;
    CGFloat _radius;
}

@end*/

@implementation Blob 

@synthesize center = _center;
@synthesize radius = _radius;

- (id)initWithCenter:(NSPoint)center radius:(CGFloat)radius {
    self = [super init];
    if (self) {
        self.center = center;
        self.radius = radius;
    }
    return self;
}

@end
