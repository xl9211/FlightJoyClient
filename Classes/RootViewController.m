    //
//  RootViewController.m
//  MyNav
//
//  Created by 王 攀 on 11-8-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

- (void) stopUpdateProcess {
    NSLog(@"Root stopUpdateProcess...");
    [super stopUpdateProcess]; 
    
    //设置编辑模式
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
								   initWithTitle:@"编辑" 
								   style:UIBarButtonItemStyleBordered 
								   target:self 
								   action:@selector(toggleEdit:)];
	self.navigationItem.leftBarButtonItem = editButton;
	[editButton release];
}


- (void)loadToolbarItems {
    NSLog(@"Root loadToolbarItems...");
    [super loadToolbarItems];
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
    [self.refreshToolbarItems addObject:feedbackImageButton];
    [self.refreshToolbarItems addObject:settingImageButton];
}

@end