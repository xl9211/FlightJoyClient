//
//  SearchConditionController.h
//  MyNav
//
//  Created by 王 攀 on 11-8-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SecondLevelViewController.h"
#import "Company.h"
#import "Airport.h"
#import "/usr/include/sqlite3.h"

#define kLabelTag			4096
#define kSearchConditionCompanyTag	1024
#define kSearchConditionFlightNoTag	512
#define kSearchConditionDateTag 2048

#define kSearchConditionCompanyRouteTag	256
#define kSearchConditionFromRouteTag	128
#define kSearchConditionToRouteTag	64
#define kSearchConditionDateRouteTag 32
#define kFilename		@"flights.sqlite3"

@protocol FlightAddDelegate;

@interface SearchConditionController : UIViewController 
<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	id <FlightAddDelegate> delegate;
	Company *searchConditionCompany;
    Airport *searchConditionTakeoffAirport;
    Airport *searchConditionArrivalAirport;
	NSString *searchConditionFlightNo;
	NSString *searchConditionDate;
	
	NSMutableDictionary *tempValues;
	UITextField *textFieldBeingEdited;
    IBOutlet UITableView *tableView;
    int m_selectedSegmentIndex;
    
    sqlite3	*database;
}
@property(nonatomic, assign) id <FlightAddDelegate> delegate;
@property (nonatomic, retain) Company *searchConditionCompany;
@property (nonatomic, retain) Airport *searchConditionTakeoffAirport;
@property (nonatomic, retain) Airport *searchConditionArrivalAirport;
@property (nonatomic, retain) NSString *searchConditionFlightNo;
@property (nonatomic, retain) NSString *searchConditionDate;

@property (nonatomic, retain) NSMutableDictionary *tempValues;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;
@property (nonatomic,retain) UITableView *tableView;

- (void)save;
- (void)cancel;

- (void)didFinish:sender;
- (IBAction)segmentControlDidChanged:(id)sender;
@end

@protocol FlightAddDelegate <NSObject>
// recipe == nil on cancel
- (void)searchConditionController:(SearchConditionController *)searchConditionController didAddRecipe:(int)recipe;

@end
