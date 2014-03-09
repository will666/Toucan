//
//  DownloadPart.m
//  Toucan
//
//  Created by will on 23/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import "MainController+URLDownload.h"


@implementation MainController(URLDownload)

# pragma mark -
# pragma mark NSURLDownload delegate methods

- (IBAction)stopDownloading:(id)sender
{
//	if(downloadIsRunning == NO) return;
	
	[theDownload cancel], downloadIsRunning = NO;
	
//	[createSearchFolder setEnabled: YES];
//	[changePath setEnabled: YES];
	
	[self updateDockWithTitle: @"" withIconName: nil];
	[itemsToDownload removeAllObjects];
	[pb setDoubleValue: 0];
	[pb2 setDoubleValue: 0];
	[cancelDownloadButton setEnabled: NO];
	iii = 0;
	[percents setStringValue: @""];
	if([splitViewDownload isSubviewCollapsed: downloadView] == NO) [splitViewDownload toggleCollapse: nil];
	[NSApp setApplicationIconImage: nil];
}

- (void)startDownloading:(NSString *)theUrl
{
//	[createSearchFolder setEnabled: NO];
//	[changePath setEnabled: NO];
	
	theRequest2 = [NSURLRequest requestWithURL: [NSURL URLWithString: [theUrl stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding]] 
								   cachePolicy: NSURLRequestUseProtocolCachePolicy 
							   timeoutInterval: 30.0
				   ];
	theDownload = [[NSURLDownload alloc] initWithRequest: theRequest2 delegate: self];
	[theDownload setDeletesFileUponFailure: YES];
	
	//	downloadIsRunning = YES;
	
	if (!theDownload)
	{
		if([self.itemsToDownload count] > 1) iii++, [self startDownloading: [self.itemsToDownload objectAtIndex: iii]];
		else
		{
			//			NSRunAlertPanel(@"Attention !", @"L'image n'a pu être sauvegardée !", @"OK", NULL, NULL);
			if(growlIsNotifying == YES)
				[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"%@ - Attention !", 
														  [[NSFileManager defaultManager] displayNameAtPath: [[NSBundle mainBundle] bundlePath]]
														  ]
											description: NSLocalizedString(@"GROWL_DOWNLOAD_ERROR_DESCRIPTION_NOTIFICATION",@"Un problème est survenue lors de l'enregistrement de l'image !")
									   notificationName: @"Download Fails"
											   iconData: [NSImage imageNamed: @"NSStopProgressFreestandingTemplate"]
											   priority: 1
											   isSticky: NO
										   clickContext: nil];
			downloadIsRunning = NO;
		}
	}
	else
	{
		downloadIsRunning = YES;
		DLog(@"Download Request allocated...");
	}
}

- (void)downloadDidBegin:(NSURLDownload *)download
{
	downloadIsRunning = YES;
	if([itemsToDownload count] > 1)
	{
		[pb setMaxValue: [self.itemsToDownload count]];
		
		if(iii == 0) [pb setDoubleValue: 0];
	}
	else
	{
		[pb setDoubleValue: 0];
		[pb2 setDoubleValue: 0];
	}
	
	iii++;
	[progressIndicator startAnimation: self];
	[saveButton setEnabled: NO forSegment: 0];
	[saveButton setEnabled: NO forSegment: 1];
	[saveButton setEnabled: NO forSegment: 2];
	[cancelDownloadButton setEnabled: YES];
	
	DLog(@"Download begin...");
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
//	downloadIsRunning = NO;
	if(([self.itemsToDownload count] > 1) && (iii != [self.itemsToDownload count])) iii++, unfetchedItems++, [self startDownloading: [[self.itemsToDownload objectAtIndex: iii] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
	
	[download release];
	
	if([self.itemsToDownload count] <= 1)
	{
		if(growlIsNotifying == YES)
			[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"%@ - Attention !", 
													  [[NSFileManager defaultManager] displayNameAtPath: [[NSBundle mainBundle] bundlePath]]
													  ]
										description: NSLocalizedString(@"GROWL_DOWNLOAD_ERROR_DESCRIPTION_NOTIFICATION",@"Un problème est survenue lors de l'enregistrement de l'image !")
								   notificationName: @"Download Fails"
										   iconData: [NSImage imageNamed: @"NSStopProgressFreestandingTemplate"]
										   priority: 1
										   isSticky: NO
									   clickContext: nil];
		
		[saveButton setEnabled: NO forSegment: 0];
		[saveButton setEnabled: NO forSegment: 1];
		[saveButton setEnabled: NO forSegment: 2];
		[createSearchFolder setEnabled: YES];
		[changePath setEnabled: YES];
		[percents setStringValue: @""];
		[pb setDoubleValue: 0];
		[pb2 setDoubleValue: 0];
		[cancelDownloadButton setEnabled: NO];
		if([splitViewDownload isSubviewCollapsed: downloadView] == NO) [splitViewDownload toggleCollapse: nil];
	}
	else
	{
		DLog(@"Download failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey: NSErrorFailingURLStringKey]);
	}
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
	[download release];
	
	[pb setDoubleValue:([pb doubleValue]+1)];
	
	if(([self.itemsToDownload count] > 1) && (iii != [self.itemsToDownload count]))
	{
		downloadIsRunning = NO;
		[self startDownloading: [self.itemsToDownload objectAtIndex: iii]];
		downloadIsRunning = YES;
		[self updateDockWithTitle: [NSString stringWithFormat: @"%i/%i", iii, [self.itemsToDownload count]] withIconName: @"Icon.icns"];
	}
	else
	{
		downloadIsRunning = NO;
		[self updateDockWithTitle: [NSString stringWithFormat: @"%i/%i", iii, [self.itemsToDownload count]] withIconName: @"Icon.icns"];
		
		if([self.itemsToDownload count] > 1)
		{			
			NSMutableString * fNames = [NSMutableString string];
			
			for(NSString * fName in self.itemsToDownload) [fNames appendFormat: [NSString stringWithFormat: @"%@\n", [[fName stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding] lastPathComponent]]];
			
			if(growlIsNotifying == YES)
				[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"%@ - Info", 
														  [[NSFileManager defaultManager] displayNameAtPath: [[NSBundle mainBundle] bundlePath]]
														  ]
											description: [NSString stringWithFormat: NSLocalizedString(@"GROWL_DOWNLOAD_SUCCESSFULL_DESCRIPTION_NOTIFICATION",@"Sauvegarde effectuée avec succès => %@"), 
														  fNames
														  ]
									   notificationName: @"Download OK"
											   iconData: nil
											   priority: 0
											   isSticky: NO
										   clickContext: nil];
			
			[self.itemsToDownload removeAllObjects];
			
			//--- RESTOR Dock Icon -----
//			[self updateDockWithTitle: nil withIconName: nil];
			[NSApp setApplicationIconImage: nil];
			
			[cancelDownloadButton setEnabled: NO];
			[[NSSound soundNamed: @"Blow"] play];
			[createSearchFolder setEnabled: YES];
			[changePath setEnabled: YES];
			if([splitViewDownload isSubviewCollapsed: downloadView] == NO) [splitViewDownload toggleCollapse: nil];
			
			//Bounce the Dock if iMage is not the current active application
			[[NSApplication sharedApplication] requestUserAttention: NSInformationalRequest];
		}
		else
		{
			if(growlIsNotifying == YES)
				[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"%@ - Info", 
														  [[NSFileManager defaultManager] displayNameAtPath: [[NSBundle mainBundle] bundlePath]]
														  ]
											description: [NSString stringWithFormat: NSLocalizedString(@"GROWL_DOWNLOAD_SUCCESSFULL_DESCRIPTION_NOTIFICATION",@"Sauvegarde effectuée avec succès => %@"), 
														  destinationFilename
														  ]
									   notificationName: @"Download OK"
											   iconData: nil
											   priority: 0
											   isSticky: NO
										   clickContext: nil];
			
			//Bounce the Dock if iMage is not the current active application
			[[NSApplication sharedApplication] requestUserAttention: NSInformationalRequest];
		}
		
		[self.itemsToDownload removeAllObjects];
		
		[saveButton setEnabled: YES forSegment: 0];
		[saveButton setEnabled: YES forSegment: 1];
		[saveButton setEnabled: YES forSegment: 2];
//		[saveButton setEnabled: YES];
		
		[createSearchFolder setEnabled: YES];
		[changePath setEnabled: YES];
		
		[progressIndicator stopAnimation: self];
		[percents setStringValue: @""];
		
		if([splitViewDownload isSubviewCollapsed: downloadView] == NO) [splitViewDownload toggleCollapse: nil];
		
		[cancelDownloadButton setEnabled: NO];
		
		if(unfetchedItems != 0)
		{
			if(growlIsNotifying == YES)
				[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"%@ - Attention !", 
														  [[NSFileManager defaultManager] displayNameAtPath: [[NSBundle mainBundle] bundlePath]]
														  ]
											description: [NSString stringWithFormat: 
														  NSLocalizedString(@"GROWL_DOWNLOAD_ERROR_SOME_ITEMS_UNFETCHABLE_DESCRIPTION_NOTIFICATION",
																			@"%i image(s) non téléchargée(s). Introuvable(s) sur le serveur distant !"),
														  unfetchedItems] 
									   notificationName: @"Download Fails"
											   iconData: [NSImage imageNamed: @"NSStopProgressFreestandingTemplate"]
											   priority: 1
											   isSticky: YES
										   clickContext: nil];
		}
	}
	
	[self tableViewStuff];
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{
//	[destinationFilename release];
//	destinationFilename = [[dest stringValue] stringByAppendingPathComponent: [[imgInfosUrl stringValue] lastPathComponent]];
	self.destinationFilename = [[self.itemsToDownloadOutput objectAtIndex: (iii-1)] stringByAppendingPathComponent: filename];
	[download setDestination: self.destinationFilename allowOverwrite: NO];
//	[destinationFilename retain];
}

- (void)download:(NSURLDownload *)download didCreateDestination:(NSString *)path
{
    DLog(@"Final file destination: %@", path);
}

- (void)setDownloadResponse:(NSURLResponse *)aDownloadResponse
{
    [aDownloadResponse retain];
    [downloadResponse release];
    downloadResponse = aDownloadResponse;
	DLog(@"Download Response: %@", aDownloadResponse);
}

- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response
{
    bytesReceived = 0;
    [self setDownloadResponse: response];
	DLog(@"Did Receive Response: %@", response);
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(unsigned)length
{
	long long expectedLength = [downloadResponse expectedContentLength];
    bytesReceived = bytesReceived + length;
	
    if (expectedLength != NSURLResponseUnknownLength) {
		float percentComplete = (bytesReceived/(float)expectedLength)*100.0;
		
		if([self.itemsToDownload count] > 1)
		{
			[pb2 setDoubleValue: percentComplete];
			[percents setStringValue: [NSString stringWithFormat: NSLocalizedString(@"COMPLETED_DOWNLOAD_PERCENTS",@"%i%% de \"%@\" effectués"), 
									   (int)percentComplete, 
									   [self.destinationFilename lastPathComponent]]
			 ];
		}
		else
		{
			[pb setDoubleValue: percentComplete];
			[pb2 setDoubleValue: percentComplete];
			[percents setStringValue: [NSString stringWithFormat: NSLocalizedString(@"COMPLETED_DOWNLOAD_PERCENTS",@"%i%% de \"%@\" effectués"), 
									   (int)percentComplete, 
									   [[infosUrl title] lastPathComponent]]
			 ];
		}
		
		DLog(@"Percent complete - %f", percentComplete);
    }
	else DLog(@"Bytes received - %d",bytesReceived);
}

@end
