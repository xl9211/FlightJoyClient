//
//  Company.h
//  MyNav
//
//  Created by 王 攀 on 11-9-8.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Company : NSObject {
	NSString *shortname;
	NSString *fullname;
}
@property (nonatomic, retain) NSString* shortname;
@property (nonatomic, retain) NSString* fullname;

@end
