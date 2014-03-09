//
//  CustomNSCell.m
//  Toucan
//
//  Created by will on 13/04/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import "CustomCell.h"


@implementation CustomCell

- (id)initTextCell:(NSString *)aString
{
	self = [super initTextCell: aString];
	
	return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	
//    if ([[controlView window] isKeyWindow])
//        currentTint = [self controlTint];
//    else
//        currentTint = NSClearControlTint;
	
	
}

- (NSColor *)highlightColorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSControlTint tint = NSGraphiteControlTint;
	return [NSColor colorForControlTint: tint];
}

@end
