//
//  MyNavAppDelegate.m
//  MyNav
//
//  Created by 王 攀 on 11-8-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyNavAppDelegate.h"

@implementation MyNavAppDelegate

@synthesize window;
@synthesize navController;
@synthesize deviceToken;


- (NSString *)appKey {
    return @"4ead70725270150996000001";
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken { 
    
    NSString *str = [NSString 
                     stringWithFormat:@"%@",deviceToken];
    NSLog(str);
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:str 
                          message:@"" 
                          delegate:self 
                          cancelButtonTitle:@"确定" 
                          otherButtonTitles:nil];
    //[alert show];
    [alert release];
    self.deviceToken = str;
}
- (NSString *)getDeviceToken {
    return self.deviceToken;
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err { 
    
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    NSLog(str);    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:str 
                          message:@"" 
                          delegate:self 
                          cancelButtonTitle:@"确定" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    for (id key in userInfo) {
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
    }    
    
}

#pragma mark -
#pragma mark Application lifecycle

+ (MyNavAppDelegate *)sharedAppDelegate
{
    return (MyNavAppDelegate *) [UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	[MobClick setDelegate:self];
    [MobClick appLaunched];
    
    //Change the host name here to change the server your monitoring
	hostReach = [[Reachability reachabilityWithHostName: @"specialbrian.gicp.net"] retain];
	[self updateInterfaceWithReachability];
    
    application.applicationSupportsShakeToEdit = YES;
	
    // Override point for customization after application launch.
	navController.view.backgroundColor = [ UIColor colorWithPatternImage:[UIImage imageNamed:@"china5.png"] ];
    [window addSubview: navController.view];
	
    [window makeKeyAndVisible];
    
    NSLog(@"Registering for push notifications...");    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeAlert | 
      UIRemoteNotificationTypeBadge | 
      UIRemoteNotificationTypeSound)];
    
    //更新到最新机场列表，并入库
    //select count(*) from sqlite_master where type='table' and name = 'cityinfo';
    if ( ![self airportTableExists] ) {
        [self createAirportTable];
        [self loadAirportsFromServer];
    }
    
    return YES;
}

- (BOOL)airportTableExists {
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
    
	NSString *query = @"select count(*) from sqlite_master where type='table' and name = 'airport';";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int tableNum = sqlite3_column_int(statement, 0);
            if (tableNum == 1) {
                sqlite3_finalize(statement);
                sqlite3_close(database);	
                return YES;
            }
		}
	}
    sqlite3_finalize(statement);
    sqlite3_close(database);	
    return NO;
}

//创建机场信息表
- (void)createAirportTable {
	if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
	char *errorMsg;
	NSString *createSQL = @"CREATE TABLE IF NOT EXISTS airport (";
	createSQL = [createSQL stringByAppendingString:@" ID INTEGER PRIMARY KEY AUTOINCREMENT,"];
	
	createSQL = [createSQL stringByAppendingString:@" shortname TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" fullname TEXT,"];
    createSQL = [createSQL stringByAppendingString:@" city TEXT"];
    
	createSQL = [createSQL stringByAppendingString:@");"];
	
	if (sqlite3_exec (database, [createSQL  UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert1(0, @"Error creating table: %s", errorMsg);
	}
    sqlite3_close(database);	
}

- (void)loadAirportsFromServer
{
    responseData = [[NSMutableData data] retain];
	NSString *url = [[NSString alloc] initWithString:@"http://118.194.161.243:28888/getAirportList"];
	
	NSString *post = nil;  
	post = [[NSString alloc] initWithString:@"lang=zh"];
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];  
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];  
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
	[request setURL:[NSURL URLWithString:url]];  
	[request setHTTPMethod:@"POST"]; 
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
	[request setHTTPBody:postData];  
	[[NSURLConnection alloc] initWithRequest:request delegate:self];
}
#pragma mark -
#pragma mark HTTP Response Methods
//HTTP Response - begin
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}
- (NSString *)dataFilePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"MyNavAppDelegate.connectionDidFinishLoading...");
	[connection release];
	
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	NSError *error;
	SBJSON *json = [[SBJSON new] autorelease];
	NSArray *airportInfos = [json objectWithString:responseString error:&error];
	
	if (airportInfos == nil) {
		NSLog([NSString stringWithFormat:@"JSON parsing failed: %@", [error localizedDescription]]);
	} else {		
		for (int i = 0; i < [airportInfos count]; i++) {
			NSMutableDictionary *airportInfo = [airportInfos objectAtIndex:i];
			NSString *city = [airportInfo objectForKey:@"city"];
			NSString *shortname = [airportInfo objectForKey:@"short"];	
            NSString *fullname = [airportInfo objectForKey:@"full"];			
            
            //入库
            if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
                sqlite3_close(database);
                NSAssert(0, @"Failed to open database");
            }
            
            NSString *insertSQL = @"INSERT OR REPLACE INTO airport (";
            insertSQL = [insertSQL stringByAppendingString:@" city,"];
            insertSQL = [insertSQL stringByAppendingString:@" shortname,"];
            insertSQL = [insertSQL stringByAppendingString:@" fullname"];
            insertSQL = [insertSQL stringByAppendingString:@") VALUES ('%@','%@','%@');"];
            
            NSString *update = [[NSString alloc] initWithFormat:insertSQL,
                                city, shortname, fullname ];
            char * errorMsg;
            //NSLog(@"update...");

            if (sqlite3_exec (database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                NSAssert1(0, @"Error updating tables: %s", errorMsg);
                sqlite3_close(database);
            }
            sqlite3_close(database);	
		}
	}
}
//HTTP Response - end

-(BOOL) isServerReachable 
{
	if (hostReach == nil) {
		NSLog(@"%@",@"isServerReachable--hostReach == nil");
		return NO;
	}
	
	NetworkStatus netStatus = [hostReach currentReachabilityStatus];
    if (netStatus == NotReachable) {
		NSLog(@"%@",@"isServerReachable--netStatus == NotReachable");
		
		return NO;
	}  
	return YES;
}

- (void) updateInterfaceWithReachability
{
	NetworkStatus netStatus = [hostReach currentReachabilityStatus];
    if (netStatus == NotReachable) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"离线"
														message:@"更新航班时出错，\n请检查您的网络连接"
													   delegate:nil
											  cancelButtonTitle:@"确定"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [MobClick appTerminated];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    [MobClick appLaunched];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    [MobClick appTerminated];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[navController release];
    [window release];
    [super dealloc];
}


@end
