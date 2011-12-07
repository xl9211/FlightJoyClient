//
//  SearchConditionDateController.m
//  MyNav
//
//  Created by 王 攀 on 11-9-7.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchConditionDateController.h"
#import "RootViewController.h"
#import "MyNavAppDelegate.h"

@implementation SearchConditionDateController
@synthesize calendarView;
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	calendarView.calendarViewDelegate = self;
	
	//toolbar text
	UILabel *updateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, self.view.frame.size.width, 21.0f)];
	[updateTimeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
	[updateTimeLabel setBackgroundColor:[UIColor clearColor]];
	[updateTimeLabel setTextColor:[UIColor whiteColor]];
	[updateTimeLabel setText:@"请选择出发日期"];
	[updateTimeLabel setTextAlignment:UITextAlignmentCenter];
	UIBarButtonItem *updateTimeLabelButton = [[UIBarButtonItem alloc] initWithCustomView:updateTimeLabel];
	NSArray *items = [[NSArray alloc] initWithObjects: updateTimeLabelButton, nil]; 
	[self setToolbarItems:items animated:YES];
	
    [super viewDidLoad];
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
    [super dealloc];
}

#pragma mark -
#pragma mark CalendarViewDelegate delegate
- (void) selectDateChanged:(CFGregorianDate) selectDate
{
	DLog(@"selectDateChanged!!!");
	DLog(@"year: %d, month: %2d, day: %d", selectDate.year,
		  selectDate.month,
		  selectDate.day);
	NSString *responseString = [[NSString alloc] initWithFormat:@"%d-",selectDate.year];
	if (selectDate.month<10) {
		responseString = [responseString stringByAppendingString:@"0"];
	} 
	responseString = [responseString stringByAppendingFormat:@"%d-", selectDate.month];
	if (selectDate.day<10) {
		responseString = [responseString stringByAppendingString:@"0"];
	} 
	responseString = [responseString stringByAppendingFormat:@"%d", selectDate.day];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	
	NSDate *now = [[NSDate alloc] init];
	NSString *todayStr = [dateFormatter stringFromDate:now];
	NSDate *today = [dateFormatter dateFromString:todayStr];
		
	NSDate *selectedDate = [dateFormatter dateFromString:responseString];
	
	int interval = [selectedDate timeIntervalSinceDate:today];
	//responseString = [responseString stringByAppendingString:responseStringOrigin];
	DLog(@"interval : %d",interval);
	if ( interval < 0 ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
														message:@"本软件暂不支持查询历史航班"
													   delegate:nil
											  cancelButtonTitle:@"确定"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	MyNavAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *root = [delegate.navController.viewControllers objectAtIndex:0];
	[root.searchNavController popViewControllerAnimated:YES];
	
	NSArray *allControllers = root.searchNavController.viewControllers;
	SearchConditionController *parent = [allControllers lastObject];
	parent.searchConditionDate = responseString;
	[parent.tableView reloadData];	
}
- (void) monthChanged:(CFGregorianDate) currentMonth viewLeftTop:(CGPoint)viewLeftTop height:(float)height
{
	DLog(@"monthChanged!!!");
	
}
- (void) beforeMonthChange:(TdCalendarView*) calendarView willto:(CFGregorianDate) currentMonth
{
	DLog(@"beforeMonthChange!!!");
	
}
@end
