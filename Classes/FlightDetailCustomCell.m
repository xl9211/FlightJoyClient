//
//  FlightDetailCustomCell.m
//  MyNav
//
//  Created by 王 攀 on 11-8-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlightDetailCustomCell.h"

@implementation FlightDetailCustomCell
@synthesize statusLabel;
@synthesize flightBuildingLabel;
@synthesize timePointLabel;
@synthesize buildingEntranceLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}


@end
