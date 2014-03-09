//
//  MainController.m
//  Toucan
//
//  Created by William VALENTIN on October 03, 2009.
//	©2009 ExoApps, All Rights Reserved
//

#import "MainController.h"
#import "MyImageObject.h"
#import "SlideShowObject.h"
#import <RegexKit/RegexKit.h>
#import "SendMail.h"
#import "DesktopImage.h"
//-- Import categories ------------------
#import "NSObject+DeallocControl.h"
#import "MainController+TableView.h"
#import "MainController+URLDownload.h"
#import "MainController+SaveImages.h"
#import "MainController+URLConnection.h"
#import "MainController+ImageBrowser.h"
#import "MainController+Utilities.h"
#import "MainController+SplitView.h"
#import "MainController+UserPreferences.h"
#import "MainController+ImageView.h"
#import "MainController+TabSearch.h"

#import "CustomScroller.h"

#pragma mark -

@implementation MainController

@synthesize win;
@synthesize currentSearchTerm;
@synthesize imageObjects;
@synthesize url;
@synthesize imageItems;
@synthesize itemsToDownload;
@synthesize itemsToDownloadOutput;
@synthesize destinationFilename;


//- (id)retain
//{
//    DLog(@"Retain: Retain count is now %d", self.retainCount+1);
//    return [super retain];
//}
//
//- (void)release
//{
//    DLog(@"Release: Retain count is now %d", self.retainCount-1);
//    [super release];
//}

# pragma mark -
# pragma mark Init / UserDefaults

-(id)init
{
    if (self = [super init])
	{
       [self setupDefaults];
	}
    return self;
}

-(void)windowDidBecomeMain:(NSNotification *)aNotification
{
	NSFileManager * manager = [NSFileManager defaultManager];
	BOOL folderExists = [manager fileExistsAtPath: [dest stringValue]];
	
	if(folderExists == NO) [self readPrefs], [self tableViewStuff];
}

-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
	[self readPrefs];
	
	if(growlIsNotifying == YES) [GrowlApplicationBridge setGrowlDelegate: self];
	
	DLog(@"Destination folder: %@", [dest stringValue]);
	
	zoomFactor = 0.5;
	
	[self tableViewStuff];
}

-(BOOL)shouldCloseSheet:(id)sender
{
//	[[NSUserDefaultsController sharedUserDefaultsController] save: self];
	
	if((sender == siteSearchWindowButton) && (![[searchTermTextField stringValue] isEqualToString: @""])) [self start: sender];
	
	return YES;
}

-(void)awakeFromNib
{	
	[splitViewDownload toggleCollapse: nil];
	
	[horizontalLine setBoxType: NSBoxCustom];
	[horizontalLine setBorderColor: [NSColor grayColor]];
	
	[win makeFirstResponder: searchTermTextField];
	
	[win setRepresentedURL:[NSURL fileURLWithPath: [[NSFileManager defaultManager] displayNameAtPath: [[NSBundle mainBundle] bundlePath]]]];
	NSImage * imglogo = [NSImage imageNamed: @"Icon"];
	[imglogo setSize: NSMakeSize(16, 16)]; // scale your image if needed (and maybe should use userSpaceScaleFactor)
//	[win setRepresentedFilename: [[NSFileManager defaultManager] displayNameAtPath: [[NSBundle mainBundle] bundlePath]]];
	[[win standardWindowButton: NSWindowDocumentIconButton] setImage: imglogo];
	
	[imageView setBackgroundColor: [NSColor darkGrayColor]];
	[imageView setCurrentToolMode: IKToolModeMove];
	[[IKImageEditPanel sharedImageEditPanel] setHidesOnDeactivate: YES];

	[imageBrowser setValue: [NSColor darkGrayColor] forKey: IKImageBrowserBackgroundColorKey];
	[imageBrowser setCellsStyleMask: IKCellsStyleOutlined | IKCellsStyleShadowed];
	
	[browserScroll setBackgroundColor: [NSColor darkGrayColor]];
	[browserScroll setBorderType: NSNoBorder];
	[browserScroll setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
	[browserScroll setDocumentView: imageBrowser];
	
	[win setTitle: [[NSFileManager defaultManager] displayNameAtPath: [[NSBundle mainBundle] bundlePath]]];
	[copyrights setStringValue: NSLocalizedString(@"COPYRIGHTS_TEXT_FIELD_LABEL",@"©2009 William VALENTIN, Tous droits réservés")];
	[splitButton setState: 1];
	[saveButton setEnabled: NO forSegment: 0];
	[saveButton setEnabled: NO forSegment: 1];
	[saveButton setEnabled: NO forSegment: 2];

	[searchButton setEnabled: NO];
	
	[tbiSize setLabel: NSLocalizedString(@"SIZE_TOOLBAR_ITEM_LABEL",@"Taille")];
	[tbiSize setPaletteLabel: NSLocalizedString(@"SIZE_TOOLBAR_ITEM_PALETTE_LABEL",@"Taille")];
	[tbiTint setLabel: NSLocalizedString(@"TINT_TOOLBAR_ITEM_LABEL",@"Teinte")];
	[tbiTint setPaletteLabel: NSLocalizedString(@"TINT_TOOLBAR_ITEM_PALETTE_LABEL",@"Teinte")];
	[tbiCopy setLabel: NSLocalizedString(@"COPY_TOOLBAR_ITEM_LABEL",@"Copyrights")];
	[tbiCopy setPaletteLabel: NSLocalizedString(@"COPY_TOOLBAR_ITEM_PALETTE_LABEL",@"Copyrights")];
	[tbiSearchField setLabel: NSLocalizedString(@"SEARCH_FIELD_TOOLBAR_ITEM_LABEL",@"Recherche")];
	[tbiSearchField setPaletteLabel: NSLocalizedString(@"SEARCH_FIELD_TOOLBAR_ITEM_PALETTE_LABEL",@"Recherche")];
	[tbiSearchButton setLabel: NSLocalizedString(@"SEARCH_BUTTON_TOOLBAR_ITEM_LABEL",@"Envoyer")];
	[tbiSearchButton setPaletteLabel: NSLocalizedString(@"SEARCH_BUTTON_TOOLBAR_ITEM_PALETTE_LABEL",@"Envoyer")];
	[tbiSafe setLabel: NSLocalizedString(@"SAFE_RADIO_BUTTON_TOOLBAR_LABEL",@"Modération")];
	[tbiSafe setPaletteLabel: NSLocalizedString(@"SAFE_RADIO_BUTTON_TOOLBAR_PALETTE_LABEL",@"Modération")];
	
	[tbiSearchButton setToolTip: NSLocalizedString(@"SEARCH_BUTTON_TOOLBAR_ITEM_TOOLTIP_LABEL",@"Cliquez pour lancer la recherche")];
	[tbiSearchField setToolTip: NSLocalizedString(@"SEARCH_FIELD_TOOLBAR_ITEM_TOOLTIP_LABEL",@"Entrez les mots clé à rechercher")];
	[tbiCopy setToolTip: NSLocalizedString(@"COPY_TOOLBAR_ITEM_TOOLTIP_LABEL",@"Choisissez le type de droits d'utilisation des images")];
	[tbiTint setToolTip: NSLocalizedString(@"TINT_TOOLBAR_ITEM_TOOLTIP_LABEL",@"Choisissez la teinte des images")];
	[tbiSize setToolTip: NSLocalizedString(@"SIZE_TOOLBAR_ITEM_TOOLTIP_LABEL",@"Spécifier la taille des images")];
	[tbiSafe setToolTip: NSLocalizedString(@"SAFE_RADIO_BUTTON_TOOLBAR_TOOLTIP_LABEL",@"Activer/Désactiver le filtre de modération des résultats")];
	[tbiFormat setToolTip: NSLocalizedString(@"FORMAT_TOOLBAR_ITEM_TOOLTIP_LABEL",@"Choisissez le format d'images")];
	[tbiType setToolTip: NSLocalizedString(@"TYPE_TOOLBAR_ITEM_TOOLTIP_LABEL",@"Choisissez le type d'images")];
	
	[prefGeneral setLabel: NSLocalizedString(@"GENERAL_PREF_TOOLBAR_ITEM_LABEL",@"Général")];
	[prefGeneral setPaletteLabel: NSLocalizedString(@"GENERAL_PREF_TOOLBAR_ITEM_PALETTE_LABEL",@"Général")];
	[prefAdvanced setLabel: NSLocalizedString(@"ADVANCED_PREF_TOOLBAR_ITEM_LABEL",@"Avancé")];
	[prefAdvanced setPaletteLabel: NSLocalizedString(@"ADVANCED_PREF_TOOLBAR_ITEM_PALETTE_LABEL",@"Avancé")];
	
	[size addItemWithTitle: NSLocalizedString(@"ICON_POPUP_BUTTON_TITLE",@"Icon")];
	[size addItemWithTitle: NSLocalizedString(@"MIDDLE_POPUP_BUTTON_TITLE",@"Middle")];
	[size addItemWithTitle: NSLocalizedString(@"HUGE_POPUP_BUTTON_TITLE",@"Big")];
	[size addItemWithTitle: @"+400x300"];
	[size addItemWithTitle: @"+640x480"];
	[size addItemWithTitle: @"+800x600"];
	[size addItemWithTitle: @"+1024x768"];
	[size addItemWithTitle: @"+2MP"];
	[size addItemWithTitle: @"+4MP"];
	[size addItemWithTitle: @"+6MP"];
	[size addItemWithTitle: @"+8MP"];
	[size addItemWithTitle: @"+10MP"];
	[size addItemWithTitle: @"+12MP"];
	[size addItemWithTitle: @"+15MP"];
	[size addItemWithTitle: @"+20MP"];
	[size addItemWithTitle: @"+40MP"];
	[size addItemWithTitle: @"+70MP"];
	
	[format addItemWithTitle: @"jpg"];
	[format addItemWithTitle: @"gif"];
	[format addItemWithTitle: @"png"];
	[format addItemWithTitle: @"bmp"];
	
	[tint addItemWithTitle: NSLocalizedString(@"COLOR_POPUP_BUTTON_TITLE",@"Couleur")];
	[tint addItemWithTitle: NSLocalizedString(@"BLACK_AND_WHITE_POPUP_BUTTON_TITLE",@"N&B")];
	
	[type addItemWithTitle: NSLocalizedString(@"NEWS_POPUP_BUTTON_TITLE",@"Actualité")];
	[type addItemWithTitle: NSLocalizedString(@"FACE_POPUP_BUTTON_TITLE",@"Visages")];
	[type addItemWithTitle: NSLocalizedString(@"PHOTO_CONTENT_POPUP_BUTTON_TITLE",@"Contenu photo")];
	[type addItemWithTitle: NSLocalizedString(@"CLIPART_POPUP_BUTTON_TITLE",@"Images clipart")];
	[type addItemWithTitle: NSLocalizedString(@"HAND_DRAW_POPUP_BUTTON_TITLE",@"Dessins au trait")];
	
	[copy addItemWithTitle: NSLocalizedString(@"COPYRIGHTS_1_POPUP_BUTTON_TITLE",@"Réutilisation autorisée")];
	[copy addItemWithTitle: NSLocalizedString(@"COPYRIGHTS_2_POPUP_BUTTON_TITLE",@"Réutilisation à des fins commerciales autorisée")];
	[copy addItemWithTitle: NSLocalizedString(@"COPYRIGHTS_3_POPUP_BUTTON_TITLE",@"Réutilisation avec modification autorisée")];
	[copy addItemWithTitle: NSLocalizedString(@"COPYRIGHTS_4_POPUP_BUTTON_TITLE",@"Réutilisation avec modification à des fins commerciales autorisée")];
	
	[server addItemsWithTitles: [NSArray arrayWithObjects: @"FR", @"US", @"UK", @"DE", @"IT", @"CH", nil]];
	[serverToolbar addItemsWithTitles: [NSArray arrayWithObjects: @"FR", @"US", @"UK", @"DE", @"IT", @"CH", nil]];
	[serverToolbar selectItemWithTitle: [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey: @"PreferedSearchServer"]];
	
	[positionTextField setStringValue: @""];
	[infosUrl setTitle: @""];
	[percents setStringValue: @""];
	[destFolderLabel setStringValue: NSLocalizedString(@"DESTINATION_FOLDER_DIALOG_TITLE",@"Dossier de destination : ")];
	
	[progressIndicator setHidden: YES];
	
	[infosImage setImage: nil];
	[infosSize setStringValue: NSLocalizedString(@"INFO_SIZE",@"Taille : ")];
	[infosType setStringValue: NSLocalizedString(@"INFO_TYPE",@"Type : ")];
	[infosSource setTitle: @""];
	[infosSource setUrlString: @""];
	[infosUrl setTitle: @""];
	[infosUrl setUrlString: @""];
	
	[slideShowButton setToolTip: NSLocalizedString(@"SLIDESHOW_BUTTON_TOOLTIP_LABEL",@"Lancer le diaporama")];
	
	[searchTermTextFieldCell setPlaceholderString: NSLocalizedString(@"SEARCH_TEXTFIELD_CELL_PLACEHOLDER",@"Chercher sur un site => MOT_CLE :SITE")];
	[slideShowButton setEnabled: NO];
	[deleteImageButton setEnabled: NO];
	[sendMailButton setEnabled: NO];
	[changeDesktopImageButton setEnabled: NO];
	[cancelDownloadButton setEnabled: NO];
	
	[imageToolModeLabel setStringValue: NSLocalizedString(@"IMAGE_TOOL_MODE_MOVE_LABEL",@"Mode outil actuel : Déplacement")];
	[imageCropToolButton setHidden: YES];
	
	[imageSlider setEnabled: NO];
	[detailsInfoButton setEnabled: NO];
	[navLeftButton setEnabled: NO];
	[navRightButton setEnabled: NO];
	[downloadButton setEnabled: NO];
	
	[tab setRowHeight: 30.0];
	NSSize aSize = NSMakeSize(3.0, 5.0);
	[tab setIntercellSpacing: aSize];
	
//	[imageView setImageWithURL: [NSURL fileURLWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"Icon.icns"]]];
	
//	//SearchField Menu-------------
//	NSMenu *cellMenu = [[[NSMenu alloc] initWithTitle:@"Search Menu"]
//                        autorelease];
//    NSMenuItem *item;
//	
//    item = [[[NSMenuItem alloc] initWithTitle:@"Google"
//                                       action:@selector(start:)
//                                keyEquivalent:@""] autorelease];
//    [item setTarget:self];
//    [item setTag:1];
//    [cellMenu insertItem:item atIndex:0];
//	
//    item = [[[NSMenuItem alloc] initWithTitle:@"Autre site"
//                                       action:@selector(start:)
//                                keyEquivalent:@""] autorelease];
//    [item setTarget:self];
//    [item setTag:2];
//    [cellMenu insertItem:item atIndex:1];
//	 
//	
//    id searchCell = [searchTermTextField cell];
//    [searchCell setSearchMenuTemplate:cellMenu];
//	//--------------------------------------------
	
	
//	NSUInteger selectedSearchMenuItem = [[[searchTermTextField cell] searchMenuTemplate] indexOfItem: googleItem];
//	[[[searchTermTextField cell] searchMenuTemplate] selectItemAtIndex: selectedSearchMenuItem];
}

-(void)applicationWillTerminate:(NSNotification *)aNotification
{
	id prefs = [NSUserDefaultsController sharedUserDefaultsController];
	[[prefs values] setValue: [server titleOfSelectedItem] forKey: @"PreferedSearchServer"];
}

-(BOOL)windowShouldClose:(id)sender
{
	[NSApp terminate: nil];
	return YES;
}

-(void)dealloc
{
	self.currentSearchTerm = nil;
	self.destinationFilename = nil;
	self.url = nil;
	self.imageObjects = nil;
	self.imageItems = nil;
	[imageLoadedUrl release], imageLoadedUrl = nil;
	self.itemsToDownload = nil;
	self.itemsToDownloadOutput = nil;
	[MainController deallocControl: self];
	[super dealloc];
}

# pragma mark -
# pragma mark IBActions

-(IBAction)loadGrowlNotifications:(id)sender
{
	if([checkBoxGrowl state] == 1)
	{
		[GrowlApplicationBridge setGrowlDelegate: self];
		
		[GrowlApplicationBridge notifyWithTitle: @"Infos"
									description: @"Growl pour Toucan a démarré"
							   notificationName: @"Growl Started"
									   iconData: nil
									   priority: 0
									   isSticky: NO
								   clickContext: nil];
		growlIsNotifying = YES;
	}
	if([checkBoxGrowl state] == 0)
	{
		[GrowlApplicationBridge notifyWithTitle: @"Infos"
									description: @"Growl poru Toucan s'est arrêté"
							   notificationName: @"Growl Stopped"
									   iconData: nil
									   priority: 0
									   isSticky: NO
								   clickContext: nil];
		growlIsNotifying = NO;
	}
}

-(IBAction)nav:(id)sender
{
	[infosUrl setTitle: @""];
	
	if(connectionIsRunning == YES) [searchConnection cancel], connectionIsRunning = NO;
	
	if([sender tag] == 0)
	{
		// do nothing if there are no search results
		if([self.imageObjects count] == 0) return;
	
		// minimum start position is 0
		currentStartPosition -= [self.imageObjects count];
		if(currentStartPosition < 0) currentStartPosition = 0;
	
		[self startSearchWithTerm: self.currentSearchTerm atStartPosition: currentStartPosition];
	}
	
	if([sender tag] == 1)
	{
		// do nothing if there are no search results
		if([self.imageObjects count] == 0) return;	
		[imageBrowser setSelectionIndexes: [NSIndexSet indexSet] byExtendingSelection: NO];
		currentStartPosition += [self.imageObjects count];
		[self startSearchWithTerm: self.currentSearchTerm atStartPosition: currentStartPosition];
	}
	
	
//	if([sender selectedSegment] == 0)
//	{
//		// do nothing if there are no search results
//		if([self.imageObjects count] == 0)
//			return;
//		
//		// minimum start position is 0
//		currentStartPosition -= [self.imageObjects count];
//		if(currentStartPosition < 0)
//			currentStartPosition = 0;
//		
//		[self startSearchWithTerm: self.currentSearchTerm
//				  atStartPosition: currentStartPosition];
//	}
//
//	if([sender selectedSegment] == 1)
//	{
//		// do nothing if there are no search results
//		if([self.imageObjects count] == 0)
//			return;
//		
//		[imageBrowser setSelectionIndexes: [NSIndexSet indexSet] byExtendingSelection: NO];
//		
//		currentStartPosition += [self.imageObjects count];
//		
//		[self startSearchWithTerm: self.currentSearchTerm
//				  atStartPosition: currentStartPosition];
//	}
	
	[imageBrowser scrollIndexToVisible: [[imageBrowser selectionIndexes] firstIndex]];

}

-(IBAction)start:(id)sender
{
	[infosUrl setTitle: @""];
	connectionIsRunning = NO;
	
	if([[searchTermTextField stringValue] length] > 0)
	{
		self.currentSearchTerm = [searchTermTextField stringValue];
		currentStartPosition = 0;
		self.imageObjects = [NSMutableArray array];
		[self startSearchWithTerm: self.currentSearchTerm atStartPosition: currentStartPosition];
	}
	
	[imageBrowser scrollIndexToVisible: [[imageBrowser selectionIndexes] firstIndex]];

	
//	NSUserDefaultsController * sharedUser = [NSUserDefaultsController sharedUserDefaultsController];
//	[[sharedUser values] setValue: @"Test" forKey: @"items"];
	
//	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//	[dic setObject:[NSMutableArray arrayWithObjects:@"test", @"jpg", @"color", @"+1024", @"face", nil] forKey:@"items"];
//	[[NSUserDefaults standardUserDefaults] registerDefaults:dic];
}

-(IBAction)downloadItems:(id)sender
{
	[self saveData: sender];
}

-(IBAction)searchOptionsDidChange:(id)sender
{
	if((![[searchTermTextField stringValue] isEqualToString: @""]) && ([checkBoxReloadSearchOnArgsChange state] == 1))
	[self startSearchWithTerm: self.currentSearchTerm
			  atStartPosition: currentStartPosition];
}

-(IBAction)setDetailsInfos:(id)sender
{
	if([sender state] == 0) [imageBrowser setCellsStyleMask: IKCellsStyleOutlined | IKCellsStyleShadowed];
	else [imageBrowser setCellsStyleMask: IKCellsStyleOutlined | IKCellsStyleShadowed | IKCellsStyleTitled | IKCellsStyleSubtitled];
}

-(IBAction)activateSearchButton:(id)sender
{
	if([[searchTermTextField stringValue] isEqualToString: @""])
	{
		[searchButton setEnabled: NO];
	}
	else
	{
		[searchButton setEnabled: YES];
	}
	
	if([createSearchFolder state] == 1)
	{
		id prefs = [[NSUserDefaultsController sharedUserDefaultsController] values];
		id path = [prefs valueForKey: @"OutputFolder"];
		id output = [path stringByAppendingPathComponent: [[searchTermTextField stringValue] capitalizedString]];
		[dest setStringValue: output];
		
		if([[NSFileManager defaultManager] fileExistsAtPath: [dest stringValue]]) [self tableViewStuff];
	}
}

-(IBAction)updateOutputFolder:(id)sender
{
	id prefs = [[NSUserDefaultsController sharedUserDefaultsController] values];
	id path = [prefs valueForKey: @"OutputFolder"];
	id output = [path stringByAppendingPathComponent: [[searchTermTextField stringValue] capitalizedString]];
	
	if(([createSearchFolder state] == 1) && (![[[[dest stringValue] capitalizedString] lastPathComponent] isEqualToString: [[searchTermTextField stringValue] capitalizedString]])) [dest setStringValue: output];
	else [dest setStringValue: path];
	
	if([[NSFileManager defaultManager] fileExistsAtPath: [dest stringValue]]) [self tableViewStuff];
}

-(IBAction)playSlideshow:(id)sender
{
	slide = [[SlideShowObject alloc] init];
	slide.mSlideshow = [[IKSlideshow sharedSlideshow] retain];
	slide.mImagePaths = [[NSMutableArray alloc] init];
	
	if([[tabSearch stringValue] length] != 0)
	{
		for(int i = 0; i < [self.imageItems count]; i++)
		{
			[slide.mImagePaths addObject: [[dest stringValue] stringByAppendingPathComponent: [[activeSet objectAtIndex: i] valueForKey: @"name"]]];
		}
	}
	else
	{
		for(int i = 0; i < [self.imageItems count]; i++)
		{
			[slide.mImagePaths addObject: [[dest stringValue] stringByAppendingPathComponent: [[self.imageItems objectAtIndex: i] valueForKey: @"name"]]];
		}
	}
	[slide run];
}

-(IBAction)deleteImage:(id)sender
{
	if([[tabSearch stringValue] length] != 0)
	{	
		[imageView setImageWithURL: NULL];
		[self deleteImagesFromArray: activeSet itemsAtIndexes: [tab selectedRowIndexes] fromDisc: YES withFilePath: [dest stringValue]];
		//	[tab deselectAll: sender];
		[[tabColImg headerCell] setStringValue: [NSString stringWithFormat: @"#%i", [activeSet count]]];
		[tab reloadData];
		if([activeSet count] > 0) [slideShowButton setEnabled: YES];
		else [slideShowButton setEnabled: NO];
		
		NSUInteger index = [[tab selectedRowIndexes] firstIndex];
		
		if(index != NSNotFound)
		{
			NSURL * imgPath = [NSURL fileURLWithPath: [[dest stringValue] stringByAppendingPathComponent: [[activeSet objectAtIndex: index] valueForKey: @"name"]]];
			[imageView setImageWithURL: imgPath];
		}
		
		return;
	}
	
	[imageView setImageWithURL: NULL];
	[self deleteImagesFromArray: self.imageItems itemsAtIndexes: [tab selectedRowIndexes] fromDisc: YES withFilePath: [dest stringValue]];
//	[tab deselectAll: sender];
	[[tabColImg headerCell] setStringValue: [NSString stringWithFormat: @"#%i", [self.imageItems count]]];
	[tab reloadData];
	if([self.imageItems count] > 0) [slideShowButton setEnabled: YES];
	else [slideShowButton setEnabled: NO];
	
	NSUInteger index = [[tab selectedRowIndexes] firstIndex];
    
	if(index != NSNotFound)
	{
		NSURL * imgPath = [NSURL fileURLWithPath: [[dest stringValue] stringByAppendingPathComponent: [[self.imageItems objectAtIndex: index] valueForKey: @"name"]]];
		[imageView setImageWithURL: imgPath];
	}
}

-(IBAction)setSearchCategoryFrom:(NSMenuItem *)menuItem
{
    //searchCategory = [menuItem tag];
    [[searchTermTextField cell] setPlaceholderString: [menuItem title]];
}

-(IBAction)googleItemClicked:(id)sender
{
	[siteSearchTextField setStringValue: @""];
}

-(IBAction)sendMailWithAttachement:(id)sender
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSIndexSet * indexes = [tab selectedRowIndexes];
	
	if([indexes count] != 0)
	{
		NSMutableArray * imgArray = [NSMutableArray array];
		for(NSUInteger index = [indexes lastIndex]; index != NSNotFound; index = [indexes indexLessThanIndex: index])
		{
			if([[tabSearch stringValue] length] != 0) [imgArray addObject: [[dest stringValue] stringByAppendingPathComponent: [[activeSet objectAtIndex: index] valueForKey: @"name"]]];
			else [imgArray addObject: [[dest stringValue] stringByAppendingPathComponent: [[self.imageItems objectAtIndex: index] valueForKey: @"name"]]];
		}
		
		SendMail * mail = [[SendMail alloc] init];
		mail.filesPaths = imgArray;
		[mail sendTheMail];
		[mail release];
	}
	[pool release];
}

-(IBAction)changeDesktopWallpaper:(id)sender
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSUInteger index = [[tab selectedRowIndexes] firstIndex];
	if(index != NSNotFound)
	{
		DesktopImage * desk = [[DesktopImage alloc] init];
		
		if([[tabSearch stringValue] length] != 0) desk.imagePath = [[dest stringValue] stringByAppendingPathComponent: [[activeSet objectAtIndex: index] valueForKey: @"name"]];
		else desk.imagePath = [[dest stringValue] stringByAppendingPathComponent: [[self.imageItems objectAtIndex: index] valueForKey: @"name"]];
		[desk changeDesktopImage];
		[desk release];
	}
	[pool release];
}

// This method initiates the search. It takes a search term and a start position (0-based)
-(void)startSearchWithTerm:(NSString *)searchTerm atStartPosition:(NSUInteger)start
{	
	if(connectionIsRunning == YES) [searchConnection cancel], connectionIsRunning = NO;
	
	[progressIndicator setHidden: NO];
	[progressIndicator startAnimation: self];
	
	NSString * sizeArg = nil;
	
	if([[size titleOfSelectedItem] isEqualToString: @"∞"]) sizeArg = @"";
	if(
	   ([[size titleOfSelectedItem] isEqualToString: @"Icone"]) || 
	   ([[size titleOfSelectedItem] isEqualToString: @"Icon"])
	  ) sizeArg = @"&imgsz=i";
	if(
	   ([[size titleOfSelectedItem] isEqualToString: @"Moyenne"]) || 
	   ([[size titleOfSelectedItem] isEqualToString: @"Middle"])
	  ) sizeArg = @"&imgsz=m";
	if(
	   ([[size titleOfSelectedItem] isEqualToString: @"Grande"]) || 
	   ([[size titleOfSelectedItem] isEqualToString: @"Big"])
	  ) sizeArg = @"&imgsz=l";
	
	if([[size titleOfSelectedItem] isEqualToString: @"+400x300"]) sizeArg = @"&imgsz=qsvga";
	if([[size titleOfSelectedItem] isEqualToString: @"+640x480"]) sizeArg = @"&imgsz=vga";
	if([[size titleOfSelectedItem] isEqualToString: @"+800x600"]) sizeArg = @"&imgsz=svga";
	if([[size titleOfSelectedItem] isEqualToString: @"+1024x768"]) sizeArg = @"&imgsz=xga";
	if([[size titleOfSelectedItem] isEqualToString: @"+2MP"]) sizeArg = @"&imgsz=2mp";
	if([[size titleOfSelectedItem] isEqualToString: @"+4MP"]) sizeArg = @"&imgsz=4mp";
	if([[size titleOfSelectedItem] isEqualToString: @"+6MP"]) sizeArg = @"&imgsz=6mp";
	if([[size titleOfSelectedItem] isEqualToString: @"+8MP"]) sizeArg = @"&imgsz=8mp";
	if([[size titleOfSelectedItem] isEqualToString: @"+10MP"]) sizeArg = @"&imgsz=10mp";
	if([[size titleOfSelectedItem] isEqualToString: @"+12MP"]) sizeArg = @"&imgsz=12mp";
	if([[size titleOfSelectedItem] isEqualToString: @"+15MP"]) sizeArg = @"&imgsz=15mp";
	if([[size titleOfSelectedItem] isEqualToString: @"+20MP"]) sizeArg = @"&imgsz=20mp";
	if([[size titleOfSelectedItem] isEqualToString: @"+40MP"]) sizeArg = @"&imgsz=40mp";
	if([[size titleOfSelectedItem] isEqualToString: @"+70MP"]) sizeArg = @"&imgsz=70mp";
	
	NSString * formatArg = nil;
	
	if([[format titleOfSelectedItem] isEqualToString: @"∞"]) formatArg = @"";
	if([[format titleOfSelectedItem] isEqualToString: @"jpg"]) formatArg = @"&as_filetype=jpg";
	if([[format titleOfSelectedItem] isEqualToString: @"gif"]) formatArg = @"&as_filetype=gif";
	if([[format titleOfSelectedItem] isEqualToString: @"png"]) formatArg = @"&as_filetype=png";
	if([[format titleOfSelectedItem] isEqualToString: @"bmp"]) formatArg = @"&as_filetype=bmp";
	
	NSString * tintArg = nil;
	
	if([[tint titleOfSelectedItem] isEqualToString: @"∞"]) tintArg = @"";
	if(
	   ([[tint titleOfSelectedItem] isEqualToString: @"Couleur"]) || 
	   ([[tint titleOfSelectedItem] isEqualToString: @"Color"])
	  ) tintArg = @"&imgc=color";
	if(
	   ([[tint titleOfSelectedItem] isEqualToString: @"N&B"]) || 
	   ([[tint titleOfSelectedItem] isEqualToString: @"B&W"])
	  ) tintArg = @"&imgc=gray";
	
	NSString * copyArg = nil;
	
	if([[copy titleOfSelectedItem] isEqualToString: @"∞"]) copyArg = @"";
	if(
	   ([[copy titleOfSelectedItem] isEqualToString: @"Réutilisation autorisée"]) || 
	   ([[copy titleOfSelectedItem] isEqualToString: @"Labeled for reuse"])
	   ) copyArg = @"&as_rights=%28cc_publicdomain%7Ccc_attribute%7Ccc_sharealike%7Ccc_noncommercial%7Ccc_nonderived%29";
	if(
	   ([[copy titleOfSelectedItem] isEqualToString: @"Réutilisation à des fins commerciales autorisée"]) || 
	   ([[copy titleOfSelectedItem] isEqualToString: @"Labeled for commercial reuse"])
	   ) copyArg = @"&as_rights=%28cc_publicdomain%7Ccc_attribute%7Ccc_sharealike%7Ccc_nonderived%29.-%28cc_noncommercial%29";
	if(
	   ([[copy titleOfSelectedItem] isEqualToString: @"Réutilisation avec modification autorisée"]) || 
	   ([[copy titleOfSelectedItem] isEqualToString: @"Labeled for reuse with modification"])
	   ) copyArg = @"&as_rights=%28cc_publicdomain%7Ccc_attribute%7Ccc_sharealike%7Ccc_noncommercial%29.-%28cc_nonderived%29";
	if(
	   ([[copy titleOfSelectedItem] isEqualToString: @"Réutilisation avec modification à des fins commerciales autorisée"]) || 
	   ([[copy titleOfSelectedItem] isEqualToString: @"Labeled for commercial reuse with modification"])
	   ) copyArg = @"&as_rights=%28cc_publicdomain%7Ccc_attribute%7Ccc_sharealike%29.-%28cc_noncommercial%7Ccc_nonderived%29";
	
	NSString * typeArg = nil;
	
	if([[type titleOfSelectedItem] isEqualToString: @"∞"]) typeArg = @"";
	if(
	   ([[type titleOfSelectedItem] isEqualToString: @"Actualité"]) || 
	   ([[type titleOfSelectedItem] isEqualToString: @"News"])
	  ) typeArg = @"&imgtype=news";
	if(
	   ([[type titleOfSelectedItem] isEqualToString: @"Visages"]) || 
	   ([[type titleOfSelectedItem] isEqualToString: @"Faces"])
	  ) typeArg = @"&imgtype=face";
	if(
	   ([[type titleOfSelectedItem] isEqualToString: @"Contenu photo"]) || 
	   ([[type titleOfSelectedItem] isEqualToString: @"Photo content"])
	  ) typeArg = @"&imgtype=photo";
	if(
	   ([[type titleOfSelectedItem] isEqualToString: @"Images clipart"]) || 
	   ([[type titleOfSelectedItem] isEqualToString: @"Clipart"])
	  ) typeArg = @"&imgtype=clipart";
	if(
	   ([[type titleOfSelectedItem] isEqualToString: @"Dessins au trait"]) || 
	   ([[type titleOfSelectedItem] isEqualToString: @"Hand draw"])
	  ) typeArg = @"&imgtype=lineart";

	NSString * safeArg = nil;
	
	if([safe state] == 0) safeArg = @""; else safeArg = @"&safe=off";
	
	NSString * selectedServer = nil;
	NSString * hlArg = nil;
	if([[serverToolbar titleOfSelectedItem] isEqualToString: @"FR"]) selectedServer = @"http://images.google.fr/", hlArg = @"fr";
	if([[serverToolbar titleOfSelectedItem] isEqualToString: @"US"]) selectedServer = @"http://images.google.com/", hlArg = @"en";
	if([[serverToolbar titleOfSelectedItem] isEqualToString: @"UK"]) selectedServer = @"http://images.google.co.uk/", hlArg = @"en";
	if([[serverToolbar titleOfSelectedItem] isEqualToString: @"DE"]) selectedServer = @"http://images.google.de/", hlArg = @"de";
	if([[serverToolbar titleOfSelectedItem] isEqualToString: @"IT"]) selectedServer = @"http://images.google.it/", hlArg = @"it";
	if([[serverToolbar titleOfSelectedItem] isEqualToString: @"CH"]) selectedServer = @"http://images.google.ch/", hlArg = @"ch";
	
	NSString * siteArg = nil;
//	NSRange newRange = [[searchTermTextField stringValue] rangeOfString: @"site:"];
//	if(newRange.location != NSNotFound)
//	{
//		NSString * site = [[[searchTermTextField stringValue] componentsSeparatedByString: @"site:"] lastObject];
//		siteArg = [NSString stringWithFormat: @"&as_sitesearch=%@", site];
//	}
	siteArg = [NSString stringWithFormat: @"&as_sitesearch=%@", [[siteSearchTextField stringValue] stringByReplacingOccurrencesOfString: @"http://" withString: @""]];
	
	NSString * urlString = [NSString stringWithFormat:@"%@images?as_q=%@&start=%@%@%@%@%@%@%@&hl=%@%@", 
						   selectedServer, 
                           [searchTerm stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding], 
                           [NSString stringWithFormat:@"%d", start],
						   safeArg, 
						   sizeArg, 
						   formatArg, 
						   tintArg, 
						   typeArg, 
						   copyArg,	
						   hlArg, 
						   siteArg
						   ];
    
    
    // replace all spaces with +
    urlString = [urlString stringByReplacingOccurrencesOfString: @" " withString: @"+"];
    
    // create a request with the url
    NSMutableURLRequest * theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: urlString]
                                                cachePolicy: NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval: 60.0];
	[theRequest setValue: [NSString stringWithFormat: @"http://images.google.%@/imghp?hl=%@&tab=wi", 
						   [[server titleOfSelectedItem] lowercaseString], 
						   [[server titleOfSelectedItem] lowercaseString]
						   ]
	  forHTTPHeaderField: @"Referer"];
    
    // create the connection with the request and start loading the data
    searchConnection = [[NSURLConnection alloc] initWithRequest: theRequest delegate: self];
	connectionIsRunning = YES;
    
    if(searchConnection) 
    {
        // Create the NSMutableData that will hold the received data
        // receivedData is declared as a method instance
        receivedData = [[NSMutableData data] retain];
    } 
    else 
    {
		connectionIsRunning = NO;
		
        // inform the user that the download could not be made
        DLog(@">>> Error: could not establish connection");
		
		if(growlIsNotifying == YES)
		[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"%@ - Attention !", 
												  [[NSFileManager defaultManager] displayNameAtPath: [[NSBundle mainBundle] bundlePath]]
												  ]
									description: NSLocalizedString(@"GROWL_CONNEXION_FAILED_DESCRIPTION_NOTIFICATION",@"Connexion avec le serveur distant impossible !")
							   notificationName: @"Connexion Failed"
									   iconData: [NSImage imageNamed: @"NSStopProgressFreestandingTemplate"]
									   priority: 1
									   isSticky: NO
								   clickContext: nil];
    }    
}

@end
