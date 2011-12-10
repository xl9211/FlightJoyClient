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
#import "MobClick.h"
#import "QueryResultController.h"
#import "DisclosureButtonTitleView.h"
#import <MessageUI/MessageUI.h>
#import "PlaneAnnotation.h"
#import "UIImage-Extensions.h"

#define kFilename		@"flights.sqlite3"

@class DisclosureDetailController;

@interface DisclosureButtonController : UIViewController 
<UITableViewDelegate, UITableViewDataSource, InfoSetDelegate,
CLLocationManagerDelegate, MKMapViewDelegate, UIActionSheetDelegate,
MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> {
    id <FlightAddDelegate> delegate;
	NSMutableArray *list;
	NSMutableArray *cityList;
    NSMutableArray *airportShortList;
	sqlite3	*database;
	NSDictionary *flightInfo;
	DisclosureDetailController *childController;
    IBOutlet UITableView *tableView;

	//UIActivityIndicatorView *updateProgressInd;
    
    //mapview
    IBOutlet MKMapView *mapView; 
	NSMutableArray *airportLocationList;
    int m_currentSegmentIndex;
    
    //detail statebar
    IBOutlet UILabel *stateLabelLeft;
    IBOutlet UILabel *stateLabelCenter;
    IBOutlet UILabel *stateLabelRight;
    IBOutlet UIProgressView *progressView;
    int m_statebarIndex;
    
    //
    NSString *parentClassName;
    DisclosureButtonTitleView *detailTitleView;
    
    //
    int todo;
    int done;
    double deltaAngel;
}
@property(nonatomic, assign) id <FlightAddDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *list;
@property (nonatomic, retain) NSMutableArray *cityList;
@property (nonatomic, retain) NSMutableArray *airportShortList;
@property (nonatomic, retain) NSDictionary *flightInfo;
@property (nonatomic,retain) UIActivityIndicatorView *updateProgressInd;
@property (nonatomic,retain) UITableView *tableView;

//mapview
@property(nonatomic, retain) IBOutlet MKMapView *mapView; 
@property (nonatomic, retain) NSMutableArray *airportLocationList;

//detail statebar
@property (nonatomic, retain) UILabel *stateLabelLeft;
@property (nonatomic, retain) UILabel *stateLabelCenter;
@property (nonatomic, retain) UILabel *stateLabelRight;
@property (nonatomic, retain) UIProgressView *progressView;

//
@property (nonatomic,retain) NSString *parentClassName;
@property (nonatomic,retain) DisclosureButtonTitleView *detailTitleView;
@property (nonatomic) int todo;
@property (nonatomic) int done;
@property (nonatomic) double deltaAngel;

+ (CGFloat)annotationPadding;
+ (CGFloat)calloutHeight;

//点击按钮后，触发这个方法  
- (void)sendSMS;
-(void)sendEMail;
//可以发送邮件的话  
-(void)displayComposerSheet;
-(void)launchMailAppOnDevice;

@end
