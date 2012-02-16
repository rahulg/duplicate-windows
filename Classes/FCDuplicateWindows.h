//
//  FCDuplicateWindows.h
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

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface FCDuplicateWindows : NSObject {
  IBOutlet NSImageView *outputView;
  IBOutlet NSArrayController *arrayController;
  IBOutlet NSWindow *applicationWindow;
  IBOutlet NSPopUpButton *popUp;
  
  CGWindowID currentWindow;
  NSTimer *timer;
  NSTimer *updateWindowListTimer;
}

-(IBAction)windowChanged:(id)sender;

-(void)setOutputImage:(CGImageRef)cgImage;
-(void)createSingleWindowShot:(CGWindowID)windowID;
-(void)updateWindowListForGUI;

-(void)invalidateWindow;

@end
