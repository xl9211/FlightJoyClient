//
//  MyNavAppDelegate.h
//  MyNav
//
//  Created by 王 攀 on 11-8-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "MobClick.h"
#import "JSON.h"
#import "VersionCheckUtil.h"
#import "/usr/include/sqlite3.h"
#define kFilename		@"flights.sqlite3"

@class Reachability;

@interface MyNavAppDelegate : NSObject <UIApplicationDelegate, MobClickDelegate, UIAlertViewDelegate> {
    UIWindow *window;
	UINavigationController *navController;
    Reachability *internetReachable;
	Reachability *hostReachable;
    NSString *deviceToken;
    NSMutableData *responseData;
    sqlite3	*database;
    NSString *serverIpaUrl;
    NSURLConnection *versionConnection;
    NSURLConnection *airportConnection;
    
    VersionCheckUtil *versionCheck;
    BOOL internetActive;
    BOOL hostActive;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) NSString *deviceToken;
@property (nonatomic, retain) NSString *serverIpaUrl;
@property (nonatomic) BOOL internetActive;
@property (nonatomic) BOOL hostActive;

+ (MyNavAppDelegate *)sharedAppDelegate;
- (BOOL)isServerReachable;
- (NSString *)getDeviceToken;
- (void) checkNetworkStatus:(NSNotification *)notice;
@end

