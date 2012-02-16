//
//  FCDuplicateWindows.m
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

#import "FCDuplicateWindows.h"


@implementation FCDuplicateWindows

// Simple helper to twiddle bits in a uint32_t. 
uint32_t ChangeBits(uint32_t currentBits, uint32_t flagsToChange, BOOL setFlags)
{
	if(setFlags)
	{	// Set Bits
		return currentBits | flagsToChange;
	}
	else
	{	// Clear Bits
		return currentBits & ~flagsToChange;
	}
}

NSString *kAppNameKey = @"applicationName";	// Application Name & PID
NSString *kWindowOriginKey = @"windowOrigin";	// Window Origin as a string
NSString *kWindowSizeKey = @"windowSize";		// Window Size as a string
NSString *kWindowIDKey = @"windowID";			// Window ID
NSString *kWindowLevelKey = @"windowLevel";	// Window Level
NSString *kWindowOrderKey = @"windowOrder";	// The overall front-to-back ordering of the windows as returned by the window server


-(void)setOutputImage:(CGImageRef)cgImage
{
	if(cgImage != NULL)
	{
		// Create a bitmap rep from the image...
		NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
		// Create an NSImage and add the bitmap representation to it
		NSImage *image = [[NSImage alloc] init];
		[image addRepresentation:bitmapRep];
		[bitmapRep release];
    
    NSRect screenRect = [[applicationWindow screen] visibleFrame];
    
    // Save image's size rectangle describing window for later to avoid repeatedly sending these messages 
    // (I don't know if this is neccesary)
    NSRect frame = [applicationWindow frame];
    NSSize imageSize = [image size];
    
    [applicationWindow setContentAspectRatio:imageSize];
    
    // Calculate new origin so that window's center doesn't change through its tranformation:
    NSPoint oldCenter = NSMakePoint(frame.origin.x+(frame.size.width/2), frame.origin.y+(frame.size.height/2));
    NSPoint newOrigin = NSMakePoint((oldCenter.x-(imageSize.width/2)<screenRect.origin.x)?screenRect.origin.x:(oldCenter.x-(imageSize.width/2)), 
                                    (oldCenter.y-(imageSize.height/2)<screenRect.origin.y)?screenRect.origin.y:oldCenter.y-(imageSize.height/2));
    
    // Set the output view to the new NSImage.
		[outputView setImage:image];
    
    if (imageSize.width<20.0) {
      imageSize.width=20.0;
    }
    if (imageSize.height<20.0) {
      imageSize.height=20.0;
    }
    
    CGRect rect = CGRectIntegral(CGRectMake(newOrigin.x, newOrigin.y, imageSize.width, imageSize.height));
    
    // Resize window.
    [applicationWindow setFrame:NSRectFromCGRect(rect) display:YES animate:YES];
    
		[image release];
	}
	else
	{
    // There is no image
		[outputView setImage:nil];
	}
}

-(void)updateDrawing
{
  CGWindowImageOption imageOptions = kCGWindowImageDefault;
  imageOptions = ChangeBits(imageOptions, kCGWindowImageBoundsIgnoreFraming, YES);
	CGImageRef cgImage = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, currentWindow, imageOptions);
	
  if(cgImage != NULL)
	{
		// Create a bitmap rep from the image...
		NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
		// Create an NSImage and add the bitmap rep to it...
		NSImage *image = [[NSImage alloc] init];
		[image addRepresentation:bitmapRep];
		[bitmapRep release];
    
    if (applicationWindow) {
      [applicationWindow setContentAspectRatio:[image size]];
    } else {
      [self dealloc];
      return;
    }

    
    
		// Set the output view to the new NSImage.
		[outputView setImage:image];
		[image release];
	}
	else
	{
		[outputView setImage:nil];
	}
  
	CGImageRelease(cgImage);
}

-(IBAction)windowChanged:(id)sender
{
  NSArray *selection = [arrayController selectedObjects];
  
  NSArray *objects = [arrayController arrangedObjects];
  
	if([selection count] == 0)
	{
		[self setOutputImage:NULL];
	}
	else if([selection count] == 1)
	{
		// Single window selected, so use the single window options.
		// Need to grab the CGWindowID to pass to the method.
		CGWindowID windowID = [[[objects objectAtIndex:[popUp indexOfSelectedItem]] objectForKey:kWindowIDKey] unsignedIntValue];
		[self createSingleWindowShot:windowID];
    currentWindow = windowID;
	}  
}



#pragma mark Window List & Window Image Methods
typedef struct
{
	// Where to add window information
	NSMutableArray * outputArray;
	// Tracks the index of the window when first inserted
	// so that we can always request that the windows be drawn in order.
	int order;
} WindowListApplierData;

void WindowListApplierFunction(const void *inputDictionary, void *context)
{
	NSDictionary *entry = (NSDictionary*)inputDictionary;
	WindowListApplierData *data = (WindowListApplierData*)context;
	
	// The flags that we pass to CGWindowListCopyWindowInfo will automatically filter out most undesirable windows.
	// However, it is possible that we will get back a window that we cannot read from, so we'll filter those out manually.
	int sharingState = [[entry objectForKey:(id)kCGWindowSharingState] intValue];
	if(sharingState != kCGWindowSharingNone)
	{
		NSMutableDictionary *outputEntry = [NSMutableDictionary dictionary];
		
		// Grab the application name, but since it's optional so we need to check before we can use it.
		NSString *applicationName = [entry objectForKey:(id)kCGWindowOwnerName];
		if(applicationName != NULL)
		{
      // Get the window name
      NSString *windowName = [entry objectForKey:(id)kCGWindowName];
      NSString *nameAndPID;
      if ([windowName length]>0 && (windowName != NULL)) {
        nameAndPID = [NSString stringWithFormat:@"%@ – %@", applicationName, windowName];
      } else {
        nameAndPID = applicationName;
      }

      // Forget the PID
			// PID is required so we assume it's present.
			//NSString *nameAndPID = [NSString stringWithFormat:@"%@ (%@)", applicationName, [entry objectForKey:(id)kCGWindowOwnerPID]];
			[outputEntry setObject:nameAndPID forKey:kAppNameKey];
		}
		else
		{
			// The application name was not provided, so we use a fake application name to designate this.
			// PID is required so we assume it's present.
			NSString *nameAndPID = [NSString stringWithFormat:@"((unknown)) (%@)", [entry objectForKey:(id)kCGWindowOwnerPID]];
			[outputEntry setObject:nameAndPID forKey:kAppNameKey];
		}
		
    
		// Grab the Window Bounds, it's a dictionary in the array, but we want to display it as strings
		CGRect bounds;
		CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[entry objectForKey:(id)kCGWindowBounds], &bounds);
		NSString *originString = [NSString stringWithFormat:@"%.0f/%.0f", bounds.origin.x, bounds.origin.y];
		[outputEntry setObject:originString forKey:kWindowOriginKey];
		NSString *sizeString = [NSString stringWithFormat:@"%.0f*%.0f", bounds.size.width, bounds.size.height];
		[outputEntry setObject:sizeString forKey:kWindowSizeKey];
		
		// Grab the Window ID & Window Level. Both are required, so just copy from one to the other
		[outputEntry setObject:[entry objectForKey:(id)kCGWindowNumber] forKey:kWindowIDKey];
		[outputEntry setObject:[entry objectForKey:(id)kCGWindowLayer] forKey:kWindowLevelKey];
		
		// Finally, we are passed the windows in order from front to back by the window server
		// Should the user sort the window list we want to retain that order so that screen shots
		// look correct no matter what selection they make, or what order the items are in. We do this
		// by maintaining a window order key that we'll apply later.
		[outputEntry setObject:[NSNumber numberWithInt:data->order] forKey:kWindowOrderKey];
		data->order++;
		
		[data->outputArray addObject:outputEntry];
	}
}

-(void)updateWindowListForGUI
{
	// Ask the window server for the list of windows.
  CGWindowListOption listOptions = kCGWindowListOptionAll;
	listOptions = ChangeBits(listOptions, kCGWindowListOptionOnScreenOnly, YES);
	listOptions = ChangeBits(listOptions, kCGWindowListExcludeDesktopElements, YES);
	CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
	
	// Copy the returned list, further pruned, to another list. This also adds some bookkeeping
	// information to the list as well as 
	NSMutableArray * prunedWindowList = [NSMutableArray array];
	WindowListApplierData data = {prunedWindowList, 0};
	CFArrayApplyFunction(windowList, CFRangeMake(0, CFArrayGetCount(windowList)), &WindowListApplierFunction, &data);
	CFRelease(windowList);
	
	// Set the new window list
	[arrayController setContent:prunedWindowList];
}

-(void)createSingleWindowShot:(CGWindowID)windowID
{
	// Create an image from the passed in windowID with the single window option selected by the user.
  CGWindowImageOption imageOptions = kCGWindowImageDefault;
  imageOptions = ChangeBits(imageOptions, kCGWindowImageBoundsIgnoreFraming, YES);
	CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, windowID, imageOptions);
	[self setOutputImage:windowImage];
	CGImageRelease(windowImage);
}

-(void)awakeFromNib
{
  [self updateWindowListForGUI];
  
  // This is in anticipation of fullscreen mode, where the image is not to be scaled.
  // The default will be to start in windowed mode where the image is scaled to the size of the window
  [outputView setImageScaling:NSScaleToFit];
  
  // This is now specified in the window definition itself
  [applicationWindow setContentMinSize:NSMakeSize(20.0, 20.0)];
  
  // Timer to update the window 20 times per second.
  timer = [NSTimer timerWithTimeInterval:1.0/20.0 target:self selector: @selector(updateDrawing) userInfo: nil repeats: YES];
  // Timer to update the window list every 5 seconds.
  updateWindowListTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector: @selector(updateWindowListForGUI) userInfo: nil repeats: YES];
  
  // Add timers to Run Loop.
  [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
  [[NSRunLoop currentRunLoop] addTimer:updateWindowListTimer forMode:NSDefaultRunLoopMode];
}

-(void)invalidateWindow {
  applicationWindow = nil;
}

-(void)dealloc
{
  [timer invalidate];
  [updateWindowListTimer invalidate];
  [super dealloc];
}

@end
