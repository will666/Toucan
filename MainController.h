//
//  MainController.h
//  Toucan
//
//  Created by William VALENTIN on October 03, 2009.
//	©2009 ExoApps, All Rights Reserved
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
//#import <BWToolkitFramework/BWToolkitFramework.h>
#import <Growl-WithInstaller/Growl.h>
#import "SlideShowObject.h"


@interface MainController : NSObject <GrowlApplicationBridgeDelegate>
{	
	IBOutlet IKImageBrowserView * imageBrowser;
    IBOutlet IKImageView * imageView;
    IBOutlet NSTextField * searchTermTextField;
	IBOutlet NSTextFieldCell * searchTermTextFieldCell;
    IBOutlet NSTextField * positionTextField;
    IBOutlet NSProgressIndicator * progressIndicator;
    
	NSDictionary * imageProperties;
	NSString * imageUTType;
	IKSaveOptions * imageSaveOptions;
	
    NSMutableData * receivedData;
    NSURLConnection * searchConnection;
    
    NSMutableArray * imageObjects;
    NSString * currentSearchTerm;
    NSUInteger currentStartPosition;
	
	IBOutlet NSWindow * win;
	IBOutlet NSPopUpButton * size;
	IBOutlet NSPopUpButton * tint;
	IBOutlet NSPopUpButton * format;
	IBOutlet NSPopUpButton * type;
	IBOutlet NSPopUpButton * copy;
	IBOutlet NSButton * safe;
	
	IBOutlet NSButton * searchButton;
	IBOutlet NSSegmentedControl * sizeButton;
	IBOutlet NSSegmentedControl * saveButton;
	
	IBOutlet NSProgressIndicator * pb;
	IBOutlet NSProgressIndicator * pb2;
	IBOutlet NSButton * splitButton;
	IBOutlet NSTextField * dest;
	IBOutlet NSTextField * copyrights;
	IBOutlet NSTextField * percents;
	
	IBOutlet NSTextField * destFolderLabel;
	
	IBOutlet NSButton * slideShowButton;
	IBOutlet NSButton * sendMailButton;
	IBOutlet NSButton * changeDesktopImageButton;
	
	NSURLRequest * theRequest2;
	NSURLDownload * theDownload;
	NSURLResponse * downloadResponse;
	long bytesReceived;
	NSString * destinationFilename;
	
	IBOutlet BWSplitView * mainSplitView;
	IBOutlet BWSplitView * splitViewDownload;
	
// -- Toolbar Items Outlet --
	IBOutlet NSToolbarItem * tbiSize;
	IBOutlet NSToolbarItem * tbiTint;
	IBOutlet NSToolbarItem * tbiSearchField;
	IBOutlet NSToolbarItem * tbiSearchButton;
	IBOutlet NSToolbarItem * tbiCopy;
	IBOutlet NSToolbarItem * tbiSafe;
	IBOutlet NSToolbarItem * tbiFormat;
	IBOutlet NSToolbarItem * tbiType;
	
	IBOutlet NSToolbarItem * prefGeneral;
	IBOutlet NSToolbarItem * prefAdvanced;
	
	IBOutlet NSTextField * infosSize;
	IBOutlet NSTextField * infosName;
	IBOutlet BWHyperlinkButton * infosSource;
	IBOutlet BWHyperlinkButton * infosUrl;
	IBOutlet NSImageView * infosImage;
	IBOutlet NSTextField * infosType;
	
	IBOutlet NSPopUpButton * server;
	
	NSString * url;
	
	IBOutlet NSButton * checkBoxReloadSearchOnArgsChange;
	IBOutlet NSButton * checkBoxGrowl;
	
	float zoomFactor;
	
	NSMutableArray * itemsToDownload;
	NSMutableArray * itemsToDownloadOutput;
	
	int iii;
	
	IBOutlet NSTableView * tab;
	IBOutlet NSTableColumn * tabCol;
	IBOutlet NSTableColumn * tabColImg;
	IBOutlet NSTableColumn * tabColFormat;
	IBOutlet NSTableColumn * tabColSize;
	IBOutlet NSTableColumn * tabColDate;
	IBOutlet NSTableColumn * tabColFileSize;
	NSMutableArray * imageItems;
	
	SlideShowObject * slide;
	
	BOOL growlIsNotifying;
	
	IBOutlet NSButton * deleteImageButton;
	IBOutlet NSButton * createSearchFolder;
	
	IBOutlet NSButton * cancelDownloadButton;
	
	BOOL connectionIsRunning;
	BOOL downloadIsRunning;
	int unfetchedItems;
	
//	IBOutlet NSSegmentedControl * navButton;
	IBOutlet BWTexturedSlider * imageSlider;
	IBOutlet NSButton * detailsInfoButton;
	
	IBOutlet NSView * downloadView;
	
	IBOutlet NSPopUpButton * serverToolbar;
	IBOutlet NSTextField * siteSearchTextField;
	
	IBOutlet NSMenuItem * googleItem;
	IBOutlet NSButton * siteSearchWindowButton;
	
	IBOutlet NSSplitView * leftSplitView;
	IBOutlet NSView * leftSplitViewContentTop;
	IBOutlet NSView * leftSplitViewContentBottom;
	
	IBOutlet BWAnchoredPopUpButton * imageToolModeButton;
	IBOutlet BWInsetTextField * imageToolModeLabel;
	IBOutlet BWAnchoredButton * imageCropToolButton;
	
	IBOutlet BWAnchoredButton * navLeftButton;
	IBOutlet BWAnchoredButton * navRightButton;
	
	NSString * imageLoadedUrl;
	
	IBOutlet BWAnchoredButton * downloadButton;
	
	IBOutlet NSScrollView * browserScroll;
	
	IBOutlet NSButton * changePath;
	
	IBOutlet NSTextField * theNum;
	
	IBOutlet NSSearchField * tabSearch;
	NSMutableArray * activeSet;
	NSMutableArray * subset;
	
	IBOutlet NSView * customViewBG;
	IBOutlet NSBox * horizontalLine;
}

@property (assign) IBOutlet NSWindow * win;
@property (retain) NSString * currentSearchTerm;
@property (readwrite,retain) NSMutableArray * imageObjects;
@property (retain) NSString * url;
@property (readwrite,retain) NSMutableArray * imageItems;
@property (readwrite,retain) NSMutableArray * itemsToDownload;
@property (readwrite,retain) NSMutableArray * itemsToDownloadOutput;
@property (retain) NSString * destinationFilename;

- (IBAction)nav:(id)sender;
- (IBAction)start:(id)sender;

- (void)startSearchWithTerm:(NSString*)searchTerm atStartPosition:(NSUInteger)start;

- (IBAction)searchOptionsDidChange:(id)sender;
- (IBAction)activateSearchButton:(id)sender;

- (IBAction)setDetailsInfos:(id)sender;

- (IBAction)playSlideshow:(id)sender;
- (IBAction)loadGrowlNotifications:(id)sender;

- (IBAction)deleteImage:(id)sender;
- (IBAction)updateOutputFolder:(id)sender;

- (IBAction)setSearchCategoryFrom:(NSMenuItem *)menuItem;
- (IBAction)googleItemClicked:(id)sender;

- (IBAction)sendMailWithAttachement:(id)sender;
- (IBAction)changeDesktopWallpaper:(id)sender;

- (IBAction)downloadItems:(id)sender;

@end
