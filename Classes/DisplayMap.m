//  DisplayMap.m
//  iphonemap
//
//  Created by 王 攀 on 11-10-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DisplayMap.h"
@implementation DisplayMap
@synthesize coordinate,title,subtitle;
-(void)dealloc{
	[title release];
	[super dealloc];
}
@end
