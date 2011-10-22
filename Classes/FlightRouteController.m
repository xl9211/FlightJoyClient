//
//  FlightRouteController.m
//  MyNav
//
//  Created by 王 攀 on 11-10-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlightRouteController.h"
#import "DisplayMap.h"
#import <MapKit/MKAnnotation.h>

@implementation FlightRouteController
@synthesize mapView;
@synthesize cityList;
@synthesize cityLocationList;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	for (int i = 0; i < [self.cityList count]; i++) {
		NSString *airport = [self.cityList objectAtIndex:i];
		NSLog(airport);
	}
	self.mapView.delegate=self;
	
	/*
	CLLocationManager *locationManager = [[CLLocationManager alloc] init];//创建位置管理器
	locationManager.delegate=self;//设置代理
	locationManager.desiredAccuracy=kCLLocationAccuracyBest;//指定需要的精度级别
	locationManager.distanceFilter=1000.0f;//设置距离筛选器
	[locationManager startUpdatingLocation];//启动位置管理器
	
	CLLocationCoordinate2D currentLocation = [[locationManager location] coordinate];
	NSLog(@"longitude:%f",currentLocation.longitude);
	NSLog(@"latitude:%f",currentLocation.latitude);
	
	MKCoordinateRegion theRegion = { {0.0, 0.0 }, { 0.0, 0.0 } };
	theRegion.center=currentLocation;
	theRegion.span.longitudeDelta = 0.1f;
	theRegion.span.latitudeDelta = 0.1f;
	
	[mapView setRegion:theRegion animated:YES];*/
	[mapView setZoomEnabled:YES];
	[mapView setScrollEnabled:YES];	

	NSMutableArray *overlays = [[NSMutableArray alloc] init];
	CLLocationCoordinate2D pointsToUse[2];
	
	DisplayMap *ann = nil;
	if (self.cityList != nil) {				
		for (int i = 0; i < [self.cityList count]; i++) {			
			ann = [[DisplayMap alloc] init];
			ann.title = [self.cityList objectAtIndex:i];
			ann.coordinate = [[self.cityLocationList objectAtIndex:i] coordinate];
			pointsToUse[i] = ann.coordinate;
			[mapView addAnnotation:ann];
		}
	}
	
	[self zoomToFitMapAnnotations:mapView];

    MKPolyline *lineOne = [MKPolyline polylineWithCoordinates:pointsToUse count:[self.cityList count]];
    lineOne.title = @"red";
    [overlays addObject:lineOne];
    [mapView addOverlays:overlays];
    [lineOne release];
	
	
	//[locationManager release];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyline = overlay;
        MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        polylineView.strokeColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.8];
        polylineView.lineWidth = 12.5;
        return polylineView;
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKPinAnnotationView *pinView = nil;
	
	static NSString *defaultPinID = @"com.invasivecode.pin";
	pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
	if ( pinView == nil ) pinView = [[[MKPinAnnotationView alloc]
									  initWithAnnotation:annotation reuseIdentifier:defaultPinID] autorelease];
	if ([[annotation title] isEqualToString:@"北京"]) {
		pinView.pinColor = MKPinAnnotationColorGreen;
	} else {
		pinView.pinColor = MKPinAnnotationColorRed;
	}
	
	pinView.canShowCallout = YES;
	pinView.animatesDrop = NO;
	
	return pinView;
}
	
-(void)zoomToFitMapAnnotations:(MKMapView*)mapView
{
    if([mapView.annotations count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
	DisplayMap *annotation = nil;
    for(int i=0;i<[mapView.annotations count];i++ )
    {
		annotation = [mapView.annotations objectAtIndex:i];
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}

/*
 - (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
 {
 if ([overlay isKindOfClass:[MKPolyline class]]) 
 {
 MKPolylineView *lineview=[[[MKPolylineView alloc] initWithOverlay:overlay] autorelease];
 lineview.strokeColor=[[UIColor blueColor] colorWithAlphaComponent:0.5];
 lineview.lineWidth=2.0;
 return lineview;
 }
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
