//
//  SearchConditionAirportController.h
//  MyNav
//
//  Created by 王 攀 on 11-10-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSON.h"
#import "Airport.h"
#import "RootViewController.h"
#import "/usr/include/sqlite3.h"
#define kFilename		@"flights.sqlite3"

@interface SearchConditionAirportController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
	IBOutlet	UITableView *tableView;
	IBOutlet	UISearchBar *search;
    sqlite3	*database;
	NSMutableArray		 *airportArray;
    NSMutableData *responseData;
    Airport *searchConditionAirport;
    
    double tableViewOriginHeight;
    BOOL keyboardWasShown;
}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UISearchBar *search;
@property (nonatomic, retain) NSMutableArray *airportArray;
@property (nonatomic, retain) Airport *searchConditionAirport;

- (void)resetSearch;
- (void)handleSearchForTerm:(NSString *)searchTerm;

@end
