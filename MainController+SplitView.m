//
//  MainController+SplitView.m
//  Toucan
//
//  Created by will on 23/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import "MainController+SplitView.h"


@implementation MainController(SplitView)

- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex
{
	return YES;
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
	return YES;
}

- (BOOL)splitView:(BWSplitView *)splitView shouldCollapseSubview:(NSView *)subview
{
	return YES;
}

@end
