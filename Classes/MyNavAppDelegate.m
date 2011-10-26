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

#pragma mark -
#pragma mark Application lifecycle

+ (MyNavAppDelegate *)sharedAppDelegate
{
    return (MyNavAppDelegate *) [UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    //Change the host name here to change the server your monitoring
	hostReach = [[Reachability reachabilityWithHostName: @"specialbrian.gicp.net"] retain];
	[self updateInterfaceWithReachability];
    
    application.applicationSupportsShakeToEdit = YES;
	
    // Override point for customization after application launch.
	//navController.view.backgroundColor = [ UIColor colorWithPatternImage:[UIImage imageNamed:@"china3.jpg"] ];
    [window addSubview: navController.view];
	
    [window makeKeyAndVisible];
    
    return YES;
}

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
