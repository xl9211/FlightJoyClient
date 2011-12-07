//
//  InfoViewController.h
//  MyNav
//
//  Created by 王 攀 on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol InfoSetDelegate;

@interface InfoViewController : UIViewController {
    id <InfoSetDelegate> delegate;

}
@property(nonatomic, assign) id <InfoSetDelegate> delegate;
@end

@protocol InfoSetDelegate <NSObject>
// recipe == nil on cancel
- (void)rootViewController:(InfoViewController *)infoViewController doneSetInfo:(int)recipe;
@end