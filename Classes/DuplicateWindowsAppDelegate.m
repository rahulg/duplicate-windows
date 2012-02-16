//
//  DuplicateWindowsAppDelegate.m
//  DuplicateWindows
//
//  Created by Fabián Cañas on 4/11/10.
//  Copyright 2010 Fabián Cañas. All rights reserved.
//
//  This file is part of DuplicateWindows.
//
//  DuplicateWindows is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  DuplicateWindows is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with DuplicateWindows.  If not, see <http://www.gnu.org/licenses/>.

#import "DuplicateWindowsAppDelegate.h"
#import <Sparkle/SUUpdater.h>

@implementation DuplicateWindowsAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert future initialization code here.
}

-(void)applicationWillFinishLaunching:(NSNotification *)notification {
  SUUpdater *sharedUpdater = [SUUpdater sharedUpdater];
  [sharedUpdater setAutomaticallyChecksForUpdates:TRUE];
  [sharedUpdater checkForUpdatesInBackground];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
  // Enables opening of new DW when application launches
  return YES;
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication {
  // Code that actually loads a DW when the "New" menu item is used, and when app launches
  return [NSBundle loadNibNamed:@"DuplicateWindow" owner:theApplication];
}

-(IBAction)newDuplicateWindow:(id)sender {
  [self applicationOpenUntitledFile:NSApp];
}

-(BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  return [[menuItem title] isEqualToString:@"New"];
}

@end
