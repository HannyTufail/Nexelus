//
//  TLAddJobViewController.h
//  TimeLineApp
//
//  Created by Hanny on 12/12/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Level2_Job.h"
#import "Level3_Activity.h"
#import "Level2_Customer.h"
#import "TLAddJobTableViewCell.h"
#import "DataSyncHandler.h"


@protocol TLAddJobViewControllerDelegate

-(void) addingJobInfoWasFinished;

@end


@interface TLAddJobViewController : UIViewController <UITableViewDataSource , UITableViewDelegate, UITextFieldDelegate, TLAddJobTableViewCellDelegate, DataSyncHandlerDelegate, UIAlertViewDelegate>
{
    int clientOrJobField;
    BOOL jobFieldHasValue;
    BOOL clientFieldHasValue;
    
    NSInteger showTask;
    NSInteger showWorkFunc;
    float keyboardHeightValue;
    
    NSString *settingsCustomerOption;
    NSString *settingsJobOption;
    
    float maxHoursWeek;
}

@property (nonatomic, assign) float maxHoursWeek;

@property (nonatomic, weak) id<TLAddJobViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (retain, nonatomic) NSString * selectedDateString;

@property (weak, nonatomic) IBOutlet UITableView *autoCompleteTableView;
@property (retain, nonatomic) NSMutableArray * autoCompleteArray;
@property (retain, nonatomic) NSMutableArray * clientsArray;
@property (retain, nonatomic) NSMutableArray * jobsArray;
@property (retain, nonatomic) NSMutableArray * activityArray;
@property (retain, nonatomic) NSMutableArray * activityItemList;
@property (retain, nonatomic) NSMutableArray * tasksArray;
@property (retain, nonatomic) NSMutableArray * tasksItemList;
@property (retain, nonatomic) NSMutableArray * workFuncArray;
@property (retain, nonatomic) NSMutableArray * workFuncItemList;

@property (retain,nonatomic) Level2_Job *selectedJobItem;
@property (retain,nonatomic) Level2_Customer *selectedClientItem;
@property (retain,nonatomic) Level3_Activity *selectedActivityItem;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;


-(IBAction) cancelButtonAction:(id)sender;
-(IBAction) saveButtonAction:(id)sender;

@end
