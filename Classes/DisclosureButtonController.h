//
//  DisclosureButtonController.h
//  MyNav
//
//  Created by 王 攀 on 11-8-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "/usr/include/sqlite3.h"
#import "SVGeocoder.h"
#import "RootViewController.h"
#import <MapKit/MapKit.h> 
#import <MapKit/MKAnnotation.h>
#import "WBShareKit.h"

#define kFilename		@"flights.sqlite3"

@class DisclosureDetailController;

@interface DisclosureButtonController : UIViewController 
<UITableViewDelegate, UITableViewDataSource, SVGeocoderDelegate,
CLLocationManagerDelegate, MKMapViewDelegate, UIActionSheetDelegate> {
    id <FlightAddDelegate> delegate;
	NSMutableArray *list;
	NSMutableArray *cityList;
	sqlite3	*database;
	NSDictionary *flightInfo;
	DisclosureDetailController *childController;
    IBOutlet UITableView *tableView;

	UIActivityIndicatorView *updateProgressInd;
    
    //mapview
    IBOutlet MKMapView *mapView; 
	NSMutableArray *cityLocationList;
    int m_selectedSegmentIndex;
    
    //detail statebar
    IBOutlet UILabel *stateLabelLeft;
    IBOutlet UILabel *stateLabelCenter;
    IBOutlet UILabel *stateLabelRight;
    IBOutlet UIProgressView *progressView;
    int m_statebarIndex;
    
    //
    NSString *parentClassName;
}
@property(nonatomic, assign) id <FlightAddDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *list;
@property (nonatomic, retain) NSMutableArray *cityList;
@property (nonatomic, retain) NSDictionary *flightInfo;
@property (nonatomic,retain) UIActivityIndicatorView *updateProgressInd;
@property (nonatomic,retain) UITableView *tableView;

//mapview
@property(nonatomic, retain) IBOutlet MKMapView *mapView; 
@property (nonatomic, retain) NSMutableArray *cityLocationList;

//detail statebar
@property (nonatomic, retain) UILabel *stateLabelLeft;
@property (nonatomic, retain) UILabel *stateLabelCenter;
@property (nonatomic, retain) UILabel *stateLabelRight;
@property (nonatomic, retain) UIProgressView *progressView;

//
@property (nonatomic,retain) NSString *parentClassName;

- (IBAction)segmentControlDidChanged:(id)sender;

@end
