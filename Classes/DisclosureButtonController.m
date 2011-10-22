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

@implementation DisclosureButtonController
@synthesize list;
@synthesize cityList;
@synthesize flightInfo;
@synthesize updateProgressInd;
@synthesize tableView;

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"DisclosureButtonController.viewDidLoad...");
	[self createCityInfoTable];
	if (self.cityList != nil) {				
		for (int i = 0; i < [self.cityList count]; i++) {
			NSString *city = [self.cityList objectAtIndex:i];
			[self cityInfoCheckExist:city];
		}
	}
	
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"刷新"
																	  style:UIBarButtonItemStyleBordered
																	 target:self
																	 action:@selector(refreshAction)];
	
	UIBarButtonItem *settingButton = [[UIBarButtonItem alloc] 
									  initWithCustomView:[UIButton buttonWithType:UIButtonTypeInfoLight]];
	
	updateProgressInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[updateProgressInd setHidesWhenStopped:YES];
	//[updateProgressInd startAnimating];
	
	UIBarButtonItem *updateProgressIndicatorButton = [[UIBarButtonItem alloc] initWithCustomView:updateProgressInd];
	UIBarButtonItem *updateStatusLabelButton = [[UIBarButtonItem alloc] initWithCustomView:
												[self getStatusLabel:@""]];
	
	NSArray *refreshToolbarItems = [[NSArray alloc] initWithObjects: refreshButton, 
								flexibleSpace, updateProgressIndicatorButton, updateStatusLabelButton,
								flexibleSpace, settingButton, nil]; 
	[self setToolbarItems: refreshToolbarItems animated:YES];
	
	[self.tableView addSubview:[self getStatusLabel:@"CA1067 已经起飞"]];

	//release part
	[refreshToolbarItems release];
	[refreshButton release];
	[flexibleSpace release];
	[updateProgressIndicatorButton release];
	[updateStatusLabelButton release];
	[settingButton release];
	
	
	[super viewDidLoad];
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
		//cell.selectionStyle = UITableViewCellSelectionStyleNone;		
		//cell.accessoryView = button;
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
			//flightDetailCell.selectionStyle = UITableViewCellSelectionStyleNone;
		} else if (section == 1) {
			flightDetailCell.statusLabel.text = arrivalDelayAdvanceTime;
			if ([arrivalDelayAdvanceTime rangeOfString:@"延误"].length > 0) {
				flightDetailCell.statusLabel.textColor = [UIColor redColor];
			}
			flightDetailCell.flightBuildingLabel.text = [flightInfo objectForKey:@"arrival_airport_building"];
			flightDetailCell.timePointLabel.text = [flightInfo objectForKey:@"display_arrival_time"];
			flightDetailCell.buildingEntranceLabel.text = [flightInfo objectForKey:@"arrival_airport_entrance_exit"];
			//flightDetailCell.selectionStyle = UITableViewCellSelectionStyleNone;
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
			
			headerLabel.text = [headerLabel.text stringByAppendingString:@" "];
			headerLabel.text = [headerLabel.text stringByAppendingString:[flightInfo objectForKey:@"mileage"]];
			headerLabel.text = [headerLabel.text stringByAppendingString:@"KM 已到"];
			headerLabel.text = [headerLabel.text stringByAppendingString:[flightInfo objectForKey:@"flight_location"]];
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

-(void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	FlightRouteController *routeController = 
		[[FlightRouteController alloc] initWithNibName:@"FlightRouteController" bundle:nil];
	routeController.cityList = self.cityList;

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
	
	routeController.cityLocationList = array;
	[array release];
	
	if ([routeController.cityLocationList count] != [self.cityList count]) {
		return;
	}
	MyNavAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSLog(@"...didSelectRowAtIndexPath");
	[delegate.navController pushViewController:routeController animated:YES];
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
@end
