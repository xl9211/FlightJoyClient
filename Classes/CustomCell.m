//
//  CustomCell.m
//  MyNav
//
//  Created by 王 攀 on 11-8-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomCell.h"


@implementation CustomCell
@synthesize companyFlagView;
@synthesize nameLabel;
@synthesize	takeoffDateLabel;
@synthesize flightNOLabel;
@synthesize takeoffTimeLabel;
@synthesize landTimeLabel;

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
