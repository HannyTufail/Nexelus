//
//  HomeViewController.m
//  TimeLineApp
//
//  Created by Hanny on 12/10/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "HomeViewController.h"
#import "TLWeekOfYear.h"
#import "TLUtilities.h"
#import "TLSettingsViewController.h"
#import "TLBillableHoursViewController.h"
#import "PendingJobsViewController.h"
#import "TLConstants.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"




@interface HomeViewController () <UIActionSheetDelegate>
{
    NSDate *selectedDate;
    UIButton *selectedDateButton;
    
    NSCalendar *gregorianCalendar;
    NSDateFormatter *dateFormatter;
    
    NSMutableArray *dateButtonsArray;
    NSDate *startDateOfCurrentWeek;
    UIView *eventSymbolsView;
    
    TLWeekOfYear *currentShowingWeek;
    UIButton *dropdownButton;
}
@end

@implementation HomeViewController
@synthesize dataSourceArray;
@synthesize permanentLinesArray;
@synthesize calendarDatesHoursArray, calendarDatesBillableHoursArray,calendarDatesArray, copiedTransactionsArray;

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UINib *nibForTransactionsCell = [UINib nibWithNibName:@"TLTransactionsTableViewCell" bundle:nil];
    [[self mainTableView] registerNib:nibForTransactionsCell forCellReuseIdentifier:@"TLTransactionsTableViewCell"];

    UINib *nibForTaskCell = [UINib nibWithNibName:@"TLTasksTableViewCell" bundle:nil];
    [[self mainTableView] registerNib:nibForTaskCell forCellReuseIdentifier:@"TLTasksTableViewCell"];

    
    dateButtonsArray = [[NSMutableArray alloc] initWithObjects:self.date1Button, self.date2Button, self.date3Button, self.date4Button, self.date5Button, self.date6Button, self.date7Button, nil];
    
    
    gregorianCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    gregorianCalendar.locale = [NSLocale autoupdatingCurrentLocale];
    [gregorianCalendar setFirstWeekday:2];
    
    
    dateFormatter = [[NSDateFormatter alloc] init];
    
    selectedDate = [NSDate date];
    
    currentShowingWeek = [self getWeekFromDate:selectedDate]; // Fetch CurrentWeek For Current Date
    startDateOfCurrentWeek = currentShowingWeek.weekStartDate;
    
    CGRect frame = _calendarView.bounds;
    frame.origin.y = 62;
    frame.size.height = 20;
    
    eventSymbolsView = [[UIView alloc] initWithFrame:frame];
    eventSymbolsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_calendarView addSubview:eventSymbolsView];
    [eventSymbolsView setBackgroundColor:[UIColor clearColor]];
    
    self.copiedTransactionsArray = [[NSMutableArray alloc] init];
    self.checkedTransactionsArray = [[NSMutableArray alloc] init];
    self.calendarDatesArray =[[NSMutableArray alloc] init];
    self.calendarDatesHoursArray = [[NSMutableArray alloc] init];
    self.calendarDatesBillableHoursArray = [[NSMutableArray alloc] init];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [self.mainTableView addSubview:refreshControl];
    refreshControl.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    maxHoursWeekForAddEditScreen = 0.0;
    
    [self.datePicker addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar setHidden:NO];

    [self fetchAppTitle];
    
    [self setupNavigationBarUI];
    [self setUpCalendarView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataRefreshedSuccessfullyAgainstPullToRefresh) name:kSyncCompletionNotification object:nil];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void)setupNavigationBarUI
{    
    UIImage *dropDownImage = [UIImage imageNamed:@"icn_actions.png"];
    
    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonAction:)];
    
    dropdownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropdownButton addTarget:self action:@selector(showOptionsViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [dropdownButton setContentMode:UIViewContentModeScaleAspectFit];
    [dropdownButton setBackgroundImage:dropDownImage forState:UIControlStateNormal];
    dropdownButton.frame = CGRectMake(0, 0, 22.0, 22.0);
    UIBarButtonItem *dropDownBarButton = [[UIBarButtonItem alloc] initWithCustomView:dropdownButton];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    buttonflexible.width = -16;
    [self.navigationItem setRightBarButtonItems:@[addButton,buttonflexible,dropDownBarButton]];
    self.navigationItem.title = @"Timesheet";
    
    [self makeCustomBarButtonForBack:NO];
}


-(void)addButtonAction:(id)sender
{
    
    if (!_optionsView.hidden)
    {
        [self showOptionsViewButtonAction:nil];
    }
    
    TLAddJobViewController *controller = [[TLAddJobViewController alloc] initWithNibName:@"TLAddJobViewController" bundle:nil];
    controller.delegate = self;
    controller.selectedDateString = [NSString stringWithFormat:@"%@", selectedDate];
    controller.maxHoursWeek = maxHoursWeekForAddEditScreen;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void) fetchAppTitle
{
    NSString *query = [NSString stringWithFormat:@"SELECT display_name FROM pdm_sys_names WHERE field_name = '%@';",FIELD_APP_NAME];
    self.title = [[[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:query] lastObject] lastObject];
}

#pragma mark - UIDatePicker Methods

- (void)datePickerChanged:(UIDatePicker *)datePicker
{
    NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
    [dateFormatters setDateFormat:@"EEEE MMMM dd, yyyy"];
    NSString *strDate = [dateFormatters stringFromDate:datePicker.date];
    self.monthCalendarTextField.text = strDate;
}

-(IBAction)doneButtonForDatePickerClicked:(UIBarButtonItem*)button
{
    selectedDate = self.datePicker.date;
    currentShowingWeek = [self getWeekFromDate:self.datePicker.date];
    [self setUpCalendarView];
    self.datePickerView.hidden = YES;
    self.calendarView.userInteractionEnabled = YES;
    
    if (!self.dataSourceArray.count >0)
    {
        [self.NoTransactionsLabel setHidden:NO];
    }
    else
    {
        [self.NoTransactionsLabel setHidden:YES];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    BOOL shouldSwipe = NO;
    
    if ( [gestureRecognizer isMemberOfClass:[UISwipeGestureRecognizer class]] )
    {
        if ([_optionsView isHidden]) {
            shouldSwipe = YES;
        }
        else
        {
            shouldSwipe = NO;
        }
    }
    
    return shouldSwipe;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer*)gestureRecognizer;
    
    if(CGRectContainsPoint(self.calendarView.frame, [gestureRecognizer locationInView:self.view]))
    {
        //show animation
        switch(swipe.direction)
        {
            case UISwipeGestureRecognizerDirectionLeft:
            {
                [self showNextWeekWithAnimation:YES];
                return YES;
            }
                break;
                
            case UISwipeGestureRecognizerDirectionRight:
            {
                [self showPreviousWeekWithAnimation:YES];
                return YES;
            }
                break;
            default:
                break;
        }
    }
    return NO;
}

#pragma mark - OptionsView IBAction Methods

-(void) submitCheckedTransaction:(Transaction *) transactObj
{
    __block NSString * query = @"";
    if (transactObj.units == 0)
    {
        query = [NSString stringWithFormat:@"DELETE FROM pld_transaction WHERE  transaction_id = '%@';",transactObj.transactionID];
        [[DataSyncHandler defaultHandler] executeQuery:query];
    }
    else
    {
        if ([TLUtilities verifyInternetAvailability])
        {
            transactObj.submitFlag = 1;
            transactObj.syncStatus = 1;
            transactObj.approvalStatus = 0;
            transactObj.appliedDate = [TLUtilities ConvertDate:transactObj.appliedDate FromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM-dd HH:mm:ss"];
            [DataSyncHandler defaultHandler].isSyncingTransaction = YES;
            [[DataSyncHandler defaultHandler] updateTransactionOnServer:transactObj completionHandler:^(BOOL success, NSString *errMsg) {
                if (success)
                {
                    NSLog(@"Transaction Updated Successfully On Server from Home Screen after Submitting.");
                    [self fetchTransactionsOfCurrentSelectedDate];
                    // No need to update transaction in LocalDB from here now, because it would automatically be updated into the LocalDB in "updateTransactionOnServer" Method in DataSyncHandler class.
                }

                [DataSyncHandler defaultHandler].isSyncingTransaction = YES;
            }];
        }
        else
        {
            transactObj.submitFlag = 1;
            query = [NSString stringWithFormat:@"UPDATE pld_transaction SET submitted_flag = 1,approval_flag = 0 ,sync_status=0 WHERE  transaction_id = '%@';",transactObj.transactionID];
            [[DataSyncHandler defaultHandler] executeQuery:query];
        }
    }
}

- (IBAction)sumitButtonTapped:(id)sender
{
    if (!self.checkedTransactionsArray.count >0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:SUBMIT_CHECK_MESSAGE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
//        errorVariable = 0;
        MBProgressHUD * hud =  nil;
        NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"SELF.submitFlag != 1"];
        NSArray * tempArray = [self.checkedTransactionsArray filteredArrayUsingPredicate:namePredicate];
        if (tempArray.count >0)
        {
            // Check if there is a Pure permanent Line in the array
            NSPredicate *transactioIDPredicate = [NSPredicate predicateWithFormat:@"SELF.transactionID != %@",@""];
            NSArray * transactionsTempArray = [tempArray filteredArrayUsingPredicate:transactioIDPredicate];
            if (transactionsTempArray.count >0)
            {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = SUBMIT_MESSAGE;
                hud.mode = MBProgressHUDModeIndeterminate;
                
                for (Transaction * tempObj in transactionsTempArray)
                {
                    [self submitCheckedTransaction:tempObj];
                }
                
                    double delayInSeconds = 1.5;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           [self fetchTransactionsOfCurrentSelectedDate];
                           hud.labelText = SUBMIT_SUCCESSFULLY;
                           hud.mode = MBProgressHUDModeText;
                           [hud hide:YES afterDelay:1.0];
                       });
                
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:SUBMIT_PINNED_CHECK_MESSAGE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
        else
        {
            NSString * messageString = [NSString stringWithFormat:@"Transaction(s) already Submitted"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:messageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];

        }
    }
}

- (IBAction)submitAllButtonTapped:(id)sender
{
    if (!self.dataSourceArray.count >0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:SUBMIT_ALL_NO_TRANSACTION delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        MBProgressHUD * hud =  nil;
        NSPredicate *submittedPredicate = [NSPredicate predicateWithFormat:@"SELF.submitFlag != 1"];
        NSArray * tempArray = [self.dataSourceArray filteredArrayUsingPredicate:submittedPredicate];
        if (tempArray.count >0)
        {
            // Check if there is a Pure permanent Line in the array
            NSPredicate *transactioIDPredicate = [NSPredicate predicateWithFormat:@"SELF.transactionID != %@",@""];
            NSArray * transactionsTempArray = [tempArray filteredArrayUsingPredicate:transactioIDPredicate];
            if (transactionsTempArray.count >0)
            {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = SUBMIT_MESSAGE;
                hud.mode = MBProgressHUDModeIndeterminate;

                
                for (Transaction * tempObj in transactionsTempArray)
                {
                    [self submitCheckedTransaction:tempObj];
                }
                
                double delayInSeconds = 1.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       [self fetchTransactionsOfCurrentSelectedDate];
                       hud.labelText = SUBMIT_SUCCESSFULLY;
                       hud.mode = MBProgressHUDModeText;
                       [hud hide:YES afterDelay:1.0];
                   });
            }
            else
            {
                // In this case we shall not show 'SUBMIT_PINNED_CHECK_MESSAGE' because Submit All doesnt care about the checked transactions.
                // this section means here that All the avialable transactions on this data are EITHER already Submitted OR Pinned Lines.
                
                NSString * messageString = [NSString stringWithFormat:@"No Transaction(s) available for submission"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:messageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
        else
        {
            NSString * messageString = [NSString stringWithFormat:@"Transaction(s) already Submitted"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:messageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

-(void) deleteCheckedTransaction:(Transaction *) transactObj
{
    if ([TLUtilities verifyInternetAvailability])
    {
        transactObj.appliedDate = [TLUtilities ConvertDate:transactObj.appliedDate FromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM-dd HH:mm:ss"];
        [[DataSyncHandler defaultHandler] deleteTransactionOnServer:transactObj completionHandler:^(BOOL success, NSString *errMsg) {
            
            if (success)
            {
                // No need to delete transaction in LocalDB from here now, because it would automatically be deleted into the LocalDB in "deleteTransactionOnServer" Method in DataSyncHandler class.
                [self.copiedTransactionsArray removeAllObjects];
            }
            else
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:errMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
    else
    {
            [self.copiedTransactionsArray removeAllObjects];
            transactObj.deletedFlag = 1;
            NSString * updateQuery = [NSString stringWithFormat:@"UPDATE pld_transaction SET sync_status = 0, deleted = 1 WHERE  transaction_id = '%@';",transactObj.transactionID];
            [[DataSyncHandler defaultHandler] executeQuery:updateQuery];
    }
}

- (IBAction)deleteButtonTapped:(id)sender
{
    if (!self.checkedTransactionsArray.count >0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:DELETE_CHECK_MESSAGE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        NSPredicate *submittedPredicate = [NSPredicate predicateWithFormat:@"SELF.submitFlag != 1"];
        NSArray * tempArray = [self.checkedTransactionsArray filteredArrayUsingPredicate:submittedPredicate];
        if (tempArray.count >0)
        {
            // Check if there is a Pure permanent Line in the array
            NSPredicate *transactioIDPredicate = [NSPredicate predicateWithFormat:@"SELF.transactionID != %@",@""];
            NSArray * transactionsTempArray = [tempArray filteredArrayUsingPredicate:transactioIDPredicate];
            if (transactionsTempArray.count >0)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CONFIRMATION_REQUIRED_TITLE message:SURE_TO_DELETE delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES",nil];
                alert.delegate = self;
                alert.tag = 1473;
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:SUBMIT_PINNED_CHECK_MESSAGE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
        else
        {
            NSString * messageString = [NSString stringWithFormat:@"Action cannot be performed on current Transaction(s)"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:messageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    
}
- (IBAction)copyButtonTapped:(id)sender
{
    if (!self.checkedTransactionsArray.count >0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:COPY_CHECK_MESSAGE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self.copiedTransactionsArray removeAllObjects];
        // Check if there is a Pure permanent Line in the array
        NSPredicate *transactioIDPredicate = [NSPredicate predicateWithFormat:@"SELF.transactionID != %@",@""];
        NSArray * transactionsTempArray = [self.checkedTransactionsArray filteredArrayUsingPredicate:transactioIDPredicate];
        if (transactionsTempArray.count >0)
        {
            copyFlag = 1;
            
            // keep the selected Transactions in the Copied Array unless user pastes them.
            [self.copiedTransactionsArray addObjectsFromArray:transactionsTempArray];
            
            MBProgressHUD * hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = COPIED_SUCCESSFULLY;
            hud.mode = MBProgressHUDModeText;
            [hud hide:YES afterDelay:1.0];
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:SUBMIT_PINNED_CHECK_MESSAGE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }

        
    }
}

- (IBAction)pasteButtonTapped:(id)sender
{
    if (!self.copiedTransactionsArray.count >0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:PASTE_CHECK_MESSAGE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
//        // Check if there is a Pure permanent Line in the array
//        NSPredicate *transactioIDPredicate = [NSPredicate predicateWithFormat:@"SELF.transactionID != %@",@""];
//        NSArray * transactionsTempArray = [self.checkedTransactionsArray filteredArrayUsingPredicate:transactioIDPredicate];
//        if (transactionsTempArray.count >0)
//        {
            MBProgressHUD * hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = PASTE_MESSAGE;
            hud.mode = MBProgressHUDModeIndeterminate;
        
            int counter =0;
            for (Transaction * transactionObj in self.copiedTransactionsArray)
            {
                counter +=1;
                transactionObj.units = 0.0;
                transactionObj.submitFlag  =0;
                transactionObj.approvalStatus = 0;
                transactionObj.syncStatus = 0;
                transactionObj.deletedFlag = 0;
                transactionObj.nonBillableFlag = 0;
                transactionObj.timeStamp = @"";
                transactionObj.errorCode = 0;
                transactionObj.errorFlag = 0;
                transactionObj.errorDescription = @"";
                
                transactionObj.appliedDate = [TLUtilities ConvertDate:[NSString stringWithFormat:@"%@",selectedDate] FromFormat:@"yyyy-MM-dd HH:mm:ss z" toFormat:@"yyyy-MM-dd"];
                transactionObj.submittedDate = [TLUtilities ConvertDate:[NSString stringWithFormat:@"%@",selectedDate] FromFormat:@"yyyy-MM-dd HH:mm:ss z" toFormat:@"yyyy-MM-dd"];
                transactionObj.modifyDate = [NSString stringWithFormat:@"%@",[NSDate date]];
                
                NSString * transactionID = [NSString stringWithFormat:@"%@", [TLUtilities generateTransactionIDusingCounter:counter]];
                NSString * resourceID = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_RESOURCE_ID];
                if ([transactionObj.resUsageCode isEqualToString:@""]) {
                    transactionObj.resUsageCode = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_RES_USAGE_CODE];
                }
                
                NSString * query = [NSString stringWithFormat:@"INSERT INTO pld_transaction VALUES(%i,'%@','%@','%@','%@',%i,'%@','%@',%.2f,'%@','%@','%@','%@',%i,%i,'%@',%i,%i,%i,'%@','%@',%i,%i,'%@');",[[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE] intValue],
                                    transactionID,
                                    transactionObj.level2Key,
                                    transactionObj.level3Key,
                                    transactionObj.appliedDate,
                                    transactionObj.transactionType,
                                    resourceID,
                                    transactionObj.resUsageCode,
                                    transactionObj.units,
                                    transactionObj.locationCode,
                                    transactionObj.orgUnit,
                                    transactionObj.taskCode,
                                    transactionObj.comments,
                                    transactionObj.nonBillableFlag,
                                    transactionObj.submitFlag,
                                    transactionObj.submittedDate,
                                    transactionObj.approvalStatus,
                                    transactionObj.syncStatus,
                                    transactionObj.deletedFlag,
                                    transactionObj.modifyDate,
                                    transactionObj.timeStamp,
                                    transactionObj.errorFlag,
                                    transactionObj.errorCode,
                                    transactionObj.errorDescription];
                [[DataSyncHandler defaultHandler] executeQuery:query];
            }
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
           {
               [self fetchTransactionsOfCurrentSelectedDate];
               hud.labelText = PASTED_SUCCESSFULLY;
               hud.mode = MBProgressHUDModeText;
               [hud hide:YES afterDelay:1.0];
               
           });
        [self.copiedTransactionsArray removeAllObjects];
//        }
    }
}

#pragma mark - UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 102)
    {
        if(buttonIndex == 1)
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:UDKEY_USER_HAS_LOGGED_IN];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else {
            
        }
    }
    else if ( alertView.tag == 1473)
    {
        if(buttonIndex == 1)
        {
            MBProgressHUD * hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = DELETE_MESSAGE;
            hud.mode = MBProgressHUDModeIndeterminate;
            
            NSPredicate *submittedPredicate = [NSPredicate predicateWithFormat:@"SELF.submitFlag != 1"];
            NSArray * tempArray = [self.checkedTransactionsArray filteredArrayUsingPredicate:submittedPredicate];
            if (tempArray.count >0)
            {
                // Check if there is a Pure permanent Line in the array
                NSPredicate *transactioIDPredicate = [NSPredicate predicateWithFormat:@"SELF.transactionID != %@",@""];
                NSArray * transactionsTempArray = [tempArray filteredArrayUsingPredicate:transactioIDPredicate];
                if (transactionsTempArray.count >0)
                {
                    for (Transaction * tempObj in transactionsTempArray)
                    {
                        [self deleteCheckedTransaction:tempObj];
                    }
                    
                    double delayInSeconds = 1.5;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           [self updateCaledarViewUI];
                           [self fetchTransactionsOfCurrentSelectedDate];
                           hud.labelText = DELETE_SUCCESSFULLY;
                           hud.mode = MBProgressHUDModeText;
                           [hud hide:YES afterDelay:1.0];
                       });
                }
            }
        }
    }
}

#pragma mark - IBAction Methods

- (IBAction) monthCalendarButtonTapped:(id)sender
{
    self.calendarView.userInteractionEnabled = NO;
    self.datePicker.date = selectedDate;
    self.datePickerView.hidden = NO;
    
    [self.NoTransactionsLabel setHidden:YES];
}

- (IBAction)menuButtonAction:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Billable Hours Chart",@"Pending Transactions",@"User Settings",@"Main Menu",@"Sign Out", nil];
    sheet.delegate = self;
    [sheet showInView:self.view];
}

-(void)showOptionsViewButtonAction:(id)sender
{
    UIImage *downImage = [UIImage imageNamed:@"icn_actions.png"];
    UIImage *upImage = [UIImage imageNamed:@"icn_actions_up.png"];
    
//    if (_optionsView.hidden)
//    {
//        CGRect frame = _optionsView.frame;
//        _optionsView.frame = frame;
//        frame.origin.y += 85;
//        [UIView animateWithDuration:0.7 animations:^{
//            _optionsView.frame = frame;
//           _optionsView.hidden = !_optionsView.hidden;
//        } completion:^(BOOL finished){
//            [self.calendarView setUserInteractionEnabled:NO];
//            [dropdownButton setBackgroundImage:upImage forState:UIControlStateNormal];
//        }];
//        
//    }
//    else if (!_optionsView.hidden)
//    {
//        __block CGRect rectFrame = _optionsView.frame;
//        [UIView animateWithDuration:0.7 animations:^{
//            
//            rectFrame.origin.y -= 85;
//            _optionsView.frame = rectFrame;
//            
//        } completion:^(BOOL finished)
//        {
//            _optionsView.hidden = !_optionsView.hidden;
//            [self.calendarView setUserInteractionEnabled:YES];
//            [dropdownButton setBackgroundImage:downImage forState:UIControlStateNormal];
//        }];
//    }
    
    if (_optionsView.hidden)
    {
        [self.calendarView setUserInteractionEnabled:NO];
        
        [dropdownButton setBackgroundImage:upImage forState:UIControlStateNormal];
    }
    else if (!_optionsView.hidden)
    {
        [self.calendarView setUserInteractionEnabled:YES];
        
        [dropdownButton setBackgroundImage:downImage forState:UIControlStateNormal];
    }
     _optionsView.hidden = !_optionsView.hidden;
}

-(void) updatePendingTransactionsCount
{
    NSString *query = [NSString stringWithFormat:@"SELECT pld_transaction.* , level2_description FROM pld_transaction join pdd_level2 on pld_transaction.level2_key=pdd_level2.level2_key WHERE sync_status = 0 AND deleted = 0 AND unit != 0;"];
    NSArray * pendingTransactionsArray = [[DataSyncHandler defaultHandler].dbManager loadDataFromDB:query];
    
    self.pendingTransactionsLabel.text = [NSString stringWithFormat:@"%@ \nPending Transaction(s): %i",[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_LAST_SYNC_DATE],(int)pendingTransactionsArray.count];
}

- (void)refreshTable
{
    if ([TLUtilities verifyInternetAvailability])
    {
        UIFont *font = [UIFont boldSystemFontOfSize:14.0];
        
        NSDictionary *attrsDictionary = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:font};
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_LAST_SYNC_DATE] attributes:attrsDictionary];
        refreshControl.attributedTitle = attributedTitle;
        
        // Sync Transactions Only as per instructions from Asim Jamil on 11th Feb, 2015.
        [DataSyncHandler defaultHandler].delegate = self;
        [DataSyncHandler defaultHandler].isDelegateSetFromLogin = NO;
        [DataSyncHandler defaultHandler]._syncTypes = forPullToRefresh;
        [[DataSyncHandler defaultHandler] syncLocalDBTransactionsOnlyWithServerAndFetchLatest];
        [self updatePendingTransactionsCount];
        [self.mainTableView reloadData];
    }
    else
    {
        [refreshControl endRefreshing];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Synchronization" message:INTERNET_NOT_AVAILABLE delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(IBAction) pendingTransactionsButtonTapped:(id) sender
{
    if (!_optionsView.hidden)
    {
        [self showOptionsViewButtonAction:nil];
    }
    
    PendingJobsViewController *pendingJobController = [[PendingJobsViewController alloc] initWithNibName:@"PendingJobsViewController" bundle:nil];
    pendingJobController.calendarDatesArray = self.calendarDatesArray;
    pendingJobController.calendarDatesHoursArray = self.calendarDatesBillableHoursArray;
    
    [self.navigationController pushViewController:pendingJobController animated:YES];
}

#pragma mark - LocalDB methods implementation

-(void) runSQLQuery:(NSString *) query forPermanentLines:(BOOL) isPermanentLinesQuery
{
    NSArray *transactionsArray =[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:query];
    
    if (transactionsArray.count >0)
    {
        for (NSArray * tempArray in transactionsArray)
        {
            NSString * transactID = @"";
            NSString * level2Key = @"";
            NSString * level2Desc = @"";
            NSString * level3Key = @"";
            NSString * appliedDate = @"";
            NSString * resourceID = @"";
            NSString * resUsageCode = @"";
            NSString * locationCode = @"";
            NSString * orgUnit = @"";
            NSString * taskCode = @"";
            NSString * comments = @"";
            NSString * modifiedDate= @"";
            NSString * submittedDate = @"";
            NSString * timeStamp = @"";
            NSString * errorDescription = @"";
            
            int approvalFlag = 0;
            int syncStatus = 0;
            int nonBillableFlag =0;
            int submittedFlag =0;
            int  transactType = 0;
            float  unit =0.0;
            int errorFlag = 0;
            int errorCode =0;
            
            
            if (isPermanentLinesQuery)
            {
                transactID = @"";
                level2Key = [tempArray objectAtIndex:1];
                level3Key = [tempArray objectAtIndex:2];
                taskCode = [tempArray objectAtIndex:3];
                appliedDate = [tempArray objectAtIndex:4];
                modifiedDate = [tempArray objectAtIndex:5];
                syncStatus = [[tempArray objectAtIndex:6] intValue];
                level2Desc = [tempArray objectAtIndex:8];
                transactType = 0;
                resourceID = @"";
                resUsageCode = @"";
                unit = 0.0;
                locationCode = @"";
                orgUnit = @"";
                comments = @"";
                nonBillableFlag = 0;
                submittedFlag = 0;
                submittedDate = @"";
                approvalFlag = 0;
                
                timeStamp = @"";
                errorFlag = 0;
                errorCode = 0;
                errorDescription = @"";

            }
            else
            {
                transactID = [tempArray objectAtIndex:1];
                level2Key = [tempArray objectAtIndex:2];
                level3Key = [tempArray objectAtIndex:3];
                appliedDate = [tempArray objectAtIndex:4];
                transactType = [[tempArray objectAtIndex:5] intValue];
                resourceID = [tempArray objectAtIndex:6];
                resUsageCode = [tempArray objectAtIndex:7];
                unit = [[tempArray objectAtIndex:8] floatValue];
                locationCode = [tempArray objectAtIndex:9];
                orgUnit = [tempArray objectAtIndex:10];
                taskCode = [tempArray objectAtIndex:11];
                comments = [tempArray objectAtIndex:12];
                nonBillableFlag = [[tempArray objectAtIndex:13] intValue];
                submittedFlag = [[tempArray objectAtIndex:14] intValue];
                submittedDate = [tempArray objectAtIndex:15];
                approvalFlag = [[tempArray objectAtIndex:16] intValue];
                syncStatus = [[tempArray objectAtIndex:17] intValue];
                //            int deleted = [[tempArray objectAtIndex:18] intValue];
                modifiedDate = [tempArray objectAtIndex:19];
                
                timeStamp =[tempArray objectAtIndex:20];
                errorFlag = [[tempArray objectAtIndex:21] intValue];
                errorCode = [[tempArray objectAtIndex:22] intValue];
                errorDescription = [tempArray objectAtIndex:23];
                
                if (tempArray.count > 24) {
                    level2Desc = [tempArray objectAtIndex:24];
                }
                else
                {
                    level2Desc = @"";
                }
                
            }
            
            /*
             pld_transaction(company_code INTEGER NOT NULL,transaction_id TEXT NOT NULL,level2_key  TEXT NOT NULL,level3_key TEXT NOT NULL, applied_date DATE NOT NULL,trx_type INTEGER NOT NULL,resource_id TEXT NOT NULL,res_usage_code TEXT,unit REAL,location_code TEXT,org_unit  TEXT,task_code TEXT, comments TEXT,nonbillable_flag INTEGER,submitted_flag  INTEGER,submitted_date DATE, approval_flag INTEGER,sync_status INTEGER,deleted  INTEGER,modified_datetime DATE,timestamp TEXT, error_flag INTEGER,error_code INTEGER, error_description TEXT, PRIMARY KEY(company_code, transaction_id))
             
             */
            
            Transaction * transObj = [[Transaction alloc] initTransactionWithID:transactID
                                                                transactionType:transactType
                                                                          ofJob:level2Key
                                                                       activity:level3Key
                                                                       taskCode:taskCode
                                                                        orgUnit:orgUnit
                                                                       comments:comments
                                                                       resource:resourceID
                                                                   resUsageCode:resUsageCode
                                                                      appliedOn:appliedDate
                                                                     modifiedOn:modifiedDate
                                                                    submittedOn:submittedDate
                                                              withApprovalFlags:approvalFlag
                                                                     submitFlag:submittedFlag
                                                                nonBillableFlag:nonBillableFlag
                                                                  andSyncedFlag:syncStatus
                                                                          Units:unit
                                                                andLocationCode:locationCode];
            transObj.level2Description = level2Desc;
            transObj.isPermanentLine = isPermanentLinesQuery;
            transObj.timeStamp = timeStamp;
            transObj.errorFlag = errorFlag;
            transObj.errorCode = errorCode;
            transObj.errorDescription = errorDescription;
            
            if (transObj)
            {
                if (isPermanentLinesQuery)
                {
                    // If task is compulsory then add use Predicate. @"(level2Key=%@) AND (level3Key=%@) AND (taskCode=%@)"
                    // Otherwise just use this @"(level2Key=%@) AND (level3Key=%@)
                    
                           NSInteger showTask = [[NSUserDefaults standardUserDefaults] integerForKey:UDKEY_SHOW_TASKS];
                            NSPredicate * levelPredicate = nil;
                            if (showTask == 3)
                            {
                                levelPredicate = [NSPredicate predicateWithFormat:@"(level2Key=%@) AND (level3Key=%@) AND (taskCode=%@)", transObj.level2Key, transObj.level3Key, transObj.taskCode];
                            }
                            else
                                levelPredicate = [NSPredicate predicateWithFormat:@"(level2Key=%@) AND (level3Key=%@)", transObj.level2Key, transObj.level3Key];
                            
                            NSArray *resArray = [self.dataSourceArray filteredArrayUsingPredicate:levelPredicate];//[tempArray filteredArrayUsingPredicate:levelPredicate];
                            if (resArray.count >0)
                            {
                                for (Transaction * tempObj in resArray)
                                {
                                    int anIndex= (int)[self.dataSourceArray indexOfObject:tempObj];
                                    if (anIndex!= -1)
                                    {
                                        Transaction * tempObj = [self.dataSourceArray objectAtIndex:anIndex];
                                        [tempObj setIsPermanentLine:YES];
                                    }
                                }
                            }
                            else
                            {
                                [self.dataSourceArray addObject:transObj];
                            }
                }
                else
                 [self.dataSourceArray addObject:transObj];
            }
        }
    }
    
    // Sort the dataSource Array based on 'SortBy' value.
    NSString * sortByString = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_SORT_BY]];
    if ([sortByString isEqualToString:@"1"] || [sortByString isEqualToString:@"3"])
    {
        // sort By Level2Key
        NSArray *sortedArray;
        sortedArray = [self.dataSourceArray sortedArrayUsingComparator:^NSComparisonResult(Transaction * a, Transaction * b) {
            NSString *first = a.level2Key;
            NSString *second = b.level2Key;
            return [first compare:second];
        }];
        
        [self.dataSourceArray removeAllObjects];
        [self.dataSourceArray addObjectsFromArray:sortedArray];
    }
    else if ([sortByString isEqualToString:@"2"])
    {
        // sort By Level2  Desc
        NSArray *sortedArray;
        sortedArray = [self.dataSourceArray sortedArrayUsingComparator:^NSComparisonResult(Transaction * a, Transaction * b) {
            NSString *first = a.level2Description;
            NSString *second = b.level2Description;
            return [first compare:second];
        }];
        [self.dataSourceArray removeAllObjects];
        [self.dataSourceArray addObjectsFromArray:sortedArray];
    }
    // Reload the table view.
    [self.mainTableView reloadData];
}

-(void) fetchPermanentLinesTransactionsOfCurrentSelectedDate
{
    
    /*
     
     SELECT pdm_permanent_line.*, level2_description FROM pdm_permanent_line JOIN pdd_level2 on pdm_permanent_line.level2_key=pdd_level2.level2_key WHERE deleted = 0 AND '%@' BETWEEN ifnull(start_date, '1700-01-01') AND '2099-12-30'
     
     SELECT pdm_permanent_line.*, level2_description FROM pdm_permanent_line JOIN pdd_level2 on pdm_permanent_line.level2_key=pdd_level2.level2_key JOIN pdd_level3 on pdm_permanent_line.level2_key = pdd_level3.level2_key AND pdm_permanent_line.level3_key=pdd_level3.level3_key  WHERE deleted = 0 AND '%@' BETWEEN ifnull(start_date, '1700-01-01') AND '2099-12-30' AND '%@' <= ifnull(pdd_level2.close_date, '2099-01-01') AND '%@' <= ifnull(pdd_level3.close_date, '2099-01-01')
     */
    
    NSString * appliedDateString = [TLUtilities ConvertDate:[NSString stringWithFormat:@"%@", selectedDate] FromFormat:@"yyyy-MM-dd HH:mm:ss z" toFormat:@"yyyy-MM-dd"];
    NSString *query = [NSString stringWithFormat:@" SELECT pdm_permanent_line.*, level2_description FROM pdm_permanent_line JOIN pdd_level2 on pdm_permanent_line.level2_key=pdd_level2.level2_key JOIN pdd_level3 on pdm_permanent_line.level2_key = pdd_level3.level2_key AND pdm_permanent_line.level3_key=pdd_level3.level3_key  WHERE deleted = 0 AND '%@' BETWEEN ifnull(start_date, '1700-01-01') AND '2099-12-30' AND ('%@' <= ifnull(pdd_level2.close_date, '2099-01-01') OR  pdd_level2.close_date ='' Or pdd_level2.close_date is null) AND ('%@' <= ifnull(pdd_level3.close_date, '2099-01-01') OR  pdd_level3.close_date ='' Or pdd_level3.close_date is null)", appliedDateString,appliedDateString,appliedDateString];
    
    
    [self runSQLQuery:query forPermanentLines:YES];
}

-(void) fetchTransactionsOfCurrentSelectedDate
{
    copyFlag = 0;
    
    // Remove all the Checked Transactions on Previously selected Date from this Array; And after performing Actions in OptionsView.
    [self.checkedTransactionsArray removeAllObjects];
    self.dataSourceArray = [[NSMutableArray alloc] init];
    
    NSString * appliedDateString = [TLUtilities ConvertDate:[NSString stringWithFormat:@"%@", selectedDate] FromFormat:@"yyyy-MM-dd HH:mm:ss z" toFormat:@"yyyy-MM-dd"];
    NSString *query = [NSString stringWithFormat:@"SELECT pld_transaction.* , level2_description FROM pld_transaction left join pdd_level2 on pld_transaction.level2_key=pdd_level2.level2_key WHERE applied_date = '%@'AND deleted = 0;",appliedDateString];
    [self runSQLQuery:query forPermanentLines:NO];
    
    // We have all the Transactions of the the Selected Date. Now is the time we should fetch Permanent Lines and apply conditions.
    [self fetchPermanentLinesTransactionsOfCurrentSelectedDate];
    
    if (!self.dataSourceArray.count >0 && [self.datePickerView isHidden])
    {
        [self.NoTransactionsLabel setHidden:NO];
    }
    else
    {
        [self.NoTransactionsLabel setHidden:YES];
    }
    [self updatePendingTransactionsCount];
    [self updateCaledarViewUI];
}


#pragma mark - TLEditJobViewControllerDelegate Methods

-(void) editingJobInfoWasFinished
{
    [self.copiedTransactionsArray removeAllObjects];
    [self fetchTransactionsOfCurrentSelectedDate];
    [self updatePendingTransactionsCount];
}

#pragma mark - TLAddJobViewControllerDelegate Methods

-(void) addingJobInfoWasFinished
{
    [self.copiedTransactionsArray removeAllObjects];
    [self fetchTransactionsOfCurrentSelectedDate];
    [self updatePendingTransactionsCount];
}

#pragma mark - Calender Handler Methods

- (void)showPreviousWeekWithAnimation:(BOOL)animated
{
    currentShowingWeek = [self getPreviousWeek];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.weekOfMonth = -1;
    selectedDate = [gregorianCalendar dateByAddingComponents:components toDate:selectedDate options:0];
    
    if(animated)
    {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromLeft;
        
        transition.delegate = self;
        [self.calendarView.layer addAnimation:transition forKey:nil];
    }
    
    [self setUpCalendarView];
    
}

- (void)showNextWeekWithAnimation:(BOOL)animated{
    
    currentShowingWeek = [self getNextWeek];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.weekOfMonth = 1;
    selectedDate = [gregorianCalendar dateByAddingComponents:components toDate:selectedDate options:0];
    
    if(animated){
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromRight;
        
        transition.delegate = self;
        [self.calendarView.layer addAnimation:transition forKey:nil];
    }
    
    [self setUpCalendarView];
}

- (void)setUpCalendarView
{
    [dateFormatter setDateFormat:@"EEEE MMMM dd, yyyy"];
    NSString *monthYear = [dateFormatter stringFromDate:selectedDate];
    
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:monthYear];
//    NSRange monthRange = [monthYear rangeOfString:[[monthYear componentsSeparatedByString:@" "] objectAtIndex:0]];
//    if([TLUtilities isIPad])
//    {
//        [attributedString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:30.0]} range:monthRange];
//    }
//    else{
//        [attributedString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0]} range:monthRange];
//    }
    
    
    self.monthCalendarTextField.text = monthYear;
    
    NSDate *tempDate = currentShowingWeek.weekStartDate;
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [dateFormatter setDateFormat:@"dd"];
    for(int i = 0; i < [dateButtonsArray count]; i++)
    {
        UIButton *dateButton = [dateButtonsArray objectAtIndex:i];
        [dateButton setTitle:[dateFormatter stringFromDate:tempDate] forState:UIControlStateNormal];
        
        if([TLUtilities isSameDayWithDate1:tempDate date2:selectedDate]) {
            
            selectedDateButton = dateButton;
            [dateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            if([TLUtilities isSameDayWithDate1:selectedDate date2:[NSDate date]])
            {
                [dateButton setBackgroundImage:[UIImage imageNamed:@"red_circle.png"] forState:UIControlStateNormal];
            }
            else{
                [dateButton setBackgroundImage:[UIImage imageNamed:@"purple_circle.png"] forState:UIControlStateNormal];
            }
            
            // Fetch the Transactions of Selected Date in Next/Previous Calendar. Just like Native Calendar Functionality.
            [self fetchTransactionsOfCurrentSelectedDate];
        }
        else
        {
            [dateButton setBackgroundImage:nil forState:UIControlStateNormal];
            [dateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            if(dateButton.tag == 0 || dateButton.tag == 6)
            {
                [dateButton setTitleColor:[UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            }
            else if([TLUtilities isSameDayWithDate1:tempDate date2:[NSDate date]]){
                [dateButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0 ] forState:UIControlStateNormal];
            }
            else{
                [dateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            
        }
        components.day = 1;
        tempDate = [gregorianCalendar dateByAddingComponents:components toDate:tempDate options:0];
    }
    
    [self updateCaledarViewUI];
}

-(TLWeekOfYear *) getWeekFromDate:(NSDate *) dateSelected
{
    // 1 == Sunday, 7 == Saturday
    
    TLWeekOfYear *week = [[TLWeekOfYear alloc] init];
    
    NSDateComponents *components = [gregorianCalendar components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:dateSelected];

    NSInteger dayofweek = [[gregorianCalendar components:NSWeekdayCalendarUnit fromDate:dateSelected] weekday];
   
    //Week Start Date
    int day = [components day] - (dayofweek - 1);
    [components setDay:day];
    
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss a"];
    
    week.weekStartDate = [gregorianCalendar dateFromComponents:components];
    
    components = [[NSDateComponents alloc] init];
    
    components.day = 6;
    
    week.weekEndDate = [gregorianCalendar dateByAddingComponents:components toDate:week.weekStartDate options:0];
    
    week.weekStartDateString = [dateFormatter stringFromDate:week.weekStartDate];
    week.weekEndDateString = [dateFormatter stringFromDate:week.weekEndDate];
    
    return week;
}

- (TLWeekOfYear *)getNextWeek
{
    TLWeekOfYear *week = [[TLWeekOfYear alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss a"];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = 7;
    week.weekStartDate = [gregorianCalendar dateByAddingComponents:components toDate:currentShowingWeek.weekStartDate options:0];
    components.day = 6;
    week.weekEndDate = [gregorianCalendar dateByAddingComponents:components toDate:week.weekStartDate options:0];
    
    week.weekStartDateString = [dateFormatter stringFromDate:week.weekStartDate];
    week.weekEndDateString = [dateFormatter stringFromDate:week.weekEndDate];
    
    return week;
}

- (TLWeekOfYear *)getPreviousWeek {
    
    TLWeekOfYear *week = [[TLWeekOfYear alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss a"];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = -7;
    week.weekStartDate = [gregorianCalendar dateByAddingComponents:components toDate:currentShowingWeek.weekStartDate options:0];
    components.day = 6;
    week.weekEndDate = [gregorianCalendar dateByAddingComponents:components toDate:week.weekStartDate options:0];
    
    week.weekStartDateString = [dateFormatter stringFromDate:week.weekStartDate];
    week.weekEndDateString = [dateFormatter stringFromDate:week.weekEndDate];
    
    return week;
}

- (IBAction)dateSelected:(id)sender
{
    selectedDateButton = (UIButton *)sender;
    selectedDate = [currentShowingWeek.weekStartDate dateByAddingTimeInterval:selectedDateButton.tag*60*60*24];
    [self setUpCalendarView];
    
    // Run a query on LocalDB for the Transactions for particular selected Date using Column "applied_date";
    [self fetchTransactionsOfCurrentSelectedDate];
}

- (void)updateCaledarViewUI
{
    if (self.calendarDatesArray.count>0)
    {
        [self.calendarDatesArray removeAllObjects];
    }
    if (self.calendarDatesHoursArray.count>0)
    {
        [self.calendarDatesHoursArray removeAllObjects];
    }
    if (self.calendarDatesBillableHoursArray.count >0)
    {
        [self.calendarDatesBillableHoursArray removeAllObjects];
    }
    
    for(UILabel *label in  [eventSymbolsView subviews])
    {
        [label removeFromSuperview];
    }
    
    maxHoursWeekForAddEditScreen = 0.0;
    NSDate *tempDate = currentShowingWeek.weekStartDate;
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    for(int i = 0; i < [dateButtonsArray count]; i++)
    {
        UIButton *dateButton = [dateButtonsArray objectAtIndex:i];
        [dateButton setTitle:[dateFormatter stringFromDate:tempDate] forState:UIControlStateNormal];

        float hoursOfTheDate = [[DataSyncHandler defaultHandler] getHoursForSelectedDate:[NSString stringWithFormat:@"%@",tempDate] withBillableFlag:NO];
        float hoursOfTheDateForBillable = [[DataSyncHandler defaultHandler] getHoursForSelectedDate:[NSString stringWithFormat:@"%@",tempDate] withBillableFlag:YES];

        
        maxHoursWeekForAddEditScreen +=hoursOfTheDate;
        
        // Save Calendar Dates and total hours for that date for Chart View and Billable Chart
        [self.calendarDatesHoursArray addObject:[NSString stringWithFormat:@"%.2f",hoursOfTheDate]];
        [self.calendarDatesBillableHoursArray addObject:[NSString stringWithFormat:@"%.2f", hoursOfTheDateForBillable]];
        
        NSDateFormatter * dateFormaterer = [[NSDateFormatter alloc] init];
        [dateFormaterer  setDateFormat:@"MMM dd"];
        NSString * tempDateString = [dateFormaterer stringFromDate:tempDate];
        [self.calendarDatesArray addObject: tempDateString];
        
        NSArray *tempArray = [NSArray arrayWithObject:@"tempObj"];
        
        if([tempArray count] > 0 )
        {
            static float width = 30;
            static float height = 30;
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
            label.center = CGPointMake(CGRectGetMidX(dateButton.frame), height/2);
            [label setText:[NSString stringWithFormat:@"%.2f",hoursOfTheDate]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFont:[UIFont systemFontOfSize:9.0]];
            
            [eventSymbolsView addSubview:label];
            
            if([TLUtilities isSameDayWithDate1:selectedDate date2:tempDate] == NO) {
            }
        }
        components.day = 1;
        tempDate = [gregorianCalendar dateByAddingComponents:components toDate:tempDate options:0];
    }
}

#pragma mark - DataSyncHandler Delegate Methods

-(void) permanentLineAddedSuccessfully
{
    [self fetchTransactionsOfCurrentSelectedDate];
}

-(void) permanentLineNotAddedDueToError
{
    [self fetchTransactionsOfCurrentSelectedDate];
}

-(void) permanentLineDeletedSuccessfully
{
    [self fetchTransactionsOfCurrentSelectedDate];
}

-(void) permanentLineNotDeletedDueToError
{    
    [self fetchTransactionsOfCurrentSelectedDate];
}

-(void) dataRefreshedSuccessfullyAgainstPullToRefresh
{
    [refreshControl endRefreshing];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    [self fetchTransactionsOfCurrentSelectedDate];
    [self updatePendingTransactionsCount];
    [self updateCaledarViewUI];
    [self.mainTableView reloadData];
}

#pragma mark - TLTaskTableViewCell Delegate Methods
-(void) pinButtonTappedOnTaskCell:(TLTasksTableViewCell *)cell
{
    NSIndexPath * indexPath = [self.mainTableView indexPathForCell:cell];
    Transaction * tempObj = [self.dataSourceArray objectAtIndex:indexPath.row];
    
    [DataSyncHandler defaultHandler].delegate = self;
    [DataSyncHandler defaultHandler].isDelegateSetFromLogin = NO;
    [DataSyncHandler defaultHandler]._syncTypes = forPullToRefresh;
    if ([tempObj.transactionID isEqualToString:@""])
    {
        if (!cell.isPinned)
        {
            [[DataSyncHandler defaultHandler] deletePermanentLineFromLocalDBAndServerForLevel2Key:tempObj.level2Key level3Key:tempObj.level3Key taskCode:tempObj.taskCode andStartDate: [NSString stringWithFormat:@"%@", selectedDate]];
        }
    }
    else
    {
        if (cell.isPinned)
        {
            [[DataSyncHandler defaultHandler] addNewPermanentLineWithLevel2Key:tempObj.level2Key level3Key:tempObj.level3Key taskCode:tempObj.taskCode forDate:[NSString stringWithFormat:@"%@", selectedDate]];
        }
        else
        {
            [[DataSyncHandler defaultHandler] deletePermanentLineFromLocalDBAndServerForLevel2Key:tempObj.level2Key level3Key:tempObj.level3Key taskCode:tempObj.taskCode andStartDate: [NSString stringWithFormat:@"%@", selectedDate]];
        }
    }
}

-(void) checkButtonTappedOnTaskCell:(TLTasksTableViewCell *)cell
{
    NSIndexPath * indexPath = [self.mainTableView indexPathForCell:cell];
    Transaction * transactObj = [self.dataSourceArray objectAtIndex:indexPath.row];
    
        if (cell.isChecked)
        {
            [self.checkedTransactionsArray addObject:transactObj];
        }
        else
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"transactionID=%@", transactObj.transactionID];
            NSArray *tempArray = [self.checkedTransactionsArray filteredArrayUsingPredicate:predicate];
            if (tempArray.count>0) {
                Transaction * tempObj = [tempArray lastObject];
                [self.checkedTransactionsArray removeObject:tempObj];
            }
        }    
}


#pragma mark - TLTransactionsTableViewCell Delegate Methods

-(void) pinButtonTappedOnTransactionCell:(TLTransactionsTableViewCell *)cell
{
    NSIndexPath * indexPath = [self.mainTableView indexPathForCell:cell];
    Transaction * tempObj = [self.dataSourceArray objectAtIndex:indexPath.row];
    
    [DataSyncHandler defaultHandler].delegate = self;
    [DataSyncHandler defaultHandler].isDelegateSetFromLogin = NO;
    [DataSyncHandler defaultHandler]._syncTypes = forPullToRefresh;
    
    if ([tempObj.transactionID isEqualToString:@""])
    {
        if (!cell.isPinned)
        {
            [[DataSyncHandler defaultHandler] deletePermanentLineFromLocalDBAndServerForLevel2Key:tempObj.level2Key level3Key:tempObj.level3Key taskCode:tempObj.taskCode andStartDate: [NSString stringWithFormat:@"%@", selectedDate]];
        }
    }
    else
    {
        if (cell.isPinned)
        {
            [[DataSyncHandler defaultHandler] addNewPermanentLineWithLevel2Key:tempObj.level2Key level3Key:tempObj.level3Key taskCode:tempObj.taskCode forDate:[NSString stringWithFormat:@"%@", selectedDate]];
        }
        else
        {
            [[DataSyncHandler defaultHandler] deletePermanentLineFromLocalDBAndServerForLevel2Key:tempObj.level2Key level3Key:tempObj.level3Key taskCode:tempObj.taskCode andStartDate: [NSString stringWithFormat:@"%@", selectedDate]];
        }
    }
}

-(void) checkButtonTappedOnTransactionCell:(TLTransactionsTableViewCell *)cell
{
    NSIndexPath * indexPath = [self.mainTableView indexPathForCell:cell];
    Transaction * transactObj = [self.dataSourceArray objectAtIndex:indexPath.row];
    
    if (cell.isChecked) {
        [self.checkedTransactionsArray addObject:transactObj];
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"transactionID=%@", transactObj.transactionID];
        NSArray *tempArray = [self.checkedTransactionsArray filteredArrayUsingPredicate:predicate];
        if (tempArray.count>0) {
            Transaction * tempObj = [tempArray lastObject];
            [self.checkedTransactionsArray removeObject:tempObj];
        }
    }    
}


#pragma mark - UITableViewDelegate + UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Transaction * tempObj = [self.dataSourceArray objectAtIndex:indexPath.row];
    NSString * sortByString = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_SORT_BY]];
    
    static NSString * cellIdentifier = @"";
    TLTasksTableViewCell *  cell = nil;
    // Set the Frames of Activity and hours Label if sortByString!= 3 or there is no description available.
    
    if ([sortByString isEqualToString:@""] || [sortByString isEqualToString:@"1"]  || [sortByString isEqualToString:@"2"] || [tempObj.level2Description isEqualToString:@""])
    {
       cellIdentifier = @"TLTransactionsTableViewCell";
    }
    else
    {
        cellIdentifier = @"TLTasksTableViewCell";
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

    cell.countLabel.text = [NSString stringWithFormat:@"%i",(int) indexPath.row+1];
    
    if ([sortByString isEqualToString:@""]||[sortByString isEqualToString:@"1"]) // Show Level2 Key
    {
        cell.jobIDLabel.text = tempObj.level2Key;       
    }
    else if([sortByString isEqualToString:@"2"]) // Show Level2 Description
    {
        if ([tempObj.level2Description isEqualToString:@""])
        {
            cell.jobIDLabel.text = tempObj.level2Key;
        }
        else
            cell.jobIDLabel.text = tempObj.level2Description;
    }
    else if([sortByString isEqualToString:@"3"]) // Show Both Level2 Key and Description
    {
        cell.jobIDLabel.text = tempObj.level2Key;
        if (![tempObj.level2Description isEqualToString:@""])
        {
            cell.jobDescLabel.text = tempObj.level2Description;
        }
    }
    
    cell.activityNameLabel.text = tempObj.level3Key;
    cell.hoursLabel.text = [NSString stringWithFormat:@"%.2f hr(s)",tempObj.units];
    
// Pinned Logics
    if (tempObj.isPermanentLine)
    {
        cell.isPinned = YES;
        [cell.pinImageView setImage:[UIImage imageNamed:@"pin.png"]];
        [cell.pinButton setSelected:YES];
    }
    else
    {
        cell.isPinned = NO;
        [cell.pinImageView setImage:[UIImage imageNamed:@"unpin.png"]];
        [cell.pinButton setSelected:NO];
    }
    
// Checked Logic
    if (self.checkedTransactionsArray.count >0)
    {
        BOOL objectPresent = [self.checkedTransactionsArray containsObject:tempObj];
        if (objectPresent) {
            cell.isChecked = YES;
            [cell.checkImageView setImage:[UIImage imageNamed:@"icn_selected"]];
            [cell.checkmarkButton setSelected:YES];
        }
        else
        {
            cell.isChecked = NO;
            [cell.checkImageView setImage:[UIImage imageNamed:@"icn_unselected"]];
            [cell.checkmarkButton setSelected:NO];
        }
    }
    else
    {
        cell.isChecked = NO;
        [cell.checkImageView setImage:[UIImage imageNamed:@"icn_unselected"]];
        [cell.checkmarkButton setSelected:NO];
    }
    
    
    //Change the colors of the Cells based on SubmittedFlag = 1, color rgb(215,228,188)
    // ApporvalFlag = 1 Color = rgb(209,209,220)
    // ApprovalFlag = 2 Color = rgb(255,111,111)
    // If Approval and Submitted both flags are 1 then ApprovalFlag would have preference.
    
    if ([tempObj.transactionID isEqualToString:@""]){ //isPermanentLine && tempObj.units == 0.00) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        if (tempObj.submitFlag == 1)
        {
            cell.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:228.0/255.0 blue:188.0/255.0 alpha:1.0];
        }
        if (tempObj.approvalStatus == 1 || tempObj.approvalStatus == 4)
        {
            cell.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0];
        }
        else if (tempObj.approvalStatus == 2)
        {
            cell.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:111.0/255.0 blue:111.0/255.0 alpha:1.0];
        }
        else if (tempObj.submitFlag == 0 && tempObj.approvalStatus == 0)
        {
            cell.backgroundColor = [UIColor whiteColor];
        }
    }

    
        return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.dataSourceArray count];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!_optionsView.hidden)
    {
        [self showOptionsViewButtonAction:nil];
    }
    
    Transaction * tempObj = [self.dataSourceArray objectAtIndex:indexPath.row];
    TLEditJobViewController *controller = [[TLEditJobViewController alloc] initWithNibName:@"TLEditJobViewController" bundle:nil];
    
    controller._editViewCalled = isFromHomeScreen;
    controller.delegate = self;
    controller.selectedDateString = [NSString stringWithFormat:@"%@", selectedDate];
    [controller setTransactionItem:tempObj];
    controller.maxHoursWeek = maxHoursWeekForAddEditScreen;
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex)
    {
        case 0:
        {
            // Billable Hours
            [self openBillableHours];
        }
            break;
        case 1:
        {
            // Show Pending Tansactions
            [self pendingTransactionsButtonTapped:nil];
            
        }
            break;
        case 2:
        {
            // Show Settings
            [self openSettings];
            
        }
            break;
        case 3:
        {
            // Main Menu
            [self goBackToMainMenu];
        }
            break;
        case 4:
        {
            // Logout User
            [self logoutUser];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -  UIActionsheet Methods

-(void) makeCustomBarButtonForBack:(BOOL) backButton
{
        UIImage *iconImage = [UIImage imageNamed:@"logo.png"];//[UIImage imageNamed:@"Icon-40.png"];
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setFrame:CGRectMake(0, 0, iconImage.size.width, iconImage.size.height)];
        [leftButton setBackgroundImage:iconImage forState:UIControlStateNormal];
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        self.navigationItem.leftBarButtonItem = barButtonItem;
}

-(void)openSettings
{
    TLSettingsViewController *settingsController = [[TLSettingsViewController alloc] initWithNibName:@"TLSettingsViewController" bundle:nil];
    [self.navigationController pushViewController:settingsController animated:YES];
}
-(void)openBillableHours
{
    BOOL shouldShowCharView = NO;
    double numberOfHours = 0.0;
    
    for (NSString * valueString in self.calendarDatesBillableHoursArray)
    {
        numberOfHours += [valueString floatValue];
    }
    if (numberOfHours>0)
    {
        shouldShowCharView = YES;
    }
    
    if (shouldShowCharView)
    {
        TLBillableHoursViewController *controller = [[TLBillableHoursViewController alloc] initWithNibName:@"TLBillableHoursViewController" bundle:nil];
        controller.titlesArray = self.calendarDatesArray;
        controller.valuesArray = self.calendarDatesBillableHoursArray;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:BILLABLE_HOURS_CHECK_TITLE message:BILLABLE_HOURS_CHECK_MESSAGE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void) goBackToMainMenu
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)logoutUser
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CONFIRMATION_REQUIRED_TITLE message:LOG_OUT_MESSAGE delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue to Sign out",nil];
    alert.delegate = self;
    alert.tag = 102;
    [alert show];
}


@end
