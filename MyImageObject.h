//
//  MyImageObject.h
//  Toucan
//
//  Created by William VALENTIN on 09/10/09.
//  Copyright 2009 ExoApps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>


# pragma mark IKImageBrowserItem protocol objects

@interface MyImageObject : NSObject
{
    NSString * imageUrl;
    NSString * thumbnailUrl;
    NSSize imageSize;
    NSSize thumbnailSize;
	NSString * imageSizeText;
	NSString * imageRefUrl;
}

@property (retain) NSString * imageUrl;
@property (retain) NSString * thumbnailUrl;
@property NSSize imageSize;
@property NSSize thumbnailSize;
@property (retain) NSString * imageSizeText;
@property (retain) NSString * imageRefUrl;

@end
