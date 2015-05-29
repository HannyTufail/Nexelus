//
//  MainMenuViewController.m
//  Nexelus
//
//  Created by Mac on 5/11/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import "MainMenuViewController.h"
#import "HomeViewController.h"
#import "ReportListViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction Methods
- (IBAction)expenseReportButtonTpd:(id)sender {
    ReportListViewController *reportListController = [[ReportListViewController alloc] initWithNibName:@"ReportListViewController" bundle:nil];
    [self.navigationController pushViewController:reportListController animated:YES];
}

- (IBAction)timeLineButtonTpd:(id)sender
{
    HomeViewController *homeController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    [self.navigationController pushViewController:homeController animated:YES];
}
@end
