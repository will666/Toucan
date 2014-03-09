//
//  MainController+UserPreferences.h
//  Toucan
//
//  Created by will on 23/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainController.h"


@interface MainController(UserPreferences)

- (void)setupDefaults;
- (void)readPrefs;

@end
