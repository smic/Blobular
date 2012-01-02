//
//  Geometry.m
//  Blobular
//
//  Created by Stephan Michels on 25.06.09.
//  Copyright 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "Geometry.h"


CGFloat distanceOf(NSPoint p0, NSPoint p1) {
	return hypotf(p1.x - p0.x, p1.y - p0.y);
}

double angle(NSPoint p0, NSPoint p1) {
	return to_radians(atan2(p1.y - p0.y, p1.x - p0.x));
}

double to_radians(double angle) {
	return angle / M_PI * 180.0;
}

double discriminate_angle(double angle) {
	return fmod(angle, 360.0);
}

double rotate_angle(double angle) {
	return discriminate_angle(angle + 180.0);
}

/*!
 Calculates the two intersection point of two circles at p0 and p1
 and radius r0 and r1. pi is the intersection point of the right side 
 of p0->p1 and pi_prime of the left side.
 */
BOOL circle_circle_intersection(NSPoint p0, CGFloat r0,
                                NSPoint p1, CGFloat r1,
                                NSPoint *pi, NSPoint *pi_prime) {
	
	// dx and dy are the vertical and horizontal distances between
	// the circle centers.
	CGFloat dx = p1.x - p0.x;
	CGFloat dy = p1.y - p0.y;
	
	// Determine the straight-line distance between the centers.
	//d = sqrt((dy*dy) + (dx*dx));
	CGFloat d = hypotf(dx,dy); // Suggested by Keith Briggs
	
	// Check for solvability.
	if (d <= 0  || d > (r0 + r1)) {
		// no solution. circles do not intersect.
		return NO;
	}
	if (d < fabs(r0 - r1)) {
		// no solution. one circle is contained in the other
		return NO;
	}
	
	// 'point 2' is the point where the line through the circle
	// intersection points crosses the line between the circle
	// centers.  
	
	// Determine the distance from point 0 to point 2.
	CGFloat a = ((r0*r0) - (r1*r1) + (d*d)) / (2.0f * d) ;
	
	// Determine the coordinates of point 2.
    NSPoint p2 = NSMakePoint(p0.x + (dx * a / d), 
                             p0.y + (dy * a / d));

	// Determine the distance from point 2 to either of the
	// intersection points.
	CGFloat h = sqrt((r0 * r0) - (a * a));
	
	// Now determine the offsets of the intersection points from
	// point 2.
	float rx = -dy * (h / d);
	float ry = dx * (h / d);
	
	// Determine the absolute intersection points.
	(*pi).x = p2.x + rx;
	(*pi).y = p2.y + ry;
	(*pi_prime).x = p2.x - rx;
	(*pi_prime).y = p2.y - ry;
	
	return YES;
}
