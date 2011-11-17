//
//  PlaneAnnotation.h
//  MyNav
//
//  Created by 王 攀 on 11-11-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PlaneAnnotation : NSObject <MKAnnotation>
{
    UIImage *image;
    NSString *title;
    double latitude;
    double longitude;
}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *title;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end