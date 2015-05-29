//
//  PendingJobsViewController.h
//  Nexelus
//
//  Created by Mac on 2/24/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLEditJobViewController.h"


@interface PendingJobsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TLEditJobViewControllerDelegate, DataSyncHandlerDelegate, UIActionSheetDelegate>
{
    float maxHoursWeekForAddEditScreen;
    
    UIRefreshControl * refreshControl;
}

@property (retain, nonatomic) NSMutableArray * calendarDatesArray;
@property (retain, nonatomic) NSMutableArray * calendarDatesHoursArray;

@property (weak, nonatomic) IBOutlet UILabel *NoTransactionsLabel;
@property (nonatomic, retain) NSMutableArray * dataSourceArray;
@property (nonatomic , weak) IBOutlet UITableView *mainTableView;

@property (weak, nonatomic) IBOutlet UIView *bottomMenuView;
@property (weak, nonatomic) IBOutlet UILabel *pendingTransactionsLabel;

- (IBAction)menuButtonAction:(id)sender;

@end
