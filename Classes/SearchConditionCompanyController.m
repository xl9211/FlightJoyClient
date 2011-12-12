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
#import "JSON.h"

@implementation SearchConditionCompanyController
@synthesize tableView;
@synthesize search;
@synthesize companyListData;
@synthesize searchConditionCompany;

#pragma mark -
#pragma mark Initialization

- (void)resetSearch
{
    companyListData = [[NSMutableArray alloc] init];
    [tableView reloadData];
}
- (NSString *)dataFilePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

- (void)handleSearchForTerm:(NSString *)searchTerm
{
    companyListData = [[NSMutableArray alloc] init];
    //查询数据库中的匹配记录
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
	NSString *query = [NSString stringWithFormat:@"select * from company where fullname like '%%%@%%' or shortname like '%%%@%%';", searchTerm, searchTerm];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int recordPointer = 0;
			int recordId = sqlite3_column_int(statement, recordPointer++);
            
			//读取char
			char *shortnameChar = (char *)sqlite3_column_text(statement, recordPointer++);
            char *fullnameChar = (char *)sqlite3_column_text(statement, recordPointer++);
            
			//生成String
			NSString *recordIdStr = [[NSString alloc] initWithFormat:@"%d", recordId];
			NSString *shortnameStr = [[NSString alloc] initWithUTF8String:shortnameChar];
            NSString *fullnameStr = [[NSString alloc] initWithUTF8String:fullnameChar];
            
			Company *company = [[Company alloc] init];
            company.shortname = shortnameStr;
            company.fullname = fullnameStr;
			[companyListData addObject:company];
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);	
    DLog(@"%d", [companyListData count]);
	[tableView reloadData];
}

#pragma mark -
#pragma mark Search Bar Delegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    DLog(@"searchBarSearchButtonClicked...");
	NSString *searchTerm = [searchBar text];
	[self handleSearchForTerm:searchTerm];
    [search resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    DLog(@"searchBarCancelButtonClicked...");
	search.text = @"";
	[self resetSearch];
	[searchBar resignFirstResponder];
}
//假设此时数据库中已经存储了全部航空公司数据
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchTerm
{
    //DLog(@"searchBar:textDidChange...");
    
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
#pragma mark 软键盘相关处理
- (void) registerForKeyboardNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
}


- (void) keyboardWasShown:(NSNotification *) notif{
    NSDictionary *info = [notif userInfo];
    
    NSValue *value = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    CGRect tableViewFrame= [tableView frame];
    tableViewFrame.size.height = tableViewOriginHeight - keyboardSize.height - 43;
    tableView.frame = tableViewFrame;
    keyboardWasShown = YES;
}

- (void) keyboardWasHidden:(NSNotification *) notif{
    NSDictionary *info = [notif userInfo];
    
    NSValue *value = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    CGRect tableViewFrame= [tableView frame];
    tableViewFrame.size.height = tableViewOriginHeight - 86;
    tableView.frame = tableViewFrame;
    keyboardWasShown = NO;
}

#pragma mark -
#pragma mark 数据源获取相关操作
- (BOOL)companyTableExists {
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
    
	NSString *query = @"select count(*) from sqlite_master where type='table' and name = 'company';";
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

//创建机场信息表
- (void)createCompanyTable {
	if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
	char *errorMsg;
	NSString *createSQL = @"CREATE TABLE IF NOT EXISTS company (";
	createSQL = [createSQL stringByAppendingString:@" ID INTEGER PRIMARY KEY AUTOINCREMENT,"];
	
	createSQL = [createSQL stringByAppendingString:@" shortname TEXT,"];
	createSQL = [createSQL stringByAppendingString:@" fullname TEXT"];
    
	createSQL = [createSQL stringByAppendingString:@");"];
	
	if (sqlite3_exec (database, [createSQL  UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert1(0, @"Error creating table: %s", errorMsg);
	}
    sqlite3_close(database);	
}

- (void)loadCompaniesFromServer
{
    //get json
	responseData = [[NSMutableData data] retain];
	NSString *url = [[NSString alloc] initWithString:@"http://fd.tourbox.me/getCompanyList"];
	
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

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {	
    //更新到最新机场列表，并入库
    if ( ![self companyTableExists] ) {
        [self createCompanyTable];
        [self loadCompaniesFromServer];
    }
    
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
	
    CGRect tableViewFrame= [tableView frame];
    tableViewOriginHeight = tableViewFrame.size.height;
    [self registerForKeyboardNotifications];
    [search becomeFirstResponder];
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
	DLog(@"connectionDidFinishLoading...");
	[connection release];
	
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	DLog(responseString);
	
	NSError *error;
	//SBJSON *json = [[SBJSON new] autorelease];
    NSArray *companyInfos = [responseString JSONValue]; 

    //NSArray *companyInfos = [json objectWithString:responseString error:&error];
	
	if (companyInfos == nil) {
		DLog([NSString stringWithFormat:@"JSON parsing failed: %@", [error localizedDescription]]);
	} else {		
		for (int i = 0; i < [companyInfos count]; i++) {
			NSMutableDictionary *companyInfo = [companyInfos objectAtIndex:i];
			NSString *shortname = [companyInfo objectForKey:@"short"];	
            NSString *fullname = [companyInfo objectForKey:@"full"];			
            
            //入库
            if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
                sqlite3_close(database);
                NSAssert(0, @"Failed to open database");
            }
            
            NSString *insertSQL = @"INSERT OR REPLACE INTO company (";
            insertSQL = [insertSQL stringByAppendingString:@" shortname,"];
            insertSQL = [insertSQL stringByAppendingString:@" fullname"];
            insertSQL = [insertSQL stringByAppendingString:@") VALUES ('%@','%@');"];
            
            NSString *update = [[NSString alloc] initWithFormat:insertSQL,
                                shortname, fullname ];
            char * errorMsg;
            //DLog(@"update...");
            
            if (sqlite3_exec (database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                NSAssert1(0, @"Error updating tables: %s", errorMsg);
                sqlite3_close(database);
            }
            sqlite3_close(database);	
		}
	}
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
	cell.text = [company.shortname stringByAppendingFormat:@" - %@", company.fullname];
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

	self.searchConditionCompany.shortname = company.shortname;
	self.searchConditionCompany.fullname = company.fullname;
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

