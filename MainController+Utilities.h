//
//  MainController+Utilities.h
//  Toucan
//
//  Created by will on 23/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainController.h"
#import "UKDockProgressIndicator.h"
#import "MainController+TableView.h"

@interface MainController(Utilities)

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector;
- (NSString *)stringFromFileSize:(int)theSize;
- (void)updateDockWithTitle:(NSString *)stats withIconName:(NSString *)icon;
- (NSDictionary *)registrationDictionaryForGrowl;
- (void)deleteImagesFromArray:(NSMutableArray *)anArray itemsAtIndexes:(NSIndexSet *)indexes fromDisc:(BOOL)choice withFilePath:(NSString *)path;
- (void)folderChoiceClosed:(NSOpenPanel *)openPanel returnCode:(NSInteger)code contextInfo:(void *)contextInfo;
- (IBAction)chooseSaveFolder:(id)sender;

@end
