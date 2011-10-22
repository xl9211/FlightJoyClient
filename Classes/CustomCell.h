//
//  CustomCell.h
//  MyNav
//
//  Created by 王 攀 on 11-8-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomCell : UITableViewCell {
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *takeoffDateLabel;
	IBOutlet UILabel *flightNOLabel;
	IBOutlet UILabel *takeoffTimeLabel;
	IBOutlet UILabel *landTimeLabel;
}
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *takeoffDateLabel;
@property (nonatomic, retain) UILabel *flightNOLabel;
@property (nonatomic, retain) UILabel *takeoffTimeLabel;
@property (nonatomic, retain) UILabel *landTimeLabel;
@end
