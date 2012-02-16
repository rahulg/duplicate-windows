//
//  FCDuplicateWindow.h
//  DuplicateWindows
//
//  Created by Fabián Cañas on 4/18/10.
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
//
//
//  FCDuplicateWindow is the "Duplicate Window" -- Screenshots form the source window are
//  drawn to the DWImageView contained in the FCDuplicateWindow by FCDuplicateWindows.
//
//  This class implements custom code necesary for window movement and resizing, as well
//  as code to track the mouse as it enters and exits the window to control the visibility
//  of UI elements within the window.

#import <Cocoa/Cocoa.h>
#import "DWImageView.h"
#import "FCDuplicateWindows.h"
#import "DuplicateWindowsAppDelegate.h"

@interface FCDuplicateWindow : NSWindow {
  // initial mouse location of window resize and move operations
  NSPoint initialLocation;
  NSRect windowRect;
  IBOutlet NSPopUpButton *popUp;
  IBOutlet DWImageView *outputView;
  
  IBOutlet FCDuplicateWindows *duplicateWindows;
  IBOutlet NSArrayController *arrayController;
  BOOL isOnTop;
}

-(IBAction)toggleFullscreen:(id)sender;

-(IBAction)toggleTransparent:(id)sender;

-(IBAction)toggleOnTop:(id)sender;

//@property (assign) NSPoint initialLocation;

@end
