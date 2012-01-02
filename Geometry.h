//
//  Geometry.h
//  Blobular
//
//  Created by Stephan Michels on 25.06.09.
//  Copyright 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import <Cocoa/Cocoa.h>


CGFloat distanceOf(NSPoint p0, NSPoint p1);

double angle(NSPoint p0, NSPoint p1);

double to_radians(double angle);

double discriminate_angle(double angle);

double rotate_angle(double angle);

BOOL circle_circle_intersection(NSPoint p0, CGFloat r0,
                                NSPoint p1, CGFloat r1,
                                NSPoint *pi, NSPoint *pi_prime);