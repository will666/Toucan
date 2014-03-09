//
//  SaveImagesPart.h
//  Toucan
//
//  Created by will on 23/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainController.h"
#import "MyImageObject.h"
#import "MainController+TableView.h"
#import "MainController+URLDownload.h"
#import "MainController+Utilities.h"

@interface MainController(SaveImages)

- (IBAction)saveImage:(id)sender;
- (IBAction)saveImageAs:(id)sender;
- (IBAction)saveButtonsActions:(id)sender;
- (IBAction)saveData:(id)sender;
- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end
