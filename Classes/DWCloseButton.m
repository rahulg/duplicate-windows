//
//  DWCloseButton.m
//  DuplicateWindows
//
//  Created by Fabián Cañas on 4/23/10.
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

#import "DWCloseButton.h"


@implementation DWCloseButton

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      [self setImage:[NSImage imageNamed:@"close_bar.pdf"]];
      [self updateTrackingAreas];
    }
    return self;
}

-(void)updateTrackingAreas{
  NSLog(@"Tracking area updates");
  if (trackingArea != nil) {
    [self removeTrackingArea:trackingArea];
  }
  NSTrackingAreaOptions trackingOptions =
  NSTrackingCursorUpdate | NSTrackingEnabledDuringMouseDrag | NSTrackingMouseEnteredAndExited |
  NSTrackingActiveAlways;
  // note: NSTrackingActiveAlways flags turns off the cursor updating feature
  // NSTrackingActiveInActiveApp used to be the option. Good to remember.
  
  trackingArea = [[NSTrackingArea alloc]
                  initWithRect: [self bounds] // track the entire view
                  options: trackingOptions
                  owner: self
                  userInfo: nil];
  [self addTrackingArea: trackingArea];
}

-(void)mouseEntered:(NSEvent *)theEvent {
  [self setImage:[NSImage imageNamed:@"close_bar_h.pdf"]];
}
-(void)mouseExited:(NSEvent *)theEvent {
  // End a closing operation if mouse exits the CloseButton
  isClosing = NO;
  [self setImage:[NSImage imageNamed:@"close_bar.pdf"]];
}

-(void)mouseDown:(NSEvent *)theEvent {
  // MouseDown inside the colseButton begins a close event.
  isClosing = YES;
  [self setImage:[NSImage imageNamed:@"close_bar_p.pdf"]];
}

-(void)mouseUp:(NSEvent *)theEvent {
  // Closing event started by clicking close button,
  // and mouse-up happens before mouse leaves button area.
  if (isClosing) {
	  [[self window] performClose:self];
  }
}

@end
