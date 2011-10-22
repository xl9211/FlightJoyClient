//
//  FlightDetailCustomCell.h
//  MyNav
//
//  Created by 王 攀 on 11-8-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FlightDetailCustomCell : UITableViewCell {
	IBOutlet UILabel *statusLabel;
	IBOutlet UILabel *flightBuildingLabel;
	IBOutlet UILabel *timePointLabel;
	IBOutlet UILabel *buildingEntranceLabel;
}
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UILabel *flightBuildingLabel;
@property (nonatomic, retain) UILabel *timePointLabel;
@property (nonatomic, retain) UILabel *buildingEntranceLabel;

@end
