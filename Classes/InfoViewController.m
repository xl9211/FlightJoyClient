//
//  InfoViewController.m
//  MyNav
//
//  Created by 王 攀 on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"

@implementation InfoViewController
@synthesize delegate;

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

- (void)cancel {
    [self.delegate rootViewController:self doneSetInfo:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 100.0, 50.0, 30.0)];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"highlightBack.png"] forState:UIControlStateNormal];
    [saveButton setTitle:@"完成" forState:UIControlStateNormal];
    [saveButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    [saveButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];  
    //UIColor *backgroundColor = [UIColor colorWithRed:0 green:0.2f blue:0.55f alpha:1];
	//[self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
    // Do any additional setup after loading the view from its nib.
}
- (void)umengFeedback {
    [MobClick event:@"feedback_click" label:@"列表页"];
    [MobClick showFeedback:self];
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	DLog(@"didSelectRowAtIndexPath...");
	//MyNavAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	//RootViewController *root = [delegate.navController.viewControllers objectAtIndex:0];
	//UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
	NSUInteger row = [indexPath row];
    
	if (row == 0) {
        [self umengFeedback];
	} else if (row == 2) {
        versionCheck = [[VersionCheckUtil alloc] init];
        [versionCheck checkVersion];
        
		/*
        SearchConditionDateController *searchCDC = [[SearchConditionDateController alloc] initWithNibName:@"SearchConditionDateController" bundle:nil];
		searchCDC.title = label.text;
		[root.searchNavController pushViewController:searchCDC animated:YES];
         */
        
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	DLog(@"...didSelectRowAtIndexPath");
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *currentVersionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];

    UIColor *veryDarkGray = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1];
    UIColor *veryLightGray = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1];
    
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = veryDarkGray;
    headerLabel.shadowColor = veryLightGray;     
    headerLabel.shadowOffset = CGSizeMake(1.0,1.0); 
    headerLabel.textAlignment = UITextAlignmentCenter;
	headerLabel.font = [UIFont systemFontOfSize:16];
    headerLabel.text = [[NSString alloc]initWithFormat:@"飞趣 v%@",currentVersionStr];
	
    return headerLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 55;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
    //return [self.companyListData count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Configure the cell...
    NSUInteger row = [indexPath row];
	
    switch (row) {
        case 0:
            cell.text = @"意见反馈";
            break;
        case 1:
            cell.text = @"关于飞趣";
            break;
        case 2:
            cell.text = @"检查更新";
            break;
        default:
            break;
    }
    //Company *company = [companyListData objectAtIndex:row];
	//cell.text = [company.shortname stringByAppendingFormat:@" - %@", company.fullname];
    return cell;
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

- (void)dealloc {
    [versionCheck release];
    [super dealloc];
}
@end
