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
    [self.delegate searchConditionController:self didAddRecipe:nil];
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

@end
