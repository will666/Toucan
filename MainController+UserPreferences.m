//
//  MainController+UserPreferences.m
//  Toucan
//
//  Created by will on 23/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import "MainController+UserPreferences.h"


@implementation MainController(UserPreferences)

- (void)setupDefaults
{
    NSString * userDefaultsValuesPath;
    NSDictionary * userDefaultsValuesDict;
    NSDictionary * initialValuesDict;
    NSArray * resettableUserDefaultsKeys;
	
    // load the default values for the user defaults
    userDefaultsValuesPath = [[NSBundle mainBundle] pathForResource: @"UserDefaults" ofType: @"plist"];
    userDefaultsValuesDict = [NSDictionary dictionaryWithContentsOfFile: userDefaultsValuesPath];
	
    // set them in the standard user defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults: userDefaultsValuesDict];
	
    // if your application supports resetting a subset of the defaults to
    // factory values, you should set those values
    // in the shared user defaults controller
	NSString * defaultOutputPath = [[NSString stringWithFormat: @"%@", NSHomeDirectory()] stringByAppendingPathComponent: @"Downloads"];
    resettableUserDefaultsKeys = [NSArray arrayWithObjects: @"US", 0, 0, 0, defaultOutputPath, 0, 0, 0, nil];
	//	resettableUserDefaultsKeys = [NSArray arrayWithObjects: @"PreferedSearchServer", @"ReloadSearchOnArgsChange", @"SaveSearchArgs", @"SaveOutputFolder", @"OutputFolder", @"SUAutomaticallyUpdate", @"SUEnableAutomaticChecks", @"EnableGrowlNotifications", nil];
    initialValuesDict = [userDefaultsValuesDict dictionaryWithValuesForKeys: resettableUserDefaultsKeys];
	
    // Set the initial values in the shared user defaults controller
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues: initialValuesDict];
	
	[[NSUserDefaultsController sharedUserDefaultsController] setAppliesImmediately: YES];

 
//	NSString * defaultOutputPath = [[NSString stringWithFormat: @"%@", NSHomeDirectory()] stringByAppendingPathComponent: @"Downloads"];
//	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
//															 @"US", @"PreferedSearchServer",
//															 @"NO", @"ReloadSearchOnArgsChange",
//															 @"NO", @"SaveSearchArgs",
//															 @"NO",	@"SaveOutputFolder",
//															 defaultOutputPath, @"OutputFolder",
//															 @"NO", @"SUAutomaticallyUpdate",
//															 @"NO", @"SUEnableAutomaticChecks",
//															 @"NO", @"EnableGrowlNotifications",
//															 nil]];
	
}

# pragma mark -
# pragma mark Common Utility

- (void)readPrefs
{
	id sharedValues = [[NSUserDefaultsController sharedUserDefaultsController] values];
	
	if([[sharedValues valueForKey: @"PreferedSearchServer"] isEqualToString: @""]) [server selectItemWithTitle: @"US"];
	else [server selectItemWithTitle: [sharedValues valueForKey: @"PreferedSearchServer"]];
	
	int SaveOutputFolder = [[sharedValues valueForKey: @"SaveOutputFolder"] intValue];
	
	if(SaveOutputFolder == 0) [dest setStringValue: [NSHomeDirectory() stringByAppendingPathComponent: @"Downloads"]];
	
	NSFileManager * manager = [NSFileManager defaultManager];
	BOOL outputFolderExists;
	if([manager fileExistsAtPath: [sharedValues valueForKey: @"OutputFolder"]]) outputFolderExists = YES;
	else outputFolderExists = NO;
	
	if((SaveOutputFolder == 1) && (outputFolderExists == YES)) [dest setStringValue: [sharedValues valueForKey: @"OutputFolder"]];
	else [dest setStringValue: [NSHomeDirectory() stringByAppendingPathComponent: @"Downloads"]], [sharedValues setValue: [dest stringValue] forKey: @"OutputFolder"];
	
	int EnableGrowlNotifications = [[sharedValues valueForKey: @"EnableGrowlNotifications"] intValue];
	
	if(EnableGrowlNotifications == 1) growlIsNotifying = YES;
	else growlIsNotifying = NO;
}

@end
