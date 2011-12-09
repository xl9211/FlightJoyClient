//
//  CLMAlertView.m
//  UIALertView
//
//  Created by kindy_imac on 11-10-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CLMAlertView.h"


@implementation CLMAlertView
@synthesize bgImage, detailTextlAligment;

-(void)show
{
	[super show];
	
	for(UIView *label in [self subviews])
	{
		NSLog(@"alertsubview = %@", label);
		
		
		 if([label isKindOfClass:[UIImageView class]])
		 {
		
			 if(bgImage)
			 {
				 [(UIImageView *)label setImage:[bgImage stretchableImageWithLeftCapWidth:bgImage.size.width / 2.0 topCapHeight:bgImage.size.height / 2.0]];
			 }
			 
		 }
		 
		//UILabel *label = [[alert subviews] objectAtIndex:1];
		if([label isKindOfClass:[UILabel class]] && label.frame.size.height > 40)
		{
			((UILabel *)label).textAlignment = detailTextlAligment;
			break;
			
		}
		//NSLog(label.text);
	}
}

-(void)dealloc
{
	[bgImage release];
	[super dealloc];
}
@end
