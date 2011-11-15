//
//  DisclosureButtonTitleView.h
//  MyNav
//
//  Created by 王 攀 on 11-11-15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DisclosureButtonTitleView : UIView {
    IBOutlet UILabel *titleLabel;
    IBOutlet UIActivityIndicatorView *updateProgressInd;
    IBOutlet UILabel *updateStatusLabel;
}
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIActivityIndicatorView *updateProgressInd;
@property (nonatomic, retain) UILabel *updateStatusLabel;

@end
