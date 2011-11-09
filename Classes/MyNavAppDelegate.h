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

@class Reachability;

@interface MyNavAppDelegate : NSObject <UIApplicationDelegate, MobClickDelegate> {
    UIWindow *window;
	UINavigationController *navController;
	Reachability  *hostReach;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;

+ (MyNavAppDelegate *)sharedAppDelegate;
- (BOOL)isServerReachable;

@end

