//
//  SearchConditionCompanyController.m
//  MyNav
//
//  Created by 王 攀 on 11-9-7.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchConditionCompanyController.h"
#import "RootViewController.h"
#import "MyNavAppDelegate.h"
#import "JSON/JSON.h"

@implementation SearchConditionCompanyController
@synthesize companyListData;
@synthesize searchConditionCompany;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {	
	//get json
	responseData = [[NSMutableData data] retain];
	NSString *url = [[NSString alloc] initWithString:@"http://118.194.161.243:28888/getCompanyList"];
	//NSString *url = [[NSString alloc] initWithString:@"http://specialbrian.gicp.net:10001/getCompanyList"];
	//NSString *url = [[NSString alloc] initWithString:@"http://192.168.1.100:10001/getCompanyList"];
	
	NSString *post = nil;  
	post = [[NSString alloc] initWithString:@"lang=zh"];
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];  
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];  
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
	[request setURL:[NSURL URLWithString:url]];  
	[request setHTTPMethod:@"POST"]; 
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
	[request setHTTPBody:postData];  
	[[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	//toolbar text
	UILabel *updateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, self.view.frame.size.width, 21.0f)];
	[updateTimeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
	[updateTimeLabel setBackgroundColor:[UIColor clearColor]];
	[updateTimeLabel setTextColor:[UIColor whiteColor]];
	[updateTimeLabel setText:@"请选择航空公司"];
	[updateTimeLabel setTextAlignment:UITextAlignmentCenter];
	UIBarButtonItem *updateTimeLabelButton = [[UIBarButtonItem alloc] initWithCustomView:updateTimeLabel];
	NSArray *items = [[NSArray alloc] initWithObjects: updateTimeLabelButton, nil]; 
	[self setToolbarItems:items animated:YES];
	
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
//HTTP Response - begin
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//label.text = [NSString stringWithFormat:@"Connection failed: %@", [error description]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"connectionDidFinishLoading...");
	[connection release];
	
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	//responseString = @"[{\"takeoff_delay_advance_time\": \"+00:24\", \"takeoff_airport_entrance_exit\": \"\", \"takeoff_city\": \"\u5317\u4eac\", \"arrival_airport_building\": \"\", \"actual_takeoff_time\": \"08:19\", \"takeoff_airport\": \"\u9996\u90fd\u56fd\u9645\u673a\u573a\", \"flight_state\": \"\u5df2\u7ecf\u5230\u8fbe\", \"flight_no\": \"CA1509\", \"company\": \"\u4e2d\u56fd\u56fd\u9645\u822a\u7a7a\u516c\u53f8\", \"schedule_takeoff_time\": \"07:55\", \"arrival_delay_advance_time\": \"+00:15\", \"estimate_takeoff_time\": \"07:55\", \"arrival_airport\": \"\u8427\u5c71\u56fd\u9645\u673a\u573a\", \"estimate_arrival_time\": \"10:02\", \"actual_arrival_time\": \"10:00\", \"plane_model\": \"A321-213\", \"arrival_airport_entrance_exit\": \"\", \"schedule_arrival_time\": \"09:45\", \"arrival_city\": \"\u676d\u5dde\", \"takeoff_airport_building\": \"T3\"} , {\"takeoff_delay_advance_time\": \"+00:00\", \"takeoff_airport_entrance_exit\": \"\", \"takeoff_city\": \"\u5317\u4eac\", \"arrival_airport_building\": \"T3\", \"actual_takeoff_time\": \"--:--\", \"takeoff_airport\": \"\u9996\u90fd\u56fd\u9645\u673a\u573a\", \"flight_state\": \"\u8ba1\u5212\u822a\u73ed\", \"flight_no\": \"MU7188\", \"company\": \"\u4e2d\u56fd\u4e1c\u65b9\u822a\u7a7a\u516c\u53f8\", \"schedule_takeoff_time\": \"09:05\", \"arrival_delay_advance_time\": \"+00:00\", \"estimate_takeoff_time\": \"--:--\", \"arrival_airport\": \"\u5730\u7a9d\u5821\u56fd\u9645\u673a\u573a\", \"estimate_arrival_time\": \"--:--\", \"actual_arrival_time\": \"--:--\", \"plane_model\": \"333\", \"arrival_airport_entrance_exit\": \"\", \"schedule_arrival_time\": \"13:15\", \"arrival_city\": \"\u4e4c\u9c81\u6728\u9f50\", \"takeoff_airport_building\": \"T2\"} , {\"takeoff_delay_advance_time\": \"+00:00\", \"takeoff_airport_entrance_exit\": \"\", \"takeoff_city\": \"\u676d\u5dde\", \"arrival_airport_building\": \"T3\", \"actual_takeoff_time\": \"--:--\", \"takeoff_airport\": \"\u8427\u5c71\u56fd\u9645\u673a\u573a\", \"flight_state\": \"\u8ba1\u5212\u822a\u73ed\", \"flight_no\": \"CA1703\", \"company\": \"\u4e2d\u56fd\u56fd\u9645\u822a\u7a7a\u516c\u53f8\", \"schedule_takeoff_time\": \"09:00\", \"arrival_delay_advance_time\": \"+00:00\", \"estimate_takeoff_time\": \"--:--\", \"arrival_airport\": \"\u9996\u90fd\u56fd\u9645\u673a\u573a\", \"estimate_arrival_time\": \"--:--\", \"actual_arrival_time\": \"--:--\", \"plane_model\": \"A320-214\", \"arrival_airport_entrance_exit\": \"\", \"schedule_arrival_time\": \"10:55\", \"arrival_city\": \"\u5317\u4eac\", \"takeoff_airport_building\": \"\"} ]";
	
	NSLog(responseString);
	
	NSError *error;
	SBJSON *json = [[SBJSON new] autorelease];
	NSArray *companyInfos = [json objectWithString:responseString error:&error];
	//[responseString release];	
	
	if (companyInfos == nil) {
		NSLog([NSString stringWithFormat:@"JSON parsing failed: %@", [error localizedDescription]]);
	} else {		
		NSMutableArray *companyArray = [[NSMutableArray alloc] init];
		for (int i = 0; i < [companyInfos count]; i++) {
			NSMutableDictionary *companyInfo = [companyInfos objectAtIndex:i];
			NSString *abbrev = [companyInfo objectForKey:@"short"];
			NSString *chname = [companyInfo objectForKey:@"full"];			
			Company *company = [[Company alloc]init];
			company.chname = chname;
			company.abbrev = abbrev;
			[companyArray addObject:company];
		}
		self.companyListData = companyArray;
		[companyArray release];
	}
	[self.tableView reloadData];
}
//HTTP Response - end

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.companyListData count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSUInteger row = [indexPath row];
	Company *company = [companyListData objectAtIndex:row];
	cell.text = [company.abbrev stringByAppendingFormat:@" - %@", company.chname];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.

	NSUInteger row = [indexPath row];
	Company *company = [companyListData objectAtIndex:row];

	self.searchConditionCompany.abbrev = company.abbrev;
	self.searchConditionCompany.chname = company.chname;
	MyNavAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *root = [delegate.navController.viewControllers objectAtIndex:0];
	[root.searchNavController popViewControllerAnimated:YES];

	NSArray *allControllers = root.searchNavController.viewControllers;
	SearchConditionController *parent = [allControllers lastObject];
	[parent.tableView reloadData];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[responseData release];
    [super dealloc];
}


@end

