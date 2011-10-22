//
//  DisclosureButtonController.h
//  MyNav
//
//  Created by 王 攀 on 11-8-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DisclosureDetailController : UIViewController {
	IBOutlet UILabel *label;
	NSString *message;
}
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) NSString *message;

@end
