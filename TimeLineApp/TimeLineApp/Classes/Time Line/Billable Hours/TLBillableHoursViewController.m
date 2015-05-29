//
//  TLBillableHoursViewController.m
//  TimeLineApp
//
//  Created by Hanny on 12/12/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "TLBillableHoursViewController.h"
#import "TLSettingsViewController.h"
@interface TLBillableHoursViewController ()

@end

@implementation TLBillableHoursViewController
@synthesize barChart;
@synthesize titlesArray, valuesArray;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Billable Hours";
    [self makeCustomBackButtonWithLogo];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadChart];
}
-(void)loadChart{
    
    // @"87E317", @"17A9E3", @"E32F17", @"FFE53D",
    NSArray *array = [barChart createChartDataWithTitles: self.titlesArray
                                                  values:self.valuesArray
                                                  colors:[NSArray arrayWithObjects:@"17A9E3", @"17A9E3", @"17A9E3", @"17A9E3",@"17A9E3",@"17A9E3",@"17A9E3", nil]
                                             labelColors:[NSArray arrayWithObjects:@"FFFFFF", @"FFFFFF", @"FFFFFF", @"FFFFFF", @"FFFFFF",@"FFFFFF",@"FFFFFF",nil]];
    
    //Set the Shape of the Bars (Rounded or Squared) - Rounded is default
    [barChart setupBarViewShape:BarShapeSquared];
    
    //Set the Style of the Bars (Glossy, Matte, or Flat) - Glossy is default
    [barChart setupBarViewStyle:BarStyleMatte];
    
    //Set the Drop Shadow of the Bars (Light, Heavy, or None) - Light is default
    [barChart setupBarViewShadow:BarShadowLight];
    
    //Generate the bar chart using the formatted data
    [barChart setDataWithArray:array
                      showAxis:DisplayBothAxes
                     withColor:[UIColor whiteColor]
       shouldPlotVerticalLines:YES];

}

-(void) makeCustomBackButtonWithLogo
{
    UIImage *iconImage = [UIImage imageNamed:@"back_logo.png"];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, iconImage.size.width, iconImage.size.height)];
    [leftButton setBackgroundImage:iconImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(navigationBackButtonTpd) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
}

-(void) navigationBackButtonTpd
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
