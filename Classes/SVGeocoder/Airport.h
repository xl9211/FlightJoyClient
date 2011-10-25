//
//  Airport.h
//  MyNav
//
//  Created by 王 攀 on 11-10-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Airport : NSObject{
	NSString *city;
	NSString *shortname;
	NSString *fullname;
}
@property (nonatomic, retain) NSString* city;
@property (nonatomic, retain) NSString* shortname;
@property (nonatomic, retain) NSString* fullname;

@end
