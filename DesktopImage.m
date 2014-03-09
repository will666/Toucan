//
//  DesktopImage.m
//  Toucan
//
//  Created by will on 17/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import "DesktopImage.h"


@implementation DesktopImage

@synthesize imagePath;

- (void)dealloc
{
	self.imagePath = nil;
	[super dealloc];
}

- (void)changeDesktopImage
{
//	SInt32 MacVersion;
//	
//	if (Gestalt(gestaltSystemVersion, &MacVersion) == noErr)
//	{
//		if(MacVersion < 0x1060)
//		{
//			//10.5 Framework
//			NSString * script = [NSString stringWithFormat: 
//								 @"tell application \"Finder\"\n"
//								 "set image_file to POSIX file \"%@\"\n"
//								 "set desktop picture to image_file\n"
//								 "end tell", 
//								 self.imagePath];
//			
//			NSDictionary * anError = nil;
//			NSAppleScript * aps = [[NSAppleScript alloc] initWithSource: script];
//			[aps executeAndReturnError: &anError];
//			[aps release];
//			
//			[[NSDistributedNotificationCenter defaultCenter] postNotificationName: @"com.apple.desktop" object: @"BackgroundChanged"];
//		}
//		else
//		{
//			//10.6 Framework
//			NSError * error = nil;
//			NSScreen * screen = [NSScreen mainScreen];
//			NSURL * path = [NSURL fileURLWithPath: self.imagePath];
//			[[NSWorkspace sharedWorkspace] setDesktopImageURL: path forScreen: screen options: nil error: &error];
//		}
//	}
	
	// OS version =< 10.6.x
	if([self.imagePath isEqualToString: @""]) return;
	
	NSString * script = [NSString stringWithFormat: 
						 @"tell application \"Finder\"\n"
						 "set image_file to POSIX file \"%@\"\n"
						 "set desktop picture to image_file\n"
						 "end tell", 
						 self.imagePath];
	
	NSDictionary * anError = nil;
	NSAppleScript * aps = [[NSAppleScript alloc] initWithSource: script];
	[aps executeAndReturnError: &anError];
	[aps release];
	
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName: @"com.apple.desktop" object: @"BackgroundChanged"];
}

@end
