    //
//  DisclosureButtonController.m
//  MyNav
//
//  Created by 王 攀 on 11-8-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DisclosureButtonController.h"
#import "MyNavAppDelegate.h"
#import "DisclosureDetailController.h"
#import "FlightDetailCustomCell.h"
#import "RootViewController.h"
#import "DisplayMap.h"

@implementation DisclosureButtonController
@synthesize list;
@synthesize cityList;
@synthesize flightInfo;
@synthesize updateProgressInd;
@synthesize tableView;
@synthesize delegate;

//mapview
@synthesize mapView;
@synthesize cityLocationList;

//detail statebar
@synthesize stateLabelLeft;
@synthesize stateLabelCenter;
@synthesize stateLabelRight;
@synthesize progressView;

//
@synthesize parentClassName;

#pragma mark -
- (id)initWithStyle:(UITableViewStyle)style
{
	if (self = [super initWithStyle:UITableViewStyleGrouped])
	{
	}
	return self;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/
- (NSString *)dataFilePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSLog(documentsDirectory);
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

//创建城市信息表（纬经度）
- (void)createCityInfoTable {
	if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
	char *errorMsg;
	NSString *createSQL = @"CREATE TABLE IF NOT EXISTS cityinfo (";
	createSQL = [createSQL stringByAppendingString:@" ID INTEGER PRIMARY KEY AUTOINCREMENT,"];
	
	createSQL = [createSQL stringByAppendingString:@" name TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" latitude REAL,"];
	createSQL = [createSQL stringByAppendingString:@" longitude REAL"];
	
	createSQL = [createSQL stringByAppendingString:@");"];
	
	if (sqlite3_exec (database, [createSQL  UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert1(0, @"Error creating table: %s", errorMsg);
	}
}

- (void)cityInfoCheckExist:(NSString *)city {
	if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
	NSString *query = [[NSString alloc]initWithFormat:@"SELECT * FROM cityinfo where name='%@'",city];
	int recordCount = 0;
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			recordCount ++;
		}
	}
	if (recordCount == 0) {
		
		SVGeocoder *geocodeRequest = [[SVGeocoder alloc] initWithAddress:city];
		[geocodeRequest setDelegate:self];
		[geocodeRequest startAsynchronous];
	}
}

- (void)geocoder:(SVGeocoder *)geocoder didFailWithError:(NSError *)error {
	
	UIAlertView *alertView = [[UIAlertView alloc] 
							  initWithTitle:@"地址解析失败" 
							  message:[error description] 
							  delegate:nil 
							  cancelButtonTitle:@"知道了" 
							  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
    
    [geocoder release];
}

- (void)geocoder:(SVGeocoder *)geocoder didFindPlacemark:(SVPlacemark *)placemark {
	//NSLog(@"---%@",placemark.formattedAddress);
	//反向地址解析 http://maps.google.com/maps/api/geocode/json?latlng=32.794919,119.906321&sensor=true
	//正向地址解析 http://maps.google.com/maps/api/geocode/json?address=jiangdu,+yangzhou,+jiangsu&sensor=false
	//正向地址解析类库：https://github.com/samvermette/SVGeocoder
	
	if (self.cityList != nil) {				
		for (int i = 0; i < [self.cityList count]; i++) {
			NSString *city = [self.cityList objectAtIndex:i];
			if ([placemark.formattedAddress rangeOfString:city].length > 0) {
				[self insertCityInfoIntoTable:city withLat:placemark.coordinate.latitude 
									  withLng:placemark.coordinate.longitude]; 
				break;
			}
		}
	}
	
	
	[geocoder release];
}


- (void)insertCityInfoIntoTable:(NSString *)city withLat:(double)latitude withLng:(double)longtitude {
	if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
	NSString *insertSQL = @"INSERT INTO cityinfo (";
	insertSQL = [insertSQL stringByAppendingString:@" name,"];
	insertSQL = [insertSQL stringByAppendingString:@" latitude,"];
	insertSQL = [insertSQL stringByAppendingString:@" longitude"];
	insertSQL = [insertSQL stringByAppendingString:@") VALUES ('%@', %f, %f);"];
	
	NSString *update = [[NSString alloc] initWithFormat:insertSQL, city, latitude, longtitude];
	NSLog(update);
	char * errorMsg;
	
	if (sqlite3_exec (database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
	{
		NSAssert1(0, @"Error updating tables: %s", errorMsg);
		sqlite3_close(database);
	}
}

- (void)save {
	if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
    //insert into followedflights select * from searchedflights;
    NSString *recordIdStr = [flightInfo objectForKey:@"recordId"];
    NSString *insertSelect = [[NSString alloc] 
                              initWithFormat:@"insert into followedflights select * from searchedflights where id = %@;", recordIdStr];
	char * errorMsg;
	if (sqlite3_exec (database, [insertSelect UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
	{
		NSAssert1(0, @"Error insertSelecting tables: %s", errorMsg);	
	}
    
    //delete from searchedflights;
    NSString *delete = [[NSString alloc] initWithString:@"delete from searchedflights;"];
    if (sqlite3_exec (database, [delete UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
	{
		NSAssert1(0, @"Error deleting tables: %s", errorMsg);	
	}
    
	sqlite3_close(database);	
    [self.delegate searchConditionController:self didAddRecipe:nil];
}

- (void)showSendActionSheet
{
	// open a dialog with two custom buttons
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"将航班信息分享于"
                                                             delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil
                                                    otherButtonTitles:@"邮件", @"新浪微博", @"人人网", @"短信息", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
	[actionSheet release];
}

#pragma mark -
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"邮件");
            break;
        case 1:
            NSLog(@"微博");
            [self StartSinaPhotoWeibo];
            break;
        case 2:
            NSLog(@"人人");
            break;
        case 3:
            NSLog(@"短信");
            break;
        default:
            break;
    }
}

- (void)showInfo {
    NSLog(@"showInfo...");
}
#pragma mark -
#pragma mark 工具类方法
- (void)umengFeedback {
    [MobClick showFeedback:self];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"DisclosureButtonController.viewDidLoad...");
    MyNavAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *root = [delegate.navController.viewControllers objectAtIndex:0];
	self.delegate = root;
    
    NSArray *allControllers = self.navigationController.viewControllers;
	ListViewController *parent = [allControllers objectAtIndex:[allControllers count]-2];
    self.parentClassName = [NSString stringWithUTF8String:object_getClassName(parent)];
    
	[self createCityInfoTable];
	if (self.cityList != nil) {				
		for (int i = 0; i < [self.cityList count]; i++) {
			NSString *city = [self.cityList objectAtIndex:i];
			[self cityInfoCheckExist:city];
		}
	}
	
    //toolbar
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                       target:self action:@selector(refreshAction)];
    
    UIButton* infoButton = [UIButton buttonWithType: UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(umengFeedback) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] 
									  initWithCustomView:infoButton];    
	
	updateProgressInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[updateProgressInd setHidesWhenStopped:YES];
	//[updateProgressInd startAnimating];
	
	UIBarButtonItem *updateProgressIndicatorButton = [[UIBarButtonItem alloc] initWithCustomView:updateProgressInd];
	UIBarButtonItem *updateStatusLabelButton = [[UIBarButtonItem alloc] initWithCustomView:
												[self getStatusLabel:@""]];
	
    NSMutableArray *refreshToolbarItems = [[NSMutableArray alloc] initWithObjects: refreshButton, 
                                                                 flexibleSpace, updateProgressIndicatorButton, updateStatusLabelButton,
                                                                 flexibleSpace, nil]; ;
    [self setToolbarItems: refreshToolbarItems animated:YES];

    if (self.parentClassName != nil 
        && [self.parentClassName isEqualToString:@"RootViewController"]) {
        [refreshToolbarItems addObject:infoBarButton];
        
        UIBarButtonItem *sendButtonItem = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                       target:self action:@selector(showSendActionSheet)];
        
        self.navigationItem.rightBarButtonItem = sendButtonItem;
	} else {
        //navigationbar
        UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关注" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
        self.navigationItem.rightBarButtonItem = saveButtonItem;
    }    
	
	//release part
	[refreshToolbarItems release];
	[refreshButton release];
	[flexibleSpace release];
	[updateProgressIndicatorButton release];
	[updateStatusLabelButton release];
	[infoBarButton release];
	
	//mapview
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
    [self switchToSegment:0];
    
    m_statebarIndex = 0;
    [self rotateStatebar];
    NSTimer *timer;
	timer = [NSTimer scheduledTimerWithTimeInterval: 3
											 target: self
										   selector: @selector(handleTimer:)
										   userInfo: nil
											repeats: YES];
    
	[super viewDidLoad];
}
- (void) handleTimer: (NSTimer *) timer
{
	[self rotateStatebar];
}
/*
 1。航班号、估算位置（已经起飞才显示）、飞行状态；
 2。已飞时间、剩余时间；（已经起飞才显示）
 3。已飞里程、剩余里程；（已经起飞才显示）
 4。飞行高度、飞行速度。（可选）
 */
- (IBAction)rotateStatebar
{
    NSString *flightState = [self.flightInfo objectForKey:@"flight_state"];
    NSString *flightNo = [self.flightInfo objectForKey:@"flight_no"];
    NSString *currentLocation = [self.flightInfo objectForKey:@"flight_location"];
    NSString *mileageStr = [flightInfo objectForKey:@"mileage"];
    int mileage = [mileageStr intValue];
    
    NSString *scheduleTakeoffDateStandard = [self.flightInfo objectForKey:@"schedule_takeoff_date_standard"];
    NSString *displayTakeoffTime = [self.flightInfo objectForKey:@"display_takeoff_time"];
    NSString *displayArrivalTime = [self.flightInfo objectForKey:@"display_arrival_time"];
    
    //计算过程暂时忽略红眼航班
    NSDate *curDate = [NSDate date];//获取当前日期
    NSDateFormatter *dateTimeFormatter=[[NSDateFormatter alloc] init];
    [dateTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *displayTakeoffTimeD = [dateTimeFormatter dateFromString:
                                   [scheduleTakeoffDateStandard stringByAppendingFormat:@" %@",displayTakeoffTime]];
    NSDate *displayArrivalTimeD = [dateTimeFormatter dateFromString:
                                   [scheduleTakeoffDateStandard stringByAppendingFormat:@" %@",displayArrivalTime]];
    
    int done = ([curDate timeIntervalSince1970]*1 - [displayTakeoffTimeD timeIntervalSince1970]*1)/60;
    int todo = ([displayArrivalTimeD timeIntervalSince1970]*1 - [curDate timeIntervalSince1970]*1)/60;
    
    switch (m_statebarIndex) {
        case 0:
            self.stateLabelLeft.text = flightNo;
            self.stateLabelRight.text = flightState;
            self.progressView.hidden = YES;
            
            if (flightState != nil && [flightState isEqualToString:@"已经起飞"]) {
                if (currentLocation != nil && ![currentLocation isEqualToString:@""]) 
                    self.stateLabelCenter.text = currentLocation;
                else
                    self.stateLabelCenter.text = @"";
            }
            break;
        case 1:
            if (flightState != nil && [flightState isEqualToString:@"已经起飞"]) {
                NSString *doneStr = nil;
                NSString *todoStr = nil;
                if (todo >= 0) {
                    //done
                    if (done % 60 == 0) {
                        doneStr = [[NSString alloc] initWithFormat:@"%d小时", done / 60];
                    } else {
                        if (done / 60 == 0) {
                            doneStr = [[NSString alloc] initWithFormat:@"%d分", done % 60];
                        } else {
                            doneStr = [[NSString alloc] initWithFormat:@"%d小时%d分", done / 60, done % 60];
                        }
                    }
                    //todo
                    if (todo % 60 == 0) {
                        todoStr = [[NSString alloc] initWithFormat:@"%d小时", todo / 60];
                    } else {
                        if (todo / 60 == 0) {
                            todoStr = [[NSString alloc] initWithFormat:@"%d分", todo % 60];
                        } else {
                            todoStr = [[NSString alloc] initWithFormat:@"%d小时%d分", todo / 60, todo % 60];
                        }
                    }
                    
                    self.stateLabelLeft.text = doneStr;
                    self.stateLabelRight.text = todoStr;
                    self.progressView.hidden = NO;
                    self.progressView.progress = (float)done / (done + todo);
                    [doneStr release];
                    [todoStr release];
                }
            }
            break;
        case 2:
            if (flightState != nil && [flightState isEqualToString:@"已经起飞"]) {
                NSString *doneMileageStr = nil;
                NSString *todoMileageStr = nil;
                if (todo >= 0) {
                    //done
                    doneMileageStr = [[NSString alloc] initWithFormat:@"%d公里", done * mileage / (done + todo)];
                    //todo
                    todoMileageStr = [[NSString alloc] initWithFormat:@"%d公里", todo * mileage / (done + todo)];

                    self.stateLabelLeft.text = doneMileageStr;
                    self.stateLabelRight.text = todoMileageStr;
                    self.progressView.hidden = NO;
                    self.progressView.progress = (float)done / (done + todo);
                    [doneMileageStr release];
                    [todoMileageStr release];
                }
                
            }
            break;
        default:
            break;
    }
    m_statebarIndex = (m_statebarIndex + 1) %3;
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"DisclosureButtonController.viewWillAppear...");
        
	//copy the root view status
	MyNavAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *root = [delegate.navController.viewControllers objectAtIndex:0];
	
	if ([root.updateProgressInd isAnimating]) {
		[updateProgressInd startAnimating];
	} else {
		[updateProgressInd stopAnimating];
	}

	[self refreshStatusLabelWithText:root.statusLabelText];
	//[root refreshAction];
	[super viewWillAppear:animated];
}

/*
 * 开始更新航班信息的过程
 */
- (void) startUpdateProcess {
	NSLog(@"DisclosureButtonController.startUpdateProcess...");
    [updateProgressInd startAnimating];
	NSString *content = @"更新中...";
	[self refreshStatusLabelWithText:content];
}
/*
 * 停止更新航班信息的过程
 */
- (void) stopUpdateProcess {
	NSLog(@"DisclosureButtonController.stopUpdateProcess...");
	[self.tableView reloadData];
	
    [updateProgressInd stopAnimating];
	NSDate *now = [[NSDate alloc] init];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yy-M-d H:mm"];
	NSString* dateString = [dateFormatter stringFromDate:now];
	
	NSString *content = [[NSString alloc]initWithFormat:@"已更新 %@",dateString];
	[self refreshStatusLabelWithText:content];
	[now release];
	[dateFormatter release];
	[content release];
}

-(void) refreshStatusLabelWithText : (NSString *)textParam{
	UILabel *updateStatusLabel = [self getStatusLabel:textParam];
	
	UIBarButtonItem *updateStatusLabelItem = (UIBarButtonItem *)[self.toolbarItems objectAtIndex:3];
	[updateStatusLabelItem initWithCustomView:updateStatusLabel];
	
	//[updateStatusLabel release];
}

-(UILabel *) getStatusLabel :(NSString *)textParam{
	UILabel *retval = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, 120.0f, 21.0f)];
	[retval setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11]];
	[retval setBackgroundColor:[UIColor clearColor]];
	[retval setTextColor:[UIColor whiteColor]];
	[retval setText:textParam];
	[retval setTextAlignment:UITextAlignmentLeft];
	retval.numberOfLines = 0;//这个一定要设成0
	CGSize size = [textParam sizeWithFont:[UIFont systemFontOfSize:11] 
						constrainedToSize:CGSizeMake(200, 1000) 
							lineBreakMode:UILineBreakModeWordWrap];
	CGRect rct = retval.frame;
	rct.size = size;
	retval.frame = rct;
	retval.center = CGPointMake(160, 160);
	return retval;
}

//用户点击更新按钮的被动更新过程
- (void)refreshAction { 
	NSLog(@"DisclosureButtonController.refreshAction");
	MyNavAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *root = [delegate.navController.viewControllers objectAtIndex:0];
	[root refreshAction];
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
	[list release];
	[childController release];
	[flightInfo release];
    [super dealloc];
}

#pragma mark -
#pragma mark Table Data Source Methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSLog(@"DisclosureButtonController.numberOfSectionsInTableView...");
	if (list == nil) {
		NSLog(@"list == nil");
		return 0;
	} else {
		NSLog(@"[list count]:%d",[list count]);

		return [list count];
	}

}

- (NSInteger)tableView:(UITableView *)tableView
	numberOfRowsInSection:(NSInteger)section {
	NSLog(@"DisclosureButtonController.numberOfRowsInSection...");

	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"DisclosureButtonController.cellForRowAtIndexPath...");

	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	NSString *airportString = [list objectAtIndex:section];
	NSLog(@"section:%d, row:%d...", section, row);
	
	static NSString * DisclosureButtonCellIdentifier = @"DisclosureButtonCellIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DisclosureButtonCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:DisclosureButtonCellIdentifier] autorelease];
	}
	
	static NSString *FlightDetailCustomCellIdentifier = @"FlightDetailCustomCellIdentifier";
	FlightDetailCustomCell *flightDetailCell = [tableView dequeueReusableCellWithIdentifier:FlightDetailCustomCellIdentifier];
	if (flightDetailCell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FlightDetailCustomCell" owner:self options:nil];
		flightDetailCell = [nib objectAtIndex:0];
	}

	UIImage *image = [UIImage imageNamed:@"xiangqing.png"];
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
	button.frame = frame;	// match the button's size with the image size
	[button setBackgroundImage:image forState:UIControlStateNormal];
	
	NSString *takeoffDelayAdvanceTime = [flightInfo objectForKey:@"takeoff_delay_advance_time"];
	NSString *arrivalDelayAdvanceTime = [flightInfo objectForKey:@"arrival_delay_advance_time"];

	if (row == 0) {
		cell.text = airportString;
		cell.backgroundColor = [UIColor colorWithRed:0 green:0.2f blue:0.55f alpha:1];
		//cell.backgroundColor = [UIColor colorWithRed:0 green:0.2f blue:0.4f alpha:1]; 
		cell.textColor = [UIColor whiteColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;		
		cell.accessoryView = button;
		cell.image = nil;
		if (section == 0) {
			if ([takeoffDelayAdvanceTime rangeOfString:@"已"].length > 0) {
				cell.image = [UIImage imageNamed:@"duigou.png"];
			}
		} else if (section == 1) {
			if ([arrivalDelayAdvanceTime rangeOfString:@"已"].length > 0) {
				cell.image = [UIImage imageNamed:@"duigou.png"];
			}
		}
	} else {
		if (section == 0) {
			flightDetailCell.statusLabel.text = takeoffDelayAdvanceTime;
			if ([takeoffDelayAdvanceTime rangeOfString:@"延误"].length > 0) {
				flightDetailCell.statusLabel.textColor = [UIColor redColor];
			}
			flightDetailCell.flightBuildingLabel.text = [flightInfo objectForKey:@"takeoff_airport_building"];
			flightDetailCell.timePointLabel.text = [flightInfo objectForKey:@"display_takeoff_time"];
			flightDetailCell.buildingEntranceLabel.text = [flightInfo objectForKey:@"takeoff_airport_entrance_exit"];
			flightDetailCell.selectionStyle = UITableViewCellSelectionStyleNone;
		} else if (section == 1) {
			flightDetailCell.statusLabel.text = arrivalDelayAdvanceTime;
			if ([arrivalDelayAdvanceTime rangeOfString:@"延误"].length > 0) {
				flightDetailCell.statusLabel.textColor = [UIColor redColor];
			}
			flightDetailCell.flightBuildingLabel.text = [flightInfo objectForKey:@"arrival_airport_building"];
			flightDetailCell.timePointLabel.text = [flightInfo objectForKey:@"display_arrival_time"];
			flightDetailCell.buildingEntranceLabel.text = [flightInfo objectForKey:@"arrival_airport_entrance_exit"];
			flightDetailCell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
	}

	NSLog(@"...DisclosureButtonController.cellForRowAtIndexPath");

	if (row == 0) {
		return cell;
	} else {
		return flightDetailCell;
	}
}

#pragma mark -
#pragma mark Table Delegate Methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor darkGrayColor];
	headerLabel.font = [UIFont systemFontOfSize:14];
	
	NSString* labelText = @"    ";
    switch (section) {
        case 0:
            headerLabel.text = [labelText stringByAppendingString:@"起飞 "];
			headerLabel.text = [headerLabel.text stringByAppendingString:[flightInfo objectForKey:@"schedule_takeoff_date"]];
			headerLabel.text = [headerLabel.text stringByAppendingString:@" "];
			headerLabel.text = [headerLabel.text stringByAppendingString:[flightInfo objectForKey:@"schedule_takeoff_time"]];
			headerLabel.text = [headerLabel.text stringByAppendingString:@"     机型: "];
			headerLabel.text = [headerLabel.text stringByAppendingString:[flightInfo objectForKey:@"plane_model"]];
            break;
        case 1:
            headerLabel.text = [labelText stringByAppendingString:@"到达 "];
			headerLabel.text = [headerLabel.text stringByAppendingString:[flightInfo objectForKey:@"schedule_arrival_date"]];
			headerLabel.text = [headerLabel.text stringByAppendingString:@" "];
			headerLabel.text = [headerLabel.text stringByAppendingString:[flightInfo objectForKey:@"schedule_arrival_time"]];
            break;
    }
	
    return headerLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger row = [indexPath row];
	if (row == 0) {
		return 35;
	} else {
		return 75;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 35;
}

/*
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger row = [indexPath row];
	if (row == 1) {
		return UITableViewCellAccessoryNone;
	} else {
		return UITableViewCellAccessoryDetailDisclosureButton;

	}

}*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //do something
}

-(void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"haha");
	if (childController == nil) {
		childController = [[DisclosureDetailController alloc]
						   initWithNibName:@"DisclosureDetail" bundle:nil];
	}
	childController.title = @"Disclosure Button Pressed";
	NSUInteger row = [indexPath row];
	NSString *selectedMovie = [list objectAtIndex:row];
	NSString *detailMessage = [[NSString alloc]
							   initWithFormat:@"You pressed the disclosure button for %@.", selectedMovie];
	childController.message = detailMessage;
	childController.title = selectedMovie;
	[detailMessage release];
	MyNavAppDelegate *delegate = 
	[[UIApplication sharedApplication] delegate];
	[delegate.navController pushViewController:childController animated:YES];
}
#pragma mark -
#pragma mark Map View Methods
- (IBAction)segmentControlDidChanged:(id)sender
{
    NSLog(@"segmentControlDidChanged...");
	UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
	[self switchToSegment:segmentControl.selectedSegmentIndex];
}

- (void) switchToSegment:(int)segmentIndex {
    switch (segmentIndex) {
		case 0:
            m_selectedSegmentIndex = 0;
            [self.tableView setHidden:NO];
            [self.mapView setHidden:YES];
			break;
		case 1:
            m_selectedSegmentIndex = 1;
            [self.tableView setHidden:YES];
            [self.mapView setHidden:NO];
            [self loadMapviewData];
			break;
	}
}

- (void) loadMapviewData {
    //1. prepare data
    NSMutableArray *array = [[NSMutableArray alloc] init];
	if (self.cityList != nil) {				
		if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
			sqlite3_close(database);
			NSAssert(0, @"Failed to open database");
		}
		for (int i = 0; i < [self.cityList count]; i++) {
			NSString *city = [self.cityList objectAtIndex:i];
			NSString *query = [[NSString alloc]initWithFormat:@"SELECT latitude, longitude FROM cityinfo where name='%@'",city];
			sqlite3_stmt *statement;
			if (sqlite3_prepare_v2( database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
				while (sqlite3_step(statement) == SQLITE_ROW) {					
					double latitude = sqlite3_column_double(statement, 0);
					double longitude = sqlite3_column_double(statement, 1);
					CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];					
					[array addObject:location];
				}
			}
		}
		sqlite3_close(database);	
	}
	self.cityLocationList = array;
	[array release];
	
	if ([self.cityLocationList count] != [self.cityList count]) {
		return;
	}
    
    //2. show annotation
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

#pragma mark -
#pragma mark Weibo share
- (void)StartSina {
    NSLog(@"StartSina");
    [[WBShareKit mainShare] setDelegate:self];
    [[WBShareKit mainShare] startSinaOauthWithSelector:@selector(sinaSuccess:) withFailedSelector:@selector(sinaError:)];
}

- (void)StartSendSinaWeibo {
    NSDate *curDate = [NSDate date];
    int timestamp = [curDate timeIntervalSince1970];
    NSString *weiboText = [[NSString alloc]initWithFormat:@"WBShareKit test %d",timestamp];
    [[WBShareKit mainShare] sendSinaRecordWithStatus:weiboText lat:0 lng:0 delegate:self successSelector:@selector(sendRecordTicket:finishedWithData:) failSelector:@selector(sendRecordTicket:failedWithError:)];
}

- (void)StartSinaPhotoWeibo {
    NSDate *curDate = [NSDate date];
    int timestamp = [curDate timeIntervalSince1970];
    NSString *weiboText = [[NSString alloc]initWithFormat:@"发送图文微博测试 %d",timestamp];
    NSLog(@"%@",[[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"]);
    [[WBShareKit mainShare] sendSinaPhotoWithStatus:weiboText lat:0 lng:0 path:[[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"] delegate:self successSelector:@selector(sendRecordTicket:finishedWithData:) failSelector:@selector(sendRecordTicket:failedWithError:)];
}

#pragma mark sina delegate
- (void)sinaSuccess:(NSData *)_data
{
    NSLog(@"sina ok:%@",_data);
}

- (void)sinaError:(NSError *)_error
{
    NSLog(@"sina error:%@",_error);
}

- (void)sendRecordTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSError *error;
	SBJSON *json = [[SBJSON new] autorelease];
	NSMutableDictionary *responseObject = [json objectWithString:string error:&error];
    
	if (responseObject != nil) {
		NSString *errorCodeStr = [responseObject objectForKey:@"error_code"];
        NSString *errorStr = [responseObject objectForKey:@"error"];
        if (errorCodeStr != nil && [errorCodeStr isEqualToString:@"400"]
            && errorStr != nil && [errorStr rangeOfString:@"40072"].length > 0) 
            [self StartSina];
        else if (errorCodeStr != nil && [errorCodeStr isEqualToString:@"403"]
                 && errorStr != nil && [errorStr rangeOfString:@"40302"].length > 0) 
            [self StartSina];
        else {
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"发送新浪微博成功" message:string delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [al show];
            [al release];
        }
	} else {	
        NSLog([NSString stringWithFormat:@"JSON parsing failed: %@", [error localizedDescription]]);
    }
}
- (void)sendRecordTicket:(OAServiceTicket *)ticket failedWithError:(NSError *)error
{
    
}

@end
