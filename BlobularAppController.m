//
//  DelaunayAppController.m
//  delaunay
//
//  Created by Stephan Michels on 17.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BlobularAppController.h"


@implementation BlobularAppController

@synthesize view = _view;
@synthesize probeSizeMenuItem = _probeSizeMenuItem;
@synthesize probeSizeView = _probeSizeView;

- (void)dealloc {
    self.view = nil;
    self.probeSizeMenuItem = nil;
    self.probeSizeView = nil;
    
    [super dealloc];
}

-(void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self.probeSizeMenuItem setView:self.probeSizeView];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

- (IBAction)showProbes:(id)sender {
	self.view.showProbes = !self.view.showProbes;
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item {
	SEL action = [item action];	
	if (action == @selector(showProbes:)) {
		NSMenuItem *menuItem = (NSMenuItem*)item;
        [menuItem setState:self.view.showProbes ? NSOnState : NSOffState];
	}
	return YES;
}


@end
