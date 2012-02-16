//
//  DWImageView.m
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


#import "DWImageView.h"
#import "FCDuplicateWindow.h"

@implementation DWImageView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      [self updateTrackingAreas];
    }
    return self;
}

-(void)updateTrackingAreas {
  if (trackingArea != nil) {
    [self removeTrackingArea:trackingArea];
  }
  NSTrackingAreaOptions trackingOptions =
  NSTrackingCursorUpdate | NSTrackingEnabledDuringMouseDrag | NSTrackingMouseEnteredAndExited |
  NSTrackingActiveAlways | NSTrackingAssumeInside;
  // note: NSTrackingActiveAlways flags turns off the cursor updating feature
  // NSTrackingActiveInActiveApp used to be the option. Good to remember.
  
  trackingArea = [[NSTrackingArea alloc]
                  initWithRect: [self bounds] // track the entire view
                  options: trackingOptions
                  owner: self
                  userInfo: nil];
  [self addTrackingArea: trackingArea];
}

// Popup bar to show close buttong and available TWs should only be visible 
// when the mouse is inside the current window.
//
// Future versions will use these methods to show and hide additional
// DW-specific controls.
-(void)mouseEntered:(NSEvent *)theEvent {
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
  [dict setObject:popUp forKey:NSViewAnimationTargetKey];
  [dict setObject:NSViewAnimationFadeInEffect forKey:NSViewAnimationEffectKey];
  NSViewAnimation *anim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:dict]];
  [anim setDuration:0.2];
  [anim setAnimationCurve:NSAnimationEaseIn];
  [anim startAnimation];
  [anim release];
}
-(void)mouseExited:(NSEvent *)theEvent {
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
  [dict setObject:popUp forKey:NSViewAnimationTargetKey];
  [dict setObject:NSViewAnimationFadeOutEffect forKey:NSViewAnimationEffectKey];
  NSViewAnimation *anim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:dict]];
  [anim setDuration:0.3];
  [anim setAnimationCurve:NSAnimationEaseIn];
  [anim startAnimation];
  [anim release];
}

-(void)drawRect:(NSRect)rect {
  // Clear the background with a dark gray color
  if ([self isInFullScreenMode]) {
    NSGraphicsContext* theContext = [NSGraphicsContext currentContext];
    [theContext saveGraphicsState];
    [[NSColor colorWithDeviceRed:0.2 green:0.2 blue:0.2 alpha:1.0] setFill];
    NSRectFill(rect);
    [theContext restoreGraphicsState];
  }
  // Let out NSImageView super class deal with the rest.
  [super drawRect:rect];
}

-(IBAction)toggleFullscreen:(id)sender {
  if ([self isInFullScreenMode]) {
    // Change FullScreen menu item to reflect state.
    [[[[[NSApp mainMenu] itemWithTitle:@"View"] submenu]itemWithTitle:@"Exit Full Screen"] setTitle:@"Enter Full Screen"];
    [self exitFullScreenModeWithOptions:nil];
    [self setImageScaling:NSScaleToFit];
    
    
    // Window resizing code from FCDuplicateWindows is run whenever the TW is changed. However, if the view
    // is in full screen mode, this view will not appropriately resize itself according to the rules set up
    // in the nib file when the window changes size. This leads to an incorrectly placed DWImageView inside
    // the FCDuplicateWindow when we exit full screen mode after changing windows while in full screen mode
    // 
    // The following three lines resize the current view when exiting full-screen mode s.t. its dimensions
    // match the window, and the view's origin in the the window's bottom-left corner.
    NSRect newframe = [[self window] frame];
    newframe.origin = NSMakePoint(0.0, 0.0);
    [self setFrame: newframe];
    //
    //
    
  } else {
    // Change FullScreen menu item to reflect state.
    [[[[[NSApp mainMenu] itemWithTitle:@"View"] submenu]itemWithTitle:@"Enter Full Screen"] setTitle:@"Exit Full Screen"];
    [popUp setHidden:NO];
    
    // TODO : Get rid of, then Restore "On Top" state after going full screen
    
    // Create Dictionary to pass menubar-hiding option to fullscreenMode
    //   Should this dictionary just be kept in the app, or by itself in the object instead of created every time?
    NSDictionary *optDict = [NSDictionary dictionaryWithObject:
                            [NSNumber numberWithInt:
                             (NSApplicationPresentationAutoHideMenuBar|NSApplicationPresentationHideDock)] 
                                                        forKey:@"NSFullScreenModeApplicationPresentationOptions"];
    [self enterFullScreenMode:[NSScreen mainScreen] withOptions:optDict];
    [self setImageScaling:NSScaleProportionally];
  }
  
  // Ensure that Mouse tracking for entering and exiting the view reflect new size
  [self updateTrackingAreas];
}

-(void)cancelOperation:(id)sender {
  if ([self isInFullScreenMode]) [self toggleFullscreen:self];
}

@end
