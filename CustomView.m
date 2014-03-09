//
//  CustomView.m
//  Toucan
//
//  Created by will on 12/04/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import "CustomView.h"


@implementation CustomView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame: frame];
	
    if(self)
	{
		//[self setPostsBoundsChangedNotifications: YES];
    }
	
    return self;
}

- (void)awakeFromNib
{
	img = [NSImage imageNamed: @"bg.tif"];
	[self setNeedsDisplay: YES];
}
			   
- (void)drawRect:(NSRect)rect
{
//	NSSize isize = [img size];
//	[img drawInRect: [self bounds] fromRect: NSMakeRect(0.0, 0.0, isize.width, isize.height) operation: NSCompositeCopy fraction: 1.0];
	
	[img setFlipped: YES];
	
	[img drawInRect: /*rect*/ [self bounds]
			 fromRect: NSZeroRect
			operation: NSCompositeSourceOver
			 fraction: 1.0];
	
	CGFloat cornerRadius = 5.0;
	
	NSBezierPath * path = [NSBezierPath bezierPathWithRoundedRect: /*rect*/ [self bounds] xRadius: cornerRadius yRadius: cornerRadius];
	[path addClip];
	[path setLineWidth: 3];
	[[NSColor darkGrayColor] set];
	[path stroke];
}

@end
