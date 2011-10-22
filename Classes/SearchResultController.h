//
//  SearchResultController.h
//  MyNav
//
//  Created by 王 攀 on 11-9-8.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchConditionController.h"
#import "/usr/include/sqlite3.h"

#define kFilename		@"flights.sqlite3"
#define kTableViewRowHeight 66;


@interface SearchResultController : UITableViewController {
	id <FlightAddDelegate> delegate;
	NSMutableData *responseData;
	NSMutableArray  *flightArray;
	SearchConditionController *searchConditionController;
	sqlite3	*database;
	UIActivityIndicatorView *updateProgressInd;
	UIBarButtonItem *saveButtonItem;
	UIBarButtonItem *saveAllButtonItem;
}
@property(nonatomic, assign) id <FlightAddDelegate> delegate;
@property (nonatomic,retain) NSMutableArray  *flightArray;
@property (nonatomic,retain) SearchConditionController *searchConditionController;
@property (nonatomic,retain) UIActivityIndicatorView *updateProgressInd;
@property (nonatomic,retain) UIBarButtonItem *saveButtonItem;
@property (nonatomic,retain) UIBarButtonItem *saveAllButtonItem;

- (void)getSearchConditionController:(SearchConditionController *)lsearchConditionController;
- (NSString *)dataFilePath;
@end
