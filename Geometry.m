//
//  Geometry.m
//  Blobular
//
//  Created by Stephan Michels on 25.06.09.
//  Copyright 2009 Beilstein Institut. All rights reserved.
//

#import "Geometry.h"


double distanceOf(NSPoint p0, NSPoint p1) {
	return hypot(p1.x-p0.x, p1.y-p0.y);
}

float angle(NSPoint p0, NSPoint p1) {
	return to_radians(atan2(p1.y-p0.y, p1.x-p0.x));
}

float to_radians(float angle) {
	return angle/M_PI*180;
}

float discriminate_angle(float angle) {
	return fmod(angle, 360.0f);
}

float rotate_angle(float angle) {
	return discriminate_angle(angle+180.0f);
}

/*!
 Calculates the two intersection point of two circles at p0 and p1
 and radius r0 and r1. pi is the intersection point of the right side 
 of p0->p1 and pi_prime of the left side.
 */
int circle_circle_intersection(NSPoint p0, float r0,
                               NSPoint p1, float r1,
                               NSPoint *pi, NSPoint *pi_prime) {
	
	// dx and dy are the vertical and horizontal distances between
	// the circle centers.
	float dx = p1.x - p0.x;
	float dy = p1.y - p0.y;
	
	// Determine the straight-line distance between the centers.
	//d = sqrt((dy*dy) + (dx*dx));
	float d = hypot(dx,dy); // Suggested by Keith Briggs
	
	// Check for solvability.
	if (d <= 0  || d > (r0 + r1)) {
		// no solution. circles do not intersect.
		return 0;
	}
	if (d < fabs(r0 - r1)) {
		// no solution. one circle is contained in the other
		return 0;
	}
	
	// 'point 2' is the point where the line through the circle
	// intersection points crosses the line between the circle
	// centers.  
	
	// Determine the distance from point 0 to point 2.
	float a = ((r0*r0) - (r1*r1) + (d*d)) / (2.0 * d) ;
	
	// Determine the coordinates of point 2.
	float x2 = p0.x + (dx * a/d);
	float y2 = p0.y + (dy * a/d);
	
	// Determine the distance from point 2 to either of the
	// intersection points.
	float h = sqrt((r0*r0) - (a*a));
	
	// Now determine the offsets of the intersection points from
	// point 2.
	float rx = -dy * (h/d);
	float ry = dx * (h/d);
	
	// Determine the absolute intersection points.
	(*pi).x = x2 + rx;
	(*pi).y = y2 + ry;
	(*pi_prime).x = x2 - rx;
	(*pi_prime).y = y2 - ry;
	
	return 1;
}
