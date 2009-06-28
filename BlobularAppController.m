//
//  DelaunayAppController.m
//  delaunay
//
//  Created by Stephan Michels on 17.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BlobularAppController.h"


@implementation BlobularAppController

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

- (IBAction)showProbes:(id)sender {
	NSLog(@"Show probes %i", view.showProbes);
	view.showProbes = !view.showProbes;
	view.needsDisplay = YES;
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item {
	SEL action = [item action];
	NSLog(@"validate item %@", NSStringFromSelector(action));
	
	if (action == @selector(showProbes:)) {
		NSMenuItem *menuItem = (NSMenuItem*)item;
		[menuItem setEnabled:view.showProbes];
	}
	return YES;
}


@end
