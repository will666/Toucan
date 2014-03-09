//
//  SaveImagesPart.m
//  Toucan
//
//  Created by will on 23/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import "MainController+SaveImages.h"


@implementation MainController(SaveImages)

# pragma mark -
# pragma mark Save Images/Data Stuff

- (IBAction)saveImage:(id)sender
{
	if([createSearchFolder state] == 1)
	{
		NSFileManager * manager = [NSFileManager defaultManager];
		if(![manager fileExistsAtPath: [dest stringValue]]) [manager createDirectoryAtPath: [dest stringValue] attributes: nil];
	}
	
	if([imageView image] != NULL)
    {
		NSUInteger index = [[imageBrowser selectionIndexes] firstIndex];
		
		if(index != NSNotFound)
		{
			MyImageObject * obj = [self.imageObjects objectAtIndex: index];
			
			imageSaveOptions = [[IKSaveOptions alloc] initWithImageProperties: imageProperties imageUTType: imageUTType];
			
			NSString * path = [[dest stringValue] stringByAppendingPathComponent: [obj.imageUrl lastPathComponent]];
			NSString * newUTType = [imageSaveOptions imageUTType];
			CGImageRef image;
			
			image = [imageView image];
			
			if(image)
			{
				NSURL * anUrl = [NSURL fileURLWithPath: path];
				CGImageDestinationRef destImage = CGImageDestinationCreateWithURL((CFURLRef)anUrl, (CFStringRef)newUTType, 1, NULL);
				
				if (destImage)
				{
					CGImageDestinationAddImage(destImage, image, (CFDictionaryRef)[imageSaveOptions imageProperties]);
					CGImageDestinationFinalize(destImage);
					CFRelease(destImage);
				}
			}
			[imageSaveOptions release];
			
			
			//------------------------------------------------------------------------------------------------------------------------------------------------------
			
			
			//					imageSaveOptions = [[IKSaveOptions alloc] initWithImageProperties: imageProperties imageUTType: imageUTType];
			//		
			//					NSString * path = [[dest stringValue] stringByAppendingPathComponent: [imageLoadedUrl lastPathComponent]];
			//					NSString * newUTType = [imageSaveOptions imageUTType];
			//					CGImageRef image;
			//				
			//					image = [imageView image];
			//				
			//					if(image)
			//					{
			//						NSURL * anUrl = [NSURL fileURLWithPath: path];
			//						CGImageDestinationRef destImage = CGImageDestinationCreateWithURL((CFURLRef)anUrl, (CFStringRef)newUTType, 1, NULL);
			//					
			//						if (destImage)
			//						{
			//							CGImageDestinationAddImage(destImage, image, (CFDictionaryRef)[imageSaveOptions imageProperties]);
			//							CGImageDestinationFinalize(destImage);
			//							CFRelease(destImage);
			//						}
			//					}
			//					[imageSaveOptions release];
			
			
			//------------------------------------------------------------------------------------------------------------------------------------------------------
			
			
			if(growlIsNotifying == YES)
				[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"%@ - Info", 
														  [[NSFileManager defaultManager] displayNameAtPath: [[NSBundle mainBundle] bundlePath]]]
											description: [NSString stringWithFormat: NSLocalizedString(@"GROWL_DOWNLOAD_SUCCESSFULL_DESCRIPTION_NOTIFICATION",@"Sauvegarde effectuée avec succès => %@"), path]
									   notificationName: @"Download OK"
											   iconData: nil
											   priority: 0
											   isSticky: NO
										   clickContext: nil];
			[self tableViewStuff];
		}
	}
	else
	{
		if(growlIsNotifying == YES)
			[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"%@ - Info", 
													  [[NSFileManager defaultManager] displayNameAtPath: [[NSBundle mainBundle] bundlePath]]]
										description: NSLocalizedString(@"GROWL_DOWNLOAD_ERROR_DESCRIPTION_NOTIFICATION",@"Un problème est survenue lors de l'enregistrement de l'image !")
								   notificationName: @"Download OK"
										   iconData: nil
										   priority: 0
										   isSticky: NO
									   clickContext: nil];
	}
}

- (IBAction)saveImageAs:(id)sender
{
	if([createSearchFolder state] == 1)
	{
		NSFileManager * manager = [NSFileManager defaultManager];
		if(![manager fileExistsAtPath: [dest stringValue]]) [manager createDirectoryAtPath: [dest stringValue] attributes: nil];
	}
	
	NSSavePanel * savePanel = [NSSavePanel savePanel];
    imageSaveOptions = [[IKSaveOptions alloc] initWithImageProperties: imageProperties imageUTType: imageUTType];
    [imageSaveOptions addSaveOptionsAccessoryViewToSavePanel: savePanel];
	
    //NSString * fileName = [[win representedFilename] lastPathComponent];
	NSString * fileName = [[[infosUrl title] lastPathComponent] stringByDeletingPathExtension];
    [savePanel beginSheetForDirectory: NULL 
								 file: fileName 
					   modalForWindow: win 
						modalDelegate: self 
					   didEndSelector: @selector(savePanelDidEnd:returnCode:contextInfo:)
						  contextInfo: NULL
	 ];
}

- (IBAction)saveData:(id)sender
{	
	if([createSearchFolder state] == 1)
	{
		NSFileManager * manager = [NSFileManager defaultManager];
		if(![manager fileExistsAtPath: [dest stringValue]]) [manager createDirectoryAtPath: [dest stringValue] attributes: nil];
	}
	
	NSIndexSet * indexes = [imageBrowser selectionIndexes];
	
	if(![self.itemsToDownload count] > 0) self.itemsToDownload = [NSMutableArray array], self.itemsToDownloadOutput = [NSMutableArray array];
	
	for(NSUInteger index = [indexes lastIndex]; index != NSNotFound; index = [indexes indexLessThanIndex: index])
	{
		MyImageObject * obj = [self.imageObjects objectAtIndex: index];
		NSURL * imageUrl = [NSURL URLWithString: obj.imageUrl];
		self.url = [NSString stringWithFormat: @"%@", imageUrl];
		[self.itemsToDownload addObject: self.url];
		[self.itemsToDownloadOutput addObject: [dest stringValue]];
		
		DLog(@"%@", self.itemsToDownload);
	}
	
	//	if(downloadIsRunning == YES) [theDownload cancel], downloadIsRunning = NO;
	
	
	if(downloadIsRunning == NO)
	{
		[pb setMinValue: 0];
		[pb2 setDoubleValue: 0];
		[splitViewDownload toggleCollapse: nil];
	}
	else
	{
		// Add more images to imageItems then to the download queue
		if(growlIsNotifying == YES)
			[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"%@ Info", 
													  [[NSFileManager defaultManager] displayNameAtPath: [[NSBundle mainBundle] bundlePath]]
													  ]
										description: [NSString stringWithFormat: 
													  NSLocalizedString(@"GROWL_ADD_DOWNLOADS_NOTIFICATION",@"%i images ajoutées à la liste des téléchargements"), 
													  [[imageBrowser selectionIndexes] count]
													  ]
								   notificationName: @"Path has changed"
										   iconData: nil
										   priority: 1
										   isSticky: NO
									   clickContext: nil];
		[pb setMaxValue: [self.itemsToDownload count]];
		[self updateDockWithTitle: [NSString stringWithFormat: @"%i/%i", iii, [self.itemsToDownload count]] withIconName: @"Icon.icns"];
		return;
	}
	
	if([itemsToDownload count] > 1)
	{
		iii = 0;
		unfetchedItems = 0;
		[self updateDockWithTitle: [NSString stringWithFormat: @"%i/%i", iii, [self.itemsToDownload count]] withIconName: @"Icon.icns"];
		[self startDownloading: [self.itemsToDownload objectAtIndex: 0]];
	}
	else
	{
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		[self startDownloading: self.url];
//		[self performSelectorInBackground: @selector(startDownloading:) withObject: self.url];
		[pool release];
	}
}

- (IBAction)saveButtonsActions:(id)sender
{
	//	if([createSearchFolder state] == 1)
	//	{
	//		NSFileManager * manager = [NSFileManager defaultManager];
	//		[manager createDirectoryAtPath: [dest stringValue] attributes: nil];
	//	}
	//	
	//	switch([sender selectedSegment])
	//	{
	//		case 0:
	//			[self saveData];
	//			break;
	//		case 1:
	//			[self saveImageAs];
	//			break;
	//		case 2:
	//			[self saveImage];
	//			break;
	//		default:
	//			return;
	//			break;
	//	}
}

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if(returnCode == NSOKButton)
    {
        NSString * path = [sheet filename];
        NSString * newUTType = [imageSaveOptions imageUTType];
        CGImageRef image;
		
        image = [imageView image];
		
        if(image)
        {
            NSURL * anUrl = [NSURL fileURLWithPath: path];
            CGImageDestinationRef destImage = CGImageDestinationCreateWithURL((CFURLRef)anUrl, (CFStringRef)newUTType, 1, NULL);
			
            if(destImage)
            {
                CGImageDestinationAddImage(destImage, image, (CFDictionaryRef)[imageSaveOptions imageProperties]);
                CGImageDestinationFinalize(destImage);
                CFRelease(destImage);
				
				if(growlIsNotifying == YES)
					[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"%@ - Info", 
															  [[NSFileManager defaultManager] displayNameAtPath: [[NSBundle mainBundle] bundlePath]]
															  ]
												description: [NSString stringWithFormat: NSLocalizedString(@"GROWL_DOWNLOAD_SUCCESSFULL_DESCRIPTION_NOTIFICATION",@"Sauvegarde effectuée avec succès => %@"), 
															  path
															  ]
										   notificationName: @"Download OK"
												   iconData: nil
												   priority: 0
												   isSticky: NO
											   clickContext: nil];
            }
			[self tableViewStuff];
        } 
		else
        {
            DLog(@"*** saveImageToPath - no image");
        }
    }
	[imageSaveOptions release];
}

@end
