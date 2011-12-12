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
    
    UILabel *ltitle = [[UILabel alloc]initWithFrame:CGRectMake(0.0 , 11.0f, 160.0f, 21.0f)];
    [ltitle setText:@"飞趣航班助理"];    
    [ltitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:22]];
	[ltitle setBackgroundColor:[UIColor clearColor]];
	[ltitle setTextColor:[UIColor whiteColor]];
	[ltitle setTextAlignment:UITextAlignmentCenter];
    
    self.navigationItem.titleView = ltitle;
    
}
- (void)announceAddFollowedFlightsToServer {
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

- (void)rootViewController:(InfoViewController *)infoViewController doneSetInfo:(int)recipe{
    DLog(@"searchConditionController didAddRecipe");
    [self dismissModalViewControllerAnimated:YES];
}

- (void)showInfo {
    DLog(@"showInfo...");
    InfoViewController *infoViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
    infoViewController.title = @"软件信息";	
    infoViewController.delegate = self;

	// Create the navigation controller and present it modally.
	UINavigationController *navigationController = [[UINavigationController alloc]
													initWithRootViewController:infoViewController];
	[navigationController setToolbarHidden:YES];    
    UIColor *backgroundColor = [UIColor blackColor];
	[navigationController.navigationBar setTintColor:backgroundColor];
    
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

	[self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];
	[infoViewController release];
}

- (void)loadToolbarItems {
    [super loadToolbarItems];
    
    UIButton* infoButton = [UIButton buttonWithType: UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] 
									  initWithCustomView:infoButton];
    [self.refreshToolbarItems addObject:infoBarButton];
}

- (void)addOrUpdateTableWithServerResponse:(NSString *)responseString {
    [super addOrUpdateTableWithServerResponse:responseString];
    //NSError *error;
	//SBJSON *json = [[SBJSON new] autorelease];
	//NSArray *luckyNumbers = [json objectWithString:responseString error:&error];
    NSArray *luckyNumbers = [responseString JSONValue]; 

	//[responseString release];	
	
	if (luckyNumbers == nil) {
		//DLog([NSString stringWithFormat:@"JSON parsing failed: %@", [error localizedDescription]]);
	} else {	
		for (int i = 0; i < [luckyNumbers count]; i++) {
            NSString *recordId = [self.requestRecordIdArray objectAtIndex:i];
            DLog(@"recordId: %@", recordId);

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
-(void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    [MobClick event:@"delete" label:@"单条"];
	NSUInteger row = [indexPath row];
	NSDictionary *flightInfo = [self.flightArray objectAtIndex:row];
	NSString *recordId = [flightInfo objectForKey:@"recordId"];
    
    //是时候 调用告知服务器当前用户删除了哪些航班 啦！
    NSArray *idArrayToDelete = [[NSArray alloc] initWithObjects: recordId, nil]; 
    [self announceDeleteFollowedFlightsToServer:idArrayToDelete];
    
	DLog(@"recordId:%@", recordId);
    NSString *delete = [[NSString alloc] initWithFormat:@"DELETE FROM followedflights where id = %@;", recordId];
	char * errorMsg;
	
	if (sqlite3_exec (database, [delete UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
	{
		NSAssert1(0, @"Error deleting tables: %s", errorMsg);	
	} else {
		[self.flightArray removeObjectAtIndex:row];
		[self.controllers removeObjectAtIndex:row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
    
	sqlite3_close(database);	
    DLog(@"delete...");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [MobClick event:@"view_route" label:@"进入详情页"];
    
    MyNavAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	DLog(@"...didSelectRowAtIndexPath");
	[delegate.navController pushViewController:currentNextController animated:YES];
}
@end
