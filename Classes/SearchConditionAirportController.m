//
//  SearchConditionAirportController.m
//  MyNav
//
//  Created by 王 攀 on 11-10-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SearchConditionAirportController.h"

@implementation SearchConditionAirportController
@synthesize tableView;
@synthesize search;
@synthesize airportArray;
@synthesize searchConditionAirport;

#pragma mark -
#pragma mark Custom Methods
- (void)resetSearch
{
/*	self.names = [self.allNames mutableDeepCopy];
    
	NSMutableArray *keyArray = [[NSMutableArray alloc] init];
	[keyArray addObjectsFromArray:[[self.allNames allKeys] sortedArrayUsingSelector:@selector(compare:)]];
	self.keys = keyArray;
	[keyArray release];
 */
}
- (void)handleSearchForTerm:(NSString *)searchTerm
{
    airportArray = [[NSMutableArray alloc] init];
    //查询数据库中的匹配记录
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
	NSString *query = [NSString stringWithFormat:@"select * from airport where city like '%@%%' or fullname like '%@%%' or shortname like '%@%%';", searchTerm, searchTerm, searchTerm];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int recordPointer = 0;
			int recordId = sqlite3_column_int(statement, recordPointer++);
            
			//读取char
			char *shortnameChar = (char *)sqlite3_column_text(statement, recordPointer++);
            char *fullnameChar = (char *)sqlite3_column_text(statement, recordPointer++);
			char *cityChar = (char *)sqlite3_column_text(statement, recordPointer++);

			//生成String
			NSString *recordIdStr = [[NSString alloc] initWithFormat:@"%d", recordId];
			NSString *shortnameStr = [[NSString alloc] initWithUTF8String:shortnameChar];
            NSString *fullnameStr = [[NSString alloc] initWithUTF8String:fullnameChar];
			NSString *cityStr = [[NSString alloc] initWithUTF8String:cityChar];
            
			Airport *airport = [[Airport alloc] init];
            airport.shortname = shortnameStr;
            airport.fullname = fullnameStr;
            airport.city = cityStr;
			[airportArray addObject:airport];
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);	
    NSLog(@"%d", [airportArray count]);
	[tableView reloadData];
}

#pragma mark -
#pragma mark Search Bar Delegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBarSearchButtonClicked...");
	NSString *searchTerm = [searchBar text];
	[self handleSearchForTerm:searchTerm];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBarCancelButtonClicked...");
	search.text = @"";
	[self resetSearch];
	[tableView reloadData];
	[searchBar resignFirstResponder];
}
//假设此时数据库中已经存储了全部机场数据
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchTerm
{
    //NSLog(@"searchBar:textDidChange...");

	int length = [[searchTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
    
	if (length == 0 || searchTerm == nil)
	{	
		[self resetSearch];
		[tableView reloadData];
		return;
	}
	[self handleSearchForTerm:searchTerm];
    
}

#pragma mark -
#pragma mark UIViewController Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadAirportsFromServer
{
    responseData = [[NSMutableData data] retain];
	NSString *url = [[NSString alloc] initWithString:@"http://118.194.161.243:28888/getAirportList"];
	
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
}

- (BOOL)airportTableExists {
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
    
	NSString *query = @"select count(*) from sqlite_master where type='table' and name = 'airport';";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int tableNum = sqlite3_column_int(statement, 0);
            if (tableNum == 1) {
                sqlite3_finalize(statement);
                sqlite3_close(database);	
                return YES;
            }
		}
	}
    sqlite3_finalize(statement);
    sqlite3_close(database);	
    return NO;
}
- (void)viewDidLoad
{
    NSLog(@"viewDidLoad...");
    //check if airport table exist
    //select count(*) from sqlite_master where type='table' and name = 'cityinfo';
    if ( ![self airportTableExists] ) {
        [self createAirportTable];
        [self loadAirportsFromServer];
    }
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark HTTP Response Methods
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
- (NSString *)dataFilePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	//NSLog(documentsDirectory);
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

//创建机场信息表
- (void)createAirportTable {
	if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
	char *errorMsg;
	NSString *createSQL = @"CREATE TABLE IF NOT EXISTS airport (";
	createSQL = [createSQL stringByAppendingString:@" ID INTEGER PRIMARY KEY AUTOINCREMENT,"];
	
	createSQL = [createSQL stringByAppendingString:@" shortname TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" fullname TEXT,"];
    createSQL = [createSQL stringByAppendingString:@" city TEXT"];

	createSQL = [createSQL stringByAppendingString:@");"];
	
	if (sqlite3_exec (database, [createSQL  UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert1(0, @"Error creating table: %s", errorMsg);
	}
    sqlite3_close(database);	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"connectionDidFinishLoading...");
	[connection release];
	
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	NSError *error;
	SBJSON *json = [[SBJSON new] autorelease];
	NSArray *airportInfos = [json objectWithString:responseString error:&error];
	
	if (airportInfos == nil) {
		NSLog([NSString stringWithFormat:@"JSON parsing failed: %@", [error localizedDescription]]);
	} else {		
		NSMutableArray *airportArray = [[NSMutableArray alloc] init];
		for (int i = 0; i < [airportInfos count]; i++) {
			NSMutableDictionary *airportInfo = [airportInfos objectAtIndex:i];
			NSString *city = [airportInfo objectForKey:@"city"];
			NSString *shortname = [airportInfo objectForKey:@"short"];	
            NSString *fullname = [airportInfo objectForKey:@"full"];			
            
            //入库
            if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
                sqlite3_close(database);
                NSAssert(0, @"Failed to open database");
            }
            
            NSString *insertSQL = @"INSERT OR REPLACE INTO airport (";
            insertSQL = [insertSQL stringByAppendingString:@" city,"];
            insertSQL = [insertSQL stringByAppendingString:@" shortname,"];
            insertSQL = [insertSQL stringByAppendingString:@" fullname"];
            insertSQL = [insertSQL stringByAppendingString:@") VALUES ('%@','%@','%@');"];
            
            NSString *update = [[NSString alloc] initWithFormat:insertSQL,
                                city, shortname, fullname ];
            char * errorMsg;
            
            if (sqlite3_exec (database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                NSAssert1(0, @"Error updating tables: %s", errorMsg);
                sqlite3_close(database);
            }
            sqlite3_close(database);	
		}
		//self.companyListData = airportArray;
		[airportArray release];
	}
    
	[self.tableView reloadData];
}
//HTTP Response - end

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [airportArray count];
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];
	Airport *airport = [airportArray objectAtIndex:row];
	
	static NSString *sectionsTableIdentifier = @"sectionsTableIdentifier";
	
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier: sectionsTableIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero 
									   reuseIdentifier: sectionsTableIdentifier] autorelease];
	}
	
	cell.text = [[NSString alloc] initWithFormat:@"%@ %@ - %@", [airport fullname], [airport shortname], [airport city]];
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    NSLog(@"SearchConditionAirportController.didSelectRowAtIndexPath...");
	NSUInteger row = [indexPath row];

	Airport *airport = [airportArray objectAtIndex:row];
    
	MyNavAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *root = [delegate.navController.viewControllers objectAtIndex:0];
	[root.searchNavController popViewControllerAnimated:YES];
    
	NSArray *allControllers = root.searchNavController.viewControllers;
	SearchConditionController *parent = [allControllers lastObject];
    if ([self.title isEqualToString:@"出发"]) {
        parent.searchConditionTakeoffAirport = airport;
    } else {
        parent.searchConditionArrivalAirport = airport;
    }

	[parent.tableView reloadData];
}
@end
