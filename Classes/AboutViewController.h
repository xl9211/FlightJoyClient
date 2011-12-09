//
//  AboutViewController.h
//  MyNav
//
//  Created by 王 攀 on 11-12-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController<UIWebViewDelegate> {
    IBOutlet UIWebView *webView;
    UIActivityIndicatorView *activityIndicatorView;
}

@end
