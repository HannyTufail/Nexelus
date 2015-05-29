//
//  TLEditJobViewController.h
//  TimeLineApp
//
//  Created by Mac on 12/26/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Transaction.h"
#import "DataSyncHandler.h"

typedef enum : NSUInteger {
    isFromHomeScreen = 1,
    isFromPendingScreen = 2
} editViewCalled;

@protocol TLEditJobViewControllerDelegate

-(void) editingJobInfoWasFinished;

@end

@interface TLEditJobViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, DataSyncHandlerDelegate>
{
    NSInteger showTask;
    NSInteger showWorkFunc;
    float maxHoursWeek;
}

@property (nonatomic, assign) float maxHoursWeek;
@property (nonatomic, assign) editViewCalled _editViewCalled;

@property (nonatomic, weak) id<TLEditJobViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (retain, nonatomic) Transaction * transactionItem;
@property (retain, nonatomic) NSString * selectedDateString;
//@property (nonatomic, strong) DBManager *dbManager;

@property (retain, nonatomic) NSMutableArray * tasksArray;
@property (retain, nonatomic) NSMutableArray * workFuncArray;
@property (retain, nonatomic) NSMutableArray * tasksItemList;
@property (retain, nonatomic) NSMutableArray * workFuncItemList;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;


-(IBAction) deleteButtonAction:(id)sender;
-(IBAction) saveButtonAction:(id)sender;
@end
