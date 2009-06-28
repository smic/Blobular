//
//  Geometry.h
//  Blobular
//
//  Created by Stephan Michels on 25.06.09.
//  Copyright 2009 Beilstein Institut. All rights reserved.
//

#import <Cocoa/Cocoa.h>


double distanceOf(NSPoint p0, NSPoint p1);

float angle(NSPoint p0, NSPoint p1);

float to_radians(float angle);

float discriminate_angle(float angle);

float rotate_angle(float angle);

int circle_circle_intersection(NSPoint p0, float r0,
                               NSPoint p1, float r1,
                               NSPoint *pi, NSPoint *pi_prime);