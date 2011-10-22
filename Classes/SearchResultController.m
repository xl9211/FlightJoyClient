//
//  SearchResultController.m
//  MyNav
//
//  Created by 王 攀 on 11-9-8.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchConditionController.h"
#import "MyNavAppDelegate.h"
#import "RootViewController.h"
#import "SearchResultController.h"
#import "JSON/JSON.h"
#import "SecondLevelViewController.h"
#import "CustomCell.h"

@implementation SearchResultController
@synthesize delegate;
@synthesize flightArray;
@synthesize searchConditionController;
@synthesize updateProgressInd;
@synthesize saveButtonItem;
@synthesize saveAllButtonItem;

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
- (void)getSearchConditionController:(SearchConditionController *)lsearchConditionController{
    searchConditionController = lsearchConditionController;//这样可以用finalRemViewController调用viewOne中的属性.
}

#pragma mark -
#pragma mark View lifecycle
- (void)save {
	if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
	for (int i = 0; i < [self.flightArray count]; i++) {
		NSMutableDictionary *flightInfo = [self.flightArray objectAtIndex:i];
		
		NSString *insertSQL = @"INSERT INTO followedflights (";
		insertSQL = [insertSQL stringByAppendingString:@" takeoff_airport_entrance_exit,"];
		insertSQL = [insertSQL stringByAppendingString:@" takeoff_city,"];
		insertSQL = [insertSQL stringByAppendingString:@" actual_takeoff_time,"];
		insertSQL = [insertSQL stringByAppendingString:@" arrival_airport_entrance_exit,"];
		insertSQL = [insertSQL stringByAppendingString:@" takeoff_airport,"];
		
		insertSQL = [insertSQL stringByAppendingString:@" arrival_airport,"];
		insertSQL = [insertSQL stringByAppendingString:@" flight_no,"];
		insertSQL = [insertSQL stringByAppendingString:@" company,"];
		insertSQL = [insertSQL stringByAppendingString:@" schedule_takeoff_time,"];
		insertSQL = [insertSQL stringByAppendingString:@" arrival_airport_building,"];
		
		insertSQL = [insertSQL stringByAppendingString:@" estimate_takeoff_time,"];
		insertSQL = [insertSQL stringByAppendingString:@" flight_state,"];
		insertSQL = [insertSQL stringByAppendingString:@" flight_location,"];
		insertSQL = [insertSQL stringByAppendingString:@" mileage,"];
		insertSQL = [insertSQL stringByAppendingString:@" actual_arrival_time,"];
		insertSQL = [insertSQL stringByAppendingString:@" plane_model,"];
		insertSQL = [insertSQL stringByAppendingString:@" estimate_arrival_time,"];
		
		insertSQL = [insertSQL stringByAppendingString:@" schedule_arrival_time,"];
		insertSQL = [insertSQL stringByAppendingString:@" takeoff_airport_building,"];
		insertSQL = [insertSQL stringByAppendingString:@" arrival_city,"];
		insertSQL = [insertSQL stringByAppendingString:@" schedule_takeoff_date"];
		insertSQL = [insertSQL stringByAppendingString:@") VALUES ('%@','%@','%@','%@','%@','%@','%@', '%@','%@','%@','%@','%@', '%@','%@','%@','%@','%@', '%@','%@','%@','%@');"];
		
		NSString *update = [[NSString alloc] initWithFormat:
							insertSQL,
							[flightInfo objectForKey:@"takeoff_airport_entrance_exit"], 
							[flightInfo objectForKey:@"takeoff_city"],
							[flightInfo objectForKey:@"actual_takeoff_time"],
							[flightInfo objectForKey:@"arrival_airport_entrance_exit"], 
							[flightInfo objectForKey:@"takeoff_airport"],
							
							[flightInfo objectForKey:@"arrival_airport"], 
							[flightInfo objectForKey:@"flight_no"],
							[flightInfo objectForKey:@"company"],
							[flightInfo objectForKey:@"schedule_takeoff_time"], 
							[flightInfo objectForKey:@"arrival_airport_building"],
							
							[flightInfo objectForKey:@"estimate_takeoff_time"], 
							[flightInfo objectForKey:@"flight_state"],
							[flightInfo objectForKey:@"flight_location"],
							[flightInfo objectForKey:@"mileage"],
							[flightInfo objectForKey:@"actual_arrival_time"],
							[flightInfo objectForKey:@"plane_model"], 
							[flightInfo objectForKey:@"estimate_arrival_time"],
							
							[flightInfo objectForKey:@"schedule_arrival_time"], 
							[flightInfo objectForKey:@"takeoff_airport_building"],
							[flightInfo objectForKey:@"arrival_city"],
							[flightInfo objectForKey:@"schedule_takeoff_date"]
							];
		char * errorMsg;
		NSLog(@"update:%@", update);
		if (sqlite3_exec (database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
		{
			NSAssert1(0, @"Error updating tables: %s", errorMsg);	
		}
	}
	sqlite3_close(database);	
    [self.delegate searchConditionController:self didAddRecipe:nil];
}

- (NSString *)dataFilePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSLog(documentsDirectory);
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self loadToolbarItems];
	[self startUpdateProcess];
	
	/*if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
	char *errorMsg;
	NSString *createSQL = @"CREATE TABLE IF NOT EXISTS FLIGHTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, FLIGHT_NO TEXT, FLIGHT_DATE TEXT);";
	if (sqlite3_exec (database, [createSQL  UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert1(0, @"Error creating table: %s", errorMsg);
	}*/
	
	
	MyNavAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *root = [delegate.navController.viewControllers objectAtIndex:0];
	self.delegate = root;

	/*NSString *jsonStr = [[NSString alloc] initWithFormat:@"[{\"flight_no\":\"%@%@\",\"takeoff_date\":\"%@\"}]",
						self.searchConditionController.searchConditionCompany.abbrev,
						self.searchConditionController.searchConditionFlightNo,
						  self.searchConditionController.searchConditionDate];	
	*/
	saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关注" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
	saveAllButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关注全部" style:UIBarButtonItemStyleDone target:self action:@selector(save)];

	//self.navigationItem.rightBarButtonItem = nil;
	self.title = @"航班";
    //[saveButtonItem release];
	
    //get json
	responseData = [[NSMutableData data] retain];
	NSString *url = [[NSString alloc] initWithString:@"http://118.194.161.243:28888/queryFlightInfoByFlightNO"];
	
	NSString *post = nil;  
	post = [[NSString alloc] initWithFormat:@"flight_no=%@%@&schedule_takeoff_date=%@",
			self.searchConditionController.searchConditionCompany.abbrev,
			self.searchConditionController.searchConditionFlightNo,
			self.searchConditionController.searchConditionDate];
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];  
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];  
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
	[request setURL:[NSURL URLWithString:url]];  
	[request setHTTPMethod:@"POST"]; 
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
	[request setHTTPBody:postData];  
	[[NSURLConnection alloc] initWithRequest:request delegate:self];	
	

}
/*
 * 停止更新航班信息的过程
 */
- (void) stopUpdateProcess {
	NSLog(@"stopUpdateProcess...");
    [updateProgressInd stopAnimating];
	NSString *content = nil;
	int flightCount = [self.flightArray count];
	if (flightCount != 0) {
		content = [[NSString alloc]initWithFormat:@"找到 %d 个航班", flightCount];
		if (flightCount == 1) {
			self.navigationItem.rightBarButtonItem = saveButtonItem;
		} else {
			self.navigationItem.rightBarButtonItem = saveAllButtonItem;
		}
	} else {
		content = [[NSString alloc]initWithString:@"未找到直飞航线！"];
	}

	[self refreshStatusLabelWithText:content];
	[content release];
}

/*
 * 开始更新航班信息的过程
 */
- (void) startUpdateProcess {
    [updateProgressInd startAnimating];
	NSString *content = @"搜索中...";
	[self refreshStatusLabelWithText:content];
	[content release];
}
-(void) refreshStatusLabelWithText : (NSString *)textParam{
	UILabel *updateStatusLabel = [self getStatusLabel:textParam];
	UIBarButtonItem *updateStatusLabelItem = (UIBarButtonItem *)[self.toolbarItems objectAtIndex:2];
	[updateStatusLabelItem initWithCustomView:updateStatusLabel];
	[updateStatusLabel release];
}

-(UILabel *) getStatusLabel :(NSString *)textParam{
	UILabel *retval = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, 120.0f, 21.0f)];
	[retval setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
	[retval setBackgroundColor:[UIColor clearColor]];
	[retval setTextColor:[UIColor whiteColor]];
	[retval setText:textParam];
	[retval setTextAlignment:UITextAlignmentLeft];
	retval.numberOfLines = 0;//这个一定要设成0
	CGSize size = [textParam sizeWithFont:[UIFont systemFontOfSize:14] 
						constrainedToSize:CGSizeMake(200, 1000) 
							lineBreakMode:UILineBreakModeWordWrap];
	CGRect rct = retval.frame;
	rct.size = size;
	retval.frame = rct;
	retval.center = CGPointMake(160, 160);
	return retval;
}

- (void)loadToolbarItems {
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	updateProgressInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[updateProgressInd setHidesWhenStopped:YES];
	
	UIBarButtonItem *updateProgressIndicatorButton = [[UIBarButtonItem alloc] initWithCustomView:updateProgressInd];
	UIBarButtonItem *updateStatusLabelButton = [[UIBarButtonItem alloc] initWithCustomView:
												[self getStatusLabel:@"搜索中..."]];
	
	NSArray *toolbarItems = [[NSArray alloc] initWithObjects:  
								flexibleSpace, updateProgressIndicatorButton, updateStatusLabelButton,
								flexibleSpace, nil]; 
	[self setToolbarItems: toolbarItems animated:YES]; 

}
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
#pragma mark http part
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
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSLog(@"searching...");
	[connection release];
	
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];	
	//responseString = @"[{\"takeoff_delay_advance_time\": \"+00:24\", \"takeoff_airport_entrance_exit\": \"\", \"takeoff_city\": \"\u5317\u4eac\", \"arrival_airport_building\": \"\", \"actual_takeoff_time\": \"08:19\", \"takeoff_airport\": \"\u9996\u90fd\u56fd\u9645\u673a\u573a\", \"flight_state\": \"\u5df2\u7ecf\u5230\u8fbe\", \"flight_no\": \"CA1509\", \"company\": \"\u4e2d\u56fd\u56fd\u9645\u822a\u7a7a\u516c\u53f8\", \"schedule_takeoff_time\": \"07:55\", \"arrival_delay_advance_time\": \"+00:15\", \"estimate_takeoff_time\": \"07:55\", \"arrival_airport\": \"\u8427\u5c71\u56fd\u9645\u673a\u573a\", \"estimate_arrival_time\": \"10:02\", \"actual_arrival_time\": \"10:00\", \"plane_model\": \"A321-213\", \"arrival_airport_entrance_exit\": \"\", \"schedule_arrival_time\": \"09:45\", \"arrival_city\": \"\u676d\u5dde\", \"takeoff_airport_building\": \"T3\"} , {\"takeoff_delay_advance_time\": \"+00:00\", \"takeoff_airport_entrance_exit\": \"\", \"takeoff_city\": \"\u5317\u4eac\", \"arrival_airport_building\": \"T3\", \"actual_takeoff_time\": \"--:--\", \"takeoff_airport\": \"\u9996\u90fd\u56fd\u9645\u673a\u573a\", \"flight_state\": \"\u8ba1\u5212\u822a\u73ed\", \"flight_no\": \"MU7188\", \"company\": \"\u4e2d\u56fd\u4e1c\u65b9\u822a\u7a7a\u516c\u53f8\", \"schedule_takeoff_time\": \"09:05\", \"arrival_delay_advance_time\": \"+00:00\", \"estimate_takeoff_time\": \"--:--\", \"arrival_airport\": \"\u5730\u7a9d\u5821\u56fd\u9645\u673a\u573a\", \"estimate_arrival_time\": \"--:--\", \"actual_arrival_time\": \"--:--\", \"plane_model\": \"333\", \"arrival_airport_entrance_exit\": \"\", \"schedule_arrival_time\": \"13:15\", \"arrival_city\": \"\u4e4c\u9c81\u6728\u9f50\", \"takeoff_airport_building\": \"T2\"} , {\"takeoff_delay_advance_time\": \"+00:00\", \"takeoff_airport_entrance_exit\": \"\", \"takeoff_city\": \"\u676d\u5dde\", \"arrival_airport_building\": \"T3\", \"actual_takeoff_time\": \"--:--\", \"takeoff_airport\": \"\u8427\u5c71\u56fd\u9645\u673a\u573a\", \"flight_state\": \"\u8ba1\u5212\u822a\u73ed\", \"flight_no\": \"CA1703\", \"company\": \"\u4e2d\u56fd\u56fd\u9645\u822a\u7a7a\u516c\u53f8\", \"schedule_takeoff_time\": \"09:00\", \"arrival_delay_advance_time\": \"+00:00\", \"estimate_takeoff_time\": \"--:--\", \"arrival_airport\": \"\u9996\u90fd\u56fd\u9645\u673a\u573a\", \"estimate_arrival_time\": \"--:--\", \"actual_arrival_time\": \"--:--\", \"plane_model\": \"A320-214\", \"arrival_airport_entrance_exit\": \"\", \"schedule_arrival_time\": \"10:55\", \"arrival_city\": \"\u5317\u4eac\", \"takeoff_airport_building\": \"\"} ]";
	
	NSLog(responseString);
	[responseData release];
	
	NSError *error;
	SBJSON *json = [[SBJSON new] autorelease];
	NSArray *flightInfos = [json objectWithString:responseString error:&error];
	//[responseString release];	
	
	if (flightInfos == nil) {
		NSLog([NSString stringWithFormat:@"JSON parsing failed: %@", [error localizedDescription]]);
	} else {		
		for (int i = 0; i < [flightInfos count]; i++) {
			NSMutableDictionary *flightInfo = [flightInfos objectAtIndex:i];
			NSLog([flightInfo objectForKey:@"takeoff_city"]);
			[array addObject:flightInfo];
		}
	}
	self.flightArray = array;
	[array release];
	[self.tableView reloadData];
	[self stopUpdateProcess];
}
//HTTP Response - end

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [flightArray count];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return kTableViewRowHeight;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    NSLog(@"cellForRowAtIndexPath...");
	
	static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
	CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
	if (cell == nil) {
		//cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:RootViewControllerCell] autorelease];
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
	//Configue the cell
	if (self.flightArray == nil || [self.flightArray count] == 0 ) {
		self.flightArray = [[NSMutableArray alloc] init];
		return cell;
	}
	
	NSDictionary* one = [flightArray objectAtIndex:indexPath.row];
	
	NSUInteger row = [indexPath row];
	//SecondLevelViewController *controller = [controllers objectAtIndex:row];
	NSString *nameLabelText = [NSString stringWithFormat:@"%@",[one objectForKey:@"takeoff_city"]];
	nameLabelText = [nameLabelText stringByAppendingString:@" 飞往 "];
	nameLabelText = [nameLabelText stringByAppendingString:[one objectForKey:@"arrival_city"]];
	cell.nameLabel.text = nameLabelText;
	cell.takeoffDateLabel.text = [one objectForKey:@"flight_state"];
	cell.flightNOLabel.text = [[one objectForKey:@"company"] stringByAppendingString:[one objectForKey:@"flight_no"]];
	cell.takeoffTimeLabel.text = [one objectForKey:@"schedule_takeoff_time"];
	cell.landTimeLabel.text = [one objectForKey:@"schedule_arrival_time"];
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;		

	NSLog(@"...cellForRowAtIndexPath");
	
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
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
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
	self.flightArray = nil;
}


- (void)dealloc {
	[self.flightArray release];
	[self.saveButtonItem release];
	[self.saveAllButtonItem release];
    [super dealloc];
}


@end

