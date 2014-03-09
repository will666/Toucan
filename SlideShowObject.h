//
//  SlideShowObject.h
//  iMages
//
//  Created by will on 15/10/09.
//  Copyright 2009 ExoApps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>


@interface SlideShowObject : NSWindowController {
	
	IKSlideshow * mSlideshow;
    NSMutableArray * mImagePaths;
	
}

@property (retain) IKSlideshow * mSlideshow;
@property (readwrite,retain) NSMutableArray * mImagePaths;

-(NSUInteger)numberOfSlideshowItems;
-(id)slideshowItemAtIndex:(NSUInteger)index;
-(NSString *)nameOfSlideshowItemAtIndex:(NSUInteger)index;
-(void)run;

@end
