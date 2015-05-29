//
//  HomeViewController.h
//  TimeLineApp
//
//  Created by Hanny on 12/10/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLAddJobViewController.h"
#import "TLEditJobViewController.h"
#import "TLTasksTableViewCell.h"
#import "TLTransactionsTableViewCell.h"
#import "DataSyncHandler.h"
#import "Transaction.h"
#import "IQDropDownTextField.h"

@interface HomeViewController : UIViewController<UITableViewDataSource , UITableViewDelegate, UIAlertViewDelegate, TLAddJobViewControllerDelegate, TLEditJobViewControllerDelegate, TLTasksTableViewCellDelegate,TLTransactionsTableViewCellDelegate, DataSyncHandlerDelegate>
{
    NSMutableArray * dataSourceArray;
    NSMutableArray * permanentLinesArray;
    
    UIRefreshControl * refreshControl;
    int copyFlag;
    
    float maxHoursWeekForAddEditScreen;
    int errorVariable;
}

@property (nonatomic, retain) NSMutableArray * dataSourceArray;
@property (retain, nonatomic) NSMutableArray * permanentLinesArray;
@property (retain, nonatomic) NSMutableArray * checkedTransactionsArray;
@property (retain, nonatomic) NSMutableArray * copiedTransactionsArray;
@property (retain, nonatomic) NSMutableArray * calendarDatesArray;
@property (retain, nonatomic) NSMutableArray * calendarDatesHoursArray;
@property (retain, nonatomic) NSMutableArray * calendarDatesBillableHoursArray;

@property (weak, nonatomic) IBOutlet UILabel *NoTransactionsLabel;
@property (weak, nonatomic) IBOutlet UITextField *monthCalendarTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIView *datePickerView;

@property (nonatomic) int recordIDToEdit;

@property (nonatomic , weak) IBOutlet UITableView *mainTableView;

@property (weak, nonatomic) IBOutlet UIButton *date1Button;
@property (weak, nonatomic) IBOutlet UIButton *date2Button;
@property (weak, nonatomic) IBOutlet UIButton *date3Button;
@property (weak, nonatomic) IBOutlet UIButton *date4Button;
@property (weak, nonatomic) IBOutlet UIButton *date5Button;
@property (weak, nonatomic) IBOutlet UIButton *date6Button;
@property (weak, nonatomic) IBOutlet UIButton *date7Button;

@property (weak, nonatomic) IBOutlet UIView *calendarView;
@property (weak, nonatomic) IBOutlet UIView *optionsView;
@property (weak, nonatomic) IBOutlet UIView *bottomMenuView;

@property (weak, nonatomic) IBOutlet UILabel *pendingTransactionsLabel;

-(IBAction)dateSelected:(id)sender;
- (IBAction)menuButtonAction:(id)sender;

- (IBAction)sumitButtonTapped:(id)sender;
- (IBAction)submitAllButtonTapped:(id)sender;
- (IBAction)deleteButtonTapped:(id)sender;
- (IBAction)copyButtonTapped:(id)sender;
- (IBAction)pasteButtonTapped:(id)sender;

- (IBAction) monthCalendarButtonTapped:(id)sender;

-(void) fetchTransactionsOfCurrentSelectedDate;
-(IBAction)doneButtonForDatePickerClicked:(UIBarButtonItem*)button;
-(IBAction) pendingTransactionsButtonTapped:(id) sender;

@end
