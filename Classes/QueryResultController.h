//
//  QueryResultController.h
//  MyNav
//
//  Created by 王 攀 on 11-11-4.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ListViewController.h"
#import "RootViewController.h"
#import "JSON/JSON.h"
#import "QueryCustomCell.h"
#define kQueryTableViewRowHeight 47;

@interface QueryResultController : ListViewController {
    id <FlightAddDelegate> delegate;
    UIBarButtonItem *saveButtonItem;
	UIBarButtonItem *saveAllButtonItem;
    int queryType; //0-航班号搜索 1-航段搜索 2－随机搜索
}

@property(nonatomic, assign) id <FlightAddDelegate> delegate;
@property (nonatomic,retain) UIBarButtonItem *saveButtonItem;
@property (nonatomic,retain) UIBarButtonItem *saveAllButtonItem;
@property (nonatomic) int queryType;

- (void)addOrUpdateTableWithServerResponse:(NSString *)responseString;

@end
