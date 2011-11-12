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
#import "MobClick.h"

#define kFilename		@"flights.sqlite3"
#define kTableViewRowHeight 74;

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
    //variable properties
    NSString *cacheTableName;
    NSString *url;
    NSString *post;
    
    NSTimer *timer;
    
    NSMutableDictionary *dicAirportFullNameToShort;
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

//variable properties
@property (nonatomic,retain) NSString *cacheTableName;
@property (nonatomic,retain) NSString *url;
@property (nonatomic,retain) NSString *post;

@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,retain) NSMutableDictionary *dicAirportFullNameToShort;

- (void)changeListMode;
- (IBAction)toggleEdit:(id)sender;
- (IBAction)switchToSearchCondition:(id)sender;
- (void) startUpdateProcess;
- (void) stopUpdateProcess;
- (void)loadToolbarItems;
- (void)requestFlightInfoFromServer;
- (void)addOrUpdateTableWithServerResponse:(NSString*)responseString;
- (NSString *) generateQueryStringUtil: (int)queryOrAnnounce;

- (NSString *)dataFilePath;
@end
