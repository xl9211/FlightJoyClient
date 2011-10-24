//
//  SearchConditionAirportController.h
//  MyNav
//
//  Created by 王 攀 on 11-10-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchConditionAirportController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
	IBOutlet	UITableView *table;
	IBOutlet	UISearchBar *search;
	NSDictionary *allNames;
	NSMutableDictionary *names;
	NSMutableArray		 *keys;
    
}
@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) UISearchBar *search;
@property (nonatomic, retain) NSDictionary *allNames;
@property (nonatomic, retain) NSMutableDictionary *names;
@property (nonatomic, retain) NSMutableArray *keys;
- (void)resetSearch;
- (void)handleSearchForTerm:(NSString *)searchTerm;

@end
