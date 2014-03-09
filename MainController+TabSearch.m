//
//  MainController+TabSearch.m
//  Toucan
//
//  Created by will on 12/04/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import "MainController+TabSearch.h"
#import "MainController+Utilities.h"


@implementation MainController(TabSearch)

- (void)controlTextDidChange:(NSNotification *)aNotification
{

	NSString * keywords = [tabSearch stringValue];
	NSEnumerator * enumerator = [self.imageItems objectEnumerator];
	NSString * nameString, * formatString, * dateString, * filesizeString;

	id obj = nil;
	
	if ([[tabSearch stringValue] length] == 0)
	{
		activeSet = self.imageItems;
		[tab reloadData];
		return;
	}
		
	if(subset != nil) [subset release];
	subset = [[NSMutableArray alloc] init];
		
		
	while(obj = [enumerator nextObject])
	{
		nameString = [[obj objectForKey: @"name"] lowercaseString];
		formatString = [[obj objectForKey: @"format"] lowercaseString];
		filesizeString = [self stringFromFileSize: [[obj objectForKey: @"filesize"] intValue]];
		
		NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setDateStyle: NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle: NSDateFormatterShortStyle];
		dateString = [dateFormatter stringFromDate: [obj objectForKey: @"date"]];
			
		if ([nameString hasPrefix: keywords] || [formatString hasPrefix: keywords] || [dateString hasPrefix: keywords] || [filesizeString hasPrefix: keywords]) [subset addObject: obj];
			
	}
	activeSet = subset;
	[tab reloadData];
}


@end
