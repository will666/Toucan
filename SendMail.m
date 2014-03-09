//
//  SendMail.m
//  Toucan
//
//  Created by will on 17/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import "SendMail.h"

@implementation SendMail

@synthesize filesPaths;

- (void)dealloc
{
	self.filesPaths = nil;
	[super dealloc];
}

- (void)sendTheMail
{
	NSDictionary * error = nil;
	NSMutableString * theScript = [NSMutableString string];
	NSMutableString * filesName = [NSMutableString string];
	
	for(NSString * item in self.filesPaths) [filesName appendFormat: [NSString stringWithFormat: @"%@, ", [item lastPathComponent]]];
	
	[theScript appendFormat: 
							@"tell application \"Mail\"\n"
							"set theMessage to make new outgoing message with properties {visible:true, subject:\"%@\", content:(ASCII character 10) & (ASCII character 10) & (ASCII character 10) & \"%@\" & (ASCII character 10) & (ASCII character 10)}\n"
							"tell content of theMessage\n",
	 [NSString stringWithFormat: NSLocalizedString(@"SEND_MAIL_SUBJECT",@"Images : %@"), filesName],
	 NSLocalizedString(@"SEND_MAIL_BODY",@"Envoyé depuis Toucan : http://www.wills-portal.com")
	 ];
	
	for(NSString * item in self.filesPaths)
	{
		[theScript appendFormat: [NSString stringWithFormat: @"make new attachment with properties {file name:\"%@\"} at after last paragraph\n", item]];
	}
	[theScript appendString:
							@"end tell\n"
							"theMessage activate\n"
							"end tell"
	];
	
	NSAppleScript * script = [[NSAppleScript alloc] initWithSource: theScript];
	[script executeAndReturnError: &error];
	
	DLog(@"%@", theScript);
	[script release];
	script = nil;
}

@end
