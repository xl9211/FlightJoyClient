//
//  SearchConditionCompanyController.h
//  MyNav
//
//  Created by 王 攀 on 11-9-7.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Company.h"

@interface SearchConditionCompanyController : UITableViewController {
	NSArray *companyListData;
	Company *searchConditionCompany;
	NSMutableData *responseData;
}
@property (nonatomic, retain) NSArray *companyListData;
@property (nonatomic, retain) Company *searchConditionCompany;

@end
