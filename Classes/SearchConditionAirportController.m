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
    airportArray = [[NSMutableArray alloc] init];
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
    airportArray = [[NSMutableArray alloc] init];
    //查询数据库中的匹配记录
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
	NSString *query = [NSString stringWithFormat:@"select * from airport where city like '%%%@%%' or fullname like '%%%@%%' or shortname like '%%%@%%';", searchTerm, searchTerm, searchTerm];
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
    [search resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBarCancelButtonClicked...");
	search.text = @"";
	[self resetSearch];
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


- (void)viewDidLoad
{
    NSLog(@"viewDidLoad...");
    CGRect tableViewFrame= [tableView frame];
    tableViewOriginHeight = tableViewFrame.size.height;
    [self registerForKeyboardNotifications];
    [search becomeFirstResponder];
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
    //[scrollView scrollRectToVisible:inputElementFrame animated:YES];
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
@end
