//
//  TableViewPart.m
//  Toucan
//
//  Created by will on 23/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import "MainController+TableView.h"


@implementation MainController(TableView)

# pragma mark -
# pragma mark TableView Stuff

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	if([[tabSearch stringValue] length] != 0) return [activeSet count];
	else return [self.imageItems count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if([[tabSearch stringValue] length] != 0)
	{
		if(tableColumn == tabCol) return [[[activeSet objectAtIndex: row] valueForKey: @"name"] stringByDeletingPathExtension];
		else if(tableColumn == tabColFormat) return [[[activeSet objectAtIndex: row] valueForKey: @"format"] lowercaseString];
		else if(tableColumn == tabColImg) return [[activeSet objectAtIndex: row] valueForKey: @"icon"];
		else if(tableColumn == tabColFileSize) return [self stringFromFileSize: [[[activeSet objectAtIndex: row] valueForKey: @"filesize"] intValue]];
		else return [[activeSet objectAtIndex: row] valueForKey: @"date"];
	}
	else
	{
	if(tableColumn == tabCol) return [[[self.imageItems objectAtIndex: row] valueForKey: @"name"] stringByDeletingPathExtension];
	else if(tableColumn == tabColFormat) return [[[self.imageItems objectAtIndex: row] valueForKey: @"format"] lowercaseString];
	else if(tableColumn == tabColImg) return [[self.imageItems objectAtIndex: row] valueForKey: @"icon"];
	else if(tableColumn == tabColFileSize) return [self stringFromFileSize: [[[self.imageItems objectAtIndex: row] valueForKey: @"filesize"] intValue]];
	else return [[self.imageItems objectAtIndex: row] valueForKey: @"date"];
	}
}

- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification
{
	[imageView setImageWithURL: NULL];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSIndexSet * indexes = [tab selectedRowIndexes];
	NSUInteger index = [[tab selectedRowIndexes] firstIndex];
	
	if(index != NSNotFound)
	{
		if([[tabSearch stringValue] length] != 0)
		{
			NSString * path = [[dest stringValue] stringByAppendingPathComponent: [[activeSet objectAtIndex: index] valueForKey: @"name"]];
			NSURL * imageUrl = [NSURL fileURLWithPath: path];
			
			//-------------------------------- Check if selected row's image file exists ----------------------------------------
			NSFileManager * manager = [NSFileManager defaultManager];
			if(![manager fileExistsAtPath: path]) [self deleteImagesFromArray: activeSet itemsAtIndexes: indexes fromDisc: NO withFilePath: [dest stringValue]];
			[[tabColImg headerCell] setStringValue: [NSString stringWithFormat: @"#%i", [activeSet count]]];
			[tab reloadData];
			//-------------------------------------------------------------------------------------------------------------------
			
			NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
			[self performSelectorInBackground: @selector(displayImageWithURL:) withObject: imageUrl];
			[pool release];
			
			//-------------- TBN task ------------
			NSImage * tbnImg = [[NSImage alloc] initWithContentsOfURL: imageUrl];
			
			NSSize imgsize = tbnImg.size;
			int w = imgsize.width;
			int h = imgsize.height;
			
			[infosImage setImage: tbnImg];
			[tbnImg release];
			
			[infosName setStringValue: [NSString stringWithFormat: NSLocalizedString(@"IMG_INFOS_NAME",@"Nom : %@"), [[[[activeSet objectAtIndex: index] valueForKey: @"name"] lastPathComponent] stringByDeletingPathExtension]]];
			[infosSize setStringValue: [NSString stringWithFormat: NSLocalizedString(@"IMG_INFOS_SIZE",@"Dimensions : %@ ppp"), [NSString stringWithFormat: @"%ix%i", w,h]]];
			[infosType setStringValue: [NSString stringWithFormat: NSLocalizedString(@"IMG_INFOS_TYPE",@"Type : %@"), [[[activeSet objectAtIndex: index] valueForKey: @"name"] pathExtension]]];
			[infosSource setTitle: [dest stringValue]];
			[infosSource setUrlString: [NSString stringWithFormat: @"file://localhost%@", [dest stringValue]]];
			[infosUrl setTitle: [NSString stringWithFormat: @"%@", imageUrl]];
			[infosUrl setUrlString: [NSString stringWithFormat: @"%@", imageUrl]];
			
			[saveButton setEnabled: YES forSegment: 1];
			[deleteImageButton setEnabled: YES];
			if([activeSet count] != 0) [slideShowButton setEnabled: YES];
			else [slideShowButton setEnabled: NO];
			[sendMailButton setEnabled: YES];
			[changeDesktopImageButton setEnabled: YES];
			
			return;
		}
		
		NSString * path = [[dest stringValue] stringByAppendingPathComponent: [[self.imageItems objectAtIndex: index] valueForKey: @"name"]];
		NSURL * imageUrl = [NSURL fileURLWithPath: path];
		
		//-------------------------------- Check if selected row's image file exists ----------------------------------------
		NSFileManager * manager = [NSFileManager defaultManager];
		if(![manager fileExistsAtPath: path]) [self deleteImagesFromArray: self.imageItems itemsAtIndexes: indexes fromDisc: NO withFilePath: [dest stringValue]];
		[[tabColImg headerCell] setStringValue: [NSString stringWithFormat: @"#%i", [self.imageItems count]]];
		[tab reloadData];
		//-------------------------------------------------------------------------------------------------------------------
		
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
		[self performSelectorInBackground: @selector(displayImageWithURL:) withObject: imageUrl];
		[pool release];
		
		//-------------- TBN task ------------
		NSImage * tbnImg = [[NSImage alloc] initWithContentsOfURL: imageUrl];
		
		NSSize imgsize = tbnImg.size;
		int w = imgsize.width;
		int h = imgsize.height;
		
		[infosImage setImage: tbnImg];
		[tbnImg release];
		
		[infosName setStringValue: [NSString stringWithFormat: NSLocalizedString(@"IMG_INFOS_NAME",@"Nom : %@"), [[[[self.imageItems objectAtIndex: index] valueForKey: @"name"] lastPathComponent] stringByDeletingPathExtension]]];
		[infosSize setStringValue: [NSString stringWithFormat: NSLocalizedString(@"IMG_INFOS_SIZE",@"Dimensions : %@ ppp"), [NSString stringWithFormat: @"%ix%i", w,h]]];
		[infosType setStringValue: [NSString stringWithFormat: NSLocalizedString(@"IMG_INFOS_TYPE",@"Type : %@"), [[[self.imageItems objectAtIndex: index] valueForKey: @"name"] pathExtension]]];
		[infosSource setTitle: [dest stringValue]];
		[infosSource setUrlString: [NSString stringWithFormat: @"file://localhost%@", [dest stringValue]]];
		[infosUrl setTitle: [NSString stringWithFormat: @"%@", imageUrl]];
		[infosUrl setUrlString: [NSString stringWithFormat: @"%@", imageUrl]];
		
		[saveButton setEnabled: YES forSegment: 1];
		[deleteImageButton setEnabled: YES];
		if([self.imageItems count] != 0) [slideShowButton setEnabled: YES];
		else [slideShowButton setEnabled: NO];
		[sendMailButton setEnabled: YES];
		[changeDesktopImageButton setEnabled: YES];
	}
	else
	{
		[saveButton setEnabled: NO forSegment: 0];
		[saveButton setEnabled: NO forSegment: 1];
		[saveButton setEnabled: NO forSegment: 2];
		[deleteImageButton setEnabled: NO];
		if([self.imageItems count] != 0) [slideShowButton setEnabled: YES];
		else [slideShowButton setEnabled: NO];
		[sendMailButton setEnabled: NO];
		[changeDesktopImageButton setEnabled: NO];
		
		[infosImage setImage: NULL];
		[infosName setStringValue: [NSString stringWithFormat:NSLocalizedString(@"IMG_INFOS_NAME",@"Nom : %@"), @"-"]];
		[infosSize setStringValue: [NSString stringWithFormat:NSLocalizedString(@"IMG_INFOS_SIZE",@"Dimensions : %@ ppp"), @"-"]];
		[infosType setStringValue: [NSString stringWithFormat:NSLocalizedString(@"IMG_INFOS_TYPE",@"Type : %@"), @"-"]];
		[infosSource setTitle: @""];
		[infosSource setUrlString: @""];
		[infosUrl setTitle: @""];
		[infosUrl setUrlString: @""];
	}
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
	if(aTableView == tab)
	{
		return YES;
	}
	else return NO;
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    [self.imageItems sortUsingDescriptors: [tableView sortDescriptors]];
    [tab reloadData];
}

- (void)tableViewStuff
{
	[progressIndicator setHidden: NO];
	[progressIndicator startAnimation: self];
	
	[tab setDelegate: self];
	[tab setAllowsMultipleSelection: YES];
	[tab setAllowsEmptySelection: YES];
//	[tab deselectAll: self];
	
//	[imageView setImageWithURL: NULL];
	
	
	self.imageItems = [NSMutableArray array];
	
	NSArray * files = [[NSFileManager defaultManager] directoryContentsAtPath: [dest stringValue]];
	
	NSArray * exts = [NSArray arrayWithObjects: @"psd", @"png", @"jpg", @"jpeg", @"tif", @"tiff", @"bmp", @"gif", @"icns", @"pdf", nil];
	NSMutableArray * extsCap = [NSMutableArray arrayWithArray: exts];
	
	int i = 0;
	
	for(NSString * someExt in exts) [extsCap addObject: [someExt uppercaseString]], [extsCap addObject: [someExt capitalizedString]];
	
	for(NSString * item in files)
	{
		for(NSString * ext in extsCap)
		{
			if([[item pathExtension] isEqualToString: ext])
			{
				//Image Icon
				NSImage * img = [[NSImage alloc] initWithContentsOfFile: [[dest stringValue] stringByAppendingPathComponent: item]];
				[img setSize: NSMakeSize(20.0,0.0)];
				if(!img) img = [NSImage imageNamed: @"NSStopProgressTemplate"];
				
				//File Size
				NSFileManager * fileManager = [NSFileManager defaultManager];
				NSString * path = [[dest stringValue] stringByAppendingPathComponent: item];
				NSDictionary * fileAttributes = [fileManager fileAttributesAtPath: path traverseLink: YES];
				
				if (fileAttributes != nil)
				{
					NSNumber * fileSize;
					//NSString * fileOwner;
					NSDate * fileModDate;
					if (fileSize = [fileAttributes objectForKey: NSFileSize])
					{
						DLog(@"File size: %qi\n", [fileSize unsignedLongLongValue]);
					}
					//if (fileOwner = [fileAttributes objectForKey: NSFileOwnerAccountName])
					//{
					//	DLog(@"Owner: %@\n", fileOwner);
					//}
					if (fileModDate = [fileAttributes objectForKey: NSFileModificationDate])
					{
						DLog(@"Modification date: %@\n", fileModDate);
					}
					
					NSString * total = [NSString stringWithFormat: @"#%i", i++];
					
					[self.imageItems addObject: 
					 [NSDictionary dictionaryWithObjectsAndKeys: 
					  total, @"num", 
					  img, @"icon", 
					  item, @"name", 
					  fileModDate, @"date", 
					  fileSize, @"filesize", 
					  [item pathExtension], @"format", 
					nil]];
					
					[img release];
				}
				else
				{
					DLog(@"Path (%@) is invalid.", path);
				}
			}
		}
	}

	[[tabColImg headerCell] setStringValue: [NSString stringWithFormat: @"#%i", [self.imageItems count]]];
	[tab reloadData];
	
	if([self.imageItems count] > 0) [slideShowButton setEnabled: YES];
	else [slideShowButton setEnabled: NO];
	
	if([[tab selectedRowIndexes] firstIndex] != NSNotFound)
	{
		[sendMailButton setEnabled: YES];
		[changeDesktopImageButton setEnabled: YES];
	}
	else
	{
		[sendMailButton setEnabled: NO];
		[changeDesktopImageButton setEnabled: NO];
	}
	
	[progressIndicator stopAnimation: self];
	[progressIndicator setHidden: YES];
}

@end
