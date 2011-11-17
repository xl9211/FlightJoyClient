//
//  PlaneAnnotation.m
//  MyNav
//
//  Created by 王 攀 on 11-11-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "PlaneAnnotation.h"

@implementation PlaneAnnotation
@synthesize image;
@synthesize title;
@synthesize latitude;
@synthesize longitude;


- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = self.latitude;
    theCoordinate.longitude = self.longitude;
    return theCoordinate; 
}

- (void)dealloc
{
    [image release];
    [super dealloc];
}

- (NSString *)title
{
    return title;
}

// optional
- (NSString *)subtitle
{
    return @"估算地点";
}

@end
