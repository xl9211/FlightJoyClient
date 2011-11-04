    //
//  RootViewController.m
//  MyNav
//
//  Created by 王 攀 on 11-8-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "SecondLevelViewController.h"
#import "MyNavAppDelegate.h"
#import "DisclosureButtonController.h"
#import "CustomCell.h"
#import "JSON/JSON.h"

@implementation RootViewController
@synthesize controllers;
@synthesize requestRecordIdArray;
@synthesize flightArray;
@synthesize searchConditionController;
@synthesize searchNavController;
@synthesize deleteToolbarItems;
@synthesize refreshToolbarItems;
@synthesize updateProgressInd;
@synthesize currentNextController;
@synthesize statusLabelText;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/
#pragma mark -
#pragma mark 模式切换相关方法
-(IBAction)toggleEdit:(id)sender
{
	[self changeListMode];
}

- (void)changeListMode {
	[self.navigationController setToolbarHidden:NO animated:NO];  
	self.navigationController.toolbar.barStyle = UIBarStyleBlack;
	
	if (!self.tableView.editing) {
		self.navigationItem.leftBarButtonItem.title = @"完成";
		self.navigationItem.leftBarButtonItem.style = UIBarButtonItemStyleDone;
		[self setToolbarItems: self.deleteToolbarItems animated:YES]; 
	} else {
		self.navigationItem.leftBarButtonItem.title = @"编辑";
		self.navigationItem.leftBarButtonItem.style = UIBarButtonItemStyleBordered;
		[self setToolbarItems: self.refreshToolbarItems animated:YES]; 
	}
	
	[self.tableView setEditing:!self.tableView.editing animated:YES];	
}

#pragma mark -
#pragma mark 删除相关方法
- (void)deleteLandedFlights {
	NSLog(@"deleteLandedFlights");
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
		NSString *delete = [[NSString alloc] initWithString:@"DELETE FROM followedflights;"];
		char * errorMsg;
		
		if (sqlite3_exec (database, [delete UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
		{
			NSAssert1(0, @"Error deleting tables: %s", errorMsg);	
		}
		sqlite3_close(database);
		[self changeListMode];
		
		self.controllers = [[NSMutableArray alloc] init];
		self.flightArray = [[NSMutableArray alloc] init];
		[self.tableView reloadData];
    }
}

- (void)deleteAllFlights {
	UIAlertView *alert = nil;
	alert = [UIAlertView alloc];
	[alert initWithTitle:@"删除全部航班"
				 message:@"您确认要删除航班列表中的全部航班吗?"
				delegate:self
	   cancelButtonTitle:@"取消"
	   otherButtonTitles:@"删除", nil];
	[alert show];
	[alert release];
	
	NSLog(@"deleteAllFlights");	
		
	//[self.controllers removeObjectAtIndex:row];
	//[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark -
#pragma mark 生命周期相关方法
/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[self createFollowedFlightTable];
	[self loadFlightInfoFromTable];
	[self loadFlightInfoFromServer];
	UIColor *backgroundColor = [UIColor colorWithRed:0 green:0.2f blue:0.55f alpha:1];
	[self.navigationController.navigationBar setTintColor:backgroundColor];
	[self.navigationController.toolbar setTintColor:backgroundColor]; 
    
	[self loadToolbarItems];
	[self setToolbarItems: self.refreshToolbarItems animated:YES]; 
	
    /*
     NSTimer *timer;
     timer = [NSTimer scheduledTimerWithTimeInterval: 1
     target: self
     selector: @selector(handleTimer:)
     userInfo: nil
     repeats: YES];
     */
	self.title = @"航班列表";
	self.tableView.backgroundColor = [UIColor clearColor];
	//[self.tableView setSeparatorColor:[UIColor clearColor]];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	self.flightArray = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[controllers release];
	[self.flightArray release];
	[responseData release];
	[self.currentNextController release];
	[self.statusLabelText release];
    [super dealloc];
}

#pragma mark -
#pragma mark 工具类方法
- (void)umengFeedback {
    [MobClick showFeedback:self];
}

- (NSString *)dataFilePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSLog(documentsDirectory);
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}
- (void)printFlightInfo:(NSMutableDictionary *)flightInfo {
	//flightInfo set
	NSLog(@"printFlightInfo...");
	NSLog(@"\"company\" : \"%@\"", [flightInfo objectForKey:@"company"]);
	NSLog(@"\"flight_no\" : \"%@\"", [flightInfo objectForKey:@"flight_no"]);
	NSLog(@"\"flight_state\" : \"%@\"", [flightInfo objectForKey:@"flight_state"]);
	NSLog(@"\"flight_location\" : \"%@\"", [flightInfo objectForKey:@"flight_location"]);
	NSLog(@"\"mileage\" : \"%@\"", [flightInfo objectForKey:@"mileage"]);
	NSLog(@"\"plane_model\" : \"%@\"", [flightInfo objectForKey:@"plane_model"]);
	NSLog(@"\"schedule_takeoff_date\" : \"%@\"", [flightInfo objectForKey:@"schedule_takeoff_date"]);
	
	NSLog(@"\"takeoff_city\" : \"%@\"", [flightInfo objectForKey:@"takeoff_city"]);
	NSLog(@"\"takeoff_airport\" : \"%@\"", [flightInfo objectForKey:@"takeoff_airport"]);
	NSLog(@"\"takeoff_airport_building\" : \"%@\"", [flightInfo objectForKey:@"takeoff_airport_building"]);
	NSLog(@"\"takeoff_airport_entrance_exit\" : \"%@\"", [flightInfo objectForKey:@"takeoff_airport_entrance_exit"]);
	NSLog(@"\"schedule_takeoff_time\" : \"%@\"", [flightInfo objectForKey:@"schedule_takeoff_time"]);
	NSLog(@"\"estimate_takeoff_time\" : \"%@\"", [flightInfo objectForKey:@"estimate_takeoff_time"]);
	NSLog(@"\"actual_takeoff_time\" : \"%@\"", [flightInfo objectForKey:@"actual_takeoff_time"]);
	//NSLog(@"\"display_takeoff_time\" : \"%@\"", [flightInfo objectForKey:@"display_takeoff_time"]);
	
	NSLog(@"\"arrival_city\" : \"%@\"", [flightInfo objectForKey:@"arrival_city"]);
	NSLog(@"\"arrival_airport\" : \"%@\"", [flightInfo objectForKey:@"arrival_airport"]);
	NSLog(@"\"arrival_airport_building\" : \"%@\"", [flightInfo objectForKey:@"arrival_airport_building"]);
	NSLog(@"\"arrival_airport_entrance_exit\" : \"%@\"", [flightInfo objectForKey:@"arrival_airport_entrance_exit"]);
	NSLog(@"\"schedule_arrival_time\" : \"%@\"", [flightInfo objectForKey:@"schedule_arrival_time"]);
	NSLog(@"\"estimate_arrival_time\" : \"%@\"", [flightInfo objectForKey:@"estimate_arrival_time"]);
	NSLog(@"\"actual_arrival_time\" : \"%@\"", [flightInfo objectForKey:@"actual_arrival_time"]);
	//NSLog(@"\"display_arrival_time\" : \"%@\"", [flightInfo objectForKey:@"display_arrival_time"]);
	NSLog(@"...printFlightInfo");
}


#pragma mark -
#pragma mark 网络请求响应相关方法
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//label.text = [NSString stringWithFormat:@"Connection failed: %@", [error description]];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"connectionDidFinishLoading...");
	
	//设置编辑模式
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
								   initWithTitle:@"编辑" 
								   style:UIBarButtonItemStyleBordered 
								   target:self 
								   action:@selector(toggleEdit:)];
	self.navigationItem.leftBarButtonItem = editButton;
	[editButton release];
	[connection release];
    
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	NSLog(responseString);
	//[responseData release];
	
	NSError *error;
	SBJSON *json = [[SBJSON new] autorelease];
	NSArray *luckyNumbers = [json objectWithString:responseString error:&error];
	//[responseString release];	
	
	if (luckyNumbers == nil) {
		NSLog([NSString stringWithFormat:@"JSON parsing failed: %@", [error localizedDescription]]);
	} else {	
		//1.使用“服务器数据”更新“数据库数据”
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
			
			int fieldcounter = 1;//weird counter start
			//update fields:
			//schedule_takeoff_time estimate_takeoff_time actual_takeoff_time
			//schedule_arrival_time estimate_arrival_time actual_arrival_time
            
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
        
		//2.读取“数据库数据”，转化为“表格展示数据”并显示
		[self loadFlightInfoFromTable];
	}
	[self stopUpdateProcess];
}
//HTTP Response - end

#pragma mark -
#pragma mark 业务相关的工具方法
- (void)convertToDisplayFlightInfo:(NSMutableDictionary *)flightInfo {
	NSDateFormatter *dateTimeFormatter=[[NSDateFormatter alloc] init];
	[dateTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
	
	//首先默认为当前日期
	NSDate *curDate = [NSDate date];//获取当前日期
	NSDate *nextDate = [curDate dateByAddingTimeInterval:24*60*60];
	NSDateFormatter *dateFormatter = [[ NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];//这里去掉 具体时间 保留日期
	NSString * curDateString = [dateFormatter stringFromDate:curDate];
	NSLog(@"%@",curDateString);
	
	NSString *scheduleTakeoffDate = [flightInfo objectForKey:@"schedule_takeoff_date"];
	//[self insertFollowedFlightIntoTable:flightInfo];
	
	NSString *scheduleTakeoffTime = [flightInfo objectForKey:@"schedule_takeoff_time"];
	NSString *actualTakeoffTime = [flightInfo objectForKey:@"actual_takeoff_time"];
	NSString *estimateTakeoffTime = [flightInfo objectForKey:@"estimate_takeoff_time"];
	
	NSString *scheduleArrivalTime = [flightInfo objectForKey:@"schedule_arrival_time"];
	NSString *actualArrivalTime = [flightInfo objectForKey:@"actual_arrival_time"];
	NSString *estimateArrivalTime = [flightInfo objectForKey:@"estimate_arrival_time"];	
	
	NSDateFormatter *timeFormatter=[[NSDateFormatter alloc] init];
	[timeFormatter setDateFormat:@"HH:mm"];
	//计算其他五个时间对应的日期：假设实际提前延误、预计提前延误不超过12小时，航班飞行时间不超过10小时 - [开始]
	//[1]
	NSString *scheduleArrivalDate = [[NSString alloc] initWithString:scheduleTakeoffDate];
	NSDate *scheduleArrivalD=[timeFormatter dateFromString:scheduleArrivalTime];
	NSDate *scheduleTakeoffD=[timeFormatter dateFromString:scheduleTakeoffTime];
	int a = ([scheduleArrivalD timeIntervalSince1970]*1 - [scheduleTakeoffD timeIntervalSince1970]*1)/60;
	if (a < 0) {
		scheduleArrivalDate = [dateFormatter stringFromDate:nextDate];
	}
	//[2]
	NSString *actualTakeoffDate = [[NSString alloc] initWithString:scheduleTakeoffDate];
	NSDate *actualTakeoffD=[timeFormatter dateFromString:actualTakeoffTime];
	a = ([actualTakeoffD timeIntervalSince1970]*1 - [scheduleTakeoffD timeIntervalSince1970]*1)/60;
	if (a < -12*60) {
		actualTakeoffDate = [dateFormatter stringFromDate:nextDate];
	}
	//[3]
	NSString *estimateTakeoffDate = [[NSString alloc] initWithString:scheduleTakeoffDate];
	NSDate *estimateTakeoffD=[timeFormatter dateFromString:estimateTakeoffTime];
	a = ([estimateTakeoffD timeIntervalSince1970]*1 - [scheduleTakeoffD timeIntervalSince1970]*1)/60;
	if (a < -12*60) {
		estimateTakeoffDate = [dateFormatter stringFromDate:nextDate];
	}
	//[4]
	NSString *actualArrivalDate = [[NSString alloc] initWithString:scheduleArrivalDate];
	NSDate *actualArrivalD=[timeFormatter dateFromString:actualArrivalTime];
	a = ([actualArrivalD timeIntervalSince1970]*1 - [scheduleArrivalD timeIntervalSince1970]*1)/60;
	if (a < -12*60) {
		actualArrivalDate = [dateFormatter stringFromDate:nextDate];
	}
	//[5]
	NSString *estimateArrivalDate = [[NSString alloc] initWithString:scheduleArrivalDate];
	NSDate *estimateArrivalD=[timeFormatter dateFromString:estimateArrivalTime];
	a = ([estimateArrivalD timeIntervalSince1970]*1 - [scheduleArrivalD timeIntervalSince1970]*1)/60;
	if (a < -12*60) {
		estimateArrivalDate = [dateFormatter stringFromDate:nextDate];
	}
	//计算其他五个时间对应的日期：假设实际提前延误、预计提前延误不超过12小时，航班飞行时间不超过10小时 - [结束]
	
	
	//1. calculate takeoffDelayAdvanceTime
	NSString *takeoffDelayAdvanceTime = [[NSString alloc] initWithString:@""];
	if (![actualTakeoffTime isEqualToString:@"--:--"]) {
		//NSLog(@"状态：已经起飞");
		[flightInfo setObject:actualTakeoffTime forKey:@"display_takeoff_time"];
		
		takeoffDelayAdvanceTime = [takeoffDelayAdvanceTime stringByAppendingString:@"已离开登机口 "];
		NSDate *actualTakeoffD=[dateTimeFormatter dateFromString:
								[actualTakeoffDate stringByAppendingFormat:@" %@",actualTakeoffTime] ];
		NSDate *scheduleTakeoffD=[dateTimeFormatter dateFromString:
								  [scheduleTakeoffDate stringByAppendingFormat:@" %@",scheduleTakeoffTime]];
		int a = ([actualTakeoffD timeIntervalSince1970]*1 - [scheduleTakeoffD timeIntervalSince1970]*1)/60;
		if (a > 0) {
			takeoffDelayAdvanceTime = [takeoffDelayAdvanceTime stringByAppendingFormat:@"延误%d分",a];
		} else {
			takeoffDelayAdvanceTime = [takeoffDelayAdvanceTime stringByAppendingFormat:@"提前%d分",-a];
		}
	} else {
		//NSLog(@"状态：计划航班");
		if (![estimateTakeoffTime isEqualToString:@"--:--"]) {
			[flightInfo setObject:estimateTakeoffTime forKey:@"display_takeoff_time"];
			takeoffDelayAdvanceTime = [takeoffDelayAdvanceTime stringByAppendingString:@"预计离开登机口 "];
			
			NSDate *estimateTakeoffD=[dateTimeFormatter dateFromString:
									  [estimateTakeoffDate stringByAppendingFormat:@" %@",estimateTakeoffTime]];
			NSDate *scheduleTakeoffD=[dateTimeFormatter dateFromString:
									  [scheduleTakeoffDate stringByAppendingFormat:@" %@",scheduleTakeoffTime]];
			int a = ([estimateTakeoffD timeIntervalSince1970]*1 - [scheduleTakeoffD timeIntervalSince1970]*1)/60;
			if (a > 0) {
				takeoffDelayAdvanceTime = [takeoffDelayAdvanceTime stringByAppendingFormat:@"延误%d分",a];
			} else {
				takeoffDelayAdvanceTime = [takeoffDelayAdvanceTime stringByAppendingFormat:@"提前%d分",-a];
			}
		} else {
			[flightInfo setObject:scheduleTakeoffTime forKey:@"display_takeoff_time"];
			takeoffDelayAdvanceTime = [takeoffDelayAdvanceTime stringByAppendingString:@"计划离开登机口 "];
		}
	}
	NSLog(takeoffDelayAdvanceTime);
	
	//2. calculate arrivalDelayAdvanceTime
	NSString *arrivalDelayAdvanceTime = [[NSString alloc] initWithString:@""];
	if (![actualArrivalTime isEqualToString:@"--:--"]) {
		//NSLog(@"状态：已经起飞");
		[flightInfo setObject:actualArrivalTime forKey:@"display_arrival_time"];
		
		arrivalDelayAdvanceTime = [arrivalDelayAdvanceTime stringByAppendingString:@"已到达 "];
		NSDate *actualArrivalD=[dateTimeFormatter dateFromString:
								[actualArrivalDate stringByAppendingFormat:@" %@",actualArrivalTime]];
		NSDate *scheduleArrivalD=[dateTimeFormatter dateFromString:
								  [scheduleArrivalDate stringByAppendingFormat:@" %@",scheduleArrivalTime]];
		int a = ([actualArrivalD timeIntervalSince1970]*1 - [scheduleArrivalD timeIntervalSince1970]*1)/60;
		if (a > 0) {
			arrivalDelayAdvanceTime = [arrivalDelayAdvanceTime stringByAppendingFormat:@"延误%d分",a];
		} else {
			arrivalDelayAdvanceTime = [arrivalDelayAdvanceTime stringByAppendingFormat:@"提前%d分",-a];
		}
	} else {
		//NSLog(@"状态：计划航班");
		if (![estimateArrivalTime isEqualToString:@"--:--"]) {
			[flightInfo setObject:estimateArrivalTime forKey:@"display_arrival_time"];
			
			arrivalDelayAdvanceTime = [arrivalDelayAdvanceTime stringByAppendingString:@"预计到达 "];
			
			NSDate *estimateArrivalD=[dateTimeFormatter dateFromString:
									  [estimateArrivalDate stringByAppendingFormat:@" %@",estimateArrivalTime]];
			NSDate *scheduleArrivalD=[dateTimeFormatter dateFromString:
									  [scheduleArrivalDate stringByAppendingFormat:@" %@",scheduleArrivalTime]];
			int a = ([estimateArrivalD timeIntervalSince1970]*1 - [scheduleArrivalD timeIntervalSince1970]*1)/60;
			if (a > 0) {
				arrivalDelayAdvanceTime = [arrivalDelayAdvanceTime stringByAppendingFormat:@"延误%d分",a];
			} else {
				arrivalDelayAdvanceTime = [arrivalDelayAdvanceTime stringByAppendingFormat:@"提前%d分",-a];
			}
		} else {
			[flightInfo setObject:scheduleArrivalTime forKey:@"display_arrival_time"];
			
			arrivalDelayAdvanceTime = [arrivalDelayAdvanceTime stringByAppendingString:@"计划到达 "];
		}
	}
	NSLog(arrivalDelayAdvanceTime);
	
	//flightInfo set
	NSLog(@"\"takeoff_airport\" : \"%@\"", [flightInfo objectForKey:@"takeoff_airport"]);
	NSLog(@"\"arrival_airport\" : \"%@\"", [flightInfo objectForKey:@"arrival_airport"]);
	NSLog(@"\"flight_state\" : \"%@\"", [flightInfo objectForKey:@"flight_state"]);
	NSLog(@"\"company\" : \"%@\"", [flightInfo objectForKey:@"company"]);
	NSLog(@"\"flight_no\" : \"%@\"", [flightInfo objectForKey:@"flight_no"]);
	
	NSLog(@"\"schedule_takeoff_time\" : \"%@\"", scheduleTakeoffTime);
	NSLog(@"\"estimate_takeoff_time\" : \"%@\"", estimateTakeoffTime);
	NSLog(@"\"actual_takeoff_time\" : \"%@\"", actualTakeoffTime);
	NSLog(@"\"display_takeoff_time\" : \"%@\"", [flightInfo objectForKey:@"display_takeoff_time"]);
	
	NSLog(@"\"schedule_arrival_time\" : \"%@\"", [flightInfo objectForKey:@"schedule_arrival_time"]);
	NSLog(@"\"estimate_arrival_time\" : \"%@\"", [flightInfo objectForKey:@"estimate_arrival_time"]);
	NSLog(@"\"actual_arrival_time\" : \"%@\"", [flightInfo objectForKey:@"actual_arrival_time"]);
	NSLog(@"\"display_arrival_time\" : \"%@\"", [flightInfo objectForKey:@"display_arrival_time"]);
	NSLog(@"\n");
	
	[flightInfo setObject:takeoffDelayAdvanceTime forKey:@"takeoff_delay_advance_time"];
	[flightInfo setObject:arrivalDelayAdvanceTime forKey:@"arrival_delay_advance_time"];
	[flightInfo setObject:scheduleTakeoffDate forKey:@"schedule_takeoff_date_standard"];
	[flightInfo setObject:[self getShortDateStringFromStandard:scheduleTakeoffDate] 
				   forKey:@"schedule_takeoff_date"];//需要从“标准格式”转换为“短格式”
	[flightInfo setObject:[self getShortDateStringFromStandard:scheduleArrivalDate] 
				   forKey:@"schedule_arrival_date"];//需要从“标准格式”转换为“短格式”
	
	[flightInfo setObject:[self getShortTimeStringFromStandard:scheduleTakeoffTime] 
				   forKey:@"schedule_takeoff_time"];//需要从“标准格式”转换为“短格式”
	NSString *displayTakeoffTime = [flightInfo objectForKey:@"display_takeoff_time"];
	[flightInfo setObject:[self getShortTimeStringFromStandard:displayTakeoffTime] 
				   forKey:@"display_takeoff_time"];//需要从“标准格式”转换为“短格式”
	
	[flightInfo setObject:[self getShortTimeStringFromStandard:scheduleArrivalTime] 
				   forKey:@"schedule_arrival_time"];//需要从“标准格式”转换为“短格式”
	NSString *displayArrivalTime = [flightInfo objectForKey:@"display_arrival_time"];
	
	[flightInfo setObject:[self getShortTimeStringFromStandard:displayArrivalTime] 
				   forKey:@"display_arrival_time"];//需要从“标准格式”转换为“短格式”
}

- (NSString *)getShortDateStringFromStandard:(NSString *)standardDateString {
	if (standardDateString == nil || [standardDateString isEqual:@""]) {
		return @"";
	}
	NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	NSDate *date=[dateFormatter dateFromString:standardDateString];
	[dateFormatter setDateFormat:@"yy-M-d"];
	NSString *shortDateString = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	return shortDateString;
}
- (NSString *)getShortTimeStringFromStandard:(NSString *)standardTimeString {
	if (standardTimeString == nil || [standardTimeString isEqual:@""]) {
		return @"";
	}
	NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:mm"];
	NSDate *date=[dateFormatter dateFromString:standardTimeString];
	[dateFormatter setDateFormat:@"H:mm"];
	NSString *shortDateString = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	return shortDateString;
}

//得到周几信息
- (int) getWeekday:(NSString *)scheduleTakeoffDateStr {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yy-M-d"];
    NSDate *scheduleTakeoffDate = [dateFormatter dateFromString:scheduleTakeoffDateStr];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | 
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    comps = [calendar components:unitFlags fromDate:scheduleTakeoffDate];
    int retval = [comps weekday];
    
    [calendar release];
    [dateFormatter release];    
    return retval;
}

-(void) refreshStatusLabelWithText : (NSString *)textParam{
	UILabel *updateStatusLabel = [self getStatusLabel:textParam];
	
	UIBarButtonItem *updateStatusLabelItem = (UIBarButtonItem *)[self.toolbarItems objectAtIndex:3];
	[updateStatusLabelItem initWithCustomView:updateStatusLabel];
	
	[updateStatusLabel release];
}

-(UILabel *) getStatusLabel :(NSString *)textParam{
	UILabel *retval = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, 120.0f, 21.0f)];
	[retval setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11]];
	[retval setBackgroundColor:[UIColor clearColor]];
	[retval setTextColor:[UIColor whiteColor]];
	[retval setText:textParam];
	[retval setTextAlignment:UITextAlignmentLeft];
	retval.numberOfLines = 0;//这个一定要设成0
	CGSize size = [textParam sizeWithFont:[UIFont systemFontOfSize:11] 
                        constrainedToSize:CGSizeMake(200, 1000) 
                            lineBreakMode:UILineBreakModeWordWrap];
	CGRect rct = retval.frame;
	rct.size = size;
	retval.frame = rct;
	retval.center = CGPointMake(160, 160);
	return retval;
}

#pragma mark -
#pragma mark 业务核心方法
//创建关注航班表
- (void)createFollowedFlightTable {
	if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
	char *errorMsg;
	NSString *createSQL = @"CREATE TABLE IF NOT EXISTS followedflights (";
	createSQL = [createSQL stringByAppendingString:@" ID INTEGER PRIMARY KEY AUTOINCREMENT,"];
	
	createSQL = [createSQL stringByAppendingString:@" company TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" flight_no TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" flight_state TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" flight_location TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" mileage TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" plane_model TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" schedule_takeoff_date TEXT,"];
	
	createSQL = [createSQL stringByAppendingString:@" takeoff_city TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" takeoff_airport TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" takeoff_airport_building TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" takeoff_airport_entrance_exit TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" schedule_takeoff_time TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" estimate_takeoff_time TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" actual_takeoff_time TEXT,"];

	createSQL = [createSQL stringByAppendingString:@" arrival_city TEXT,"];	
	createSQL = [createSQL stringByAppendingString:@" arrival_airport TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" arrival_airport_building TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" arrival_airport_entrance_exit TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" schedule_arrival_time TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" estimate_arrival_time TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" actual_arrival_time TEXT"];
	
	createSQL = [createSQL stringByAppendingString:@");"];
	
	if (sqlite3_exec (database, [createSQL  UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert1(0, @"Error creating table: %s", errorMsg);
	}
}

- (void)loadFlightInfoFromServer {
	//先读取缓存数据库
	//...
    NSMutableArray *array = [[NSMutableArray alloc] init];
	[self startUpdateProcess];
    
    NSDate *curDate = [NSDate date];//获取当前日期
	NSDateFormatter *dateFormatter = [[ NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];//这里去掉 具体时间 保留日期
	NSString *curDateString = [dateFormatter stringFromDate:curDate];
    [dateFormatter release];
	
	NSString *query_string_value = [[NSString alloc] initWithString:@"["];
	
	if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
		
	NSString *query = [NSString stringWithFormat:
                       @"SELECT ID, flight_no, schedule_takeoff_date, takeoff_city, arrival_city FROM followedflights WHERE (flight_state != '已经到达' AND flight_state != '已经取消' AND schedule_takeoff_date <= '%@') ORDER BY ID",
                       curDateString];
	int recordCount = 0;
	sqlite3_stmt *statement;
    
	if (sqlite3_prepare_v2( database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			recordCount ++;
            int fieldCounter = 0;
            int recordId = sqlite3_column_int(statement, fieldCounter++);
			char *flightNoDataChar = (char *)sqlite3_column_text(statement, fieldCounter++);
			char *scheduleTakeoffDateDataChar = (char *)sqlite3_column_text(statement, fieldCounter++);
			char *takeoffCityDataChar = (char *)sqlite3_column_text(statement, fieldCounter++);
			char *arrivalCityDataChar = (char *)sqlite3_column_text(statement, fieldCounter++);
			
            NSString *recordIdStr = [[NSString alloc] initWithFormat:@"%d",recordId];
            NSString *flightNoStr = [[NSString alloc] initWithUTF8String:flightNoDataChar];
			NSString *scheduleTakeoffDateStr = [[NSString alloc] initWithUTF8String:scheduleTakeoffDateDataChar];
			NSString *takeoffCityStr = [[NSString alloc] initWithUTF8String:takeoffCityDataChar];
			NSString *arrivalCityStr = [[NSString alloc] initWithUTF8String:arrivalCityDataChar];
			query_string_value = [query_string_value stringByAppendingFormat:
								  @"{\"flight_no\":\"%@\",\"schedule_takeoff_date\":\"%@\", \"takeoff_city\":\"%@\",\"arrival_city\":\"%@\"},",
								  flightNoStr, scheduleTakeoffDateStr, takeoffCityStr, arrivalCityStr];
            [array addObject:recordIdStr];
            [recordIdStr release];
			[flightNoStr release];
			[scheduleTakeoffDateStr release];
			[takeoffCityStr release];
			[arrivalCityStr release];
		}
	}
    self.requestRecordIdArray = array;
    
	if (recordCount > 0) {
		query_string_value = [query_string_value substringToIndex:[query_string_value length]-1];
	} else {
		//没有未死航班，则无需请求服务器了
		NSLog(@"均为已死航班，无需更新数据");
		[self stopUpdateProcess];
		return;
	}

	query_string_value = [query_string_value stringByAppendingString:@"]"];
	
	
	//get json
	responseData = [[NSMutableData data] retain];
	NSString *url = [[NSString alloc] initWithString:@"http://118.194.161.243:28888/updateFollowedFlightInfo"];
	
	NSString *post = nil;  
	post = [[NSString alloc] initWithFormat:@"query_string=%@", query_string_value];
	NSLog(post);

	//NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];  
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];  
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];  
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
	[request setURL:[NSURL URLWithString:url]];  
	[request setHTTPMethod:@"POST"]; 
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
	//[request setTimeoutInterval:1];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
	[request setHTTPBody:postData];  
	[[NSURLConnection alloc] initWithRequest:request delegate:self];
}


//从关注航班表中读取数据，刷新表格
- (void)loadFlightInfoFromTable{
	self.flightArray = [[NSMutableArray alloc] init];
	NSMutableArray *controllerArray = [[NSMutableArray alloc] init];
	
	if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
	NSString *query = @"SELECT * FROM followedflights ORDER BY schedule_takeoff_date DESC, schedule_takeoff_time DESC";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int recordPointer = 0;
			int recordId = sqlite3_column_int(statement, recordPointer++);
			NSLog(@"recordId:%d",recordId);
            
			//读取char
			char *companyChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *fligtNoChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *flightStateChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *flightLocationChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *mileageChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *planeModelChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *scheduleTakeoffDateChar = (char *)sqlite3_column_text(statement, recordPointer++);
			
			char *takeoffCityChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *takeoffAirportChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *takeoffAirportBuildingChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *takeoffAirportEntranceExitChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *scheduleTakeoffTimeChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *estimateTakeoffTimeChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *actualTakeoffTimeChar = (char *)sqlite3_column_text(statement, recordPointer++);
			
			char *arrivalCityChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *arrivalAirportChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *arrivalAirportBuildingChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *arrivalAirportEntranceExitChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *scheduleArrivalTimeChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *estimateArrivalTimeChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *actualArrivalTimeChar = (char *)sqlite3_column_text(statement, recordPointer++);
			
			//生成String
			NSString *recordIdStr = [[NSString alloc] initWithFormat:@"%d", recordId];
			NSString *companyStr = [[NSString alloc] initWithUTF8String:companyChar];
			NSString *fligtNoStr = [[NSString alloc] initWithUTF8String:fligtNoChar];
			NSString *flightStateStr = [[NSString alloc] initWithUTF8String:flightStateChar];
			NSString *flightLocationStr = [[NSString alloc] initWithUTF8String:flightLocationChar];
			NSString *mileageStr = [[NSString alloc] initWithUTF8String:mileageChar];
            
			NSString *planeModelStr = [[NSString alloc] initWithUTF8String:planeModelChar];
			NSString *scheduleTakeoffDateStr = [[NSString alloc] initWithUTF8String:scheduleTakeoffDateChar];
			
			NSString *takeoffCityStr = [[NSString alloc] initWithUTF8String:takeoffCityChar];
			NSString *takeoffAirportStr = [[NSString alloc] initWithUTF8String:takeoffAirportChar];
			NSString *takeoffAirportBuildingStr = [[NSString alloc] initWithUTF8String:takeoffAirportBuildingChar];
			NSString *takeoffAirportEntranceExitStr = [[NSString alloc] initWithUTF8String:takeoffAirportEntranceExitChar];
			NSString *scheduleTakeoffTimeStr = [[NSString alloc] initWithUTF8String:scheduleTakeoffTimeChar];
			NSString *estimateTakeoffTimeStr = [[NSString alloc] initWithUTF8String:estimateTakeoffTimeChar];
			NSString *actualTakeoffTimeStr = [[NSString alloc] initWithUTF8String:actualTakeoffTimeChar];
			
			NSString *arrivalCityStr = [[NSString alloc] initWithUTF8String:arrivalCityChar];
			NSString *arrivalAirportStr = [[NSString alloc] initWithUTF8String:arrivalAirportChar];
			NSString *arrivalAirportBuildingStr = [[NSString alloc] initWithUTF8String:arrivalAirportBuildingChar];
			NSString *arrivalAirportEntranceExitStr = [[NSString alloc] initWithUTF8String:arrivalAirportEntranceExitChar];
			NSString *scheduleArrivalTimeStr = [[NSString alloc] initWithUTF8String:scheduleArrivalTimeChar];
			NSString *estimateArrivalTimeStr = [[NSString alloc] initWithUTF8String:estimateArrivalTimeChar];
			NSString *actualArrivalTimeStr = [[NSString alloc] initWithUTF8String:actualArrivalTimeChar];
			
			//生成原始数据
			NSMutableDictionary *flightInfo = [[NSMutableDictionary alloc] init];
			[flightInfo setObject:recordIdStr forKey:@"recordId"];
			[flightInfo setObject:companyStr forKey:@"company"];
			[flightInfo setObject:fligtNoStr forKey:@"flight_no"];
			[flightInfo setObject:flightStateStr forKey:@"flight_state"];
			[flightInfo setObject:flightLocationStr forKey:@"flight_location"];
			[flightInfo setObject:mileageStr forKey:@"mileage"];
			[flightInfo setObject:planeModelStr forKey:@"plane_model"];
			[flightInfo setObject:scheduleTakeoffDateStr forKey:@"schedule_takeoff_date"];
			
			[flightInfo setObject:takeoffCityStr forKey:@"takeoff_city"];
			[flightInfo setObject:takeoffAirportStr forKey:@"takeoff_airport"];
			[flightInfo setObject:takeoffAirportBuildingStr forKey:@"takeoff_airport_building"];
			[flightInfo setObject:takeoffAirportEntranceExitStr forKey:@"takeoff_airport_entrance_exit"];
			[flightInfo setObject:scheduleTakeoffTimeStr forKey:@"schedule_takeoff_time"];
			[flightInfo setObject:estimateTakeoffTimeStr forKey:@"estimate_takeoff_time"];
			[flightInfo setObject:actualTakeoffTimeStr forKey:@"actual_takeoff_time"];
			
			[flightInfo setObject:arrivalCityStr forKey:@"arrival_city"];
			[flightInfo setObject:arrivalAirportStr forKey:@"arrival_airport"];
			[flightInfo setObject:arrivalAirportBuildingStr forKey:@"arrival_airport_building"];
			[flightInfo setObject:arrivalAirportEntranceExitStr forKey:@"arrival_airport_entrance_exit"];
			[flightInfo setObject:scheduleArrivalTimeStr forKey:@"schedule_arrival_time"];
			[flightInfo setObject:estimateArrivalTimeStr forKey:@"estimate_arrival_time"];
			[flightInfo setObject:actualArrivalTimeStr forKey:@"actual_arrival_time"];
			
			//转化为表格显示数据，其实就是计算如下信息:
            /*
             takeoff_delay_advance_time
             arrival_delay_advance_time
             schedule_takeoff_date_standard
             schedule_takeoff_date
             schedule_arrival_date
             schedule_takeoff_time
             display_takeoff_time
             schedule_arrival_time
             display_arrival_time
             */
			[self convertToDisplayFlightInfo:flightInfo];
			
			[self.flightArray addObject:flightInfo];
			
			//加入controller元素
			NSMutableArray *takeoffArrivalAirportArray = [[NSMutableArray alloc] initWithObjects:
                                                          [flightInfo objectForKey:@"takeoff_airport"],
                                                          [flightInfo objectForKey:@"arrival_airport"], nil];
			
			NSMutableArray *takeoffArrivalCityArray = [[NSMutableArray alloc] initWithObjects:
                                                       [flightInfo objectForKey:@"takeoff_city"],
                                                       [flightInfo objectForKey:@"arrival_city"], nil];
			DisclosureButtonController *disclosureButtonController = 
            [[DisclosureButtonController alloc] initWithNibName:@"DisclosureButtonController" bundle:nil];
			
			//NSLog(@"2...");
			
			disclosureButtonController.list = takeoffArrivalAirportArray;
			disclosureButtonController.cityList = takeoffArrivalCityArray;
            
			disclosureButtonController.flightInfo = flightInfo;
			NSString *titleText = [NSString stringWithFormat:@"%@",[flightInfo objectForKey:@"takeoff_city"]];
			titleText = [titleText stringByAppendingString:@" 飞往 "];
			titleText = [titleText stringByAppendingString:[flightInfo objectForKey:@"arrival_city"]];
			disclosureButtonController.title = titleText;			
			//disclosureButtonController.rowImage = [UIImage imageNamed:@"moveMeIcon.png"];
			//NSLog(@"3...");
			
			[controllerArray addObject:disclosureButtonController];
			[disclosureButtonController release];
			[takeoffArrivalAirportArray release];
			
			//释放无用变量
			[companyStr release];
			[fligtNoStr release];
			[flightStateStr release];
			[planeModelStr release];
			[scheduleTakeoffDateStr release];
			
			[takeoffCityStr release];
			[takeoffAirportStr release];
			[takeoffAirportBuildingStr release];
			[takeoffAirportEntranceExitStr release];
			[scheduleTakeoffTimeStr release];
			[estimateTakeoffTimeStr release];
			[actualTakeoffTimeStr release];
			
			[arrivalCityStr release];
			[arrivalAirportStr release];
			[arrivalAirportBuildingStr release];
			[arrivalAirportEntranceExitStr release];
			[scheduleArrivalTimeStr release];
			[estimateArrivalTimeStr release];
			[actualArrivalTimeStr release];
		}
	}
	self.controllers = controllerArray;
    
	[self.tableView reloadData];
}



/*
 * 开始更新航班信息的过程
 */
- (void) startUpdateProcess {
	DisclosureButtonController *controller = (DisclosureButtonController *)currentNextController;
	[controller startUpdateProcess];
	
	if (self.tableView.editing) {
		return;
	}
    [updateProgressInd startAnimating];
	statusLabelText = [[NSString alloc]initWithString:@"更新中..."];
	[self refreshStatusLabelWithText:statusLabelText];
}
/*
 * 停止更新航班信息的过程
 */
- (void) stopUpdateProcess {
	NSLog(@"stopUpdateProcess...");
	
	DisclosureButtonController *currentController = (DisclosureButtonController *)currentNextController;
	NSMutableDictionary *flightInfo = currentController.flightInfo;
	NSString *flightNo = [flightInfo objectForKey:@"flight_no"];
	NSString *scheduleTakeoffDate = [flightInfo objectForKey:@"schedule_takeoff_date"];

	if (self.controllers != nil) {				
		for (int i = 0; i < [self.controllers count]; i++) {
			DisclosureButtonController *tempController = [self.controllers objectAtIndex:i];
			NSMutableDictionary *tempFlightInfo = tempController.flightInfo;
			
			NSString *tempFlightNo = [tempFlightInfo objectForKey:@"flight_no"];
			NSString *tempScheduleTakeoffDate = [tempFlightInfo objectForKey:@"schedule_takeoff_date"];
			if ([tempFlightNo isEqualToString:flightNo]
				&& [tempScheduleTakeoffDate isEqualToString:scheduleTakeoffDate]) {
				currentController.flightInfo = tempFlightInfo;
				break;
			}
		}
	}
	[currentController stopUpdateProcess];
	
	if (self.tableView.editing) {
		return;
	}
	
    [updateProgressInd stopAnimating];
	NSDate *now = [[NSDate alloc] init];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yy-M-d H:mm"];
	NSString* dateString = [dateFormatter stringFromDate:now];
	
	statusLabelText = [[NSString alloc]initWithFormat:@"已更新 %@",dateString];
	[self refreshStatusLabelWithText:statusLabelText];
	[now release];
	[dateFormatter release];
}




- (IBAction)updateDateTime
{
	/*
	 per second
	 */
	//update the detailed time label above
	NSDate *now = [[NSDate alloc] init];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HHmmss"];
	NSString* hhmmss = [dateFormatter stringFromDate:now];
	NSString* secondPart = [hhmmss substringWithRange:NSMakeRange(4,2)];
	if ([secondPart isEqualToString:@"00"]) {
		NSLog(hhmmss);
		[self selfRefreshAction];
	}
	[dateFormatter release];
}
- (void)searchConditionController:(SearchConditionController *)searchConditionController didAddRecipe:(int)recipe {
    NSLog(@"searchConditionController didAddRecipe");
	//此处不刷新，从关注航班表中读取
	[self loadFlightInfoFromTable];
    // Dismiss the modal add recipe view controller
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table Data Source Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"cellForRowAtIndexPath...");

	static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
	CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
	if (cell == nil) {
		//cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:RootViewControllerCell] autorelease];
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
	//Configue the cell
	if (self.flightArray == nil || [self.flightArray count] == 0 ) {
		self.flightArray = [[NSMutableArray alloc] init];
		return cell;
	}
	
	NSDictionary* one = [flightArray objectAtIndex:indexPath.row];
	
	NSUInteger row = [indexPath row];
	SecondLevelViewController *controller = [controllers objectAtIndex:row];
	NSString *nameLabelText = [NSString stringWithFormat:@"%@",[one objectForKey:@"takeoff_city"]];
	nameLabelText = [nameLabelText stringByAppendingString:@" 飞往 "];
	nameLabelText = [nameLabelText stringByAppendingString:[one objectForKey:@"arrival_city"]];
	//cell.nameLabel.text = controller.title;
	cell.nameLabel.text = nameLabelText;
    
    //计划起飞日期是今天，则计划起飞日期字段显示航班状态
    NSString *scheduleTakeoffDate = [one objectForKey:@"schedule_takeoff_date"];
    NSDate *curDate = [NSDate date];//获取当前日期
	NSDateFormatter *dateFormatter = [[ NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];//这里去掉 具体时间 保留日期
	NSString *curDateString = [self getShortDateStringFromStandard:[dateFormatter stringFromDate:curDate]];
    
    NSLog(@"curDateString: %@, scheduleTakeoffDate: %@", curDateString, scheduleTakeoffDate);
    if ([curDateString isEqualToString:scheduleTakeoffDate]) {
        cell.takeoffDateLabel.text = [one objectForKey:@"flight_state"];
    } else {
        int weekday = [self getWeekday:scheduleTakeoffDate];
        NSString *weekdayStr = nil;
        switch (weekday) {
            case 1:
                weekdayStr = [[NSString alloc] initWithFormat:@"周日 %@",scheduleTakeoffDate];
                break;
            case 2:
                weekdayStr = [[NSString alloc] initWithFormat:@"周一 %@",scheduleTakeoffDate];
                break;
            case 3:
                weekdayStr = [[NSString alloc] initWithFormat:@"周二 %@",scheduleTakeoffDate];
                break;
            case 4:
                weekdayStr = [[NSString alloc] initWithFormat:@"周三 %@",scheduleTakeoffDate];
                break;
            case 5:
                weekdayStr = [[NSString alloc] initWithFormat:@"周四 %@",scheduleTakeoffDate];
                break;
            case 6:
                weekdayStr = [[NSString alloc] initWithFormat:@"周五 %@",scheduleTakeoffDate];
                break;
            case 7:
                weekdayStr = [[NSString alloc] initWithFormat:@"周六 %@",scheduleTakeoffDate];
                break;
            default:
                break;
        }
        cell.takeoffDateLabel.text = weekdayStr;
        [weekdayStr release];
    }
    cell.flightNOLabel.text = [[one objectForKey:@"company"] stringByAppendingFormat:@" %@",[one objectForKey:@"flight_no"]];
	cell.takeoffTimeLabel.text = [one objectForKey:@"display_takeoff_time"];
	cell.landTimeLabel.text = [one objectForKey:@"display_arrival_time"];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    [dateFormatter release];
	NSLog(@"...cellForRowAtIndexPath");
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"numberOfRowsInSection...");
	if (self.flightArray != nil) {
		NSLog(@"self.flightArray != nil");
		NSLog(@"%d",[self.flightArray count]);

		return [self.flightArray count];
	} else {
		NSLog(@"self.flightArray == nil");
		NSLog(@"0");

		return 0;
	}

}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return kTableViewRowHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{ 
	return @"删除"; 
} 

#pragma mark -
#pragma mark Table View Delegate Methods
//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
//	return UITableViewCellAccessoryDisclosureIndicator;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"didSelectRowAtIndexPath...");
	NSUInteger row = [indexPath row];
	currentNextController = [self.controllers objectAtIndex:row];
	
	MyNavAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSLog(@"...didSelectRowAtIndexPath");
	[delegate.navController pushViewController:currentNextController animated:YES];
}

-(void)tableView:(UITableView *)tableView
	commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
	forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSDictionary *flightInfo = [self.flightArray objectAtIndex:row];
	NSString *recordId = [flightInfo objectForKey:@"recordId"];
	NSLog(@"recordId:%@", recordId);
	
	//flight_no, schedule_takeoff_date, takeoff_city, arrival_city
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
	
}


#pragma mark -
#pragma mark Toolbar Actions
- (void)loadToolbarItems {
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	//1.edit mode toolbar items
	UIBarButtonItem *deleteLandedButton = [[UIBarButtonItem alloc] 
										   initWithTitle:@"删除已到达航班" 
										   style:UIBarButtonItemStyleBordered
										   target:self 
										   action:@selector(deleteLandedFlights)];
	UIBarButtonItem *deleteAllButton = [[UIBarButtonItem alloc] 
										initWithTitle:@"删除全部航班" 
										style:UIBarButtonItemStyleBordered
										target:self 
										action:@selector(deleteAllFlights)];
	self.deleteToolbarItems = [[NSArray alloc] initWithObjects: flexibleSpace, deleteAllButton, nil]; 
	//2.normal mode toolbar items
	
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"刷新"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(refreshAction)];
    UIBarButtonItem *feedbackImageButton = 
    [[UIBarButtonItem alloc] initWithTitle:@"反馈"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(umengFeedback)];
    
    UIBarButtonItem *settingImageButton = 
    [[UIBarButtonItem alloc] initWithTitle:@"分享"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(StartSinaPhotoWeibo)];
    
	updateProgressInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[updateProgressInd setHidesWhenStopped:YES];
	
	UIBarButtonItem *updateProgressIndicatorButton = [[UIBarButtonItem alloc] initWithCustomView:updateProgressInd];
	UIBarButtonItem *updateStatusLabelButton = [[UIBarButtonItem alloc] initWithCustomView:
												[self getStatusLabel:@""]];
	
	self.refreshToolbarItems = [[NSArray alloc] initWithObjects: refreshButton, 
								flexibleSpace, updateProgressIndicatorButton, updateStatusLabelButton,
								flexibleSpace, feedbackImageButton, settingImageButton, nil]; 
}

- (IBAction)switchToSearchCondition:(id)sender
{   
	SearchConditionController *searchConditionController = [[SearchConditionController alloc]initWithNibName:@"SearchConditionController" bundle:nil];
	// Configure the RecipeAddViewController. In this case, it reports any
	// changes to a custom delegate object.
	searchConditionController.delegate = self;
	
	// Create the navigation controller and present it modally.
	UINavigationController *navigationController = [[UINavigationController alloc]
													initWithRootViewController:searchConditionController];
	[navigationController setToolbarHidden:NO];
	self.searchNavController = navigationController;
	
	[self presentModalViewController:navigationController animated:YES];
	
	// The navigation controller is now owned by the current view controller
	// and the root view controller is owned by the navigation controller,
	// so both objects should be released to prevent over-retention.
	[navigationController release];
	[searchConditionController release];
}
//用户点击更新按钮的被动更新过程
- (void)refreshAction { 
	NSLog(@"refreshAction"); 
	BOOL serverReachable = [[MyNavAppDelegate sharedAppDelegate] isServerReachable];
	if (serverReachable) {
		[self loadFlightInfoFromServer];	
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"离线"
														message:@"更新航班时出错，\n请检查您的网络连接"
													   delegate:nil
											  cancelButtonTitle:@"确定"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		//更新工具栏状态
		[updateProgressInd stopAnimating];
		statusLabelText = [[NSString alloc]initWithString:@"离线"];
		[self refreshStatusLabelWithText:statusLabelText];
	}
}
//每分钟的主动更新过程
- (void)selfRefreshAction { 
	NSLog(@"selfRefreshAction"); 
	BOOL serverReachable = [[MyNavAppDelegate sharedAppDelegate] isServerReachable];
	if (serverReachable) {
		[self loadFlightInfoFromServer];	
	} else {
		//更新工具栏状态
		[updateProgressInd stopAnimating];
		statusLabelText = [[NSString alloc]initWithString:@"离线"];
		[self refreshStatusLabelWithText:statusLabelText];
	}
}
//请求：[ {国航，数字航班号1,日期1},  {东航，数字航班号2,日期2},...,{南航,日期N}]  
//响应：

- (void) handleTimer: (NSTimer *) timer
{
	[self updateDateTime];
}

#pragma mark -
#pragma mark Weibo share
- (void)StartSina {
    NSLog(@"StartSina");
    [[WBShareKit mainShare] setDelegate:self];
    [[WBShareKit mainShare] startSinaOauthWithSelector:@selector(sinaSuccess:) withFailedSelector:@selector(sinaError:)];
}

- (void)StartSendSinaWeibo {
    NSDate *curDate = [NSDate date];
    int timestamp = [curDate timeIntervalSince1970];
    NSString *weiboText = [[NSString alloc]initWithFormat:@"WBShareKit test %d",timestamp];
    [[WBShareKit mainShare] sendSinaRecordWithStatus:weiboText lat:0 lng:0 delegate:self successSelector:@selector(sendRecordTicket:finishedWithData:) failSelector:@selector(sendRecordTicket:failedWithError:)];
}

- (void)StartSinaPhotoWeibo {
    NSDate *curDate = [NSDate date];
    int timestamp = [curDate timeIntervalSince1970];
    NSString *weiboText = [[NSString alloc]initWithFormat:@"发送图文微博测试 %d",timestamp];
    NSLog(@"%@",[[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"]);
    [[WBShareKit mainShare] sendSinaPhotoWithStatus:weiboText lat:0 lng:0 path:[[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"] delegate:self successSelector:@selector(sendRecordTicket:finishedWithData:) failSelector:@selector(sendRecordTicket:failedWithError:)];
}

#pragma mark sina delegate
- (void)sinaSuccess:(NSData *)_data
{
    NSLog(@"sina ok:%@",_data);
}

- (void)sinaError:(NSError *)_error
{
    NSLog(@"sina error:%@",_error);
}

- (void)sendRecordTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
    NSError *error;
	SBJSON *json = [[SBJSON new] autorelease];
	NSMutableDictionary *responseObject = [json objectWithString:string error:&error];
 
	if (responseObject != nil) {
		NSString *errorCodeStr = [responseObject objectForKey:@"error_code"];
        NSString *errorStr = [responseObject objectForKey:@"error"];
        if (errorCodeStr != nil && [errorCodeStr isEqualToString:@"400"]
            && errorStr != nil && [errorStr rangeOfString:@"40072"].length > 0) 
            [self StartSina];
        else if (errorCodeStr != nil && [errorCodeStr isEqualToString:@"403"]
            && errorStr != nil && [errorStr rangeOfString:@"40302"].length > 0) 
            [self StartSina];
        else {
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"发送新浪微博成功" message:string delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [al show];
            [al release];
        }
	} else {	
        NSLog([NSString stringWithFormat:@"JSON parsing failed: %@", [error localizedDescription]]);
    }
}
- (void)sendRecordTicket:(OAServiceTicket *)ticket failedWithError:(NSError *)error
{
    
}
@end