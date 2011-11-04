//
//  QueryResultController.h
//  MyNav
//
//  Created by 王 攀 on 11-11-4.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ListViewController.h"
#import "RootViewController.h"

@interface QueryResultController : ListViewController {
    id <FlightAddDelegate> delegate;
    UIBarButtonItem *saveButtonItem;
	UIBarButtonItem *saveAllButtonItem;
}

@property(nonatomic, assign) id <FlightAddDelegate> delegate;
@property (nonatomic,retain) UIBarButtonItem *saveButtonItem;
@property (nonatomic,retain) UIBarButtonItem *saveAllButtonItem;

@end
