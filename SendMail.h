//
//  SendMail.h
//  Toucan
//
//  Created by will on 17/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SendMail : NSObject {

	NSArray * filesPaths;
}

@property (retain) NSArray * filesPaths;

- (void)sendTheMail;

@end
