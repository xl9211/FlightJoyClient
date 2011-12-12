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
@synthesize airportShortList;
@synthesize flightInfo;
@synthesize updateProgressInd;
@synthesize tableView;
@synthesize delegate;

//mapview
@synthesize mapView;
@synthesize airportLocationList;

//detail statebar
@synthesize stateLabelLeft;
@synthesize stateLabelCenter;
@synthesize stateLabelRight;
@synthesize progressView;

//
@synthesize parentClassName;
@synthesize detailTitleView;
//
@synthesize todo;
@synthesize done;
@synthesize deltaAngel;
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
	DLog(documentsDirectory);
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

- (void)save {
    [MobClick event:@"follow_click" label:@"详情页"];
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
    
    UINavigationController *nav = (UINavigationController *)self.parentViewController;
    QueryResultController *qrc = (QueryResultController *)[nav.viewControllers objectAtIndex:1];
    [qrc destroyTimer];
    
    [self.delegate searchConditionController:self didAddRecipe:nil];
}

- (void)showSendActionSheet
{
    [MobClick event:@"share_click"];
	// open a dialog with two custom buttons
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"将航班信息分享于"
                                                             delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil
                                                    otherButtonTitles:@"邮件", @"新浪微博", @"腾讯微博", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	//[actionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
	[actionSheet release];
}

#pragma mark -
#pragma mark - UMSNSDataSendDelegate method

- (void)dataSendDidFinish:(UIViewController *)viewController andReturnStatus:(UMReturnStatusType)returnStatus andPlatformType:(UMShareToType)platfrom{
    
    if (platfrom == UMShareToTypeSina || platfrom == UMShareToTypeTenc)
    {
        [viewController dismissModalViewControllerAnimated:YES];
    }
}

- (NSString *)invitationContent:(UMShareToType)platfrom {
    
    switch (platfrom) {
        case UMShareToTypeRenr:
            return @"人人，私信邀请！";
            
        case UMShareToTypeSina:
            return @"新浪微博，私信邀请！";
            
        default:
            return @"腾讯微博，私信邀请！";
    }
}

#pragma mark -
#pragma mark - UIActionSheetDelegate
//1.发邮件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:@"天空之城" forKey:@"songName"];
    [dic setValue:@"北京" forKey:@"place"];
    
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] 
                           stringByAppendingPathComponent:@"newIcon1.png"];
    switch (buttonIndex) {
        case 0:
            DLog(@"邮件");
            [MobClick event:@"share_channel" label:@"邮件"];
            [self sendEMail];
            break;
        /*case 1:
            DLog(@"短信");
            [MobClick event:@"share_channel" label:@"短信"];
            [self sendSMS];
            break;
         */
        case 1:
            DLog(@"新浪微博");
            [UMSNSService setDataSendDelegate:self];            
            [UMSNSService shareToSina:self andAppkey:@"4ebf9547527015401e00006f" andShareMap:dic];
            break;
        case 2:
            DLog(@"腾讯微博");
            [UMSNSService setDataSendDelegate:self];
            [UMSNSService shareToTenc:self andAppkey:@"4ebf9547527015401e00006f" andShareMap:dic];
            //[UMSNSService shareToTenc:self andAppkey:@"4ebf9547527015401e00006f" andShareMap:dic andImgPath:imagePath];
            break;
        default:
            break;
    }
    [dic release];

}


//点击完send后  成功失败都弹框显示：
- (void) alertWithTitle: (NSString *)_title_ msg: (NSString *)msg   
{  
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_title_   
                                                    message:msg   
                                                   delegate:nil   
                                          cancelButtonTitle:@"确定"   
                                          otherButtonTitles:nil];  
    [alert show];  
    [alert release];  
}
//点击Mail按钮后，触发这个方法  
-(void)sendEMail   
{  
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));  
    
    if (mailClass != nil)  
    {  
        if ([mailClass canSendMail])  
        {  
            [self displayComposerSheet];  
        }   
        else   
        {  
            [self launchMailAppOnDevice];  
        }  
    }   
    else   
    {  
        [self launchMailAppOnDevice];  
    }      
}  
//可以发送邮件的话  
-(void)displayComposerSheet   
{  
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];  
    mailPicker.navigationBar.tintColor = [UIColor colorWithRed:0 green:0.2f blue:0.55f alpha:1];
    mailPicker.mailComposeDelegate = self;  
    //设置主题
    NSString *subjectString = [[NSString alloc]initWithFormat:@"来自飞趣的航班动态：%@ － %@ 至 %@",
                               [flightInfo objectForKey:@"flight_no"],
                               [flightInfo objectForKey:@"takeoff_city"],
                               [flightInfo objectForKey:@"arrival_city"] ];
    [mailPicker setSubject: subjectString];  
    
    // 添加发送者  
    [mailPicker setToRecipients: nil];      
    /*NSArray *toRecipients = [NSArray arrayWithObject: @"first@example.com"];  
    NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];  
    NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com", nil];  
    [mailPicker setCcRecipients:ccRecipients];      
    [mailPicker setBccRecipients:bccRecipients]; */
    
    // 添加图片  
    /*UIImage *addPic = [UIImage imageNamed: @"iconlittle.jpg"];  
    NSData *imageData = UIImageJPEGRepresentation(addPic, 1);    // jpeg  
    [mailPicker addAttachmentData: imageData mimeType: @"" fileName: @"icon.jpg"];  
    */
    NSString *emailBody = @"亲爱的乘客"; 
    emailBody = [emailBody stringByAppendingString:@"<br/>"];
    emailBody = [emailBody stringByAppendingString:@"<br/>"];
    emailBody = [emailBody stringByAppendingFormat:@"您好，%@%@ 的航班动态信息如下:", 
                 [flightInfo objectForKey:@"company"],
                 [flightInfo objectForKey:@"flight_no"]];
    emailBody = [emailBody stringByAppendingString:@"<br/>"];
    
    emailBody = [emailBody stringByAppendingString:@"<br/>"];
    
    /*出发
     2011-11-11, Hangzhou (HGH)
     计划: 18:10 CST (China)
     实际: 16:42 CST (China)
     航站楼: 2
     登机口: 203
     */
    emailBody = [emailBody stringByAppendingString:@"出发"];
    emailBody = [emailBody stringByAppendingString:@"<br/>"];
    
    emailBody = [emailBody stringByAppendingFormat:@"%@, %@ (%@)",
                 [flightInfo objectForKey:@"schedule_takeoff_date"], 
                 [flightInfo objectForKey:@"takeoff_city"],
                 [flightInfo objectForKey:@"takeoff_airport"]];
    emailBody = [emailBody stringByAppendingString:@"<br/>"];

    emailBody = [emailBody stringByAppendingFormat:@"计划: %@", [flightInfo objectForKey:@"schedule_takeoff_time"]];
    emailBody = [emailBody stringByAppendingString:@"<br/>"];
    if (![[flightInfo objectForKey:@"actual_takeoff_time"] isEqualToString:@"--:--"]) {
        emailBody = [emailBody stringByAppendingFormat:@"实际: %@", 
                     [self getShortTimeStringFromStandard:[flightInfo objectForKey:@"actual_takeoff_time"]]
                     ];
        emailBody = [emailBody stringByAppendingString:@"<br/>"];
    } else if (![[flightInfo objectForKey:@"estimate_takeoff_time"] isEqualToString:@"--:--"]) {
        emailBody = [emailBody stringByAppendingFormat:@"预计: %@", 
                     [self getShortTimeStringFromStandard:[flightInfo objectForKey:@"estimate_takeoff_time"]]
                     ];
        emailBody = [emailBody stringByAppendingString:@"<br/>"];
    }
    if (![[flightInfo objectForKey:@"takeoff_airport_building"] isEqualToString:@""]) {
        emailBody = [emailBody stringByAppendingFormat:@"航站楼: %@", [flightInfo objectForKey:@"takeoff_airport_building"]];
        emailBody = [emailBody stringByAppendingString:@"<br/>"];
    }
    if (![[flightInfo objectForKey:@"takeoff_airport_entrance_exit"] isEqualToString:@""]) {
        emailBody = [emailBody stringByAppendingFormat:@"登机口: %@", [flightInfo objectForKey:@"takeoff_airport_entrance_exit"]];
        emailBody = [emailBody stringByAppendingString:@"<br/>"];
    }
    emailBody = [emailBody stringByAppendingString:@"<br/>"];

    /*
     到达
     2011-11-11, Xiamen (XMN)
     计划: 19:30 CST (China)
     实际: 17:50 CST (China)
     航站楼: B
     登机口: B2-54
     */
    emailBody = [emailBody stringByAppendingString:@"到达"];
    emailBody = [emailBody stringByAppendingString:@"<br/>"];
    
    emailBody = [emailBody stringByAppendingFormat:@"%@, %@ (%@)",
                 [flightInfo objectForKey:@"schedule_takeoff_date"], //此处有bug
                 [flightInfo objectForKey:@"arrival_city"],
                 [flightInfo objectForKey:@"arrival_airport"]];
    emailBody = [emailBody stringByAppendingString:@"<br/>"];
    
    emailBody = [emailBody stringByAppendingFormat:@"计划: %@", [flightInfo objectForKey:@"schedule_arrival_time"]];
    emailBody = [emailBody stringByAppendingString:@"<br/>"];
    if (![[flightInfo objectForKey:@"actual_arrival_time"] isEqualToString:@"--:--"]) {
        emailBody = [emailBody stringByAppendingFormat:@"实际: %@", 
                     [self getShortTimeStringFromStandard:[flightInfo objectForKey:@"actual_arrival_time"]]
                     ];
        emailBody = [emailBody stringByAppendingString:@"<br/>"];
    } else if (![[flightInfo objectForKey:@"estimate_arrival_time"] isEqualToString:@"--:--"]) {
        emailBody = [emailBody stringByAppendingFormat:@"预计: %@", 
                     [self getShortTimeStringFromStandard:[flightInfo objectForKey:@"estimate_arrival_time"]]
                     ];
        emailBody = [emailBody stringByAppendingString:@"<br/>"];
    }
    if (![[flightInfo objectForKey:@"arrival_airport_building"] isEqualToString:@""]) {
        emailBody = [emailBody stringByAppendingFormat:@"航站楼: %@", [flightInfo objectForKey:@"arrival_airport_building"]];
        emailBody = [emailBody stringByAppendingString:@"<br/>"];
    }
    if (![[flightInfo objectForKey:@"arrival_airport_entrance_exit"] isEqualToString:@""]) {
        emailBody = [emailBody stringByAppendingFormat:@"登机口: %@", [flightInfo objectForKey:@"arrival_airport_entrance_exit"]];
        emailBody = [emailBody stringByAppendingString:@"<br/>"];
    }
    emailBody = [emailBody stringByAppendingString:@"<br/>"];
    /*
     此班機目前狀態: 着陆
     
     FlightTrack Pro - 在iPhone及iPad上追蹤您的班機.
     */
    emailBody = [emailBody stringByAppendingFormat:@"此架航班当前状态: %@",[flightInfo objectForKey:@"flight_state"]];
    emailBody = [emailBody stringByAppendingString:@"<br/>"];

    emailBody = [emailBody stringByAppendingString:@"<br/>"];

    emailBody = [emailBody stringByAppendingString:@"飞趣 - 追踪您的航班动态，让飞行乐趣无穷"];
    
    [mailPicker setMessageBody:emailBody isHTML:YES];  
    
    [self presentModalViewController: mailPicker animated:YES];  
    [mailPicker release];  
}  
-(void)launchMailAppOnDevice  
{  
    NSString *recipients = @"mailto:first@example.com&subject=my email!";  
    //@"mailto:first@example.com?cc=second@example.com,third@example.com&subject=my email!";  
    NSString *body = @"&body=email body!";  
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];  
    email = [email stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];  
    
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:email]];  
}  
- (void)mailComposeController:(MFMailComposeViewController *)controller   
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error   
{  
    /*
    NSString *msg;  
    
    switch (result)   
    {  
        case MFMailComposeResultCancelled:  
            msg = @"邮件发送取消";  
            break;  
        case MFMailComposeResultSaved:  
            msg = @"邮件保存成功";  
            [self alertWithTitle:nil msg:msg];  
            break;  
        case MFMailComposeResultSent:  
            msg = @"邮件发送成功";  
            [self alertWithTitle:nil msg:msg];  
            break;  
        case MFMailComposeResultFailed:  
            msg = @"邮件发送失败";  
            [self alertWithTitle:nil msg:msg];  
            break;  
        default:  
            break;  
    }  
    */
    [MobClick event:@"share_done" label:@"邮件"];
    [self dismissModalViewControllerAnimated:YES];  
}
- (NSString *)getShortTimeStringFromStandard:(NSString *)standardTimeString {
	if (standardTimeString == nil || [standardTimeString isEqual:@""]) {
		return @"";
	}
	NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:mm"];
	NSDate *date=[dateFormatter dateFromString:standardTimeString];
	[dateFormatter setDateFormat:@"H:mm"];
	NSString *shortDateString = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	return shortDateString;
}

//2.发短信
//iOS3.0请参考 http://archive.cnblogs.com/a/1956619/
- (void)sendSMS {
	BOOL canSendSMS = [MFMessageComposeViewController canSendText];
	DLog(@"can send SMS [%d]", canSendSMS);	
	if (canSendSMS) {
		MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
		picker.messageComposeDelegate = self;
		picker.navigationBar.tintColor = [UIColor colorWithRed:0 green:0.2f blue:0.55f alpha:1];
        
        //构造短信正文
        NSString *emailBody = [[NSString alloc] initWithFormat:@"%@ %@", 
                     [flightInfo objectForKey:@"company"],
                     [flightInfo objectForKey:@"flight_no"]];
        emailBody = [emailBody stringByAppendingString:@"<br/>"];
        
        emailBody = [emailBody stringByAppendingFormat:@"出发: %@, %@ (%@)",
                     [flightInfo objectForKey:@"schedule_takeoff_date"], 
                     [flightInfo objectForKey:@"takeoff_city"],
                     [flightInfo objectForKey:@"takeoff_airport"]];
        emailBody = [emailBody stringByAppendingString:@"<br/>"];
        
        emailBody = [emailBody stringByAppendingFormat:@"计划: %@", [flightInfo objectForKey:@"schedule_takeoff_time"]];
        emailBody = [emailBody stringByAppendingString:@"<br/>"];
        if (![[flightInfo objectForKey:@"actual_takeoff_time"] isEqualToString:@"--:--"]) {
            emailBody = [emailBody stringByAppendingFormat:@"实际: %@", 
                         [self getShortTimeStringFromStandard:[flightInfo objectForKey:@"actual_takeoff_time"]]
                         ];
            emailBody = [emailBody stringByAppendingString:@"<br/>"];
        } else if (![[flightInfo objectForKey:@"estimate_takeoff_time"] isEqualToString:@"--:--"]) {
            emailBody = [emailBody stringByAppendingFormat:@"预计: %@", 
                         [self getShortTimeStringFromStandard:[flightInfo objectForKey:@"estimate_takeoff_time"]]
                         ];
            emailBody = [emailBody stringByAppendingString:@"<br/>"];
        }
        
        emailBody = [emailBody stringByAppendingString:@"<br/>"];
        
        emailBody = [emailBody stringByAppendingFormat:@"到达: %@, %@ (%@)",
                     [flightInfo objectForKey:@"schedule_takeoff_date"], //此处有bug
                     [flightInfo objectForKey:@"arrival_city"],
                     [flightInfo objectForKey:@"arrival_airport"]];
        emailBody = [emailBody stringByAppendingString:@"<br/>"];
        
        emailBody = [emailBody stringByAppendingFormat:@"计划: %@", [flightInfo objectForKey:@"schedule_arrival_time"]];
        emailBody = [emailBody stringByAppendingString:@"<br/>"];
        if (![[flightInfo objectForKey:@"actual_arrival_time"] isEqualToString:@"--:--"]) {
            emailBody = [emailBody stringByAppendingFormat:@"实际: %@", 
                         [self getShortTimeStringFromStandard:[flightInfo objectForKey:@"actual_arrival_time"]]
                         ];
            emailBody = [emailBody stringByAppendingString:@"<br/>"];
        } else if (![[flightInfo objectForKey:@"estimate_arrival_time"] isEqualToString:@"--:--"]) {
            emailBody = [emailBody stringByAppendingFormat:@"预计: %@", 
                         [self getShortTimeStringFromStandard:[flightInfo objectForKey:@"estimate_arrival_time"]]
                         ];
            emailBody = [emailBody stringByAppendingString:@"<br/>"];
        }
        
        
        picker.body = emailBody;
        [emailBody release];
        picker.recipients = nil;
		//picker.recipients = [NSArray arrayWithObject:@"186-0123-0123"];
		[self presentModalViewController:picker animated:YES];
		[picker release];		
	} else {
        DLog(@"can't");
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	// Notifies users about errors associated with the interface
	/*
    switch (result) {
		case MessageComposeResultCancelled:
			if (DEBUG) DLog(@"Result: canceled");
			break;
		case MessageComposeResultSent:
			if (DEBUG) DLog(@"Result: Sent");
			break;
		case MessageComposeResultFailed:
			if (DEBUG) DLog(@"Result: Failed");
			break;
		default:
			break;
	}
     */
    [MobClick event:@"share_done" label:@"短信"];
	[self dismissModalViewControllerAnimated:YES];	
}
- (void)rootViewController:(InfoViewController *)infoViewController doneSetInfo:(int)recipe{
    DLog(@"searchConditionController didAddRecipe");
    [self dismissModalViewControllerAnimated:YES];
}

- (void)showInfo {
    DLog(@"showInfo...");
    InfoViewController *infoViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
    infoViewController.title = @"软件信息";	
    infoViewController.delegate = self;
    
	// Create the navigation controller and present it modally.
	UINavigationController *navigationController = [[UINavigationController alloc]
													initWithRootViewController:infoViewController];
	[navigationController setToolbarHidden:YES];    
    UIColor *backgroundColor = [UIColor blackColor];
	[navigationController.navigationBar setTintColor:backgroundColor];
    
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
	[self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];
	[infoViewController release];
}

#pragma mark -
#pragma mark 工具类方法

-(void)segmentChange {
    DLog(@"segmentChange...");
    m_currentSegmentIndex = 1 - m_currentSegmentIndex;
    switch (m_currentSegmentIndex) {
		case 0:
            [MobClick event:@"mode_switch" label:@"至时刻视图"];
            [self.tableView setHidden:NO];
            [self.mapView setHidden:YES];
			break;
		case 1:
            [MobClick event:@"mode_switch" label:@"至地图视图"];
            [self.tableView setHidden:YES];
            [self.mapView setHidden:NO];
            [self loadMapviewData];
			break;
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	DLog(@"DisclosureButtonController.viewDidLoad...");
    MyNavAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *root = [delegate.navController.viewControllers objectAtIndex:0];
	self.delegate = root;
    
    NSArray *allControllers = self.navigationController.viewControllers;
	ListViewController *parent = [allControllers objectAtIndex:[allControllers count]-2];
    self.parentClassName = [NSString stringWithUTF8String:object_getClassName(parent)];
	
    //toolbar
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                       target:self action:@selector(refreshAction)];
    
    UIButton* infoButton = [UIButton buttonWithType: UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] 
									  initWithCustomView:infoButton];    	
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:nil];
    [segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"planetab.png"] atIndex:0 animated:YES];
    [segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"map.png"] atIndex:1 animated:YES];
    /*[segmentedControl setBackgroundImage:[UIImage imageNamed:@"xiangqing.png"]
                                forState:UIControlStateHighlighted 
                              barMetrics:nil];
    */
    [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [segmentedControl setSelectedSegmentIndex:0];
    [segmentedControl setFrame:CGRectMake(0, 0, 120, 35)];
    [segmentedControl addTarget:self action:@selector(segmentChange) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *segmentBarButton = [[UIBarButtonItem alloc] 
                                         initWithCustomView:segmentedControl];
    [segmentBarButton setStyle:UISegmentedControlStyleBar];
    
    NSMutableArray *refreshToolbarItems = [[NSMutableArray alloc] initWithObjects: refreshButton, 
                                                                 flexibleSpace, 
                                           //updateProgressIndicatorButton, 
                                           //updateStatusLabelButton,
                                           segmentBarButton,
                                           flexibleSpace, nil]; ;
    [self setToolbarItems: refreshToolbarItems animated:YES];

    //生成标题栏
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DisclosureButtonTitleView" owner:self options:nil];
    self.detailTitleView = [nib objectAtIndex:0];
    [self.detailTitleView retain];
    
    UILabel *ltitle = [self.detailTitleView titleLabel];
    [ltitle setText:self.title];
    UILabel *updateStatusLabel = [self.detailTitleView updateStatusLabel];
    [updateStatusLabel setText:@""];
    
    self.navigationItem.titleView = detailTitleView;
    
    if (self.parentClassName != nil 
        && [self.parentClassName isEqualToString:@"RootViewController"]) {
        [refreshToolbarItems addObject:infoBarButton];
        UIBarButtonItem *sendButtonItem = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                       target:self action:@selector(showSendActionSheet)];
        
        self.navigationItem.rightBarButtonItem = sendButtonItem;        
	} else {
        //navigationbar
        UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 100.0, 50.0, 30.0)];
        [saveButton setBackgroundImage:[UIImage imageNamed:@"highlightBack.png"] forState:UIControlStateNormal];
        [saveButton setTitle:@"关注" forState:UIControlStateNormal];
        [saveButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
        [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
        
        self.navigationItem.rightBarButtonItem = saveButtonItem;
    }    
	
	//release part
	[refreshToolbarItems release];
	[refreshButton release];
	[flexibleSpace release];
	[infoBarButton release];
	
    //fix black corner of the tableview
    tableView.backgroundColor = [UIColor clearColor];
    tableView.opaque = NO;
    
	//mapview
    self.mapView.delegate=self;
	/*
     CLLocationManager *locationManager = [[CLLocationManager alloc] init];//创建位置管理器
     locationManager.delegate=self;//设置代理
     locationManager.desiredAccuracy=kCLLocationAccuracyBest;//指定需要的精度级别
     locationManager.distanceFilter=1000.0f;//设置距离筛选器
     [locationManager startUpdatingLocation];//启动位置管理器
     
     CLLocationCoordinate2D currentLocation = [[locationManager location] coordinate];
     DLog(@"longitude:%f",currentLocation.longitude);
     DLog(@"latitude:%f",currentLocation.latitude);
     
     MKCoordinateRegion theRegion = { {0.0, 0.0 }, { 0.0, 0.0 } };
     theRegion.center=currentLocation;
     theRegion.span.longitudeDelta = 0.1f;
     theRegion.span.latitudeDelta = 0.1f;
     
     [mapView setRegion:theRegion animated:YES];*/
	[mapView setZoomEnabled:YES];
	[mapView setScrollEnabled:YES];	
    m_currentSegmentIndex = 1;
    [self segmentChange];

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
    
    done = ([curDate timeIntervalSince1970]*1 - [displayTakeoffTimeD timeIntervalSince1970]*1)/60;
    todo = ([displayArrivalTimeD timeIntervalSince1970]*1 - [curDate timeIntervalSince1970]*1)/60;
    
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
	DLog(@"DisclosureButtonController.viewWillAppear...");
        
	//copy the root view status
	MyNavAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *root = [delegate.navController.viewControllers objectAtIndex:0];
	
    UIActivityIndicatorView *updateProgressInd = [self.detailTitleView updateProgressInd];
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
	DLog(@"DisclosureButtonController.startUpdateProcess...");
    UIActivityIndicatorView *updateProgressInd = [self.detailTitleView updateProgressInd];
    [updateProgressInd startAnimating];
	NSString *content = @"更新中...";
	[self refreshStatusLabelWithText:content];
}
/*
 * 停止更新航班信息的过程
 */
- (void) stopUpdateProcess {
	DLog(@"DisclosureButtonController.stopUpdateProcess...");
	[self.tableView reloadData];
	
    UIActivityIndicatorView *updateProgressInd = [self.detailTitleView updateProgressInd];
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
	/*UILabel *updateStatusLabel = [self getStatusLabel:textParam];
	
	UIBarButtonItem *updateStatusLabelItem = (UIBarButtonItem *)[self.toolbarItems objectAtIndex:3];
	[updateStatusLabelItem initWithCustomView:updateStatusLabel];
    */
    UILabel *updateStatusLabel = [self.detailTitleView updateStatusLabel];
    [updateStatusLabel setText:textParam];
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
	DLog(@"DisclosureButtonController.refreshAction");
    [MobClick event:@"refresh_click" label:@"详情页"];
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
	DLog(@"DisclosureButtonController.numberOfSectionsInTableView...");
	if (list == nil) {
		DLog(@"list == nil");
		return 0;
	} else {
		DLog(@"[list count]:%d",[list count]);

		return [list count];
	}

}

- (NSInteger)tableView:(UITableView *)tableView
	numberOfRowsInSection:(NSInteger)section {
	DLog(@"DisclosureButtonController.numberOfRowsInSection...");

	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DLog(@"DisclosureButtonController.cellForRowAtIndexPath...");

	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	NSString *airportString = [list objectAtIndex:section];
	DLog(@"section:%d, row:%d...", section, row);
	
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
		cell.textColor = [UIColor whiteColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;		
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

	DLog(@"...DisclosureButtonController.cellForRowAtIndexPath");

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
    UIColor *veryDarkGray = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1];
    UIColor *veryLightGray = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1];
	headerLabel.textColor = veryDarkGray;
    headerLabel.shadowColor = veryLightGray;     
    headerLabel.shadowOffset = CGSizeMake(1.0,1.0); 
	headerLabel.font = [UIFont systemFontOfSize:14];
	
	NSString* labelText = @"    ";
    switch (section) {
        case 0:
            headerLabel.text = [labelText stringByAppendingString:@"计划起飞 "];
			headerLabel.text = [headerLabel.text stringByAppendingString:[flightInfo objectForKey:@"schedule_takeoff_date"]];
			headerLabel.text = [headerLabel.text stringByAppendingString:@" "];
			headerLabel.text = [headerLabel.text stringByAppendingString:[flightInfo objectForKey:@"schedule_takeoff_time"]];
			headerLabel.text = [headerLabel.text stringByAppendingString:@"     机型: "];
			headerLabel.text = [headerLabel.text stringByAppendingString:[flightInfo objectForKey:@"plane_model"]];
            break;
        case 1:
            headerLabel.text = [labelText stringByAppendingString:@"计划到达 "];
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
	DLog(@"haha");
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


- (void) loadMapviewData {
    //1. prepare data
    NSMutableArray *array = [[NSMutableArray alloc] init];
	if (self.cityList != nil) {				
		if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
			sqlite3_close(database);
			NSAssert(0, @"Failed to open database");
		}
		for (int i = 0; i < [self.cityList count]; i++) {
			NSString *airportShort = [self.airportShortList objectAtIndex:i];
			NSString *query = [[NSString alloc]initWithFormat:@"SELECT latitude, longitude FROM airportloc where shortname='%@'",airportShort];
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
	self.airportLocationList = array;
	[array release];
    
    //2. show annotation
    NSMutableArray *overlays = [[NSMutableArray alloc] init];
	CLLocationCoordinate2D pointsToUse[2];
	
	DisplayMap *ann = nil;
	if (self.cityList != nil) {				
		for (int i = 0; i < [self.cityList count]; i++) {			
			ann = [[DisplayMap alloc] init];
			ann.title = [self.cityList objectAtIndex:i];
			ann.coordinate = [[self.airportLocationList objectAtIndex:i] coordinate];
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
    
    //计算飞机位置，增加飞行图标
    PlaneAnnotation *planeAnnotation = [[PlaneAnnotation alloc] init];
    
    DLog(@"todo: %d, done: %d...",self.todo, self.done);
    BOOL latPossitive = YES;
    BOOL longPossitive = YES;
    double deltaLatitude = pointsToUse[1].latitude - pointsToUse[0].latitude;
    double deltaLongitude = pointsToUse[1].longitude - pointsToUse[0].longitude;

    if (deltaLatitude < 0) {
        latPossitive = NO;
    }
    if (deltaLongitude < 0) {
        longPossitive = NO;
    }
    
    planeAnnotation.title = [flightInfo objectForKey:@"flight_no"];
    planeAnnotation.latitude = pointsToUse[0].latitude + done * deltaLatitude / (done + todo);
    planeAnnotation.longitude = pointsToUse[0].longitude + done * deltaLongitude / (done + todo);    
    
    //纬度阈值约束
    if (latPossitive) {
        if (planeAnnotation.latitude > pointsToUse[1].latitude) {
            planeAnnotation.latitude = pointsToUse[1].latitude;
        }
        if (planeAnnotation.latitude < pointsToUse[0].latitude) {
            planeAnnotation.latitude = pointsToUse[0].latitude;
        }
    } else {
        if (planeAnnotation.latitude < pointsToUse[1].latitude) {
            planeAnnotation.latitude = pointsToUse[1].latitude;
        }
        if (planeAnnotation.latitude > pointsToUse[0].latitude) {
            planeAnnotation.latitude = pointsToUse[0].latitude;
        }
    }
    //经度阈值约束
    if (longPossitive) {
        if (planeAnnotation.longitude > pointsToUse[1].longitude) {
            planeAnnotation.longitude = pointsToUse[1].longitude;
        }
        if (planeAnnotation.longitude < pointsToUse[0].longitude) {
            planeAnnotation.longitude = pointsToUse[0].longitude;
        }
    } else {
        if (planeAnnotation.longitude < pointsToUse[1].longitude) {
            planeAnnotation.longitude = pointsToUse[1].longitude;
        }
        if (planeAnnotation.longitude > pointsToUse[0].longitude) {
            planeAnnotation.longitude = pointsToUse[0].longitude;
        }
    }
    //修正偏移角度
    double tagit = deltaLongitude / deltaLatitude;
    deltaAngel = atan(tagit);
    if (!latPossitive) {
        deltaAngel = deltaAngel + M_PI;
    }

    [mapView addAnnotation:planeAnnotation];
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
	
    if ([annotation isKindOfClass:[PlaneAnnotation class]])   // for City of San Francisco
    {
        static NSString* PlaneAnnotationIdentifier = @"PlaneAnnotationIdentifier";
        MKPinAnnotationView* pinView =
        (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:PlaneAnnotationIdentifier];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:PlaneAnnotationIdentifier] autorelease];
            annotationView.canShowCallout = YES;
            
            UIImage *flagImage = [UIImage imageNamed:@"mapplane.png"];
            flagImage =[flagImage imageRotatedByRadians:deltaAngel];
            CGRect resizeRect;
            
            resizeRect.size = flagImage.size;
            CGSize maxSize = CGRectInset(self.view.bounds,
                                         [DisclosureButtonController annotationPadding],
                                         [DisclosureButtonController annotationPadding]).size;
            maxSize.height -= self.navigationController.navigationBar.frame.size.height + [DisclosureButtonController calloutHeight];
            if (resizeRect.size.width > maxSize.width)
                resizeRect.size = CGSizeMake(maxSize.width, resizeRect.size.height / resizeRect.size.width * maxSize.width);
            if (resizeRect.size.height > maxSize.height)
                resizeRect.size = CGSizeMake(resizeRect.size.width / resizeRect.size.height * maxSize.height, maxSize.height);
            
            resizeRect.origin = (CGPoint){0.0f, 0.0f};
            UIGraphicsBeginImageContext(resizeRect.size);
            [flagImage drawInRect:resizeRect];
            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            annotationView.image = resizedImage;
            annotationView.opaque = NO;
            
            return annotationView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    } 
    else {
        static NSString *defaultPinID = @"com.invasivecode.pin";
        pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil ) pinView = [[[MKPinAnnotationView alloc]
                                          initWithAnnotation:annotation reuseIdentifier:defaultPinID] autorelease];
        if ([[annotation title] isEqualToString:[self.cityList objectAtIndex:0]]) {
            pinView.pinColor = MKPinAnnotationColorRed;
        } else {
            pinView.pinColor = MKPinAnnotationColorGreen;
        }
        
        pinView.canShowCallout = YES;
        pinView.animatesDrop = NO;
        return pinView;
    }    
	
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

+ (CGFloat)annotationPadding;
{
    return 10.0f;
}
+ (CGFloat)calloutHeight;
{
    return 40.0f;
}
@end
