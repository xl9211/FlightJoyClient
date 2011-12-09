//
//  CLMAlertView.h
//  UIALertView
//
//  Created by kindy_imac on 11-10-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CLMAlertView : UIAlertView 
{
	//uiimage
	UIImage *bgImage;
	UITextAlignment detailTextlAligment;

}

@property (nonatomic, retain) UIImage *bgImage;
@property (nonatomic, assign) UITextAlignment detailTextlAligment;
@end
