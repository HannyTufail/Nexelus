//
//  TLBillableHoursViewController.h
//  TimeLineApp
//
//  Created by Hanny on 12/12/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarChartView.h"
@interface TLBillableHoursViewController : UIViewController
{
    
}
@property (strong, nonatomic) IBOutlet BarChartView *barChart;
@property (retain, nonatomic) NSMutableArray * titlesArray;
@property (retain, nonatomic) NSMutableArray * valuesArray;

@end
