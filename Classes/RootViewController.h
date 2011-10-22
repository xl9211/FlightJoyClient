//
//  RootViewController.h
//  MyNav
//
//  Created by 王 攀 on 11-8-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchConditionController.h"
#import "MyNavAppDelegate.h"
#import "/usr/include/sqlite3.h"

#define kFilename		@"flights.sqlite3"
#define kTableViewRowHeight 66;

@interface RootViewController : UITableViewController
<UITableViewDelegate, UITableViewDataSource, FlightAddDelegate, UIAlertViewDelegate>{
	NSArray *controllers;
	NSMutableData *responseData;
	NSMutableArray  *flightArray;
	SearchConditionController *searchConditionController; // the camera custom overlay view
	UINavigationController *searchNavController; //test
	sqlite3	*database;
	NSArray *deleteToolbarItems;
	NSArray *refreshToolbarItems;
	
	UIActivityIndicatorView *updateProgressInd;
	SecondLevelViewController *currentNextController;
	NSString *statusLabelText;
}
@property (nonatomic, retain) NSArray *controllers;
@property (nonatomic,retain) NSMutableArray  *flightArray;
@property (nonatomic, retain) SearchConditionController *searchConditionController;
@property (nonatomic, retain) UINavigationController *searchNavController;
@property (nonatomic,retain) NSArray *deleteToolbarItems;
@property (nonatomic,retain) NSArray *refreshToolbarItems;

@property (nonatomic,retain) UIActivityIndicatorView *updateProgressInd;
@property (nonatomic,retain) SecondLevelViewController *currentNextController;
@property (nonatomic,retain) NSString *statusLabelText;

-(IBAction)toggleEdit:(id)sender;
- (IBAction)switchToSearchCondition:(id)sender;
- (NSString *)dataFilePath;

@end
