//
//  InfoViewController.h
//  MyNav
//
//  Created by 王 攀 on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FlightAddDelegate;

@interface InfoViewController : UIViewController {
    id <FlightAddDelegate> delegate;

}
@property(nonatomic, assign) id <FlightAddDelegate> delegate;

@end
