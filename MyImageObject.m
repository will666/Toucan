//
//  MyImageObject.m
//  Toucan
//
//  Created by William VALENTIN on 09/10/09.
//  Copyright 2009 ExoApps. All rights reserved.
//

#import "MyImageObject.h"


@implementation MyImageObject

@synthesize imageUrl;
@synthesize thumbnailUrl;
@synthesize imageSize;
@synthesize thumbnailSize;
@synthesize imageSizeText;
@synthesize imageRefUrl;

#pragma mark -

- (void)dealloc
{
	self.imageUrl = nil;
	self.thumbnailUrl = nil;
	self.imageSizeText = nil;
	self.imageRefUrl = nil;
	[super dealloc];
}

# pragma mark -

-(NSString *)imageRepresentationType
{
    return IKImageBrowserNSURLRepresentationType;
}

-(id)imageRepresentation
{
    return [NSURL URLWithString: thumbnailUrl];
}

-(NSString *)imageUID
{
    return thumbnailUrl;
}

-(NSString *)imageTitle
{
    return [[imageUrl lastPathComponent] stringByDeletingPathExtension];
}

-(NSString *)imageSubtitle
{
    return [NSString stringWithFormat: @"%@", imageSizeText];
}

@end
