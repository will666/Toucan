//
//  MainController+ImageBrowser.h
//  Toucan
//
//  Created by will on 23/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainController.h"
#import "MyImageObject.h"


@interface MainController(ImageBrowser)

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)view;
- (id)imageBrowser:(IKImageBrowserView *)view itemAtIndex:(NSUInteger)index;
- (void)imageBrowserSelectionDidChange:(IKImageBrowserView *)aBrowser;
- (IBAction)zoomSliderDidChange:(id)sender;

@end
