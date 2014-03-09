//
//  SlideShowObject.m
//  iMages
//
//  Created by will on 15/10/09.
//  Copyright 2009 ExoApps. All rights reserved.
//

#import "SlideShowObject.h"


@implementation SlideShowObject

@synthesize mSlideshow;
@synthesize mImagePaths;


- (void)dealloc
{
	[super dealloc];
}

-(NSUInteger)numberOfSlideshowItems
{
    return [self.mImagePaths count];
	DLog(@"Number of items : %i", [self.mImagePaths count]);
}


-(id)slideshowItemAtIndex:(NSUInteger)index
{
	int i;
	i = index % [self.mImagePaths count];
    return [self.mImagePaths objectAtIndex: i];
	
	DLog(@"slideshowItemAtIndex : %@", [self.mImagePaths objectAtIndex: i]);
}

-(void)run
{
    if ([self.mImagePaths count] > 0)
	{
        [self.mSlideshow  runSlideshowWithDataSource: (id<IKSlideshowDataSource>)self
										 inMode: IKSlideshowModeImages
										options: NULL];
		//		[mSlideshow reloadData];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// to overwrite the name of an image in index-mode, implement nameOfSlideshowItemAtIndex...
- (NSString *)nameOfSlideshowItemAtIndex:(NSUInteger)index
{
    return [[[self.mImagePaths objectAtIndex: index] lastPathComponent] stringByDeletingPathExtension];
	DLog(@"nameOfSlideshowItemAtIndex : %@", [[[self.mImagePaths objectAtIndex: index] lastPathComponent] stringByDeletingPathExtension]);
}

-(void)slideshowDidStop
{
	self.mSlideshow = nil;
	self.mImagePaths = nil;
}

@end
