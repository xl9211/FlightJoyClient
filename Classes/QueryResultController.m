//
//  QueryResultController.m
//  MyNav
//
//  Created by 王 攀 on 11-11-4.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "QueryResultController.h"

@implementation QueryResultController

@synthesize delegate;
@synthesize saveButtonItem;
@synthesize saveAllButtonItem;
@synthesize queryType;

- (void)viewDidLoad {
    cacheTableName = @"searchedflights";
    [super viewDidLoad];
    MyNavAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *root = [delegate.navController.viewControllers objectAtIndex:0];
	self.delegate = root;
    saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关注" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
	saveAllButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关注全部" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.title = @"航班";
}

- (void)getSearchConditionController:(SearchConditionController *)lsearchConditionController{
    searchConditionController = lsearchConditionController;//这样可以用finalRemViewController调用viewOne中的属性.
}

- (void)requestFlightInfoFromServer {
    NSString *comanyAbbrev = self.searchConditionController.searchConditionCompany.abbrev;
    
    if (queryType == 0) {//航班号查询
        self.url = [[NSString alloc] initWithString:@"http://118.194.161.243:28888/queryFlightInfoByFlightNO"];
        self.post = [[NSString alloc] initWithFormat:@"flight_no=%@%@&schedule_takeoff_date=%@",
                comanyAbbrev,
                self.searchConditionController.searchConditionFlightNo,
                self.searchConditionController.searchConditionDate];
    } else if (queryType == 1) {//航段查询
        self.url = [[NSString alloc] initWithString:@"http://118.194.161.243:28888/queryFlightInfoByRoute"];
        if (comanyAbbrev == nil || [comanyAbbrev isEqualToString:@""]) {
            comanyAbbrev = @"all";
        }
        self.post = [[NSString alloc] initWithFormat:@"takeoff_airport=%@&arrival_airport=%@&schedule_takeoff_date=%@&company=%@",
                self.searchConditionController.searchConditionTakeoffAirport.shortname,
                self.searchConditionController.searchConditionArrivalAirport.shortname,
                self.searchConditionController.searchConditionDate,
                comanyAbbrev];
    } else if (queryType == 2) {//随机查询
        self.url = [[NSString alloc] initWithString:@"http://118.194.161.243:28888/queryFlightInfoByRandom"];
        self.post = [[NSString alloc] initWithString:@"lang=zh"];
    }
    
    [super requestFlightInfoFromServer];
}

- (void) startUpdateProcess {
	[super startUpdateProcess];
    NSString *content = @"搜索中...";
	[self refreshStatusLabelWithText:content];
	[content release];
}

- (void) stopUpdateProcess {
    [super stopUpdateProcess]; 
    
	int flightCount = [self.flightArray count];
	if (flightCount != 0) {
		statusLabelText = [[NSString alloc]initWithFormat:@"找到 %d 个航班", flightCount];
		if (flightCount == 1) {
			self.navigationItem.rightBarButtonItem = saveButtonItem;
		} else {
			self.navigationItem.rightBarButtonItem = saveAllButtonItem;
		}
	} else {
		statusLabelText = [[NSString alloc]initWithString:@"未找到直飞航线！"];
	}
    
	[self refreshStatusLabelWithText:statusLabelText];
}

#pragma mark -
#pragma mark View lifecycle
- (void)save {
	if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
    NSString *insertSelect = [[NSString alloc] initWithFormat:@"insert into followedflights select * from %@;", cacheTableName];
	char * errorMsg;
	if (sqlite3_exec (database, [insertSelect UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
	{
		NSAssert1(0, @"Error insertSelecting tables: %s", errorMsg);	
	}
    
    NSString *delete = [[NSString alloc] initWithFormat:@"delete from %@;", cacheTableName];
    if (sqlite3_exec (database, [delete UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
	{
		NSAssert1(0, @"Error deleting tables: %s", errorMsg);	
	}
    
	sqlite3_close(database);	
    [self.delegate searchConditionController:self didAddRecipe:nil];
}

- (void)addOrUpdateTableWithServerResponse:(NSString *)responseString {
    [super addOrUpdateTableWithServerResponse:responseString];
    //NSMutableArray *array = [[NSMutableArray alloc] init];
    NSError *error;
	SBJSON *json = [[SBJSON new] autorelease];
	NSArray *flightInfos = [json objectWithString:responseString error:&error];
    
    //需要增加如下准点率数据
    //"on_time"、"half_hour_late" 、"one_hour_late"、"more_than_one_hour_late" 、"cancel"
	
	if (flightInfos == nil) {
		NSLog([NSString stringWithFormat:@"JSON parsing failed: %@", [error localizedDescription]]);
	} else {		
        if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
            sqlite3_close(database);
            NSAssert(0, @"Failed to open database");
        }
        
		for (int i = 0; i < [flightInfos count]; i++) {
			NSMutableDictionary *flightInfo = [flightInfos objectAtIndex:i];
			//[array addObject:flightInfo];
            NSString *insertSQL = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (",cacheTableName];
            insertSQL = [insertSQL stringByAppendingString:@" takeoff_airport_entrance_exit,"];
            insertSQL = [insertSQL stringByAppendingString:@" takeoff_city,"];
            insertSQL = [insertSQL stringByAppendingString:@" actual_takeoff_time,"];
            insertSQL = [insertSQL stringByAppendingString:@" arrival_airport_entrance_exit,"];
            insertSQL = [insertSQL stringByAppendingString:@" takeoff_airport,"];
            
            insertSQL = [insertSQL stringByAppendingString:@" arrival_airport,"];
            insertSQL = [insertSQL stringByAppendingString:@" flight_no,"];
            insertSQL = [insertSQL stringByAppendingString:@" company,"];
            insertSQL = [insertSQL stringByAppendingString:@" schedule_takeoff_time,"];
            insertSQL = [insertSQL stringByAppendingString:@" arrival_airport_building,"];
            
            insertSQL = [insertSQL stringByAppendingString:@" estimate_takeoff_time,"];
            insertSQL = [insertSQL stringByAppendingString:@" flight_state,"];
            insertSQL = [insertSQL stringByAppendingString:@" flight_location,"];
            insertSQL = [insertSQL stringByAppendingString:@" mileage,"];
            insertSQL = [insertSQL stringByAppendingString:@" actual_arrival_time,"];
            insertSQL = [insertSQL stringByAppendingString:@" plane_model,"];
            insertSQL = [insertSQL stringByAppendingString:@" estimate_arrival_time,"];
            
            insertSQL = [insertSQL stringByAppendingString:@" schedule_arrival_time,"];
            insertSQL = [insertSQL stringByAppendingString:@" takeoff_airport_building,"];
            insertSQL = [insertSQL stringByAppendingString:@" arrival_city,"];
            insertSQL = [insertSQL stringByAppendingString:@" schedule_takeoff_date"];
            insertSQL = [insertSQL stringByAppendingString:@") VALUES ('%@','%@','%@','%@','%@','%@','%@', '%@','%@','%@','%@','%@', '%@','%@','%@','%@','%@', '%@','%@','%@','%@');"];
            
            NSString *update = [[NSString alloc] initWithFormat:
                                insertSQL,
                                [flightInfo objectForKey:@"takeoff_airport_entrance_exit"], 
                                [flightInfo objectForKey:@"takeoff_city"],
                                [flightInfo objectForKey:@"actual_takeoff_time"],
                                [flightInfo objectForKey:@"arrival_airport_entrance_exit"], 
                                [flightInfo objectForKey:@"takeoff_airport"],
                                
                                [flightInfo objectForKey:@"arrival_airport"], 
                                [flightInfo objectForKey:@"flight_no"],
                                [flightInfo objectForKey:@"company"],
                                [flightInfo objectForKey:@"schedule_takeoff_time"], 
                                [flightInfo objectForKey:@"arrival_airport_building"],
                                
                                [flightInfo objectForKey:@"estimate_takeoff_time"], 
                                [flightInfo objectForKey:@"flight_state"],
                                [flightInfo objectForKey:@"flight_location"],
                                [flightInfo objectForKey:@"mileage"],
                                [flightInfo objectForKey:@"actual_arrival_time"],
                                [flightInfo objectForKey:@"plane_model"], 
                                [flightInfo objectForKey:@"estimate_arrival_time"],
                                
                                [flightInfo objectForKey:@"schedule_arrival_time"], 
                                [flightInfo objectForKey:@"takeoff_airport_building"],
                                [flightInfo objectForKey:@"arrival_city"],
                                [flightInfo objectForKey:@"schedule_takeoff_date"]
                                ];
            char * errorMsg;
            NSLog(@"update:%@", update);
            if (sqlite3_exec (database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                NSAssert1(0, @"Error updating tables: %s", errorMsg);	
            }
		}
        sqlite3_close(database);	
	}
	//self.flightArray = array;
	//[array release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    //MyNavAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    //[delegate.navController pushViewController:currentNextController animated:YES];
    //[self.navigationController pushViewController:searchResultController animated:YES];

    [self.navigationController pushViewController:currentNextController animated:YES];
}
@end
