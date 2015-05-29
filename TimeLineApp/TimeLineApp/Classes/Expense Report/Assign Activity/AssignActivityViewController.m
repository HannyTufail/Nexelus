//
//  AssignActivityViewController.m
//  Nexelus
//
//  Created by Mac on 5/21/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import "AssignActivityViewController.h"

@interface AssignActivityViewController ()

@end

@implementation AssignActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeCustomBackButtonWithLogo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Custom Methods

-(void) makeCustomBackButtonWithLogo
{
    UIImage *iconImage = [UIImage imageNamed:@"back_logo.png"];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, iconImage.size.width, iconImage.size.height)];
    [leftButton setBackgroundImage:iconImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    self.navigationItem.title = @"Assign Activity";
}

-(void)backButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - IBAction Methods
@end
