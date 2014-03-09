//
//  DesktopImage.h
//  Toucan
//
//  Created by will on 17/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DesktopImage : NSObject {
	
	NSString * imagePath;
}

@property (retain) NSString * imagePath;

- (void)changeDesktopImage;

@end
