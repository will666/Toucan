//
//  MainController+ImageView.m
//  Toucan
//
//  Created by will on 23/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import "MainController+ImageView.h"


@implementation MainController(ImageView)

# pragma mark -
# pragma mark Display Images in IKImageView

// This method loads an image into the image view in a separate thread. 
- (void)displayImageWithURL:(id)imageUrl
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[progressIndicator setHidden: NO];
    [progressIndicator startAnimation: self];
	[imageView setImageWithURL: imageUrl];
	
	imageLoadedUrl = [imageUrl retain];
	
//	CGImageRef image = NULL;
//    CGImageSourceRef isr = CGImageSourceCreateWithURL((CFURLRef)imageUrl, NULL);
//	
//    if(isr)
//    {
//        image = CGImageSourceCreateImageAtIndex(isr, 0, NULL);
//        if (image)
//        {
//			imageProperties = (NSDictionary*)CGImageSourceCopyPropertiesAtIndex(isr, 0, (CFDictionaryRef)imageProperties);
//        }
//        CFRelease(isr);
//    }
//    if (image)
//    {
//		[imageView setImage: image imageProperties: imageProperties];
//		CGImageRelease(image);
//    }
	
	[imageView setAutoresizes: YES];
    [progressIndicator stopAnimation: self];
	[progressIndicator setHidden: YES];
	
	if([imageView image] != nil) [saveButton setEnabled: NO forSegment: 0], [saveButton setEnabled: YES forSegment: 1], [saveButton setEnabled: YES forSegment: 2], [sizeButton setHidden: NO];
	else [saveButton setEnabled: YES forSegment: 0], [saveButton setEnabled: NO forSegment: 1], [saveButton setEnabled: NO forSegment: 2], [sizeButton setHidden: YES];
	
    [pool release];    
}

- (IBAction)switchToolMode:(id)sender
{
    NSInteger newTool;
    if ([sender isKindOfClass: [NSSegmentedControl class]])
        newTool = [sender selectedSegment];
    else
		newTool = [sender tag];
	
    switch(newTool)
    {
        case 0:
            [imageView setCurrentToolMode: IKToolModeMove];
			[imageToolModeLabel setStringValue: NSLocalizedString(@"IMAGE_TOOL_MODE_MOVE_LABEL",@"Déplacement")];
			[imageCropToolButton setHidden: YES];
            break;
        case 1:
            [imageView setCurrentToolMode: IKToolModeSelect];
			[imageToolModeLabel setStringValue: NSLocalizedString(@"IMAGE_TOOL_MODE_SELECT_LABEL",@"Sélection")];
			[imageCropToolButton setHidden: YES];
            break;
        case 2:
            [imageView setCurrentToolMode: IKToolModeCrop];
			[imageToolModeLabel setStringValue: NSLocalizedString(@"IMAGE_TOOL_MODE_CROP_LABEL",@"Rognage")];
			[imageCropToolButton setHidden: NO];
            break;
        case 3:
            [imageView setCurrentToolMode: IKToolModeRotate];
			[imageToolModeLabel setStringValue: NSLocalizedString(@"IMAGE_TOOL_MODE_ROTATE_LABEL",@"Rotation")];
			[imageCropToolButton setHidden: YES];
            break;
        case 4:
            [imageView setCurrentToolMode: IKToolModeAnnotate];
			[imageToolModeLabel setStringValue: NSLocalizedString(@"IMAGE_TOOL_MODE_ANNOTATE_LABEL",@"Annotation")];
			[imageCropToolButton setHidden: YES];
            break;
    }
}

@end
