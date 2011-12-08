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
@synthesize serverIpaUrl;

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken { 
    
    NSString *str = [NSString 
                     stringWithFormat:@"%@",deviceToken];
    DLog(str);
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
    DLog(str);    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:str 
                          message:@"" 
                          delegate:self 
                          cancelButtonTitle:@"确定" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}
//查询推送的网址http://fd.tourbox.me/getPushInfo
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //if ( application.applicationState == UIApplicationStateActive ) {
        // app was already in the foreground
    //} else {
        // app was just brought from background to foreground, that is, an application is launched as a result of the user tapping the action button.
    //}
    
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    NSString *alertMessage = [apsInfo objectForKey:@"alert"];
    DLog(@"Received Push Alert: %@", alertMessage);
     
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"飞趣" 
                          message:alertMessage 
                          delegate:self 
                          cancelButtonTitle:@"确定" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release]; 
}

+ (MyNavAppDelegate *)sharedAppDelegate
{
    return (MyNavAppDelegate *) [UIApplication sharedApplication].delegate;
}

- (NSString *)channelId{
    //return @"other";
    //return @"macidea";
    return @"weiphone";
    //App Store 的版本没有channelId方法，切代表的时cocoachina
}
- (NSString *)appKey {
    return @"4ebf9547527015401e00006f";
}

#pragma mark -
#pragma mark Application lifecycle

-(BOOL)initializeDb{ 
    DLog (@"initializeDB...");  
    // look to see if DB is in known location (~/Documents/$DATABASE_FILE_NAME)  
    //START:code.DatabaseShoppingList.findDocumentsDirectory  
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    
    NSString *documentFolderPath = [searchPaths objectAtIndex: 0];  
    //查看文件目录  
    NSString *dbFilePath = [documentFolderPath stringByAppendingPathComponent:kFilename]; 
    //DLog(@"dbFilePath: %@",dbFilePath);

    [dbFilePath retain];  

    if (! [[NSFileManager defaultManager] fileExistsAtPath: dbFilePath]) {  
        // didn't find db, need to copy  
        NSString *backupDbPath = [[NSBundle mainBundle] pathForResource:@"flights" ofType:@"sqlite3"];  
        //DLog(@"backupDbPath: %@",backupDbPath);

        if (backupDbPath == nil) {  
            // couldn't find backup db to copy, bail  
            return NO;  
        } else {  
            BOOL copiedBackupDb = [[NSFileManager defaultManager] copyItemAtPath:backupDbPath toPath:dbFilePath error:nil];  
            if (! copiedBackupDb) {  
                // copying backup db failed, bail  
                return NO;  
            }  
        }  
    }  
    DLog (@"bottom of initializeDb");  
    return YES;  
} 


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions { 
    DLog(@"didFinishLaunchingWithOptions...");
    // copy the database from the bundle if necessary  
    if (! [self initializeDb]) {  
        // TODO: alert the user!  
        DLog (@"couldn't init db");  
        return;  
    } 
    
    //[MobClick setLogEnabled:YES];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行
    [MobClick setCrashReportEnabled:NO];
    
    [MobClick setDelegate:self reportPolicy:REALTIME];
    
    //Change the host name here to change the server your monitoring
	//hostReach = [[Reachability reachabilityWithHostName: @"fq.tourbox.me"] retain];
    hostReach = [[Reachability reachabilityWithHostName: @"specialbrian.gicp.net"] retain];

	[self updateInterfaceWithReachability];
    
    application.applicationSupportsShakeToEdit = YES;
	
    // Override point for customization after application launch.
	navController.view.backgroundColor = [ UIColor colorWithPatternImage:[UIImage imageNamed:@"china5.png"] ];
    UIImageView *maskImageView = [[UIImageView alloc]initWithImage: [UIImage imageNamed:@"add.png"]];
    [maskImageView setFrame:navController.view.frame];
    [maskImageView setContentMode:UIViewContentModeScaleToFill];
    [maskImageView setHidden:YES];
    
    [navController.view addSubview:maskImageView];
    [window addSubview: navController.view];
	
    [window makeKeyAndVisible];
    
    DLog(@"Registering for push notifications...");    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeAlert | 
      UIRemoteNotificationTypeBadge | 
      UIRemoteNotificationTypeSound)];
    
    //首次进入应用需要显示向导图层
    if ( ![self followedFlightsTableExists] ) {
        [maskImageView setHidden:NO];
    }
    
    return YES;
}

- (BOOL)followedFlightsTableExists {
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
    
	NSString *query = @"select count(*) from sqlite_master where type='table' and name = 'followedflights';";
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
	NSString *url = [[NSString alloc] initWithString:@"http://fd.tourbox.me/getAirportList"];
	
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
	airportConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //NSString *url = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=314022946";
        
        NSString *url = self.serverIpaUrl;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
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
	DLog(@"MyNavAppDelegate.connectionDidFinishLoading...");
    /*
     更新检查响应 http:// fd.tourbox.me/getVersionInfo
     机场列表响应 http:// fd.tourbox.me/getAirportList
     */
    //NSString *urlString = [[[connection originalRequest] URL] description];
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	NSError *error;
	SBJSON *json = [[SBJSON new] autorelease];
    
    if (connection == versionConnection) {
        DLog(@"getVersionInfo...");
        NSString *currentVersionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
        DLog(@"%@", currentVersionStr);
        
        NSMutableDictionary *versionInfo = [json objectWithString:responseString error:&error];
        NSString *serverVersionStr = [versionInfo objectForKey:@"version"];
        NSString *serverIpaStr = [versionInfo objectForKey:@"ipa"];
        self.serverIpaUrl = serverIpaStr;
        NSString *serverChangelogStr = [versionInfo objectForKey:@"changelog"];
        
        if ([serverVersionStr doubleValue] > [currentVersionStr doubleValue]) {
            UIAlertView *alert = nil;
            alert = [UIAlertView alloc];
            [alert initWithTitle:[[NSString alloc]initWithFormat:@"飞趣v%@上线了，更新内容：",serverVersionStr]
                         message:serverChangelogStr
                        delegate:self
               cancelButtonTitle:@"取消"
               otherButtonTitles:@"确定", nil];
            [alert show];
            [alert release];
        }
        
    } else if (connection == airportConnection) {
        NSArray *airportInfos = [json objectWithString:responseString error:&error];
        if (airportInfos == nil) {
            DLog([NSString stringWithFormat:@"JSON parsing failed: %@", [error localizedDescription]]);
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
                //DLog(@"update...");

                if (sqlite3_exec (database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
                {
                    NSAssert1(0, @"Error updating tables: %s", errorMsg);
                    sqlite3_close(database);
                }
                sqlite3_close(database);	
            }
        }
    }
    [connection release];	

}
//HTTP Response - end

-(BOOL) isServerReachable 
{
	if (hostReach == nil) {
		DLog(@"%@",@"isServerReachable--hostReach == nil");
		return NO;
	}
	
	NetworkStatus netStatus = [hostReach currentReachabilityStatus];
    if (netStatus == NotReachable) {
		DLog(@"%@",@"isServerReachable--netStatus == NotReachable");
		
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


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    DLog(@"applicationDidBecomeActive...");    
    responseData = [[NSMutableData data] retain];
	NSString *url = [[NSString alloc] initWithString:@"http://fd.tourbox.me/getVersionInfo"];
	NSString *post = nil;  
	post = [[NSString alloc] initWithString:@""];
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];  
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];  
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
	[request setURL:[NSURL URLWithString:url]];  
	[request setHTTPMethod:@"POST"]; 
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
	[request setHTTPBody:postData];  
	versionConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
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
