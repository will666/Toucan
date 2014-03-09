//
//  MainController+Utilities.m
//  Toucan
//
//  Created by will on 23/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import "MainController+Utilities.h"

@implementation MainController(Utilities)

# pragma mark -
# pragma mark Growl Notifications

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    BOOL resultKey = NO;
	
    if (commandSelector == @selector(insertNewline:))
	{
		// enter pressed
		resultKey = YES;
		[self start: self];
    }
	else if(commandSelector == @selector(moveLeft:))
	{
		// left arrow pressed
		resultKey = NO;
	}
	else if(commandSelector == @selector(moveRight:))
	{
		// rigth arrow pressed
		resultKey = NO;
	}
	else if(commandSelector == @selector(moveUp:))
	{
		// up arrow pressed
		resultKey = NO;
	}
	else if(commandSelector == @selector(moveDown:))
	{
		// down arrow pressed
		resultKey = NO;
	}
	else if(commandSelector == @selector(cancelOperation:))
	{
		// esc pressed
		resultKey = NO;
	}
	
    return resultKey;
}

- (NSDictionary *)registrationDictionaryForGrowl
{
    NSArray * notifications;
    notifications = [NSArray arrayWithObjects: 
					 @"Download OK",
					 @"Download Fails",
					 @"Path has changed",
					 @"Connexion Failed",
					 @"Growl Started",
					 @"Growl Stopped",
					 nil];
	
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:
			notifications, GROWL_NOTIFICATIONS_ALL,
			notifications, GROWL_NOTIFICATIONS_DEFAULT,
			nil];
	
    return (dict);
}

- (NSString *)stringFromFileSize:(int)theSize
{
	float floatSize = theSize;
	
	if(theSize < 1023) return [NSString stringWithFormat: @"%i bytes", theSize];
	
	floatSize = floatSize / 1000;
	
	if(floatSize < 1023) return [NSString stringWithFormat: @"%1.1f Ko", floatSize];
	
	floatSize = floatSize / 1000;
	
	if(floatSize < 1023) return [NSString stringWithFormat: @"%1.1f Mo", floatSize];
	
	floatSize = floatSize / 1000;
	
	return [NSString stringWithFormat: @"%1.1f Go", floatSize];
}

- (void)updateDockWithTitle:(NSString *)stats withIconName:(NSString *)icon
{
//	NSDockTile * dockTile = [[NSApplication sharedApplication] dockTile];
//	[dockTile setBadgeLabel: [NSString stringWithFormat: @"%i/%i", iii, max]];
	
	NSDockTile * dockTile = [[NSApplication sharedApplication] dockTile];
	
	//setup our image view for the dock tile
	NSRect frame = NSMakeRect(0, 0, dockTile.size.width, dockTile.size.height);
	
	NSImageView * dockImageView = [[NSImageView alloc] initWithFrame: frame];
	[dockImageView setImage: [NSImage imageNamed: icon]];
	
	//by default, add it to the NSDockTile
	[dockTile setContentView: dockImageView];
	[dockTile display];
	
	//Show Notification Badge '45'
//	[dockTile setShowsApplicationBadge: YES];
	[dockTile setBadgeLabel: stats];
	
	[dockImageView release];
	
	UKDockProgressIndicator * pbdock = [[UKDockProgressIndicator alloc] init];
	[pbdock setMaxValue: [self.itemsToDownload count]];
	[pbdock setMinValue: 0];
	[pbdock setDoubleValue: iii];
//	[pbdock display];
	[pbdock release];
}

- (void)deleteImagesFromArray:(NSMutableArray *)anArray itemsAtIndexes:(NSIndexSet *)indexes fromDisc:(BOOL)choice withFilePath:(NSString *)path
{
	for(NSUInteger index = [indexes lastIndex]; index != NSNotFound; index = [indexes indexLessThanIndex: index])
	{
	
	if(choice == YES)
	{
		NSFileManager * manager = [NSFileManager defaultManager];
		if(![manager movePath: 
			 [path stringByAppendingPathComponent: 
			  [[anArray objectAtIndex: index] valueForKey: @"name"]] 
					   toPath: [[NSHomeDirectory() stringByAppendingPathComponent: @".Trash"] stringByAppendingPathComponent: [[anArray objectAtIndex: index] valueForKey: @"name"]] 
					  handler: self])
			[manager movePath: [path stringByAppendingPathComponent: [[anArray objectAtIndex: index] valueForKey: @"name"]] 
					   toPath: [[NSHomeDirectory() stringByAppendingPathComponent: @".Trash"] 
								stringByAppendingPathComponent: [NSString stringWithFormat: @"%@-%@.%@", [[[anArray objectAtIndex: index] valueForKey: @"name"] stringByDeletingPathExtension], [NSDate date], [[[anArray objectAtIndex: index] valueForKey: @"name"] pathExtension]]] 
					  handler: self];
	}
	
	[anArray removeObjectAtIndex: index];
	}
}

- (void)folderChoiceClosed:(NSOpenPanel *)openPanel returnCode:(NSInteger)code contextInfo:(void *)contextInfo
{
	if (code == NSOKButton)
    {
        NSArray * files = [openPanel filenames];
		for(NSString * fileName in files)
		{
			DLog(@"%@",fileName);
			
			id prefs = [[NSUserDefaultsController sharedUserDefaultsController] values];
			[prefs setValue: fileName forKey: @"OutputFolder"];
			
			id path = [prefs valueForKey: @"OutputFolder"];
			id output = [path stringByAppendingPathComponent: [[searchTermTextField stringValue] capitalizedString]];
			
			if(([createSearchFolder state] == 1) && ([[NSFileManager defaultManager] fileExistsAtPath: output]) && (![fileName isEqualToString: [[searchTermTextField stringValue] capitalizedString]])) [dest setStringValue: output];
			else [dest setStringValue: path];
			
//			if([createSearchFolder state] == 1) [dest setStringValue: output];
//			else [dest setStringValue: path];
			
		}
		
		if(growlIsNotifying == YES)
			[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"%@ Info", 
													  [[NSFileManager defaultManager] displayNameAtPath: [[NSBundle mainBundle] bundlePath]]
													  ]
										description: [NSString stringWithFormat: 
													  NSLocalizedString(@"GROWL_PATH_CHANGED_DESCRIPTION_NOTIFICATION",@"Dossier de destination modifié avec succès => %@"), 
													  [dest stringValue]
													  ]
								   notificationName: @"Path has changed"
										   iconData: nil
										   priority: 1
										   isSticky: NO
									   clickContext: nil];
		
		[self tableViewStuff];
    }
    else
    {
        return;
    }
}

- (IBAction)chooseSaveFolder:(id)sender
{
	NSOpenPanel * oPanel = [NSOpenPanel openPanel];
	[oPanel setCanChooseFiles: NO];
	[oPanel setCanCreateDirectories: YES];
	[oPanel setCanChooseDirectories: YES];
	[oPanel setAllowsMultipleSelection: NO];
	[oPanel setDirectory: [NSHomeDirectory() stringByAppendingPathComponent: @"Desktop"]];
	[oPanel setTitle: NSLocalizedString(@"DESTINATION_FOLDER_DIALOG_TITLE",@"Dossier de destination")];
	
	[oPanel beginSheetForDirectory: nil 
							  file: nil 
							 types: nil 
					modalForWindow: win 
					 modalDelegate: self
					didEndSelector: @selector(folderChoiceClosed:returnCode:contextInfo:) 
					   contextInfo: nil];
}

@end
