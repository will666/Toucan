//
//  MainController+Regex.m
//  Toucan
//
//  Created by will on 23/03/10.
//  Copyright 2010 ExoApps. All rights reserved.
//

#import "MainController+Regex.h"


@implementation MainController(Regex)

# pragma mark Constant Register
//#define IMAGES_REGEX @"/imgres\\x3Fimgurl=(?<imgurl>[^&>]*)[>&]{1}imgrefurl=(?<imgrefurl>[^&>]*)[>&]{1}usg=[^&>]*[>&]{1}h=(?<height>[^&>]*)[>&]{1}w=(?<width>[^&>]*)[>&]{1}sz=(?<sz>[^&>]*)[>&]{1}hl=(?<hl>[^&>]*)[>&]{1}start=(?<start>[^&>]*)[>&]{1}tbnid=(?<tbnid>[^&>]*)[>&]{1}tbnh=(?<tbnh>[^&>]*)[>&]{1}tbnw=(?<tbnw>[^&>]*)[>&]{1}prev=(?<prev>[^&>]*)[>&]{1}<img src=(?<tbnurl>[^ ]*)[ ]"
#define IMAGES_REGEX @"<a href=/imgres\\?imgurl=(?<imgurl>.*?)\x26imgrefurl=(?<imgrefurl>.*?)\x26usg=(?<usg>.*?)\x26h=(?<height>.*?)\x26w=(?<width>.*?)\x26sz=(?<sz>.*?)\x26hl=(?<hl>.*?)\x26start=(?<start>.*?)\x26tbnid=(?<tbnid>.*?)\x26tbnh=(?<tbnh>.*?)\x26tbnw=(?<tbnw>.*?)\x26prev=(?<prev>.*?)\x26itbs=(?<itbs>.*?)><img src=(?<tbnurl>.*?) width=(?<tbnw2>.*?) height=(?<tbnh2>.*?)></a>"

- (void)regexStuff:(NSString *)result
{
	// use the regex to parse the HTML response
	RKEnumerator * matchEnumerator = [result matchEnumeratorWithRegex: IMAGES_REGEX];
	
	if([theNum intValue] <= 20) self.imageObjects = [NSMutableArray array];
	
	//------------------------------------------------------ OGREKIT FRAMEWORK --------------------------------------------------------		
	//-------------------------------------------------------------------------------------------------------------------------------------------------		
	//		OGRegularExpression * regex = [OGRegularExpression regularExpressionWithString: IMAGES_REGEX];
	//		NSEnumerator * enumerator = [regex matchEnumeratorInString: result];
	//		
	//		OGRegularExpressionMatch * match = nil;
	//		
	//		while ((match = [enumerator nextObject]) != nil)
	//		{
	//			NSString * imageUrl = [match substringNamed: @"imgurl"];
	//			
	//			double w = [[match substringNamed: @"width"] doubleValue];
	//			double h = [[match substringNamed: @"height"] doubleValue];
	//			NSSize imageSize = NSMakeSize(w,h);
	//			
	//			NSString * imageSizeText = [NSString stringWithFormat: @"%@x%@", [match substringNamed: @"width"], [match substringNamed: @"height"]];
	//			
	//			NSString * tbnUrl = [match substringNamed: @"tbnurl"];
	//			
	//            double tbnw = [[match substringNamed: @"tbnw"] doubleValue];
	//			double tbnh = [[match substringNamed: @"tbnh"] doubleValue];
	//			NSSize tbnSize = NSMakeSize(tbnw,tbnh);
	//			
	//            MyImageObject * imgObj = [[MyImageObject alloc] init];
	//            imgObj.thumbnailUrl = tbnUrl;
	//            imgObj.imageUrl = imageUrl;
	//            imgObj.thumbnailSize = tbnSize;
	//            imgObj.imageSize = imageSize;
	//			imgObj.imageSizeText = imageSizeText;
	//            
	//            [self.imageObjects addObject: imgObj];
	//            [imgObj release];
	//		}
	//-------------------------------------------------------------------------------------------------------------------------------------------------
	
	// loop over all results
	while([matchEnumerator nextRanges] != NULL) 
	{
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
		
		double width = 0.0;
		double height = 0.0;
		
		// image
		NSString * imageUrl = [matchEnumerator stringWithReferenceFormat: @"${imgurl}"];
		NSString * imageRefUrl = [matchEnumerator stringWithReferenceFormat: @"${imgrefurl}"];
		
		DLog(@"%@",imageUrl);
		
		
		[matchEnumerator getCapturesWithReferences: @"${width:%lf}", &width, nil];
		[matchEnumerator getCapturesWithReferences: @"${height:%lf}", &height, nil];
		NSSize imageSize = NSMakeSize(width, height);
		
		NSString * imageSizeText = [NSString stringWithFormat: @"%@x%@", 
									[matchEnumerator stringWithReferenceFormat: @"${width}"], 
									[matchEnumerator stringWithReferenceFormat: @"${height}"]
									];
		
		// thumbnail
		NSString * tbnUrl = [matchEnumerator stringWithReferenceFormat: @"${tbnurl}"];
		[matchEnumerator getCapturesWithReferences: @"${tbnw:%lf}", &width, nil];
		[matchEnumerator getCapturesWithReferences: @"${tbnh:%lf}", &height, nil];
		NSSize tbnSize = NSMakeSize(width, height);
		
		MyImageObject * imgObj = [[MyImageObject alloc] init];
		imgObj.thumbnailUrl = tbnUrl;
		imgObj.imageUrl = imageUrl;
		imgObj.thumbnailSize = tbnSize;
		imgObj.imageSize = imageSize;
		imgObj.imageSizeText = imageSizeText;
		imgObj.imageRefUrl = imageRefUrl;
		
		[self.imageObjects addObject: imgObj];
		
		[imgObj release];
		
		[pool release];
	}
	
	[result release];
	
	if([theNum intValue] > 20)
	{
		[positionTextField setStringValue: [NSString stringWithFormat: @"%i images", [self.imageObjects count]]];
	}
	else
	{
		[positionTextField setStringValue:[NSString stringWithFormat: NSLocalizedString(@"POSITION_TEXT_FIELD_RESULTS",@"Image : %d à %d"), 
									   currentStartPosition + 1, 
									   currentStartPosition + [self.imageObjects count]
									   ]
	 ];
	}
	
	// reload datasource
	[imageBrowser reloadData];
}

@end
