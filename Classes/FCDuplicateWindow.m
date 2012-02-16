//
//  FCDuplicateWindow.m
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


#import "FCDuplicateWindow.h"


@implementation FCDuplicateWindow

- (id) initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
  self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
  if (self != nil) {
    [self setMinSize:NSMakeSize(20.0, 20.0)];
    isOnTop = NO;
  }
  return self;
}

-(BOOL)canBecomeKeyWindow {
  return YES;
}

-(BOOL)acceptsFirstResponder {
  return YES;
}

-(IBAction)performClose:(id)sender {
  NSLog(@"Window Got performClose");
  [duplicateWindows invalidateWindow];
  [arrayController release];
  [self close];
}

- (void)mouseDown:(NSEvent *)event
{
	NSPoint mousePoint = [event locationInWindow];
	NSRect windowFrame = [self frame];
  
	BOOL resize = NO;
	if ((mousePoint.x>(windowFrame.size.width-15.0))&&(mousePoint.y<15.0)) {
		resize = YES;
	}
	
	NSPoint originalMouseLocation = [self convertBaseToScreen:[event locationInWindow]];
	NSRect originalFrame = [self frame];
  NSRect screenFrame = [[self screen] visibleFrame];
	
  CGFloat topOfScreen = (screenFrame.size.height)+screenFrame.origin.y;
  CGFloat maxDeltaY = screenFrame.origin.y+screenFrame.size.height - originalFrame.size.height - originalFrame.origin.y;
  
  while (YES)
	{ // Lock focus and take all the dragged and mouse up events until we
		// receive a mouse up.
    NSEvent *newEvent = [self
                         nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
		
    if ([newEvent type] == NSLeftMouseUp)
		{
			break;
		}
		
		// Work out how much the mouse has moved
		//
		NSPoint newMouseLocation = [self convertBaseToScreen:[newEvent locationInWindow]];
		NSPoint delta = NSMakePoint(
                                newMouseLocation.x - originalMouseLocation.x,
                                newMouseLocation.y - originalMouseLocation.y);
		
		NSRect newFrame = originalFrame;
		
		if (!resize)
		{
			// Alter the frame for a drag
			newFrame.origin.x += delta.x;
			newFrame.origin.y += ((newFrame.origin.y+newFrame.size.height+delta.y)>topOfScreen)?maxDeltaY:delta.y;
		}
		else
		{	// Alter the frame for a resize
      
      // Preserve aspect ratio:
      // TODO: fix some "jumpiness" in the logic... :-(
      if (delta.y>0.0) {
        newFrame.size.height-=delta.y;
        newFrame.size.width = ([self contentAspectRatio].width * newFrame.size.height) / [self contentAspectRatio].height;
      } else if (delta.x<0.0) {
        newFrame.size.width+=delta.x;
        newFrame.size.height = ([self contentAspectRatio].height * newFrame.size.width) / [self contentAspectRatio].width;
      } else {
        if ((abs(delta.y)*[self contentAspectRatio].width)<(delta.x*[self contentAspectRatio].height)) {
          newFrame.size.height-=delta.y;
          newFrame.size.width = ([self contentAspectRatio].width * newFrame.size.height) / [self contentAspectRatio].height;
        } else {
          newFrame.size.width+=delta.x;
          newFrame.size.height = ([self contentAspectRatio].height * newFrame.size.width) / [self contentAspectRatio].width;
        }
      }      
      
      // Maintain upper-left corner in original position.
      newFrame.origin.y += originalFrame.size.height - newFrame.size.height;
			
			//
			// Constrain to the window's min and max size
			//
			NSRect newContentRect = [self contentRectForFrameRect:newFrame];
			NSSize maxSize = [self maxSize];
			NSSize minSize = [self minSize];
			if (newContentRect.size.width > maxSize.width)
			{
				newFrame.size.width -= newContentRect.size.width - maxSize.width;
			}
			else if (newContentRect.size.width < minSize.width)
			{
				newFrame.size.width += minSize.width - newContentRect.size.width;
			}
			if (newContentRect.size.height > maxSize.height)
			{
				newFrame.size.height -= newContentRect.size.height - maxSize.height;
				newFrame.origin.y += newContentRect.size.height - maxSize.height;
			}
			else if (newContentRect.size.height < minSize.height)
			{
				newFrame.size.height += minSize.height - newContentRect.size.height;
				newFrame.origin.y -= minSize.height - newContentRect.size.height;
			}
      
      // Tracking areas in view are responsible for showing and hiding the DW-specific UI controls.
      [outputView updateTrackingAreas];
		}
		
    // Animation suring moving and resizing is luggy. Doesn't need to happen.
    // Apply the transformations and display them "in-loop"
		[self setFrame:newFrame display:YES animate:NO];
	}
}

// Toggles both in and out of full screen.
// Since the window is the FirstResponder, all we do is forward the message to our view.
-(IBAction) toggleFullscreen:(id) sender {
    [outputView toggleFullscreen:sender];
}

-(IBAction)toggleTransparent:(id)sender {
    if ([self alphaValue]<1.0) {
        [self setAlphaValue:1.0];
        [self setIgnoresMouseEvents:NO];
    } else {
        [self setAlphaValue:.4];
        [self setIgnoresMouseEvents:YES];
    }
}


// Sets whether the window is drawn above all other windows or not.
-(IBAction)toggleOnTop:(id)sender {
  if ([self level]==NSModalPanelWindowLevel) {
    isOnTop=NO;
    [self setLevel:NSNormalWindowLevel];
    if ([[sender className] isEqualToString:@"NSMenuItem"])
      [sender setState:NSOffState];
  } else {
    isOnTop=YES;
    [self setLevel:NSModalPanelWindowLevel];
    if ([[sender className] isEqualToString:@"NSMenuItem"])
      [sender setState:NSOnState];
  }
}

-(BOOL) validateMenuItem:(NSMenuItem *)menuItem {
  // FCDuplicateWindows only interact with three menu items:
  return ([[menuItem title] isEqualToString:@"Enter Full Screen"] 
          || [[menuItem title] isEqualToString:@"Always On Top"]
          || [[menuItem title] isEqualToString:@"Transparent"]
          || [[menuItem title] isEqualToString:@"Close"]);
}

-(void)becomeKeyWindow {
  // Update the "Always On Top" menu item to reflect this window's level.
  //
  // Get "Always On Top" menu item from from within the "View" menu
  NSMenuItem *aot = [[[[NSApp mainMenu] itemWithTitle:@"View"] submenu] itemWithTitle:@"Always On Top"];
  // Set that menu item's status to reflect this window's level, which is either NSStatusWindowLevel if on top,
  // or (irrelevant to this code) NSNormalWindowLevel.
  [aot setState:(([self level]==NSModalPanelWindowLevel)?NSOnState:NSOffState)];
  
  // Call to super. Do not remove. I think this handles making the window
  // a first responder, and potentially other things too.
  [super becomeKeyWindow];
}

@end
