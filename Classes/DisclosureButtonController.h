//
//  DisclosureButtonController.h
//  MyNav
//
//  Created by 王 攀 on 11-8-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecondLevelViewController.h"
#import "FlightRouteController.h"
#import "/usr/include/sqlite3.h"
#import "SVGeocoder.h"
#import <MapKit/MapKit.h> 
#define kFilename		@"flights.sqlite3"

@class DisclosureDetailController;

@interface DisclosureButtonController : SecondLevelViewController 
<UITableViewDelegate, UITableViewDataSource, SVGeocoderDelegate> {
	NSMutableArray *list;
	NSMutableArray *cityList;
	sqlite3	*database;
	NSDictionary *flightInfo;
	DisclosureDetailController *childController;

	UIActivityIndicatorView *updateProgressInd;
}
@property (nonatomic, retain) NSMutableArray *list;
@property (nonatomic, retain) NSMutableArray *cityList;
@property (nonatomic, retain) NSDictionary *flightInfo;
@property (nonatomic,retain) UIActivityIndicatorView *updateProgressInd;

@end
