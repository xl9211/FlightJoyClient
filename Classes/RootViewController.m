    //
//  RootViewController.m
//  MyNav
//
//  Created by 王 攀 on 11-8-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController
- (void)viewDidLoad {
    cacheTableName = @"followedflights";
	[super viewDidLoad];
}
- (void)announceAddFollowedFlightsToServer {
    //加载机场代码表进入数据字典
    [self loadAirportDictionary];
    NSString *announceAddStringValue = [self generateAnnounceAddStringValue];
    if ([announceAddStringValue isEqualToString:@"[]"]) {
        return;
    }
    self.url = [[NSString alloc] initWithString:@"http://fd.tourbox.me/addFollowedFlightInfo"];
    self.post = [[NSString alloc] initWithFormat:@"query_string=%@&device_token=%@", 
                 announceAddStringValue,
                 [[MyNavAppDelegate sharedAppDelegate] getDeviceToken]];
    [super requestFlightInfoFromServer];
}
-(void)announceDeleteFollowedFlightsToServer:(NSArray *)idArrayToDelete {
    //加载机场代码表进入数据字典
    [self loadAirportDictionary];
    NSString *announceDeleteStringValue = [self generateAnnounceDeleteStringValue:idArrayToDelete];
    if ([announceDeleteStringValue isEqualToString:@"[]"]) {
        return;
    }
    self.url = [[NSString alloc] initWithString:@"http://fd.tourbox.me/deleteFollowedFlightInfo"];
    self.post = [[NSString alloc] initWithFormat:@"query_string=%@&device_token=%@", 
                 announceDeleteStringValue,
                 [[MyNavAppDelegate sharedAppDelegate] getDeviceToken]];
    [super requestFlightInfoFromServer];
}
- (void)requestFlightInfoFromServer {
    //加载机场代码表进入数据字典
    [self loadAirportDictionary];
    NSString *queryStringValue = [self generateQueryStringValue];
    if ([queryStringValue isEqualToString:@"[]"]) {
        return;
    }
    self.url = [[NSString alloc] initWithString:@"http://fd.tourbox.me/updateFollowedFlightInfo"];
    self.post = [[NSString alloc] initWithFormat:@"query_string=%@", queryStringValue];
    [super requestFlightInfoFromServer];
}
- (void) stopUpdateProcess {
    [super stopUpdateProcessDisplay];     
}
- (void)loadFlightInfoFromTable{
    [super loadFlightInfoFromTable];
    if (self.flightArray != nil && [self.flightArray count] > 0) {
        //设置编辑模式
        self.navigationItem.leftBarButtonItem = enterEditItem;
    }
}

- (void)showInfo {
    NSLog(@"showInfo...");
}

- (void)loadToolbarItems {
    [super loadToolbarItems];
    /*UIBarButtonItem *feedbackImageButton = 
    [[UIBarButtonItem alloc] initWithTitle:@"反馈"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(umengFeedback)];
     */ 
    UIButton* infoButton = [UIButton buttonWithType: UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(umengFeedback) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] 
									  initWithCustomView:infoButton];
    [self.refreshToolbarItems addObject:infoBarButton];
}

- (void)addOrUpdateTableWithServerResponse:(NSString *)responseString {
    [super addOrUpdateTableWithServerResponse:responseString];
    NSError *error;
	SBJSON *json = [[SBJSON new] autorelease];
	NSArray *luckyNumbers = [json objectWithString:responseString error:&error];
	//[responseString release];	
	
	if (luckyNumbers == nil) {
		NSLog([NSString stringWithFormat:@"JSON parsing failed: %@", [error localizedDescription]]);
	} else {	
		for (int i = 0; i < [luckyNumbers count]; i++) {
            NSString *recordId = [self.requestRecordIdArray objectAtIndex:i];
            NSLog(@"recordId: %@", recordId);

			NSMutableDictionary *flightInfo = [luckyNumbers objectAtIndex:i];
            [self printFlightInfo:flightInfo];
			if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
				sqlite3_close(database);
				NSAssert(0, @"Failed to open database");
			}
            
			sqlite3_stmt *stmtUpdate= nil; 
			
			char *strUpdSQL = "UPDATE followedflights SET flight_state = ?, flight_location = ?, schedule_takeoff_time = ?, estimate_takeoff_time = ?, actual_takeoff_time = ?, schedule_arrival_time = ?, estimate_arrival_time = ?, actual_arrival_time = ? WHERE id = ?"; 
			
			if (sqlite3_prepare_v2(database, strUpdSQL, -1, &stmtUpdate, NULL) != SQLITE_OK) { 
				NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database)); 
			}
			
			int fieldcounter = 1;
            
			sqlite3_bind_text(stmtUpdate, fieldcounter++, [[flightInfo objectForKey:@"flight_state"] UTF8String], -1, SQLITE_TRANSIENT); 
			sqlite3_bind_text(stmtUpdate, fieldcounter++, [[flightInfo objectForKey:@"flight_location"] UTF8String], -1, SQLITE_TRANSIENT); 
			sqlite3_bind_text(stmtUpdate, fieldcounter++, [[flightInfo objectForKey:@"schedule_takeoff_time"] UTF8String], -1, SQLITE_TRANSIENT); 
			sqlite3_bind_text(stmtUpdate, fieldcounter++, [[flightInfo objectForKey:@"estimate_takeoff_time"] UTF8String], -1, SQLITE_TRANSIENT); 
			sqlite3_bind_text(stmtUpdate, fieldcounter++, [[flightInfo objectForKey:@"actual_takeoff_time"] UTF8String], -1, SQLITE_TRANSIENT); 
			sqlite3_bind_text(stmtUpdate, fieldcounter++, [[flightInfo objectForKey:@"schedule_arrival_time"] UTF8String], -1, SQLITE_TRANSIENT); 
			sqlite3_bind_text(stmtUpdate, fieldcounter++, [[flightInfo objectForKey:@"estimate_arrival_time"] UTF8String], -1, SQLITE_TRANSIENT); 
			sqlite3_bind_text(stmtUpdate, fieldcounter++, [[flightInfo objectForKey:@"actual_arrival_time"] UTF8String], -1, SQLITE_TRANSIENT); 
			//query fields:
			//id
            sqlite3_bind_int(stmtUpdate, fieldcounter++, [recordId intValue]);
            
			if (sqlite3_step(stmtUpdate) != SQLITE_DONE) { 
				NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database)); 
            }
            
			sqlite3_reset(stmtUpdate); 
            sqlite3_close(database);
		}
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [MobClick event:@"view_route" label:@"进入详情页"];
    
    MyNavAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSLog(@"...didSelectRowAtIndexPath");
	[delegate.navController pushViewController:currentNextController animated:YES];
}
@end