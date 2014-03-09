//
//  MainController+ImageBrowser.m
//  Toucan
//
//  Created by will on 23/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import "MainController+ImageBrowser.h"


@implementation MainController(ImageBrowser)

# pragma mark -
# pragma mark IKImageBrowserView datasource methods

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)view
{
    return [self.imageObjects count];
}

- (id)imageBrowser:(IKImageBrowserView *)view itemAtIndex:(NSUInteger)index
{
    return [self.imageObjects objectAtIndex: index];
}

- (void)imageBrowserSelectionDidChange:(IKImageBrowserView *)aBrowser
{   
    // only one selection possible
    NSUInteger index = [[imageBrowser selectionIndexes] firstIndex];
    
	if(index != NSNotFound)
	{
		if([[imageBrowser selectionIndexes] count] > 1)
		{
			[saveButton setEnabled: YES forSegment: 0];
			[saveButton setEnabled: NO forSegment: 1];
			[saveButton setEnabled: NO forSegment: 2];
			[downloadButton setEnabled: YES];
			
			[imageView setImageWithURL: NULL];
		}
		else
		{	
			//Clear imageView and save buttons before loading the resquested image
			//[imageView setImageWithURL: NULL];
			[saveButton setEnabled: NO forSegment: 0];
			[saveButton setEnabled: NO forSegment: 1];
			[saveButton setEnabled: NO forSegment: 2];
			[sizeButton setHidden: YES];
			[downloadButton setEnabled: YES];
			
			MyImageObject * obj = [self.imageObjects objectAtIndex: index];
			NSURL * imageUrl = [NSURL URLWithString: obj.imageUrl];
			
			NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
			[self performSelectorInBackground: @selector(displayImageWithURL:) withObject: imageUrl];
			[pool release];
			
			NSURL * tbnUrl = [NSURL URLWithString: obj.thumbnailUrl];
			NSImage * tbnImg = [[NSImage alloc] initWithContentsOfURL: tbnUrl];
			NSArray * src = [obj.imageUrl pathComponents];
			
			[infosImage setImage: tbnImg];
			[tbnImg release];
			
			[infosName setStringValue: [NSString stringWithFormat: NSLocalizedString(@"IMG_INFOS_NAME",@"Nom : %@"), [[obj.imageUrl lastPathComponent] stringByDeletingPathExtension]]];
			[infosSize setStringValue: [NSString stringWithFormat: NSLocalizedString(@"IMG_INFOS_SIZE",@"Dimensions : %@ ppp"), obj.imageSizeText]];
			[infosType setStringValue: [NSString stringWithFormat: NSLocalizedString(@"IMG_INFOS_TYPE",@"Type : %@"), [obj.imageUrl pathExtension]]];
			
			[infosSource setTitle: [NSString stringWithFormat: @"%@", [src objectAtIndex: 1]]];
			[infosSource setUrlString: [NSString stringWithFormat: @"http://%@", [src objectAtIndex: 1]]];
			
			[infosUrl setTitle: [NSString stringWithFormat: @"%@", obj.imageUrl]];
			[infosUrl setUrlString: [NSString stringWithFormat: @"%@", obj.imageUrl]];
			
			self.url = [NSString stringWithFormat: @"%@", imageUrl];
		}
	}
    else
    {
		[saveButton setEnabled: NO forSegment: 0];
		[saveButton setEnabled: NO forSegment: 1];
		[saveButton setEnabled: NO forSegment: 2];
		[downloadButton setEnabled: NO];
		[sizeButton setHidden: YES];
        [imageView setImageWithURL: NULL];
		
		[infosImage setImage: nil];
		[infosName setStringValue: [NSString stringWithFormat:NSLocalizedString(@"IMG_INFOS_NAME",@"Nom : %@"), @"-"]];
		[infosSize setStringValue: [NSString stringWithFormat:NSLocalizedString(@"IMG_INFOS_SIZE",@"Dimensions : %@ ppp"), @"-"]];
		[infosType setStringValue: [NSString stringWithFormat:NSLocalizedString(@"IMG_INFOS_TYPE",@"Type : %@"), @"-"]];
		[infosSource setTitle: @""];
		[infosSource setUrlString: @""];
		[infosUrl setTitle: @""];
		[infosUrl setUrlString: @""];
    }
}

- (IBAction)zoomSliderDidChange:(id)sender
{
    [imageBrowser setZoomValue: [sender floatValue]];
    [imageBrowser setNeedsDisplay: YES];
}

@end
