    //
//  SearchConditionController.m
//  MyNav
//
//  Created by 王 攀 on 11-8-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "MyNavAppDelegate.h"
#import "SearchConditionController.h"
#import "SearchConditionCompanyController.h"
#import "SearchConditionDateController.h"
#import "SearchConditionAirportController.h"
//#import "SearchResultController.h"
#import "QueryResultController.h"
#import "CustomCell.h"
#import "RootViewController.h"

@implementation SearchConditionController
@synthesize delegate;
@synthesize searchConditionCompany;
@synthesize searchConditionDate;
@synthesize searchConditionTakeoffAirport;
@synthesize searchConditionArrivalAirport;

@synthesize tempValues;
@synthesize textFieldBeingEdited;
@synthesize searchConditionFlightNo;
@synthesize tableView;

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"SearchCondition viewDidLoad!");
    UINavigationController *nav = (UINavigationController *)self.parentViewController;
    nav.view.backgroundColor = [ UIColor colorWithPatternImage:[UIImage imageNamed:@"china3.jpg"] ];

    
    NSDate *curDate = [NSDate date];//获取当前日期
    NSDateFormatter *formater = [[ NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd"];//这里去掉 具体时间 保留日期
    NSString *curDateString = [formater stringFromDate:curDate];
    self.searchConditionDate = curDateString;                
	
	UIColor *backgroundColor = [UIColor colorWithRed:0 green:0.2f blue:0.55f alpha:1];
	// Configure the navigation bar
	self.searchConditionCompany = [[Company alloc] init];
    self.navigationItem.title = @"新增航班";
	[self.navigationController.navigationBar setTintColor:backgroundColor]; 
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    [cancelButtonItem release];
    
    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStyleDone target:self action:@selector(search)];
    self.navigationItem.rightBarButtonItem = searchButtonItem;
    [searchButtonItem release];
	
	UILabel *updateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, self.view.frame.size.width, 21.0f)];
	[updateTimeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
	[updateTimeLabel setBackgroundColor:[UIColor clearColor]];
	[updateTimeLabel setTextColor:[UIColor whiteColor]];
	[updateTimeLabel setText:@"轻摇手机随机搜索一架航班"];
	[updateTimeLabel setTextAlignment:UITextAlignmentCenter];
	
	UIBarButtonItem *updateTimeLabelButton = [[UIBarButtonItem alloc] initWithCustomView:updateTimeLabel];
	NSArray *items = [[NSArray alloc] initWithObjects: updateTimeLabelButton, nil]; 
	[self.navigationController.toolbar setTintColor:backgroundColor]; 

	[self setToolbarItems:items animated:YES];
	
    [super viewDidLoad];
}
- (void)cancel {
    [self.delegate searchConditionController:self didAddRecipe:nil];
}
- (void)search {
	
	if (textFieldBeingEdited != nil)
	{
		self.searchConditionFlightNo = textFieldBeingEdited.text;
	}
	
	NSString *msg = nil;
	BOOL valid = YES;
    
    if (m_selectedSegmentIndex == 0) {//按航班号查询
        if (self.searchConditionCompany.abbrev == nil 
            || [self.searchConditionCompany.abbrev isEqualToString:@""] ) {
            valid = NO;
            msg = [[NSString alloc] initWithString:@"请选择航空公司。"];
        } else if (self.searchConditionFlightNo == nil 
                   || [self.searchConditionFlightNo isEqualToString:@""] ) {
            valid = NO;
            msg = [[NSString alloc] initWithString:@"请输入航班号。"];
        } else if (self.searchConditionDate == nil 
                   || [self.searchConditionDate isEqualToString:@""] ) {
            valid = NO;
            msg = [[NSString alloc] initWithString:@"请选择出发日期。"];
        }
    } else {//按航段查询
        if (self.searchConditionTakeoffAirport.shortname == nil 
            || [self.searchConditionTakeoffAirport.shortname isEqualToString:@""] ) {
            valid = NO;
            msg = [[NSString alloc] initWithString:@"请选择出发机场。"];
        } else if (self.searchConditionArrivalAirport.shortname == nil 
                   || [self.searchConditionArrivalAirport.shortname isEqualToString:@""] ) {
            valid = NO;
            msg = [[NSString alloc] initWithString:@"请输入目的机场。"];
        } else if (self.searchConditionDate == nil 
                   || [self.searchConditionDate isEqualToString:@""] ) {
            valid = NO;
            msg = [[NSString alloc] initWithString:@"请选择出发日期。"];
        }
    }

	if (!valid) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:msg 
							  message:@"" 
							  delegate:self 
							  cancelButtonTitle:@"确定" 
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		[msg release];
		return;
	}
	
    /*
	SearchResultController *searchResultController = 
	[[SearchResultController alloc] initWithStyle:UITableViewStylePlain];*/
    QueryResultController *searchResultController = 
	[[QueryResultController alloc] initWithStyle:UITableViewStylePlain];
	
    if (m_selectedSegmentIndex == 0) {//按航班号查询
        [searchResultController setQueryType:0];
    } else if (m_selectedSegmentIndex == 1) {//按航线查询
        [searchResultController setQueryType:1];
    }
	[searchResultController getSearchConditionController:self];
	[self.navigationController pushViewController:searchResultController animated:YES];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
- (void)didFinish:sender
{
    [self dismissModalViewControllerAnimated:YES];
}
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

- (BOOL)searchedFlightsTableExists {
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
    
	NSString *query = @"select count(*) from sqlite_master where type='table' and name = 'searchedflights';";
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

- (NSString *)dataFilePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

/*在搜索结果页返回上一级查询条件页面*/
- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillDisappear...");
    
    if ([self searchedFlightsTableExists]) {
        char * errorMsg;
        if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
            sqlite3_close(database);
            NSAssert(0, @"Failed to open database");
        }
        //delete from searchedflights;
        NSString *delete = [[NSString alloc] initWithString:@"delete from searchedflights;"];
        if (sqlite3_exec (database, [delete UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
        {
            NSAssert1(0, @"Error deleting tables: %s", errorMsg);	
        }
        sqlite3_close(database);
    }    
    
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Table Data Source Methods
-(IBAction)textFieldDone:(id)sender
{

}

- (IBAction)segmentControlDidChanged:(id)sender
{
    NSLog(@"segmentControlDidChanged...");
	UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
	switch (segmentControl.selectedSegmentIndex) {
		case 0:
            m_selectedSegmentIndex = 0;
			break;
		case 1:
            m_selectedSegmentIndex = 1;
			break;
		default:
			break;
	}
	[tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"SearchConditionController.cellForRowAtIndexPath...");
    
	NSUInteger row = [indexPath row];
	static NSString * SearchConditionFieldCellIdentifier = @"SearchConditionFieldCellIdentifier";

    UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:SearchConditionFieldCellIdentifier] autorelease];

    UIColor *aliveColor = [UIColor colorWithRed:0 green:0.2f blue:0.55f alpha:1];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
    label.textAlignment = UITextAlignmentRight;
    label.tag = kLabelTag;
    label.font = [UIFont boldSystemFontOfSize:14];
    //label.textColor = [UIColor grayColor];
    label.textColor = aliveColor;
    //[aliveColor release];
    [cell.contentView addSubview:label];
	    
    cell.backgroundColor = [UIColor whiteColor]; 
    cell.textColor = [UIColor blackColor];

    switch (row) {
        case 0:
            label.text = @"航空公司";
            label.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(90, 12, 200, 25)];
            textField.font = [UIFont boldSystemFontOfSize:16];
            textField.clearsOnBeginEditing = NO;
            if (m_selectedSegmentIndex == 0) {//按航班号查询
                textField.placeholder = @"必填";
            } else { //按航段查询
                textField.placeholder = @"选填";
            }
            textField.userInteractionEnabled = NO;
            
            textField.tag = kSearchConditionCompanyTag;
            textField.text = self.searchConditionCompany.abbrev;

            [cell.contentView addSubview:textField];
            
            break;
        case 1:
            textField = [[UITextField alloc] initWithFrame:CGRectMake(90, 12, 200, 25)];
            textField.font = [UIFont boldSystemFontOfSize:16];
            textField.clearsOnBeginEditing = NO;
            textField.placeholder = @"必填";
            
            if (m_selectedSegmentIndex == 0) {//按航班号查询
                label.text = @"航班号";
                label.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                [textField setDelegate:self];

                //textField.returnKeyType = UIReturnKeyDone;
                [textField addTarget:self 
                              action:@selector(textFieldDone:) 
                    forControlEvents:UIControlEventEditingDidEndOnExit];
                textField.tag = kSearchConditionFlightNoTag;
                [textField setText:self.searchConditionFlightNo];

            } else { //按航段查询
                label.text = @"出发";
                label.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                textField.userInteractionEnabled = NO;
                textField.tag = kSearchConditionFromRouteTag;
                [textField setText:self.searchConditionTakeoffAirport.fullname];
            }
            [cell.contentView addSubview:textField];

            break;
        case 2:
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            textField = [[UITextField alloc] initWithFrame:CGRectMake(90, 12, 200, 25)];
            textField.font = [UIFont boldSystemFontOfSize:16];
            textField.clearsOnBeginEditing = NO;
            textField.placeholder = @"必填";
            textField.userInteractionEnabled = NO;
            
            if (m_selectedSegmentIndex == 0) {//按航班号查询
                label.text = @"出发日期";
                label.backgroundColor = [UIColor clearColor];
                textField.tag = kSearchConditionDateTag;
                [textField setText:self.searchConditionDate];
            } else { //按航段查询
                label.text = @"目的";
                label.backgroundColor = [UIColor clearColor];
                textField.tag = kSearchConditionToRouteTag;   
                [textField setText:self.searchConditionArrivalAirport.fullname];
            }
            
            [cell.contentView addSubview:textField];
            break;
        case 3:
            label.text = @"出发日期";
            label.backgroundColor = [UIColor clearColor];

            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            textField = [[UITextField alloc] initWithFrame:CGRectMake(90, 12, 200, 25)];
            textField.font = [UIFont boldSystemFontOfSize:16];
            textField.clearsOnBeginEditing = NO;
            textField.placeholder = @"必填";
            [textField setText:self.searchConditionDate];
            textField.userInteractionEnabled = NO;
            
            textField.tag = kSearchConditionDateRouteTag;
            [cell.contentView addSubview:textField];				
            break;
        default:
            break;
    }//switch
    
    cell.image = nil;
    [label release];
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    switch (m_selectedSegmentIndex) {
        case 0:
            return 3;
        case 1:
            return 4;
        default:
            return 3;
    }
}

#pragma mark -
#pragma mark Table View Delegate Methods
//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
//	return UITableViewCellAccessoryDisclosureIndicator;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"didSelectRowAtIndexPath...");
	MyNavAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *root = [delegate.navController.viewControllers objectAtIndex:0];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

	NSUInteger row = [indexPath row];
	UILabel *label = [[cell.contentView subviews] objectAtIndex:0];
    
	if (row == 0) {
		SearchConditionCompanyController *searchCCC = [[SearchConditionCompanyController alloc]initWithStyle:UITableViewStyleGrouped];
		searchCCC.title = label.text;
		searchCCC.searchConditionCompany = self.searchConditionCompany;
		[root.searchNavController pushViewController:searchCCC animated:YES];
        
	} else if (row == 1) {
        if (m_selectedSegmentIndex == 1) {
            SearchConditionAirportController *searchCAC = [[SearchConditionAirportController alloc] initWithNibName:@"SearchConditionAirportController" bundle:nil];
            searchCAC.title = label.text;
            //searchCAC.searchConditionTakeoffAirport = self.searchConditionTakeoffAirport;
            [root.searchNavController pushViewController:searchCAC animated:YES];
        }
        
	} else if (row == 2) {
        if (m_selectedSegmentIndex == 0) {
            SearchConditionDateController *searchCDC = [[SearchConditionDateController alloc] initWithNibName:@"SearchConditionDateController" bundle:nil];
            searchCDC.title = label.text;
            [root.searchNavController pushViewController:searchCDC animated:YES];
        } else  {
            SearchConditionAirportController *searchCAC = [[SearchConditionAirportController alloc] initWithNibName:@"SearchConditionAirportController" bundle:nil];
            searchCAC.title = label.text;
            //searchCAC.searchConditionAirport = self.searchConditionAirport;
            [root.searchNavController pushViewController:searchCAC animated:YES];
        }
        
	} else if (row == 3) {
		SearchConditionDateController *searchCDC = [[SearchConditionDateController alloc] initWithNibName:@"SearchConditionDateController" bundle:nil];
		searchCDC.title = label.text;
		[root.searchNavController pushViewController:searchCDC animated:YES];
	}
	
	NSLog(@"...didSelectRowAtIndexPath");

}

#pragma mark Text Field Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	NSLog(@"textFieldDidBeginEditing");
	self.textFieldBeingEdited = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSLog(@"textFieldDidEndEditing");
	
	self.searchConditionFlightNo = textField.text;
	//NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textField.tag];
	//[tempValues setObject:textField.text forKey:tagAsNum];
	//[tagAsNum release];		
}
#pragma mark -
#pragma mark shake Methods
-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        // 随机查询
        NSLog(@"shake!");
        /*
        SearchResultController *searchResultController = 
        [[SearchResultController alloc] initWithStyle:UITableViewStylePlain];
        */
        QueryResultController *searchResultController = 
        [[QueryResultController alloc] initWithStyle:UITableViewStylePlain];
        
        [searchResultController setQueryType:2];
        [searchResultController getSearchConditionController:self];
        [self.navigationController pushViewController:searchResultController animated:YES];    }
}
@end
