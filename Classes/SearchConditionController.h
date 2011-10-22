//
//  SearchConditionController.h
//  MyNav
//
//  Created by 王 攀 on 11-8-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecondLevelViewController.h"
#import "Company.h"
#define kLabelTag			4096
#define kSearchConditionCompanyTag	1024
#define kSearchConditionFlightNoTag	512
#define kSearchConditionDateTag 2048

@protocol FlightAddDelegate;

@interface SearchConditionController : UIViewController 
<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	id <FlightAddDelegate> delegate;
	Company *searchConditionCompany;
	NSString *searchConditionFlightNo;
	NSString *searchConditionDate;
	
	NSMutableDictionary *tempValues;
	UITextField *textFieldBeingEdited;
    UITableView *tableView;
}
@property(nonatomic, assign) id <FlightAddDelegate> delegate;
@property (nonatomic, retain) Company *searchConditionCompany;
@property (nonatomic, retain) NSString *searchConditionFlightNo;
@property (nonatomic, retain) NSString *searchConditionDate;

@property (nonatomic, retain) NSMutableDictionary *tempValues;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;
@property (nonatomic,retain) UITableView *tableView;

- (void)save;
- (void)cancel;

- (void)didFinish:sender;
@end

@protocol FlightAddDelegate <NSObject>
// recipe == nil on cancel
- (void)searchConditionController:(SearchConditionController *)searchConditionController didAddRecipe:(int)recipe;

@end
