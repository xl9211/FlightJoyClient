//
//  SecondLevelViewController.h
//  MyNav
//
//  Created by 王 攀 on 11-8-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchConditionController.h"
#import "MyNavAppDelegate.h"
#import "/usr/include/sqlite3.h"
#import "WBShareKit.h"
#import "MobClick.h"

#define kFilename		@"flights.sqlite3"
#define kTableViewRowHeight 66;

@interface ListViewController : UITableViewController
<UITableViewDelegate, UITableViewDataSource, FlightAddDelegate, UIAlertViewDelegate> {
	UIImage *rowImage;
    
    NSArray *controllers;
	NSMutableData *responseData;
	NSMutableArray  *flightArray;
    NSArray  *requestRecordIdArray;
	SearchConditionController *searchConditionController; // the camera custom overlay view
	UINavigationController *searchNavController; //test
	sqlite3	*database;
	NSArray *deleteToolbarItems;
	NSMutableArray *refreshToolbarItems;
	
	UIActivityIndicatorView *updateProgressInd;
	UITableViewController *currentNextController;
	NSString *statusLabelText;
}
@property (nonatomic, retain) UIImage *rowImage;

@property (nonatomic, retain) NSArray *controllers;
@property (nonatomic,retain) NSMutableArray  *flightArray;
@property (nonatomic,retain) NSArray  *requestRecordIdArray;
@property (nonatomic, retain) SearchConditionController *searchConditionController;
@property (nonatomic, retain) UINavigationController *searchNavController;
@property (nonatomic,retain) NSArray *deleteToolbarItems;
@property (nonatomic,retain) NSMutableArray *refreshToolbarItems;

@property (nonatomic,retain) UIActivityIndicatorView *updateProgressInd;
@property (nonatomic,retain) UITableViewController *currentNextController;
@property (nonatomic,retain) NSString *statusLabelText;

- (void)changeListMode;
- (IBAction)toggleEdit:(id)sender;
- (IBAction)switchToSearchCondition:(id)sender;
- (void) stopUpdateProcess;
- (void)loadToolbarItems;
- (NSString *)dataFilePath;
@end
