//
//  DownloadPart.h
//  Toucan
//
//  Created by will on 23/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainController.h"
#import "MainController+TableView.h"
#import "MainController+Utilities.h"


@interface MainController(URLDownload)

- (IBAction)stopDownloading:(id)sender;
- (void)startDownloading:(NSString *)theUrl;
- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(unsigned)length;
- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response;
- (void)setDownloadResponse:(NSURLResponse *)aDownloadResponse;
- (void)download:(NSURLDownload *)download didCreateDestination:(NSString *)path;
- (void)downloadDidFinish:(NSURLDownload *)download;
- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error;
- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename;

@end
