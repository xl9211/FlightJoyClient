//
//  SearchConditionCompanyController.h
//  MyNav
//
//  Created by 王 攀 on 11-9-7.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Company.h"
#import "/usr/include/sqlite3.h"
#define kFilename		@"flights.sqlite3"

@interface SearchConditionCompanyController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    IBOutlet	UITableView *tableView;
	IBOutlet	UISearchBar *search;
    
	NSMutableArray *companyListData;
	Company *searchConditionCompany;
	NSMutableData *responseData;
    
    double tableViewOriginHeight;
    BOOL keyboardWasShown;
    
    sqlite3	*database;
}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UISearchBar *search;

@property (nonatomic, retain) NSMutableArray *companyListData;
@property (nonatomic, retain) Company *searchConditionCompany;

@end
