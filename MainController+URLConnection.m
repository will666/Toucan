//
//  MainController+URLConnection.m
//  Toucan
//
//  Created by will on 23/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import "MainController+URLConnection.h"


@implementation MainController(URLConnection)

# pragma mark -
# pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
    
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    [receivedData setLength: 0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    [receivedData appendData: data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	connectionIsRunning = NO;
	
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
    
    // inform the user
    DLog(@"Connection failed! Error - %@ %@",
		 [error localizedDescription],
		 [[error userInfo] objectForKey: NSErrorFailingURLStringKey]);
	
	if(growlIsNotifying == YES)
		[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"%@ - Attention !", 
												  [[NSFileManager defaultManager] displayNameAtPath: [[NSBundle mainBundle] bundlePath]]
												  ]
									description: NSLocalizedString(@"GROWL_CONNEXION_FAILED_DESCRIPTION_NOTIFICATION",@"Connexion avec le serveur distant impossible !")
							   notificationName: @"Connexion Failed"
									   iconData: [NSImage imageNamed: @"NSStopProgressFreestandingTemplate"]
									   priority: 1
									   isSticky: NO
								   clickContext: nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	connectionIsRunning = NO;
	
    DLog(@"Succeeded! Received %d bytes of data", [receivedData length]);
    
    if(connection == searchConnection)
    {
        // convert data to a string
        NSString * result = [[NSString alloc] initWithData: receivedData 
                                                  encoding: NSUTF8StringEncoding];
		
        if([result length] == 0)
        {
            DLog(@">>> No UTF8, trying ASCII");
            [result release];
            result = [[NSString alloc] initWithData: receivedData 
                                           encoding: NSASCIIStringEncoding];
        }
		
		if([result length] == 0)
		{
			DLog(@">>> No ASCII, trying ISOLatin1");
            [result release];
            result = [[NSString alloc] initWithData: receivedData 
                                           encoding: NSISOLatin1StringEncoding];
		}
//		DLog(@"%@", result);
        [self regexStuff: result];
    }
	
    // release the connection, and the data object
    [receivedData release];
    [connection release];

	if([theNum intValue] > [self.imageObjects count])
	{
		currentStartPosition += 20;
		[self startSearchWithTerm: self.currentSearchTerm atStartPosition: currentStartPosition];
	}
	else
	{
		if([self.imageObjects count] > 0) [imageSlider setEnabled: YES], [detailsInfoButton setEnabled: YES], [navLeftButton setEnabled: YES], [navRightButton setEnabled: YES];
		else [imageSlider setEnabled: NO], [detailsInfoButton setEnabled: NO], [navLeftButton setEnabled: NO], [navRightButton setEnabled: NO];
		
		[progressIndicator stopAnimation: self];
		[progressIndicator setHidden: YES];
	}
}

@end
