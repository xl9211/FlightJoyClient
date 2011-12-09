//
//  VersionCheckUtil.h
//  MyNav
//
//  Created by 王 攀 on 11-12-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON/JSON.h"
#import "CLMAlertView.h"

@interface VersionCheckUtil : NSObject <UIAlertViewDelegate> {
    NSMutableData *responseData;
    NSString *serverIpaUrl;
}

@property (nonatomic, retain) NSString *serverIpaUrl;
- (void)checkVersion;
@end
