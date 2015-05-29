//
//  TLEditJobViewController.m
//  TimeLineApp
//
//  Created by Mac on 12/26/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "TLEditJobViewController.h"
#import "EditClientJobTableViewCell.h"
#import "JobHoursTableViewCell.h"
#import "TaskAndWorkTableViewCell.h"
#import "CommentAreaTableViewCell.h"
#import "TLConstants.h"
#import "TLUtilities.h"
#import "AppDelegate.h"
#import "WebservicesManager.h"
#import "Task.h"
#import "WorkFunction.h"
#import "MBProgressHUD.h"


@interface TLEditJobViewController ()

@end

@implementation TLEditJobViewController
@synthesize transactionItem;
@synthesize delegate;
@synthesize selectedDateString;
@synthesize tasksArray,workFuncArray;
@synthesize tasksItemList, workFuncItemList;
@synthesize  maxHoursWeek;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.transactionItem.submitFlag == 1 || self.transactionItem.approvalStatus == 1)
    {
        self.saveButton.enabled = NO;
        self.saveButton.alpha = 0.25;
        self.deleteButton.enabled = NO;
        self.deleteButton.alpha = 0.25;
        [self.mainTableView setAlpha:0.60];
    }
    self.title = @"Edit Time";
    
    UINib *nibForJobTitleCell = [UINib nibWithNibName:@"EditClientJobTableViewCell" bundle:nil];
    [[self mainTableView] registerNib:nibForJobTitleCell forCellReuseIdentifier:@"EditClientJobTableViewCell"];
    
    UINib *nibForJobTaskAndWorkCell = [UINib nibWithNibName:@"TaskAndWorkTableViewCell" bundle:nil];
    [[self mainTableView] registerNib:nibForJobTaskAndWorkCell forCellReuseIdentifier:@"TaskAndWorkTableViewCell"];
    
    UINib *nibForJobHoursCell = [UINib nibWithNibName:@"JobHoursTableViewCell" bundle:nil];
    [[self mainTableView] registerNib:nibForJobHoursCell forCellReuseIdentifier:@"JobHoursTableViewCell"];
    
    UINib *nibForJobCommentsAreaCell = [UINib nibWithNibName:@"CommentAreaTableViewCell" bundle:nil];
    [[self mainTableView] registerNib:nibForJobCommentsAreaCell forCellReuseIdentifier:@"CommentAreaTableViewCell"];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
    [self fetchAllTasksForSelectedJobFromDB];
    [self fetchAllWorkFunctionsFromDB];
    
    showTask = [[NSUserDefaults standardUserDefaults] integerForKey:UDKEY_SHOW_TASKS];
    showWorkFunc = [[NSUserDefaults standardUserDefaults] integerForKey:UDKEY_SHOW_RES_USAGE];
    [self makeCustomBackButtonWithLogo];
    
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mainTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) makeCustomBackButtonWithLogo
{
    UIImage *iconImage = [UIImage imageNamed:@"back_logo.png"];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, iconImage.size.width, iconImage.size.height)];
    [leftButton setBackgroundImage:iconImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
}



-(void)backButtonTapped
{

    if (self.transactionItem.submitFlag == 1 || self.transactionItem.approvalStatus == 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        // making Task Cell
        IQDropDownTextField * taskTextField = [self getTextFromTaskFieldInTableView];
        
        // making WorkFunc Cell
        IQDropDownTextField * workFuncTextField = [self getTextFromWorkFunctionFieldInTableView];
        
        // making makingHours Cell
        UITextField * hoursTextField = [self getTextFromHoursFieldInTableView];
        
        
        // making Comments Cell
        UITextView * commentsView = [self getTextFromCommentsFieldInTableView];
        
        NSString * taskCodeString = @"";
        if (![taskTextField.text isEqualToString:@""])
        {
            taskCodeString = [self fetchTaskCodeFromTaskDescription:taskTextField.text];
        }
        
        NSString * workFunctionString = @"";
        if (![workFuncTextField.text isEqualToString:@""])
        {
           workFunctionString = [self fetchWorkFuncCodeFromWorkFuncDescription: workFuncTextField.text];
        }
        
        NSString * hoursString = hoursTextField.text;
        NSString * commentsString = [commentsView.text isEqualToString:@"Comments here..."]?@"":commentsView.text;
        
        
        
        if (showTask == 3)
        {
            if (showWorkFunc == 2)
            {
                if ([taskCodeString isEqualToString:self.transactionItem.taskCode]&& [hoursString floatValue] == self.transactionItem.units && [workFunctionString isEqualToString:self.transactionItem.resUsageCode] && [commentsString isEqualToString:self.transactionItem.comments]) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CONFIRMATION_REQUIRED_TITLE message:EDIT_SCREEN_UNSAVED_CHANGES_MESSAGE delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                    alert.delegate = self;
                    alert.tag = 1117;
                    [alert show];
                }
            }
            else
            {
                if ([taskCodeString isEqualToString:self.transactionItem.taskCode]&& [hoursString floatValue] == self.transactionItem.units && [commentsString isEqualToString:self.transactionItem.comments])
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CONFIRMATION_REQUIRED_TITLE message:EDIT_SCREEN_UNSAVED_CHANGES_MESSAGE delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                    alert.delegate = self;
                    alert.tag = 1117;
                    [alert show];
                }
            }
        }
        else
        {
            if (showWorkFunc == 2)
            {
                if ([hoursString floatValue] == self.transactionItem.units && [workFunctionString isEqualToString:self.transactionItem.resUsageCode] && [commentsString isEqualToString:self.transactionItem.comments])
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CONFIRMATION_REQUIRED_TITLE message:EDIT_SCREEN_UNSAVED_CHANGES_MESSAGE delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                    alert.delegate = self;
                    alert.tag = 1117;
                    [alert show];
                }
            }
            else
            {
                if ([hoursString floatValue] == self.transactionItem.units && [commentsString isEqualToString:self.transactionItem.comments])
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CONFIRMATION_REQUIRED_TITLE message:EDIT_SCREEN_UNSAVED_CHANGES_MESSAGE delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                    alert.delegate = self;
                    alert.tag = 1117;
                    [alert show];
                }
            }

        }
    }
}

#pragma mark - LocalDB interacting Methods.

-(NSString *) fetchWorkFuncDescriptionFromLocalDBForCode:(NSString *) resUsageCode
{
    NSString * workFuncDescString = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT res_usage_description FROM pdm_res_usage WHERE res_usage_code = '%@';",resUsageCode];
    NSArray * tempArray =[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:query];
    workFuncDescString = [[tempArray lastObject] lastObject];
    return workFuncDescString;
}
-(NSString *) fetchTitleOfField:(NSString *) fieldName
{
    NSString *query = [NSString stringWithFormat:@"SELECT display_name FROM pdm_sys_names WHERE field_name = '%@';",fieldName];
    NSString * titleString = [[[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:query] lastObject] lastObject];
    return titleString;
}

-(NSString *) fetchActivityDescForSelectedLevel3Key:(NSString *)level3KeyString
{
    NSString * query = [NSString stringWithFormat:@"SELECT level3_description FROM pdd_level3 WHERE company_code = %i AND level2_key = '%@' AND level3_key = '%@' ;",
                        [[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE] intValue],
                        self.transactionItem.level2Key,
                        level3KeyString];
    NSString * descString = [[[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:query] lastObject] lastObject];
    return descString;
}

-(void) fetchAllTasksForSelectedJobFromDB
{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM pdd_task WHERE task_type in (select distinct task_type from pdd_level3 where level3_key = '%@' AND level2_key = '%@');",self.transactionItem.level3Key, self.transactionItem.level2Key];
        
        NSArray * taskTempArray =[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:query];
        
        if (taskTempArray.count >0)
        {
            self.tasksArray = [[NSMutableArray alloc] init];
            self.tasksItemList = [[NSMutableArray alloc] init];
            for (NSArray * tempArray in taskTempArray)
            {
                int       taskType  = [[tempArray objectAtIndex:1] intValue];
                NSString * taskCode = [tempArray objectAtIndex:2];
                NSString * taskDesc = [tempArray objectAtIndex:3];
                 NSString * taskDescString = [TLUtilities formatRequest:taskDesc];
                
                Task * task = [[Task alloc] initWithTaskCode:taskCode ofType:taskType withTaskDescription:taskDescString andTaskTypeDescription:taskDescString];
                [self.tasksArray addObject:task];
                [self.tasksItemList addObject:taskDescString];
            }
        }
}

-(void) fetchAllWorkFunctionsFromDB
{
    NSString * query = @"SELECT * FROM pdm_res_usage";
    NSArray * workFuncTempArray =[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:query];
    
    if (workFuncTempArray.count >0)
    {
        self.workFuncArray = [[NSMutableArray alloc] init];
        self.workFuncItemList  = [[NSMutableArray alloc] init];
        for (NSArray * tempArray in workFuncTempArray)
        {
            NSString * workFuncCode = [tempArray objectAtIndex:1];
            NSString * workFuncDesc = [tempArray objectAtIndex:2];
            NSString * workFuncDescString = [TLUtilities formatRequest:workFuncDesc];
            
            WorkFunction * workFuncObj = [[WorkFunction alloc] initWithResUsageCode:workFuncCode andResUsageDescription:workFuncDescString];
            [self.workFuncArray addObject:workFuncObj];
            [self.workFuncItemList addObject:workFuncDescString];
        }
    }
}

-(void) addNewTransactionFromPurePermanentLineWithLevel2Key:(NSString *)level2KeyString level3Key:(NSString *)level3KeyString taskCode:(NSString *)taskCodeString workFunction:(NSString *) workFuncString hours:(float) hours comments:(NSString *) commentString
{
    NSString * transactionID = [NSString stringWithFormat:@"%@", [TLUtilities generateTransactionIDusingCounter:0]];
    NSString * currentDateString = [TLUtilities ConvertDate:[NSString stringWithFormat:@"%@",[NSDate date]] FromFormat:@"yyyy-MM-dd HH:mm:ss z" toFormat:@"yyyy-MM-dd"];
    NSString * commentsString = ([commentString isEqualToString:@"Comments here..."])?@"":commentString;
    
    NSString * orgUnitString = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_ORG_UNIT_CODE];
    NSString * locationCodeString = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_LOCATION_CODE];
    NSString * resourceIDString = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_RESOURCE_ID];
    NSString * appliedDateString = [TLUtilities ConvertDate:self.selectedDateString FromFormat:@"yyyy-MM-dd HH:mm:ss z" toFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * modifiedDateString = [NSString stringWithFormat:@"%@",[NSDate date]];
    NSString * timeStampString = @"";
    int errorFlag = 0;
    int errorCode = 0;
    NSString * errorDescriptionString = @"";
    
    
    Transaction * tempObj = [[Transaction alloc] initTransactionWithID:transactionID transactionType:1001 ofJob:level2KeyString activity:level3KeyString taskCode:taskCodeString orgUnit:orgUnitString comments:commentsString resource:resourceIDString resUsageCode:workFuncString appliedOn:appliedDateString modifiedOn:modifiedDateString submittedOn:currentDateString withApprovalFlags:0 submitFlag:0 nonBillableFlag:0 andSyncedFlag:0 Units:hours andLocationCode:locationCodeString];
    
    tempObj.timeStamp = timeStampString;
    tempObj.errorFlag = errorFlag;
    tempObj.errorCode = errorCode;
    tempObj.errorDescription = errorDescriptionString;
    
    if ([TLUtilities verifyInternetAvailability])
    {
        [DataSyncHandler defaultHandler].isSyncingTransaction = NO;
        [[DataSyncHandler defaultHandler] addTransactionOnServer:tempObj completionHandler:^(BOOL success, NSString *errMsg) {
            
            if (success)
            {
                // No need to add transaction in LocalDB from here now, because it would automatically be inserted into the LocalDB in "addTransactionOnServer" Method in DataSyncHandler class.
                [self popViewControllerAndNotifyHomeVC];
             }
             else
             {
                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                 UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:errMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 [alert show];
             }
            [DataSyncHandler defaultHandler].isSyncingTransaction = YES;
        }];
    }
    else
    {
        appliedDateString = [TLUtilities ConvertDate:self.selectedDateString FromFormat:@"yyyy-MM-dd HH:mm:ss z" toFormat:@"yyyy-MM-dd"];
        
        // Validate the Transaction for Duplication.
       BOOL isTransactionDuplicate =  [self validateDuplicateTransactions:tempObj];
        if (!isTransactionDuplicate)
        {
            // Save the transaction in LocalDB with sync_status = 0 for later syncing;
            NSString * query = [NSString stringWithFormat:@"INSERT INTO pld_transaction VALUES(%i,'%@','%@','%@','%@',%i,'%@','%@',%.2f,'%@','%@','%@','%@',%i,%i,'%@',%i,%i,%i,'%@','%@',%i,%i,'%@');",[[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE] intValue],
                                transactionID,
                                level2KeyString,
                                level3KeyString,
                                appliedDateString,
                                1001,
                                resourceIDString,
                                workFuncString,
                                hours,
                                locationCodeString,
                                orgUnitString,
                                taskCodeString,
                                commentsString,
                                0,
                                0,
                                currentDateString,
                                0,
                                0,
                                0,
                                modifiedDateString,
                                timeStampString,
                                errorFlag,
                                errorCode,
                                errorDescriptionString];
            
            [[DataSyncHandler defaultHandler] executeQuery:query];
            [self popViewControllerAndNotifyHomeVC];
        }
        else
        {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            NSString * level2SysName = [self fetchTitleOfField:TIME_BASED_LEVEL2_DESCRIPTION];
            NSString * level3SysName = [self fetchTitleOfField:TIME_BASED_LEVEL3_DESCRIPTION];
            
            NSString * appliedDateStringForError = [TLUtilities ConvertDate:self.selectedDateString FromFormat:@"yyyy-MM-dd HH:mm:ss z" toFormat:@"MM/dd/yyyy"];
            
            NSString * messageString = [NSString stringWithFormat:@"Duplicate Transaction already exists for:\n  %@: %@ \n %@:%@ \n Units: %.2f \n Date:%@", level2SysName,tempObj.level2Key, level3SysName, tempObj.level3Key, tempObj.units,appliedDateStringForError];
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:messageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}


-(void) UpdateTransactionWithUnit:(float) units taskCode:(NSString *)taskCodeString comments:(NSString *) commentString resUsage:(NSString *) resUsageString andTransactionID:(NSString *) transactID
{
    /*
     pld_transaction(company_code INTEGER NOT NULL,transaction_id TEXT NOT NULL,level2_key  TEXT NOT NULL,level3_key TEXT NOT NULL, applied_date DATE NOT NULL,trx_type INTEGER NOT NULL,resource_id TEXT NOT NULL,res_usage_code TEXT,unit REAL,location_code TEXT,org_unit  TEXT,task_code TEXT, comments TEXT,nonbillable_flag INTEGER,submitted_flag  INTEGER,submitted_date DATE, approval_flag INTEGER,sync_status INTEGER,deleted  INTEGER,modified_datetime DATE,timestamp TEXT, error_flag INTEGER,error_code INTEGER, error_description TEXT, PRIMARY KEY(company_code, transaction_id))
     */

    commentString = ([commentString isEqualToString:@"Comments here..."])?@"":commentString;
    
    NSDate* currentDate = [NSDate date];
    NSString * modifiedDateString = [NSString stringWithFormat:@"%@",currentDate];
    
    Transaction * tempObj = [self.transactionItem copy];
    tempObj.units = units;
    tempObj.taskCode = taskCodeString;
    tempObj.comments = commentString;
    tempObj.resUsageCode = resUsageString;
    tempObj.modifyDate = modifiedDateString;
    tempObj.approvalStatus = 0;
    tempObj.appliedDate = [TLUtilities ConvertDate:tempObj.appliedDate FromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM-dd HH:mm:ss"];
//    tempObj.comments = ([tempObj.comments isEqualToString:@"Comments here..."])?@"":tempObj.comments;
    
    EditClientJobTableViewCell *jobcell =  (EditClientJobTableViewCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if ([TLUtilities verifyInternetAvailability])
    {
        [DataSyncHandler defaultHandler].isSyncingTransaction = NO;
        [[DataSyncHandler defaultHandler] updateTransactionOnServer:tempObj completionHandler:^(BOOL success, NSString *errMsg)
         {
            if (success)
            {
                NSLog(@"Transaction Updated Successfully On Server from Edit Screen.");
            
                // No need to update transaction in LocalDB from here now, because it would automatically be updated into the LocalDB in "updateTransactionOnServer" Method in DataSyncHandler class.
                if (self._editViewCalled == isFromHomeScreen)
                {
                    if (self.transactionItem.isPermanentLine)
                    {
                        if (!jobcell.isPinned)
                        {
                            [[DataSyncHandler defaultHandler] deletePermanentLineFromLocalDBAndServerForLevel2Key:self.transactionItem.level2Key level3Key:self.transactionItem.level3Key taskCode:self.transactionItem.taskCode andStartDate:self.selectedDateString];
                        }
                        else
                        {
                            [[DataSyncHandler defaultHandler] addNewPermanentLineWithLevel2Key:self.transactionItem.level2Key level3Key:self.transactionItem.level3Key taskCode:taskCodeString forDate:self.selectedDateString];
                        }
                    }
                    else
                    {
                        if (jobcell.isPinned)
                        {
                            [[DataSyncHandler defaultHandler] addNewPermanentLineWithLevel2Key:self.transactionItem.level2Key level3Key:self.transactionItem.level3Key taskCode:taskCodeString forDate:self.selectedDateString];
                        }
                        else
                        {
                            [self popViewControllerAndNotifyHomeVC];
                        }
                    }
                    
                }
                else if (self._editViewCalled == isFromPendingScreen)
                {
                    [self popViewControllerAndNotifyHomeVC];
                }
            }
            else
            {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:errMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 [alert show];
            }
             [DataSyncHandler defaultHandler].isSyncingTransaction = YES;
        }];
    }
    else
    {
        BOOL isTransactionDuplicate =  [self validateDuplicateTransactions:tempObj];
        if (!isTransactionDuplicate)
        {
        
            NSString *   query = [NSString stringWithFormat:@"UPDATE pld_transaction SET unit= %.2f,task_code='%@',comments='%@', modified_datetime= '%@', res_usage_code = '%@',submitted_flag = %i, approval_flag = 0, sync_status = 0, timestamp = '%@',error_flag = %i, error_code = %i, error_description = '%@' WHERE  transaction_id = '%@';",
                                  units,
                                  taskCodeString,
                                  commentString,
                                  modifiedDateString,
                                  resUsageString,
                                  0,
                                  tempObj.timeStamp,
                                  tempObj.errorFlag,
                                  tempObj.errorCode,
                                  tempObj.errorDescription,
                                  transactID];
            
            [[DataSyncHandler defaultHandler] executeQuery:query];
            
            if (self._editViewCalled == isFromHomeScreen)
            {
                if (self.transactionItem.isPermanentLine)
                {
                    if (!jobcell.isPinned)
                    {
                        [[DataSyncHandler defaultHandler] deletePermanentLineFromLocalDBAndServerForLevel2Key:self.transactionItem.level2Key level3Key:self.transactionItem.level3Key taskCode:self.transactionItem.taskCode andStartDate:self.selectedDateString];
                    }
                    else
                    {
                        [[DataSyncHandler defaultHandler] addNewPermanentLineWithLevel2Key:self.transactionItem.level2Key level3Key:self.transactionItem.level3Key taskCode:taskCodeString forDate:self.selectedDateString];
                    }
                }
                else
                {
                    if (jobcell.isPinned)
                    {
                        [[DataSyncHandler defaultHandler] addNewPermanentLineWithLevel2Key:self.transactionItem.level2Key level3Key:self.transactionItem.level3Key taskCode:taskCodeString forDate:self.selectedDateString];
                    }
                    else
                    {
                        [self popViewControllerAndNotifyHomeVC];
                    }
                }
            }
            else if (self._editViewCalled == isFromPendingScreen)
            {
                [self popViewControllerAndNotifyHomeVC];
            }
        }
        else
        {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            NSString * level2SysName = [self fetchTitleOfField:TIME_BASED_LEVEL2_DESCRIPTION];
            NSString * level3SysName = [self fetchTitleOfField:TIME_BASED_LEVEL3_DESCRIPTION];
            
             NSString * appliedDateStringForError = [TLUtilities ConvertDate:self.selectedDateString FromFormat:@"yyyy-MM-dd HH:mm:ss z" toFormat:@"MM/dd/yyyy"];
            
            NSString * messageString = [NSString stringWithFormat:@"Duplicate Transaction already exists for:\n  %@: %@ \n %@:%@ \n Units: %.2f \n Date:%@", level2SysName,tempObj.level2Key, level3SysName, tempObj.level3Key, tempObj.units, appliedDateStringForError];
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:messageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    
}

#pragma mark - DataSyncHandler Delegate Methods

-(void) permanentLineAddedSuccessfully
{
    NSLog(@"Permanent Line Added Successfully from Edit Screen");
    [self popViewControllerAndNotifyHomeVC];
}

-(void) permanentLineNotAddedDueToError
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Permanent Line NOT Added Successfully from Edit Screen");
}

-(void) permanentLineDeletedSuccessfully
{
     NSLog(@"Permanent Line Deleted Successfully from Edit Screen");
    [self popViewControllerAndNotifyHomeVC];
}

-(void) permanentLineNotDeletedDueToError
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Permanent Line NOT Deleted Successfully from Edit Screen");
}

#pragma mark - IBAction Methods

-(IBAction) deleteButtonAction:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CONFIRMATION_REQUIRED_TITLE message:SURE_TO_DELETE delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alert.delegate = self;
    alert.tag = 117;
    [alert show];
}


-(IBAction) saveButtonAction:(id)sender
{
    
// making Task Cell
    IQDropDownTextField * taskTextField = [self getTextFromTaskFieldInTableView];
    
    
// making makingHours Cell
    UITextField * hoursTextField = [self getTextFromHoursFieldInTableView];
    
    
    if (showTask == 3)
    {
        // Job, Activity, Task and Hours are Mandatory Fields.
        if (taskTextField.text.length >0 && (hoursTextField.text.length >0 && [hoursTextField.text floatValue]!=0))
        {
            float hoursEntered = [hoursTextField.text floatValue];
            BOOL maxHoursCheck = [self verifyHoursWithMaxLimits:hoursEntered];
            if (maxHoursCheck)
            {
                [self validateTheLevel2AndLevel3OfTransaction];
            }
        }
        else
        {
            // Task is Compulsory and there are some Missing Required Fields.
            [self checkRequiredFieldsAndShowAlertsIncludingTaskField:YES];
        }
    }
    else
    {
        // Job, Activity and Hours are Mandatory Fields.
        if (hoursTextField.text.length >0 && [hoursTextField.text floatValue]!=0)
        {
            float hoursEntered = [hoursTextField.text floatValue];
            BOOL maxHoursCheck = [self verifyHoursWithMaxLimits:hoursEntered];
            if (maxHoursCheck)
            {
                [self validateTheLevel2AndLevel3OfTransaction];
            }
        }
        else
        {
            // Task is not Compulsory and there are some Missing Required Fields.
            [self checkRequiredFieldsAndShowAlertsIncludingTaskField:NO];
        }
    }
}

-(BOOL) validateDuplicateTransactions:(Transaction *) transactItem
{
    BOOL isDuplicate = NO;
    
    NSString * query = @"";
    NSString * appliedDate = [TLUtilities ConvertDate:transactItem.appliedDate FromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"];
    
    if (showTask == 3)
    {
        query = [NSString stringWithFormat:@"SELECT * FROM pld_transaction WHERE unit = %.2f AND level2_key = '%@' AND level3_key = '%@' AND task_code = '%@' AND comments = '%@' AND applied_date = '%@' AND transaction_id != '%@'AND deleted = 0",
                 transactItem.units,
                 transactItem.level2Key,
                 transactItem.level3Key,
                 transactItem.taskCode,
                 transactionItem.comments,
                 appliedDate,
                 transactItem.transactionID];
    }
    else
    {
        query = [NSString stringWithFormat:@"SELECT * FROM pld_transaction WHERE unit = %.2f AND level2_key = '%@' AND level3_key = '%@' AND comments = '%@' AND applied_date = '%@' AND transaction_id != '%@'",
                 transactItem.units,
                 transactItem.level2Key,
                 transactItem.level3Key,
                 transactionItem.comments,
                 appliedDate,
                 transactItem.transactionID];
    }
    
    NSArray * array = [[DataSyncHandler defaultHandler].dbManager loadDataFromDB:query];
    if (array.count >0) {
        isDuplicate = YES;
    }
    else
    {
        isDuplicate = NO;
    }

    return isDuplicate;
}

-(void) validateTheLevel2AndLevel3OfTransaction
{
    /*
     
     - the level2_status of Level2 should be 1
     - the labor_flag of Level3 should be 1
     - applied date should not be earlier than the open_date of the Level2/Level3
     - if closed_date of Level2/Level3 is not null then applied date of the transaction should not be later than the closed_date of Level2/Level3
     
     */
    
    BOOL showErrorAlert = NO;
    
    NSString * queryForLevel2 = [NSString stringWithFormat:@"SELECT * FROM pdd_level2 WHERE level2_key = '%@'", self.transactionItem.level2Key];
    NSArray * level2Array = [[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:queryForLevel2] lastObject];
    NSString * level2Status = [level2Array objectAtIndex:3];
    NSString * level2CloseDate = [level2Array objectAtIndex:4];
    NSString * level2OpenDate = [level2Array objectAtIndex:5];
    
    
    NSString * errorDescString = @"Cannot save the transaction for this";
    
    NSString * convertedLevel2OpenDate = [TLUtilities ConvertDate:level2OpenDate FromFormat:@"yyyy-MM-dd" toFormat:@"MM/dd/yyyy"];
    NSString * convertedLevel2ClosedDate = [TLUtilities ConvertDate:level2CloseDate FromFormat:@"yyyy-MM-dd" toFormat:@"MM/dd/yyyy"];
    
    NSString * level2SysName = [self fetchTitleOfField:TIME_BASED_LEVEL2_DESCRIPTION];
    NSString * level3SysName = [self fetchTitleOfField:TIME_BASED_LEVEL3_DESCRIPTION];
    
    
    if (level2Status.intValue != 1)
    {
        NSString * tempString = [NSString stringWithFormat:@" %@:%@ is not open", level2SysName,self.transactionItem.level2Key];
        errorDescString = [errorDescString stringByAppendingString:tempString];

        showErrorAlert = YES;
    }
    else if ([self.transactionItem.appliedDate compare:level2OpenDate] == NSOrderedAscending)
    {
        NSLog(@"Applied Date is Earlier than Level2 Open Date");
        
        NSString * tempString = [NSString stringWithFormat:@" %@:%@ is not valid earlier than %@", level2SysName,self.transactionItem.level2Key, convertedLevel2OpenDate];
        errorDescString = [errorDescString stringByAppendingString:tempString];
        
        showErrorAlert = YES;
    }
    else if (!level2CloseDate || ![level2CloseDate isEqualToString:@""])
    {
        if ([self.transactionItem.appliedDate compare:level2CloseDate] == NSOrderedDescending) {
            NSLog(@"Applied Date is  Later than Level2 Closed Date");
            
            NSString * tempString = [NSString stringWithFormat:@" %@:%@ is not valid later than %@", level2SysName,self.transactionItem.level2Key, convertedLevel2ClosedDate];
            errorDescString = [errorDescString stringByAppendingString:tempString];
            
            showErrorAlert = YES;
        }
    }
    
    
    if (showErrorAlert)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:errorDescString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        NSString * queryForLevel3 = [NSString stringWithFormat:@"SELECT * FROM pdd_level3 WHERE level3_key = '%@' AND level2_key = '%@'", self.transactionItem.level3Key, self.transactionItem.level2Key];
        NSArray * level3Array = [[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:queryForLevel3] lastObject];
        NSString * level3Labor = [level3Array objectAtIndex:6];
        NSString * level3CloseDate = [level3Array objectAtIndex:7];
        NSString * level3OpenDate = [level3Array objectAtIndex:8];
        
        NSString * convertedLevel3OpenDate = [TLUtilities ConvertDate:level3OpenDate FromFormat:@"yyyy-MM-dd" toFormat:@"MM/dd/yyyy"];
        NSString * convertedLevel3ClosedDate = [TLUtilities ConvertDate:level3CloseDate FromFormat:@"yyyy-MM-dd" toFormat:@"MM/dd/yyyy"];
        
        if (level3Labor.intValue!=1)
        {
            NSString * tempString = [NSString stringWithFormat:@" %@:%@  %@:%@ is not valid for the Time Entry", level2SysName,self.transactionItem.level2Key, level3SysName, self.transactionItem.level3Key];
            errorDescString = [errorDescString stringByAppendingString:tempString];
            
            showErrorAlert = YES;
        }
        else if ([self.transactionItem.appliedDate compare:level3OpenDate] == NSOrderedAscending)
        {
            NSLog(@"Applied Date is Earlier than Level3 Open Date");
            
            NSString * tempString = [NSString stringWithFormat:@" %@:%@  %@:%@ is not valid earlier than %@", level2SysName,self.transactionItem.level2Key, level3SysName, self.transactionItem.level3Key, convertedLevel3OpenDate];
            errorDescString = [errorDescString stringByAppendingString:tempString];
            
            showErrorAlert = YES;
        }
        else if (!level3CloseDate || ![level3CloseDate isEqualToString:@""])
        {
            if ([self.transactionItem.appliedDate compare:level3CloseDate] == NSOrderedDescending) {
                NSLog(@"Applied Date is  Later than Level3 Closed Date");
                
                NSString * tempString = [NSString stringWithFormat:@" %@:%@  %@:%@ is not valid later than %@", level2SysName,self.transactionItem.level2Key, level3SysName, self.transactionItem.level3Key, convertedLevel3ClosedDate];
                errorDescString = [errorDescString stringByAppendingString:tempString];
                
                showErrorAlert = YES;
            }
        }
        
        if (showErrorAlert)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:errorDescString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        else
        {
            [self saveTransactionOnServer];
        }
    }
    
}

-(void) saveTransactionOnServer
{
    
//    EditClientJobTableViewCell *jobcell =  (EditClientJobTableViewCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
// making Task Cell
    IQDropDownTextField * taskTextField = [self getTextFromTaskFieldInTableView];
   
    
// making WorkFunc Cell
    IQDropDownTextField * workFuncTextField = [self getTextFromWorkFunctionFieldInTableView];
    
// making makingHours Cell
    UITextField * hoursTextField = [self getTextFromHoursFieldInTableView];

    
// making Comments Cell
    UITextView * commentsView = [self getTextFromCommentsFieldInTableView];
    
    
    // Fetch TaskCode
    NSString * taskCodeString = [self fetchTaskCodeFromTaskDescription:taskTextField.text];
    
    // Fetch WorkFunction Code
    NSString * workFuncCodeString = [self fetchWorkFuncCodeFromWorkFuncDescription:workFuncTextField.text];
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = WEBSERVICE_UPDATING_TRANSACTION_STATUS;

    [DataSyncHandler defaultHandler].delegate = self;
    [DataSyncHandler defaultHandler].isDelegateSetFromLogin = NO;
    
    if (self.transactionItem.isPermanentLine)
    {
        // Its a Permanent Line and Pin was already RED at the begining and It will remain Pinned since we dont show UnPin option here to user.
        if ([self.transactionItem.transactionID isEqualToString:@""]) // pure Permanent Line and Still Pinned RED
        {
            // Add a New Transaction with a New Generated Transaction ID.
            // Pop the Edit View Controller.
            [self addNewTransactionFromPurePermanentLineWithLevel2Key:self.transactionItem.level2Key level3Key:self.transactionItem.level3Key taskCode:taskCodeString workFunction:workFuncCodeString hours:[hoursTextField.text floatValue] comments:commentsView.text];
        }
        else
        {
            // Its a real Transaction with Transaction ID, some hours.
            
            [self UpdateTransactionWithUnit:[hoursTextField.text floatValue] taskCode:taskCodeString comments:commentsView.text resUsage:workFuncCodeString andTransactionID:self.transactionItem.transactionID];
        }
    }
    else
    {
        // Its a normal Transaction with some hours and a TRANSACTION ID and NOT a permanent line.
        // Update the Transaction Table.
        // Add to the Permanent Lines Table.
        
        [self UpdateTransactionWithUnit:[hoursTextField.text floatValue] taskCode:taskCodeString comments:commentsView.text resUsage:workFuncCodeString andTransactionID:self.transactionItem.transactionID];
    }
}

-(void) popViewControllerAndNotifyHomeVC
{
    // Inform the delegate that the Adding Job was finished.
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.delegate editingJobInfoWasFinished];
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL) verifyHoursWithMaxLimits:(float) hoursEntered
{
    BOOL allowToSave = NO;
    
    float maxDayHoursLimit = [[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_MAX_HOURS_DAY] floatValue];
    float  maxWeekHoursLimit = [[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_MAX_HOURS_WEEK] floatValue];
    
    
    NSLog(@"%@", self.selectedDateString);
    float hoursOfTheDate = [[DataSyncHandler defaultHandler] getHoursForSelectedDate:self.selectedDateString withBillableFlag:NO];
    float previousHoursOfTransaction = self.transactionItem.units ;
    
    float totalCombinedDayHours = hoursEntered + hoursOfTheDate - previousHoursOfTransaction;
    if (totalCombinedDayHours <= maxDayHoursLimit)
    {
        float totalCombinedWeekHours = hoursEntered + maxHoursWeek - previousHoursOfTransaction;
        if (totalCombinedWeekHours <= maxWeekHoursLimit)
        {
            allowToSave = YES;
        }
        else
        {
            NSString * alertMessageString = [NSString stringWithFormat:@"You are exceeding max hour(s) Week limit of %.2f",maxWeekHoursLimit];
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:alertMessageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }
    else
    {
        NSString * alertMessageString = [NSString stringWithFormat:@"You are exceeding max hour(s) Day limit of %.2f",maxDayHoursLimit];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:alertMessageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    return allowToSave;
}

-(void) checkRequiredFieldsAndShowAlertsIncludingTaskField:(BOOL) taskFlag
{
// making Task Cell
    IQDropDownTextField * taskTextField = [self getTextFromTaskFieldInTableView];

// making makingHours Cell
    UITextField * hoursTextField = [self getTextFromHoursFieldInTableView];
    
    NSString * alertMessageString = @"";
    if (!taskTextField.text.length >0)
    {
        if (taskFlag)
        {
            alertMessageString = [NSString stringWithFormat:@"Please select Task"];
        }
        else
        {
            // Case when task is not Mandatory.
            if (!hoursTextField.text.length >0 || [hoursTextField.text floatValue] == 0)
            {
                alertMessageString = [NSString stringWithFormat:@"Please enter valid hours"];
            }
        }
    }
    else if (!hoursTextField.text.length >0 || [hoursTextField.text floatValue] == 0)
    {
        alertMessageString = [NSString stringWithFormat:@"Please enter valid hours"];
    }
    
    if (![alertMessageString isEqualToString:@""])
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:alertMessageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
        if (!taskTextField.text.length >0)
        {
            [taskTextField becomeFirstResponder];
        }
        else if (!hoursTextField.text.length >0 || [hoursTextField.text floatValue] == 0)
        {
            [hoursTextField becomeFirstResponder];
        }
    }

}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification;
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *keyboardBoundsValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyboardHeight = [keyboardBoundsValue CGRectValue].size.height;
    
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    UIEdgeInsets insets = [[self mainTableView] contentInset];
    [UIView animateWithDuration:duration delay:0. options:animationCurve animations:^{
        [[self mainTableView] setContentInset:UIEdgeInsetsMake(insets.top, insets.left, keyboardHeight, insets.right)];
        [[self view] layoutIfNeeded];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification;
{
    NSDictionary *userInfo = [notification userInfo];
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    UIEdgeInsets insets = [[self mainTableView] contentInset];
    [UIView animateWithDuration:duration delay:0. options:animationCurve animations:^{
        [[self mainTableView] setContentInset:UIEdgeInsetsMake(insets.top, insets.left, 0., insets.right)];
        [[self view] layoutIfNeeded];
    } completion:nil];
}

-(void)doneClicked:(UIBarButtonItem*)button
{
    [self.view endEditing:YES];
}

-(void) dismissKeyboardOfTextView
{
    [self.view endEditing:YES];
}


#pragma mark - UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 117)
    {
        if(buttonIndex == 1)
        {
            self.transactionItem.appliedDate = [TLUtilities ConvertDate:self.transactionItem.appliedDate FromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM-dd HH:mm:ss"];
                        
            MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = DELETE_MESSAGE;
            
            if ([TLUtilities verifyInternetAvailability])
            {
                [[DataSyncHandler defaultHandler] deleteTransactionOnServer:self.transactionItem completionHandler:^(BOOL success, NSString *errMsg) {
                    
                    if (success)
                    {
                        // No need to delete transaction in LocalDB from here now, because it would automatically be deleted into the LocalDB in "deleteTransactionOnServer" Method in DataSyncHandler class.
                        
                    }
                    else
                    {
                        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:errMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
                    }
                    [self popViewControllerAndNotifyHomeVC];
                    
                }];
            }
            else
            {
                // Update Transaction To Be Delete When Synced
            
                NSString * UpdateQueryToBeDeleteWhenSynced = [NSString stringWithFormat:@"UPDATE pld_transaction SET sync_status = 0, deleted = 1 WHERE  transaction_id = '%@';",self.transactionItem.transactionID];

                
                [[DataSyncHandler defaultHandler] executeQuery:UpdateQueryToBeDeleteWhenSynced];
                [self popViewControllerAndNotifyHomeVC];
            }
        }
    }
    
    else if (alertView.tag == 1117)
    {
        if(buttonIndex == 1)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
#pragma mark - Text From Cell's Fields

-(NSString *) fetchTaskCodeFromTaskDescription :(NSString *) taskDesc
{
    NSString * taskCodeString = @"";
    if (taskDesc.length >0)
    {
        int indexOfTaskDesc = (int)[self.tasksItemList indexOfObject:taskDesc];
        if (indexOfTaskDesc!=-1) {
            Task * taskObj = [self.tasksArray objectAtIndex:indexOfTaskDesc];
            taskCodeString = taskObj.taskCode;
        }
    }
    else if (![self.transactionItem.taskCode isEqualToString:@""]) // As per Ticket 10034 if Task is Read-Only then show the task that was already set from eSM.
    {
        taskCodeString = self.transactionItem.taskCode;
    }
    return taskCodeString;
}
-(IQDropDownTextField *) getTextFromTaskFieldInTableView
{
    
    TaskAndWorkTableViewCell * taskCell = nil;
    IQDropDownTextField *taskTextField = nil;
    if (showTask == 3) {
        taskCell = (TaskAndWorkTableViewCell *) [self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        taskTextField = (IQDropDownTextField*)[taskCell.contentView viewWithTag:105];
    }
    
    return taskTextField;
}

-(NSString *) fetchWorkFuncCodeFromWorkFuncDescription :(NSString *) workFuncDesc
{
    NSString * workFuncCodeString = @"";
    if (workFuncDesc.length >0)
    {
        int indexOfWorkFuncDesc = (int)[self.workFuncItemList indexOfObject:workFuncDesc];
        if (indexOfWorkFuncDesc!=-1) {
            WorkFunction * workObj = [self.workFuncArray objectAtIndex:indexOfWorkFuncDesc];
            workFuncCodeString = workObj.resUsageCode;
        }
    }
    else
    {
        workFuncCodeString = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_RES_USAGE_CODE];
    }
    return workFuncCodeString;
}

-(IQDropDownTextField *) getTextFromWorkFunctionFieldInTableView
{
    
    TaskAndWorkTableViewCell * workFunctionCell = nil;
    IQDropDownTextField *workFuncTextField = nil;
    if (showWorkFunc == 2)
    {
        if (showTask == 3)
        {
            workFunctionCell = (TaskAndWorkTableViewCell *) [self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
        }
        else if (showTask == 0 || showTask == 1)
        {
            workFunctionCell = (TaskAndWorkTableViewCell *) [self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        }
        workFuncTextField = (IQDropDownTextField*)[workFunctionCell.contentView viewWithTag:107];
    }
    
    return workFuncTextField;
}

-(UITextField *) getTextFromHoursFieldInTableView
{
    
    JobHoursTableViewCell * hoursCell = nil;
    UITextField *hoursTextField = nil;
    if (showTask == 3 & showWorkFunc == 2)
    {
        hoursCell = (JobHoursTableViewCell *) [self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    }
    else if (((showTask == 0 || showTask == 1) && showWorkFunc == 2) || (showTask == 3 && (showWorkFunc == 0 || showWorkFunc == 1)))
    {
        hoursCell = (JobHoursTableViewCell *) [self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    }
    else
    {
        hoursCell = (JobHoursTableViewCell *) [self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    }
    hoursTextField = (UITextField*)[hoursCell.contentView viewWithTag:106];
    
    return hoursTextField;
}

-(UITextView *) getTextFromCommentsFieldInTableView
{
    
    CommentAreaTableViewCell * commentsCell = nil;
    UITextView * commentsView = nil;
    if (showTask == 3 && showWorkFunc == 2)
    {
        commentsCell = (CommentAreaTableViewCell *) [self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]];
    }
    else if (((showTask == 0 || showTask == 1) && showWorkFunc == 2) || (showTask == 3 && (showWorkFunc == 0 || showWorkFunc == 1)))
    {
        commentsCell = (CommentAreaTableViewCell *) [self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    }
    else if ((showTask == 0 || showTask == 1) && (showWorkFunc == 0 || showWorkFunc == 1))
    {
        commentsCell = (CommentAreaTableViewCell *) [self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    }
    commentsView = (UITextView *)[commentsCell.contentView viewWithTag:108];
    
    return commentsView;
}

#pragma mark - Make Cell Methods for MainTableView

-(EditClientJobTableViewCell *) makeEditJobCellForTableView:(UITableView *) tableView atIndexPath:(NSIndexPath *) indexPath
{
    static NSString * cellIdentifier = @"EditClientJobTableViewCell";
    EditClientJobTableViewCell *  jobcell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (self.transactionItem.transactionID && self.transactionItem.transactionID.length>0)
    {
        if (self.transactionItem.isPermanentLine)
        {
            jobcell.isPinned = YES;
            [jobcell.pinImageView setImage:[UIImage imageNamed:@"pin.png"]];
            [jobcell.pinButton setSelected:YES];
        }
        else
        {
            jobcell.isPinned = NO;
            [jobcell.pinImageView setImage:[UIImage imageNamed:@"unpin.png"]];
            [jobcell.pinButton setSelected:NO];
        }
    }
    else
    {
        [jobcell.pinButton setHidden:YES];
        [jobcell.pinImageView setHidden:YES];
        [self.deleteButton setEnabled:NO];
        [self.deleteButton setAlpha:0.25];
    }
    
    if (self._editViewCalled == isFromPendingScreen)
    {
        [jobcell.pinButton setHidden:YES];
        [jobcell.pinImageView setHidden:YES];
    }
    
    NSString * appliedDateString = [TLUtilities ConvertDate:self.transactionItem.appliedDate FromFormat:@"yyyy-MM-dd" toFormat:@"eee MMMM dd, yyyy"];
    NSString * sortByString = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_SORT_BY]];
    
    if ([sortByString isEqualToString:@""]||[sortByString isEqualToString:@"1"]) // Show Level2 Key
    {
        jobcell.jobNameLabel.text = self.transactionItem.level2Key;
    }
    else if([sortByString isEqualToString:@"2"]) // Show Level2 Description
    {
        if ([self.transactionItem.level2Description isEqualToString:@""])
        {
            jobcell.jobNameLabel.text = self.transactionItem.level2Key;
        }
        else
            jobcell.jobNameLabel.text = self.transactionItem.level2Description;
    }
    
    else if ([sortByString isEqualToString:@"3"])
    {
        if ([self.transactionItem.level2Description isEqualToString:@""])
        {
            jobcell.jobNameLabel.text = self.transactionItem.level2Key;
        }
        else
            jobcell.jobNameLabel.text = [NSString stringWithFormat:@"%@ - %@", self.transactionItem.level2Key, self.transactionItem.level2Description];
    }
    
    jobcell.createdDateLabel.text = appliedDateString;
    jobcell.activityLabel.text = self.transactionItem.level3Key; //[self fetchActivityDescForSelectedLevel3Key:self.transactionItem.level3Key];
    jobcell.level3TitleLabel.text = [self fetchTitleOfField:TIME_BASED_LEVEL3_DESCRIPTION];
    
    if (self.transactionItem.submitFlag == 1 || self.transactionItem.approvalStatus == 1)
    {
        jobcell.pinButton.userInteractionEnabled = NO;
        jobcell.pinImageView.userInteractionEnabled = NO;
    }
    
    
    return jobcell;
}
-(TaskAndWorkTableViewCell *) makeTaskCellForTableView:(UITableView *) tableView atIndexPath:(NSIndexPath *) indexPath
{
    static NSString *cellIdentifier = @"TaskAndWorkTableViewCell";
    TaskAndWorkTableViewCell * taskCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    taskCell.taskAndWorkTxtField.tag = 105;
    taskCell.headingLabel.text = @"Task";
    
    NSString * taskTypeFromDBQuery = [NSString stringWithFormat:@"SELECT task_type FROM pdd_level3 WHERE level2_key = '%@' AND level3_key = '%@';",self.transactionItem.level2Key, self.transactionItem.level3Key];
    NSString * taskTypeString =  [[[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:taskTypeFromDBQuery] lastObject] lastObject];
    int taskTypeFromLevel3Activity = [taskTypeString intValue];
    
    NSString * taskDescFromDBQuery= [NSString stringWithFormat:@"SELECT task_description FROM pdd_task WHERE task_code = '%@' AND task_type = %i;", self.transactionItem.taskCode,taskTypeFromLevel3Activity];
    NSString * taskDescFromDB =  [[[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:taskDescFromDBQuery] lastObject] lastObject];
    
    taskCell.taskAndWorkTxtField.text = taskDescFromDB;
    taskCell.taskAndWorkTxtField.isOptionalDropDown = YES;
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarTintColor:[UIColor colorWithRed:238.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0]];
    [toolbar setBarStyle:UIBarStyleBlackOpaque];
    [toolbar sizeToFit];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, 200.0f, 21.0f)];
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [titleLabel setText:@"Tasks List"];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    
    UIBarButtonItem *toolBarTitle = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    [buttonDone setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [toolbar setItems:[NSArray arrayWithObjects:toolBarTitle,buttonflexible,buttonDone, nil]];
    taskCell.taskAndWorkTxtField.inputAccessoryView = toolbar;
    [taskCell.taskAndWorkTxtField setItemList:self.tasksItemList];
    
    taskCell.taskAndWorkTxtField.selectedItem = taskDescFromDB;
    [taskCell.taskAndWorkTxtField setDropDownMode:IQDropDownModeTextPicker];
    
    if (self.transactionItem.submitFlag == 1 || self.transactionItem.approvalStatus == 1)
    {
        taskCell.userInteractionEnabled = NO;
    }
    
    return taskCell;
}
-(JobHoursTableViewCell *) makeHoursCellForTableView:(UITableView *) tableView atIndexPath:(NSIndexPath *) indexPath
{
    static NSString *cellIdentifier = @"JobHoursTableViewCell";
    JobHoursTableViewCell * jobHourCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    jobHourCell.hoursStepper.value = self.transactionItem.units;
    NSString * maxHoursString = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_MAX_HOURS_DAY];
    if (maxHoursString && ![maxHoursString isEqualToString:@""])
    {
        jobHourCell.hoursStepper.maximumValue = [maxHoursString doubleValue];
        jobHourCell.hoursStepper.minimumValue = -[maxHoursString doubleValue];
    }
    else
    {
        jobHourCell.hoursStepper.maximumValue = 8.00;
        jobHourCell.hoursStepper.minimumValue = -8.00;
    }
    jobHourCell.hoursStepper.value = self.transactionItem.units;
    jobHourCell.hoursTxtField.text = [NSString stringWithFormat:@"%.2f", self.transactionItem.units];
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarTintColor:[UIColor colorWithRed:238.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0]];
    [toolbar setBarStyle:UIBarStyleBlackOpaque];
    [toolbar sizeToFit];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboardOfTextView)];
    [buttonDone setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    [toolbar setItems:[NSArray arrayWithObjects:buttonflexible,buttonDone, nil]];
    jobHourCell.hoursTxtField.inputAccessoryView = toolbar;

    if (self.transactionItem.submitFlag == 1 || self.transactionItem.approvalStatus == 1)
    {
        jobHourCell.userInteractionEnabled = NO;
    }
    
    return jobHourCell;
}
-(TaskAndWorkTableViewCell *) makeWorkFunctionCellForTableView:(UITableView *) tableView atIndexPath:(NSIndexPath *) indexPath {
    static NSString *cellIdentifier = @"TaskAndWorkTableViewCell";
    TaskAndWorkTableViewCell * workFuncCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    workFuncCell.taskAndWorkTxtField.tag = 107;
    workFuncCell.headingLabel.text = [self fetchTitleOfField:FIELD_RESOURCE_USAGE];
    
    
    NSString * resUsageDesc = [self fetchWorkFuncDescriptionFromLocalDBForCode:self.transactionItem.resUsageCode];
    if (!resUsageDesc || [resUsageDesc isEqualToString:@""])
    {
        NSString * defaultResUsage = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_RES_USAGE_CODE];
        resUsageDesc = [self fetchWorkFuncDescriptionFromLocalDBForCode:defaultResUsage];
        self.transactionItem.resUsageCode = defaultResUsage;
    }
    
    workFuncCell.taskAndWorkTxtField.text = resUsageDesc;
    workFuncCell.taskAndWorkTxtField.isOptionalDropDown = YES;
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarTintColor:[UIColor colorWithRed:238.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0]];
    [toolbar setBarStyle:UIBarStyleBlackOpaque];
    [toolbar sizeToFit];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, 200.0f, 21.0f)];
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [titleLabel setText:[NSString stringWithFormat:@"%@ List",[self fetchTitleOfField:FIELD_RESOURCE_USAGE]]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    
    UIBarButtonItem *toolBarTitle = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    [buttonDone setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [toolbar setItems:[NSArray arrayWithObjects:toolBarTitle,buttonflexible,buttonDone, nil]];
    workFuncCell.taskAndWorkTxtField.inputAccessoryView = toolbar;
    [workFuncCell.taskAndWorkTxtField setItemList:self.workFuncItemList];
    
    workFuncCell.taskAndWorkTxtField.selectedItem = resUsageDesc;
    [workFuncCell.taskAndWorkTxtField setDropDownMode:IQDropDownModeTextPicker];
    if (self.transactionItem.submitFlag == 1 || self.transactionItem.approvalStatus == 1)
    {
        workFuncCell.userInteractionEnabled = NO;
    }
    
    return workFuncCell;
}
-(CommentAreaTableViewCell *) makeCommentsCellForTableView:(UITableView *) tableView atIndexPath:(NSIndexPath *) indexPath
{
    static NSString *cellIdentifier = @"CommentAreaTableViewCell";
    CommentAreaTableViewCell * commentsCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    commentsCell.tableView = self.mainTableView;
    
    if ([self.transactionItem.comments isEqualToString:@""] || [self.transactionItem.comments isEqualToString:@"Comments here..."]) {
        commentsCell.commentsTxtView.text = @"Comments here...";
        commentsCell.commentsTxtView.textColor = [UIColor lightGrayColor];
    }
    else {
        commentsCell.commentsTxtView.text = self.transactionItem.comments;
        commentsCell.commentsTxtView.textColor = [UIColor blackColor];
    }
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarTintColor:[UIColor colorWithRed:238.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0]];
    [toolbar setBarStyle:UIBarStyleBlackOpaque];
    [toolbar sizeToFit];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboardOfTextView)];
    [buttonDone setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    [toolbar setItems:[NSArray arrayWithObjects:buttonflexible,buttonDone, nil]];
    commentsCell.commentsTxtView.inputAccessoryView = toolbar;

    if (self.transactionItem.submitFlag == 1 || self.transactionItem.approvalStatus == 1)
    {
        [commentsCell.commentsTxtView setEditable:NO];
    }
    
    return commentsCell;
}

#pragma mark - UITableViewDelegate + UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell *cell;    
    long int sectionNumber = indexPath.section;
    
    switch (sectionNumber)
    {
        case 0:
        {
            cell =  [self makeEditJobCellForTableView:tableView atIndexPath:indexPath];
            break;
        }
        case 1:
        {
            if (showTask == 3 ) // If showTask = YES
            {
                cell =  [self makeTaskCellForTableView:tableView atIndexPath:indexPath];
            }
            else if ((showTask == 0 || showTask == 1) && (showWorkFunc == 2)) // If showTask = NO But showWorkFunc = YES
            {
                cell =  [self makeWorkFunctionCellForTableView:tableView atIndexPath:indexPath];
            }
            else
            {
                cell =  [self makeHoursCellForTableView:tableView atIndexPath:indexPath];
            }

            break;
        }
        case 2:
        {
            if(showTask == 3 && showWorkFunc == 2) // If showTask = YES and ShowWorkFunc = YES
            {
                cell =  [self makeWorkFunctionCellForTableView:tableView atIndexPath:indexPath];
            }
            else if (((showTask == 0 || showTask == 1) && showWorkFunc == 2) || (showTask == 3 && (showWorkFunc == 0 ||showWorkFunc == 1))) // if anyone = YES
            {
                cell =  [self makeHoursCellForTableView:tableView atIndexPath:indexPath];
            }
            else if ((showTask == 0 || showTask == 1) && (showWorkFunc == 0 || showWorkFunc == 1)) // If showTask = NO and ShowWorkFunc = NO
            {
                cell =  [self makeCommentsCellForTableView:tableView atIndexPath:indexPath];
            }
            break;
        }
        case 3:
        {
            if (showTask == 3 && showWorkFunc == 2)
            {
                cell =  [self makeHoursCellForTableView:tableView atIndexPath:indexPath];
            }
            else if (((showTask == 0 || showTask == 1) && showWorkFunc == 2) || (showTask == 3 && (showWorkFunc == 0 ||showWorkFunc == 1)))
            {
                cell =  [self makeCommentsCellForTableView:tableView atIndexPath:indexPath];
            }

            break;
        }
        case 4:
        {
            cell =  [self makeCommentsCellForTableView:tableView atIndexPath:indexPath];
            break;
        }
        default:
            break;
    }
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int sectionCount = 3;
    if (showTask == 3)
    {
        sectionCount +=1;
    }
    if (showWorkFunc == 2)
    {
        sectionCount+=1;
    }
    return sectionCount;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1.0;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 1.0)];
    headerView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float rowHeight = 0.0;
    switch (indexPath.section)
    {
        case 0:
        {
            rowHeight = 135.0;
        }
            break;
        case 1:
        {
            rowHeight = 50.0;
        }
            break;
        case 2:
        {
            if ((showTask == 0 || showTask == 1) && (showWorkFunc == 0 ||showWorkFunc == 1)) {
                rowHeight = 170.0;
            }
            else
                rowHeight = 50.0;
        }
            break;
        case 3:
        {
            if ((showTask == 0 || showTask == 1) || (showWorkFunc == 0 ||showWorkFunc == 1)) {
                rowHeight = 170.0;
            }
            else
                rowHeight = 50.0;
        }
            break;
        case 4:
        {
            rowHeight = 170.0;
        }
            break;
        default:
            break;
    }
    return rowHeight;
}


@end
