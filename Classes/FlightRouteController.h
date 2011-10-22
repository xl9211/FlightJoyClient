//
//  FlightRouteController.h
//  MyNav
//
//  Created by 王 攀 on 11-10-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h> 

@interface FlightRouteController : UIViewController 
<CLLocationManagerDelegate, MKMapViewDelegate>{
	IBOutlet MKMapView *mapView; 
	NSMutableArray *cityList;
	NSMutableArray *cityLocationList;
}
@property(nonatomic, retain) IBOutlet MKMapView *mapView; 
@property (nonatomic, retain) NSMutableArray *cityList;
@property (nonatomic, retain) NSMutableArray *cityLocationList;

@end
