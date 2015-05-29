//
//  TLAddJobViewController.m
//  TimeLineApp
//
//  Created by Hanny on 12/12/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "TLAddJobViewController.h"

#import "JobHoursTableViewCell.h"
#import "TaskAndWorkTableViewCell.h"
#import "CommentAreaTableViewCell.h"
#import "AutoCompleteTableViewCell.h"
#import "TLUtilities.h"
#import "TLConstants.h"
#import "IQDropDownTextField.h"
#import "Level2_Customer.h"
#import "AppDelegate.h"
#import "Task.h"
#import "WorkFunction.h"
#import "WebservicesManager.h"
#import "MBProgressHUD.h"

@interface TLAddJobViewController ()



@end

@implementation TLAddJobViewController

@synthesize delegate;
@synthesize selectedDateString;
@synthesize autoCompleteArray;
@synthesize jobsArray,clientsArray,activityArray,tasksArray,workFuncArray;
@synthesize activityItemList,tasksItemList,workFuncItemList;
@synthesize selectedActivityItem;
@synthesize selectedJobItem;

@synthesize maxHoursWeek;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    self.title = @"Add Time";
    
    UINib *nibForJobTitleCell = [UINib nibWithNibName:@"TLAddJobTableViewCell" bundle:nil];
    [[self mainTableView] registerNib:nibForJobTitleCell forCellReuseIdentifier:@"TLAddJobTableViewCell"];
    
    UINib *nibForJobTaskAndWorkCell = [UINib nibWithNibName:@"TaskAndWorkTableViewCell" bundle:nil];
    [[self mainTableView] registerNib:nibForJobTaskAndWorkCell forCellReuseIdentifier:@"TaskAndWorkTableViewCell"];

    UINib *nibForJobHoursCell = [UINib nibWithNibName:@"JobHoursTableViewCell" bundle:nil];
    [[self mainTableView] registerNib:nibForJobHoursCell forCellReuseIdentifier:@"JobHoursTableViewCell"];

    UINib *nibForJobCommentsAreaCell = [UINib nibWithNibName:@"CommentAreaTableViewCell" bundle:nil];
    [[self mainTableView] registerNib:nibForJobCommentsAreaCell forCellReuseIdentifier:@"CommentAreaTableViewCell"];
    
    UINib *nibForAutoCompleteTableCell = [UINib nibWithNibName:@"AutoCompleteTableViewCell" bundle:nil];
    [[self autoCompleteTableView] registerNib:nibForAutoCompleteTableCell forCellReuseIdentifier:@"AutoCompleteTableViewCell"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.autoCompleteTableView setHidden:YES];
    self.autoCompleteArray = [[NSMutableArray alloc] init];
    self.clientsArray = [[NSMutableArray alloc] init];
    self.jobsArray = [[NSMutableArray alloc] init];
    
    jobFieldHasValue = NO;
    clientOrJobField = NO;
    
    [self fetchAllClientsFromDB];
    [self fetchAllWorkFunctionsFromDB];
    
    showTask = [[NSUserDefaults standardUserDefaults] integerForKey:UDKEY_SHOW_TASKS];
    showWorkFunc = [[NSUserDefaults standardUserDefaults] integerForKey:UDKEY_SHOW_RES_USAGE];
    
    settingsCustomerOption = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_SETTINGS_CUSTOMER_OPTION];
    settingsJobOption = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_SETTINGS_PROJECT_OPTION];
    [self makeCustomBackButtonWithLogo];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    // making Job Cell
    TLAddJobTableViewCell *jobcell =  (TLAddJobTableViewCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    UITextField *clientTextField = (UITextField*)[jobcell.contentView viewWithTag:101];
    UITextField *jobTextField = (UITextField*)[jobcell.contentView viewWithTag:102];
    IQDropDownTextField *activityTextField = (IQDropDownTextField*)[jobcell.contentView viewWithTag:104];
    
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
    
    NSString * resUsageCode =[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_RES_USAGE_CODE];
    if (showTask == 3)
    {
        if (showWorkFunc == 2)
        {
            if ([taskCodeString isEqualToString:@""]&& [hoursString floatValue] == 0 && [workFunctionString isEqualToString:resUsageCode] && [commentsString isEqualToString:@""] && [clientTextField.text isEqualToString:@""] && [jobTextField.text isEqualToString:@""] && [activityTextField.text isEqualToString:@""])
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CONFIRMATION_REQUIRED_TITLE message:EDIT_SCREEN_UNSAVED_CHANGES_MESSAGE delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                alert.delegate = self;
                alert.tag = 11177;
                [alert show];
            }
        }
        else
        {
            if ([taskCodeString isEqualToString:@""]&& [hoursString floatValue] == 0 && [commentsString isEqualToString:@""] && [clientTextField.text isEqualToString:@""] && [jobTextField.text isEqualToString:@""] && [activityTextField.text isEqualToString:@""])
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CONFIRMATION_REQUIRED_TITLE message:EDIT_SCREEN_UNSAVED_CHANGES_MESSAGE delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                alert.delegate = self;
                alert.tag = 11177;
                [alert show];
            }
        }
    }
    else
    {
        if (showWorkFunc == 2)
        {
            if ([hoursString floatValue] == 0 && [workFunctionString isEqualToString:resUsageCode] && [commentsString isEqualToString:@""] && [clientTextField.text isEqualToString:@""] && [jobTextField.text isEqualToString:@""] && [activityTextField.text isEqualToString:@""])
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CONFIRMATION_REQUIRED_TITLE message:EDIT_SCREEN_UNSAVED_CHANGES_MESSAGE delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                alert.delegate = self;
                alert.tag = 11177;
                [alert show];
            }
        }
        else
        {
            if ([hoursString floatValue] == 0 && [commentsString isEqualToString:@""] && [clientTextField.text isEqualToString:@""] && [jobTextField.text isEqualToString:@""] && [activityTextField.text isEqualToString:@""])
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CONFIRMATION_REQUIRED_TITLE message:EDIT_SCREEN_UNSAVED_CHANGES_MESSAGE delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                alert.delegate = self;
                alert.tag = 11177;
                [alert show];
            }
        }
        
    }

}


#pragma mark - IBAction Methods

-(IBAction) cancelButtonAction:(id)sender
{
    [self backButtonTapped];
}

-(void) saveTransactionOnServer
{
    TLAddJobTableViewCell *jobcell =  (TLAddJobTableViewCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *jobTextField = (UITextField*)[jobcell.contentView viewWithTag:102];
    UILabel *createdDateLabel = (UILabel*)[jobcell.contentView viewWithTag:103];
    IQDropDownTextField *activityTextField = (IQDropDownTextField*)[jobcell.contentView viewWithTag:104];
    
// making Task Cell
    IQDropDownTextField * taskTextField = [self getTextFromTaskFieldInTableView];
  
    
// making WorkFunc Cell
    IQDropDownTextField * workFuncTextField = [self getTextFromWorkFunctionFieldInTableView];
    
// making makingHours Cell
    UITextField * hoursTextField = [self getTextFromHoursFieldInTableView];
    
// making Comments Cell
    UITextView * commentsView = [self getTextFromCommentsFieldInTableView];
    

    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = WEBSERVICE_CALL_STATUS;
    
    NSString * level3KeyString = activityTextField.text;
//    if (activityTextField.text.length >0)
//    {
//        int indexOfActivityDesc = (int)[self.activityItemList indexOfObject:activityTextField.text];
//        if (indexOfActivityDesc!=-1) {
//            Level3_Activity * activityObj = [self.activityArray objectAtIndex:indexOfActivityDesc];
//            level3KeyString = activityObj.level3Key;
//        }
//    }
    
    // Fetch TaskCode
    NSString * taskCodeString = [self fetchTaskCodeFromTaskDescription:taskTextField.text];
    
    // Fetch WorkFunction Code
    NSString * workFuncCodeString = [self fetchWorkFuncCodeFromWorkFuncDescription:workFuncTextField.text];
    

    NSString * resourceIDString = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_RESOURCE_ID];
    NSString * transactionID = [NSString stringWithFormat:@"%@", [TLUtilities generateTransactionIDusingCounter:0]];
    
    NSString * currentDateString = [TLUtilities ConvertDate:[NSString stringWithFormat:@"%@",[NSDate date]] FromFormat:@"yyyy-MM-dd HH:mm:ss z" toFormat:@"yyyy-MM-dd"];
    NSString * commentsString = ([commentsView.text isEqualToString:@"Comments here..."])?@"":commentsView.text;
    NSString * orgUnitString = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_ORG_UNIT_CODE];
    NSString * locationCodeString = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_LOCATION_CODE];
    NSString * appliedDateString = [TLUtilities ConvertDate:createdDateLabel.text FromFormat:@"EEEE MMMM dd, yyyy" toFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* currentDate = [NSDate date];
    NSString * modifiedDateString = [NSString stringWithFormat:@"%@",currentDate];
    NSString * timeStampString = @"";
    int errorFlag = 0;
    int errorCode = 0;
    NSString * errorDescriptionString = @"";
    
    /*
     pld_transaction(company_code INTEGER NOT NULL,transaction_id TEXT NOT NULL,level2_key  TEXT NOT NULL,level3_key TEXT NOT NULL, applied_date DATE NOT NULL,trx_type INTEGER NOT NULL,resource_id TEXT NOT NULL,res_usage_code TEXT,unit REAL,location_code TEXT,org_unit  TEXT,task_code TEXT, comments TEXT,nonbillable_flag INTEGER,submitted_flag  INTEGER,submitted_date DATE, approval_flag INTEGER,sync_status INTEGER,deleted  INTEGER,modified_datetime DATE,timestamp TEXT, error_flag INTEGER,error_code INTEGER, error_description TEXT, PRIMARY KEY(company_code, transaction_id))
     */
    
    __block NSString * query = @"";
    
    Transaction * tempObj = [[Transaction alloc] initTransactionWithID:transactionID transactionType:1001 ofJob:jobTextField.text activity:level3KeyString taskCode:taskCodeString orgUnit:orgUnitString comments:commentsString resource:resourceIDString resUsageCode:workFuncCodeString appliedOn:appliedDateString modifiedOn:modifiedDateString submittedOn:currentDateString withApprovalFlags:0 submitFlag:0 nonBillableFlag:0 andSyncedFlag:0 Units:[hoursTextField.text floatValue] andLocationCode:locationCodeString];
    tempObj.timeStamp = timeStampString;
    tempObj.errorFlag = errorFlag;
    tempObj.errorCode = errorCode;
    tempObj.errorDescription = errorDescriptionString;
    
    [DataSyncHandler defaultHandler].delegate = self;
    [DataSyncHandler defaultHandler].isDelegateSetFromLogin = NO;
    
    if ([TLUtilities verifyInternetAvailability])
    {
        [DataSyncHandler defaultHandler].isSyncingTransaction = NO;
        [[DataSyncHandler defaultHandler] addTransactionOnServer:tempObj completionHandler:^(BOOL success, NSString *errMsg)
        {
            if (success)
            {
                // No need to add transaction in LocalDB from here now, because it would automatically be inserted into the LocalDB in "addTransactionOnServer" Method in DataSyncHandler class.
                
                // Add PermanentLine Only if Transaction is saved Successfully.
                if (jobcell.isPinned)
                {
                    [[DataSyncHandler defaultHandler] addNewPermanentLineWithLevel2Key:jobTextField.text level3Key:activityTextField.text taskCode:taskCodeString forDate:self.selectedDateString];
                    
                }
                else
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
        
        // Validate the Transaction for Duplication.
        BOOL isTransactionDuplicate =  [self validateDuplicateTransactions:tempObj];
        if (!isTransactionDuplicate)
        {
            if (jobcell.isPinned)
            {
                [[DataSyncHandler defaultHandler] addNewPermanentLineWithLevel2Key:jobTextField.text level3Key:activityTextField.text taskCode:taskCodeString forDate:self.selectedDateString];
            }
            
            // Query with SyncStatus = 0
            
            NSString * appliedDateStringForLocalDB = [TLUtilities ConvertDate:createdDateLabel.text FromFormat:@"EEEE MMMM dd, yyyy" toFormat:@"yyyy-MM-dd"];
            
            query = [NSString stringWithFormat:@"INSERT INTO pld_transaction VALUES(%i,'%@','%@','%@','%@',%i,'%@','%@',%.2f,'%@','%@','%@','%@',%i,%i,'%@',%i,%i,%i,'%@','%@',%i,%i,'%@');",[[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE] intValue],
                     transactionID,
                     jobTextField.text,
                     level3KeyString,
                     appliedDateStringForLocalDB,
                     1001,
                     resourceIDString,
                     workFuncCodeString,
                     [hoursTextField.text floatValue],
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
            NSString * appliedDateStringForError = [TLUtilities ConvertDate:createdDateLabel.text FromFormat:@"EEEE MMMM dd, yyyy" toFormat:@"MM/dd/yyyy"];
            
            
            NSString * messageString = [NSString stringWithFormat:@"Duplicate Transaction already exists for:\n  %@: %@ \n %@:%@ \n Units: %.2f \n Date:%@", level2SysName,tempObj.level2Key, level3SysName, tempObj.level3Key, tempObj.units, appliedDateStringForError];
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:messageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
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
        query = [NSString stringWithFormat:@"SELECT * FROM pld_transaction WHERE unit = %.2f AND level2_key = '%@' AND level3_key = '%@' AND task_code = '%@' AND comments = '%@' AND applied_date = '%@' AND transaction_id != '%@' AND deleted = 0",
                 transactItem.units,
                 transactItem.level2Key,
                 transactItem.level3Key,
                 transactItem.taskCode,
                 transactItem.comments,
                 appliedDate,
                 transactItem.transactionID];
    }
    else
    {
        query = [NSString stringWithFormat:@"SELECT * FROM pld_transaction WHERE unit = %.2f AND level2_key = '%@' AND level3_key = '%@' AND comments = '%@' AND applied_date = '%@' AND transaction_id != '%@'",
                 transactItem.units,
                 transactItem.level2Key,
                 transactItem.level3Key,
                 transactItem.comments,
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



-(void) validateTheLevel2:(NSString *) level2KeyString andLevel3:(NSString *)level3KeyString ofTransactionForAppliedDate:(NSString *) appliedDate
{
    /*
     
     - the level2_status of Level2 should be 1
     - the labor_flag of Level3 should be 1
     - applied date should not be earlier than the open_date of the Level2/Level3
     - if closed_date of Level2/Level3 is not null then applied date of the transaction should not be later than the closed_date of Level2/Level3
     */
    
    BOOL showErrorAlert = NO;
    
    NSString * queryForLevel2 = [NSString stringWithFormat:@"SELECT * FROM pdd_level2 WHERE level2_key = '%@'", level2KeyString];
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
        NSString * tempString = [NSString stringWithFormat:@" %@:%@ is not open", level2SysName,level2KeyString];
        errorDescString = [errorDescString stringByAppendingString:tempString];
        
        showErrorAlert = YES;
    }
    else if ([appliedDate compare:level2OpenDate] == NSOrderedAscending)
    {
        NSLog(@"Applied Date is Earlier than Level2 Open Date");
        
        NSString * tempString = [NSString stringWithFormat:@" %@:%@ is not valid earlier than %@", level2SysName,level2KeyString, convertedLevel2OpenDate];
        errorDescString = [errorDescString stringByAppendingString:tempString];
        
        showErrorAlert = YES;
    }
    else if (!level2CloseDate || ![level2CloseDate isEqualToString:@""])
    {
        if ([appliedDate compare:level2CloseDate] == NSOrderedDescending)
        {
            NSLog(@"Applied Date is  Later than Level2 Closed Date");
            
            NSString * tempString = [NSString stringWithFormat:@" %@:%@ is not valid later than %@", level2SysName,level2KeyString, convertedLevel2ClosedDate];
            errorDescString = [errorDescString stringByAppendingString:tempString];
            
            showErrorAlert = YES;
        }
    }
    
    
    // First Check If there is any Error related to Level2.
    // If YES then show Alert and donot go for Level3 Validation.
    // If NO Validate Level3.
    // If Level3 is Valid then Save TransactionOnServer
    // ELSE Show Alert With Level3 Error.
    
    if (showErrorAlert)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:errorDescString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        
        NSString * queryForLevel3 = [NSString stringWithFormat:@"SELECT * FROM pdd_level3 WHERE level3_key = '%@' AND level2_key = '%@'", level3KeyString, level2KeyString];
        NSArray * level3Array = [[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:queryForLevel3] lastObject];
        NSString * level3Labor = [level3Array objectAtIndex:6];
        NSString * level3CloseDate = [level3Array objectAtIndex:7];
        NSString * level3OpenDate = [level3Array objectAtIndex:8];
        
        NSString * convertedLevel3OpenDate = [TLUtilities ConvertDate:level3OpenDate FromFormat:@"yyyy-MM-dd" toFormat:@"MM/dd/yyyy"];
        NSString * convertedLevel3ClosedDate = [TLUtilities ConvertDate:level3CloseDate FromFormat:@"yyyy-MM-dd" toFormat:@"MM/dd/yyyy"];
        
        if (level3Labor.intValue!=1)
        {
            NSString * tempString = [NSString stringWithFormat:@" %@:%@  %@:%@ is not valid for the Time Entry", level2SysName,level2KeyString, level3SysName, level3KeyString];
            errorDescString = [errorDescString stringByAppendingString:tempString];
            
            showErrorAlert = YES;
        }
        else if ([appliedDate compare:level3OpenDate] == NSOrderedAscending)
        {
            NSLog(@"Applied Date is Earlier than Level3 Open Date");
            
            NSString * tempString = [NSString stringWithFormat:@" %@:%@  %@:%@ is not valid earlier than %@", level2SysName,level2KeyString, level3SysName, level3KeyString, convertedLevel3OpenDate];
            errorDescString = [errorDescString stringByAppendingString:tempString];
            
            showErrorAlert = YES;
        }
        else if (!level3CloseDate || ![level3CloseDate isEqualToString:@""])
        {
            if ([appliedDate compare:level3CloseDate] == NSOrderedDescending)
            {
                NSLog(@"Applied Date is  Later than Level3 Closed Date");
                
                NSString * tempString = [NSString stringWithFormat:@" %@:%@  %@:%@ is not valid later than %@", level2SysName,level2KeyString, level3SysName, level3KeyString, convertedLevel3ClosedDate];
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
            // This section Shows Level2 and Level3 both are Valid.
            [self saveTransactionOnServer];
        }
    }
}

-(IBAction) saveButtonAction:(id)sender
{
    // Prepare the query string.
    // If the recordIDToEdit property has value other than -1, then create an update query. Otherwise create an insert query.
    
// making Job Cell.
    TLAddJobTableViewCell *jobcell =  (TLAddJobTableViewCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    UITextField *clientTextField = (UITextField*)[jobcell.contentView viewWithTag:101];
    UITextField *jobTextField = (UITextField*)[jobcell.contentView viewWithTag:102];
    UILabel *createdDateLabel = (UILabel*)[jobcell.contentView viewWithTag:103];
    IQDropDownTextField *activityTextField = (IQDropDownTextField*)[jobcell.contentView viewWithTag:104];
 
// making Task Cell
    IQDropDownTextField * taskTextField = [self getTextFromTaskFieldInTableView];


// making makingHours Cell
    UITextField * hoursTextField = [self getTextFromHoursFieldInTableView];
    

    NSString * appliedDateStringForLocalDB = [TLUtilities ConvertDate:createdDateLabel.text FromFormat:@"EEEE MMMM dd, yyyy" toFormat:@"yyyy-MM-dd"];
    
// Begining of Logic
    if (showTask == 3)
    {
        // Job, Activity, Task and Hours are Mandatory Fields.
        if (jobTextField.text.length>0 && activityTextField.text.length >0 && taskTextField.text.length >0 && (hoursTextField.text.length >0 && [hoursTextField.text floatValue]!=0))
        {
            if (self.selectedJobItem) // If item exists, it means that user selected a Job from list and it exist in the Local DB as well.
            {
                float hoursEntered = [hoursTextField.text floatValue];
                BOOL maxHoursCheck = [self verifyHoursWithMaxLimits:hoursEntered];
                if (maxHoursCheck)
                {
                    [self validateTheLevel2:self.selectedJobItem.level2Key andLevel3:activityTextField.text ofTransactionForAppliedDate:appliedDateStringForLocalDB];
                }
            }
            else
            {
                // The case when User just enters Job Name in the textField and didnot pick from the list
                BOOL jobExists = [self verifyIfJOBEnteredExistsInLocalDB:jobTextField];
                if (!jobExists)
                {
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:@"JOB doesnot exists" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                }
                else
                {
                    [self validateTheLevel2:self.selectedJobItem.level2Key andLevel3:activityTextField.text ofTransactionForAppliedDate:appliedDateStringForLocalDB];
                }
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
        // Job, Activity, Task and Hours are Mandatory Fields.
        if (jobTextField.text.length>0 && activityTextField.text.length >0 && (hoursTextField.text.length >0 && [hoursTextField.text floatValue]!=0))
        {
            if (self.selectedJobItem) // If item exists, it means that user selected a Job from list and it exist in the Local DB as well.
            {
                float hoursEntered = [hoursTextField.text floatValue];
                BOOL maxHoursCheck = [self verifyHoursWithMaxLimits:hoursEntered];
                if (maxHoursCheck)
                {
                    [self validateTheLevel2:self.selectedJobItem.level2Key andLevel3:activityTextField.text ofTransactionForAppliedDate:appliedDateStringForLocalDB];
                }
            }
            else
            {
                // The case when User just enters Job Name in the textField and didnot pick from the list
                BOOL jobExists = [self verifyIfJOBEnteredExistsInLocalDB:jobTextField];
                if (!jobExists)
                {
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:@"JOB doesnot exists" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                }
                else
                {
                    [self validateTheLevel2:self.selectedJobItem.level2Key andLevel3:activityTextField.text ofTransactionForAppliedDate:appliedDateStringForLocalDB];
                }
            }
        }
        else
        {
            // Task is not Compulsory and there are some Missing Required Fields.
            [self checkRequiredFieldsAndShowAlertsIncludingTaskField:NO];
        }
    }
}

-(void) popViewControllerAndNotifyHomeVC
{
    // Inform the delegate that the Adding Job was finished.
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.delegate addingJobInfoWasFinished];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring forTextField:(int) field
{
    [self.autoCompleteArray removeAllObjects];
    
    if (field == 1)
    {
        // Client TextField selected
        if (!settingsCustomerOption || [settingsCustomerOption isEqual:@"By Name"])
        {
            if ([substring isEqualToString:@""]) {
                self.autoCompleteArray = [NSMutableArray arrayWithArray:self.clientsArray];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setValue:@"By Name" forKey:UDKEY_SETTINGS_CUSTOMER_OPTION];
                NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"SELF.customerName contains[c] %@", substring];
                NSArray * tempArray = [self.clientsArray filteredArrayUsingPredicate:namePredicate];
                self.autoCompleteArray = [NSMutableArray arrayWithArray:tempArray];
            }
            
        }
        else if([settingsCustomerOption isEqualToString:@"By Code"])
        {
            if ([substring isEqualToString:@""])
            {
                self.autoCompleteArray = [NSMutableArray arrayWithArray:self.clientsArray];
            }
            else
            {
                NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"SELF.customerCode contains[c] %@", substring];
                NSArray * tempArray = [self.clientsArray filteredArrayUsingPredicate:namePredicate];
                self.autoCompleteArray = [NSMutableArray arrayWithArray:tempArray];
            }
        }
        
    }
    else if (field == 2)
    {
        // Job TextField selected
        if (!settingsJobOption || [settingsJobOption isEqual:@"By Name"])
        {
            if ([substring isEqualToString:@""])
            {
                self.autoCompleteArray = [NSMutableArray arrayWithArray:self.jobsArray];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setValue:@"By Name" forKey:UDKEY_SETTINGS_PROJECT_OPTION];
                NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"SELF.level2Description contains[c] %@", substring];
                 NSArray * tempArray = [self.jobsArray filteredArrayUsingPredicate:namePredicate];
                self.autoCompleteArray = [NSMutableArray arrayWithArray:tempArray];
            }
        }
        else if([settingsJobOption isEqualToString:@"By Code"])
        {
            if ([substring isEqualToString:@""])
            {
                self.autoCompleteArray = [NSMutableArray arrayWithArray:self.jobsArray];
            }
            else
            {
                NSPredicate *codePredicate = [NSPredicate predicateWithFormat:@"SELF.level2Key contains[c] %@", substring];
                NSArray * tempArray = [self.jobsArray filteredArrayUsingPredicate:codePredicate];
                self.autoCompleteArray = [NSMutableArray arrayWithArray:tempArray];
            }
        }
    }
    else if (field == 3)
    {
        NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"SELF.level3Description contains[c] %@", substring];
        NSArray * tempArray = [self.activityArray filteredArrayUsingPredicate:namePredicate];
        self.autoCompleteArray = [NSMutableArray arrayWithArray:tempArray];
    }
    [self.autoCompleteTableView reloadData];
}

-(void) checkRequiredFieldsAndShowAlertsIncludingTaskField:(BOOL) taskFlag
{
    TLAddJobTableViewCell *jobcell =  (TLAddJobTableViewCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *jobTextField = (UITextField*)[jobcell.contentView viewWithTag:102];
    IQDropDownTextField *activityTextField = (IQDropDownTextField*)[jobcell.contentView viewWithTag:104];
    
// making Task Cell
    IQDropDownTextField * taskTextField = [self getTextFromTaskFieldInTableView];
    
// making makingHours Cell
    UITextField * hoursTextField = [self getTextFromHoursFieldInTableView];
    
    
    NSString * alertMessageString = @"";
    if (!jobTextField.text.length>0)
    {
        NSString * jobFieldTitle = [self fetchTitleOfField:TIME_BASED_LEVEL2_DESCRIPTION];
        if ([settingsJobOption isEqualToString:@"By Name"]) {
            alertMessageString = [NSString stringWithFormat:@"Please enter %@ Description", jobFieldTitle];
        }
        else if([settingsJobOption isEqualToString:@"By Code"])
        {
            alertMessageString = [NSString stringWithFormat:@"Please enter %@ Code", jobFieldTitle];
        }
    }
    else if (!activityTextField.text.length>0)
    {
        NSString * activityFieldTitle = [self fetchTitleOfField:TIME_BASED_LEVEL3_DESCRIPTION];
        alertMessageString = [NSString stringWithFormat:@"Please select %@ Code", activityFieldTitle];
    }
    else if (!taskTextField.text.length >0)
    {
        if (taskFlag) {
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
        
        if (!jobTextField.text.length >0)
        {
            [jobTextField becomeFirstResponder];
        }
        else if (!activityTextField.text.length>0)
        {
            [activityTextField becomeFirstResponder];
        }
        else if (!taskTextField.text.length >0)
        {
            [taskTextField becomeFirstResponder];
        }
        else if (!hoursTextField.text.length >0 || [hoursTextField.text floatValue] == 0)
        {
            [hoursTextField becomeFirstResponder];
        }
    }
}

-(BOOL) verifyIfClientEnteredExistsInLocalDB:(UITextField *) clientTextField
{
    BOOL clientExists = NO;
    
    NSString * clientItemSearchQuery = [NSString stringWithFormat:@"SELECT * FROM pdd_level2_customer WHERE customer_code = '%@'", clientTextField.text];
    NSArray * clientTempArray = [[DataSyncHandler defaultHandler].dbManager loadDataFromDB:clientItemSearchQuery];
    if (clientTempArray.count >0)
    {
        for (NSArray * tempCustomer in clientTempArray)
        {
            NSString * customerCode =[tempCustomer objectAtIndex:0];
            NSString * customerName = [tempCustomer objectAtIndex:1];
            
            Level2_Customer * customerObj = [[Level2_Customer alloc] initWithCustomerCode:customerCode andCustomerName:customerName andLevel2Key:@""];
            self.selectedClientItem = customerObj;
        }
        clientExists = YES;
    }
    else
    {
        clientExists = NO;
    }
    
    return clientExists;
}

-(BOOL) verifyIfJOBEnteredExistsInLocalDB:(UITextField *) jobTextField
{
    BOOL jobExists = NO;
    
    NSString * jobItemSearchQuery = [NSString stringWithFormat:@"SELECT * FROM pdd_level2 WHERE level2_key = '%@'", jobTextField.text];
    NSArray * jobTempArray = [[DataSyncHandler defaultHandler].dbManager loadDataFromDB:jobItemSearchQuery];
    if (jobTempArray.count >0)
    {
        for (NSArray * tempJob in jobTempArray)
        {
            NSString * level2Key = [tempJob objectAtIndex:1];
            NSString *  level2Desc = [tempJob objectAtIndex:2];
            int level2Status = [[tempJob objectAtIndex:3] intValue];
            NSString * closeDateString = [tempJob objectAtIndex:4];
            NSString * openDateString = [tempJob objectAtIndex:5];
            
            Level2_Job * tempObj = [[Level2_Job alloc] initWithLevel2Key:level2Key andDescription:level2Desc syncedLastOnDate:@"" withLevel2Status:level2Status onOpeningDate:openDateString andClosingDate:closeDateString];
            self.selectedJobItem = tempObj;
        }
        jobExists = YES;
    }
    else
    {
        jobExists = NO;
    }
    
    return jobExists;
}

-(BOOL) verifyHoursWithMaxLimits:(float) hoursEntered
{
    BOOL allowToSave = NO;
    
     float maxDayHoursLimit = [[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_MAX_HOURS_DAY] floatValue];
     float  maxWeekHoursLimit = [[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_MAX_HOURS_WEEK] floatValue];
    
    float hoursOfTheDate = [[DataSyncHandler defaultHandler] getHoursForSelectedDate:self.selectedDateString withBillableFlag:NO];
    
    float totalCombinedDayHours = hoursEntered + hoursOfTheDate ;
    if (totalCombinedDayHours <= maxDayHoursLimit)
    {
        float totalCombinedWeekHours = hoursEntered + maxHoursWeek;
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

#pragma mark - UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 11177)
    {
        if(buttonIndex == 1)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - DataSyncHandler Delegate Methods

-(void) permanentLineAddedSuccessfully
{
    NSLog(@"Permanent Line Added Successfully from ADD Screen");
    [self popViewControllerAndNotifyHomeVC];
}

-(void) permanentLineDeletedSuccessfully
{
    NSLog(@"Permanent Line Deleted Successfully from ADD Screen");
    [self popViewControllerAndNotifyHomeVC];
}



#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification;
{
        NSDictionary *userInfo = [notification userInfo];
        NSValue *keyboardBoundsValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGFloat keyboardHeight = [keyboardBoundsValue CGRectValue].size.height;
        keyboardHeightValue = keyboardHeight;
    
        CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        NSInteger animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        UIEdgeInsets insets = [[self mainTableView] contentInset];
        [UIView animateWithDuration:duration delay:0 options:animationCurve animations:^{
            UIEdgeInsets edgeInsets = UIEdgeInsetsMake(insets.top, insets.left, keyboardHeight, insets.right);
            [[self mainTableView] setContentInset:edgeInsets];
            [self.mainTableView setScrollIndicatorInsets:edgeInsets];
            [[self view] layoutIfNeeded];
        } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification;
{
        NSDictionary *userInfo = [notification userInfo];
        CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        NSInteger animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        UIEdgeInsets insets = [[self mainTableView] contentInset];
        [UIView animateWithDuration:duration delay:0 options:animationCurve animations:^{
            UIEdgeInsets edgeInsets = UIEdgeInsetsMake(insets.top, insets.left, 0.0, insets.right);
            [[self mainTableView] setContentInset:edgeInsets];
            [self.mainTableView setScrollIndicatorInsets:edgeInsets];
            [[self view] layoutIfNeeded];
        } completion:nil];
}

-(void)doneClicked:(UIBarButtonItem*)button
{
    [self.view endEditing:YES];
    if (button.tag == 1513)
    {
        if (showTask == 3)
        {
            [self fetchAllTasksForSelectedJobFromDB];
        }
    }
}

-(void) dismissKeyboardOfTextView
{
    [self.view endEditing:YES];
}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if(self.mainTableView.contentOffset.y == 0)
//    {
//        self.mainTableView.contentOffset = CGPointMake(0, -8);
//    }
//}

#pragma mark - UITextField Delegate Methods

-(void) hideAutoCompleteTableView
{
    if (![self.autoCompleteTableView isHidden])
    {
        [self.autoCompleteTableView setHidden:YES];
        [self.autoCompleteArray removeAllObjects];
        [self.autoCompleteTableView reloadData];
        [self.mainTableView setScrollEnabled:YES];
    }
}
-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 101 || textField.tag == 102)
    {
        [self.autoCompleteTableView setHidden:NO];
        [self.mainTableView setScrollEnabled:NO];
        
        float viewHeight = self.view.frame.size.height;
        float height = 0.0;
        
        if (textField.tag == 101)
        {
            height = viewHeight - (keyboardHeightValue + 140);
            clientOrJobField = 1; // clientTextField
            [self.autoCompleteTableView setFrame:CGRectMake(0.0,140.0 , self.autoCompleteTableView.frame.size.width, height)];
            
            [self searchAutocompleteEntriesWithSubstring:@"" forTextField:1];
        }
        else if(textField.tag == 102)
        {
            height = viewHeight - (keyboardHeightValue + 185);
            clientOrJobField = 2; // jobTextField;
            [self fetchAllJobsOfClientFromDB];
            [self.autoCompleteTableView setFrame:CGRectMake(0.0, 185.0, self.autoCompleteTableView.frame.size.width, height)];
            
            [self searchAutocompleteEntriesWithSubstring:@"" forTextField:2];
        }
        
    }
}
-(void) textFieldDidEndEditing:(UITextField *)textField
{
    TLAddJobTableViewCell *jobcell =  (TLAddJobTableViewCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    IQDropDownTextField * activityTextField = (IQDropDownTextField *) [jobcell.contentView viewWithTag:104];
    if (textField.tag == 102)
    {
        if ([textField.text isEqualToString:@""])
        {
            activityTextField.text = @"";
            [self.activityItemList removeAllObjects];
            [activityTextField setItemList:self.activityItemList];
        }
        TaskAndWorkTableViewCell *taskCell =  (TaskAndWorkTableViewCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        IQDropDownTextField *taskTextField = (IQDropDownTextField*)[taskCell.contentView viewWithTag:105];
        [taskTextField setText:@""];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    TLAddJobTableViewCell *jobcell =  (TLAddJobTableViewCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    UITextField * clientTextField = (UITextField *) [jobcell.contentView viewWithTag:101];
    UITextField * jobTextField = (UITextField *) [jobcell.contentView viewWithTag:102];
    IQDropDownTextField * activityTextField = (IQDropDownTextField *) [jobcell.contentView viewWithTag:104];
    
    [self hideAutoCompleteTableView];
    if (textField.tag == 101)
    {
        [textField resignFirstResponder];
        [jobTextField becomeFirstResponder];
        
    }
    else if (textField.tag == 102)
    {
        [textField resignFirstResponder];
        [activityTextField becomeFirstResponder];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    float viewHeight = self.view.frame.size.height;
    float height = 0.0;
    
    if (textField.tag == 101)
    {
        height = viewHeight - (keyboardHeightValue + 140);
        clientOrJobField = 1; // clientTextField
        [self.autoCompleteTableView setFrame:CGRectMake(0.0,140.0 , self.autoCompleteTableView.frame.size.width, height)];
    }
    else if (textField.tag == 102)
    {
        height = viewHeight - (keyboardHeightValue + 185);
        clientOrJobField = 2; // jobTextField;
        [self fetchAllJobsOfClientFromDB];
        [self.autoCompleteTableView setFrame:CGRectMake(0.0, 185.0, self.autoCompleteTableView.frame.size.width, height+5)];
    }
    self.autoCompleteTableView.hidden = NO;
    
    NSString * textString = [textField text];
    NSUInteger newLength = [textString length] + [string length] - range.length;
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ADD_SCREEN_ACCEPTABLE_CHARACTERS] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return (([string isEqualToString:filtered])&&(newLength <= CLIENT_FIELD_CHARACTERS_LIMIT));
}

-(void)textFieldDidChange:(UITextField *) textField
{
    [self searchAutocompleteEntriesWithSubstring:textField.text forTextField:clientOrJobField];
}

#pragma mark - LocalDB interacting Methods.

-(void) refreshArraysFromLocalDB
{
    [self fetchAllClientsFromDB];
    [self fetchAllJobsOfClientFromDB];
}

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


-(void) fetchAllClientsFromDB
{
    NSString * query = @"Select  DISTINCT customer_code,customer_name from pdd_level2_customer;";
    NSArray * clientTempArray =[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:query];
    
    if (clientTempArray.count>0)
    {
        if (self.clientsArray.count >0)
        {
            [self.clientsArray removeAllObjects];
        }
        
        for (NSArray * tempCustomer in clientTempArray)
        {
            NSString * customerCode =[tempCustomer objectAtIndex:0];
            NSString * customerName = [tempCustomer objectAtIndex:1];
//            NSString * level2Key = [tempCustomer objectAtIndex:3];
            
            Level2_Customer * customerObj = [[Level2_Customer alloc] initWithCustomerCode:customerCode andCustomerName:customerName andLevel2Key:@""];
            [self.clientsArray addObject:customerObj];
        }
    }
}

-(void) fetchAllJobsOfClientFromDB
{
    NSString * query = @"";
    
    TLAddJobTableViewCell *jobcell =  (TLAddJobTableViewCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *clientTextField = (UITextField*)[jobcell.contentView viewWithTag:101];
//    UITextField *level2TextField = (UITextField*)[jobcell.contentView viewWithTag:102];
    
    if (clientTextField.text.length>0)
    {
        query =[NSString stringWithFormat:@"SELECT * FROM pdd_level2 WHERE level2_key IN (select distinct level2_key from pdd_level2_customer where customer_code like '%%%@%%') AND level2_status = 1 ;",clientTextField.text];
    }
    else
    {
//        query = @"Select DISTINCT level2_key, level2_description,pdd_level2.*  from pdd_level2;";
          query = @"SELECT *  FROM pdd_level2 WHERE level2_status = 1;";
    }
    
    NSArray * jobTempArray =[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:query];
    
    if (self.jobsArray.count >0)
    {
        [self.jobsArray removeAllObjects];
    }
    
    if (jobTempArray.count >0)
    {
        for (NSArray * tempArray in jobTempArray)
        {
            NSString * level2Key = @"";
            NSString * level2Desc = @"";
            int level2Status = 0;
            NSString * closeDateString = @"";
            NSString * openDateString = @"";
            
//            if (clientTextField.text.length>0)
//            {
                level2Key = [tempArray objectAtIndex:1];
                level2Desc = [tempArray objectAtIndex:2];
                
                level2Status = [[tempArray objectAtIndex:3] intValue];
                closeDateString = [tempArray objectAtIndex:4];
                openDateString = [tempArray objectAtIndex:5];
//            NSLog(@"%@   %@", openDateString, closeDateString);
//            }
//            else
//            {
//                level2Key = [tempArray objectAtIndex:0];
//                level2Desc = [tempArray objectAtIndex:1];
//                
//            }
            
            Level2_Job * tempObj = [[Level2_Job alloc] initWithLevel2Key:level2Key andDescription:level2Desc syncedLastOnDate:@"" withLevel2Status:level2Status onOpeningDate:openDateString andClosingDate:closeDateString];
            
            [self.jobsArray addObject:tempObj];
        }
    }
}

-(void) fetchAllActivitesForSelectedJobFromDB
{
    NSString * query = @"";
    TLAddJobTableViewCell *jobcell =  (TLAddJobTableViewCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *jobTextField = (UITextField*)[jobcell.contentView viewWithTag:102];
    IQDropDownTextField * activityTxtField = (IQDropDownTextField *) [jobcell.contentView viewWithTag:104];
    
    if (jobTextField.text.length>0)
    {
        query = [NSString stringWithFormat:@"SELECT * FROM pdd_level3 WHERE labor_flag =1 AND level2_key = '%@' ORDER BY level3_key;", jobTextField.text];
        
        [self.activityArray removeAllObjects];
        [self.activityItemList removeAllObjects];
        [activityTxtField setItemList:self.activityItemList];
        
        NSArray * activityTempArray =[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:query];
        if (activityTempArray.count >0)
        {
            self.activityArray = [[NSMutableArray alloc] init];
            self.activityItemList = [[NSMutableArray alloc] init];
            
            for (NSArray * tempArray in activityTempArray)
            {
                NSString * level2KeyString    = [tempArray objectAtIndex:1];
                NSString * level3KeyString    = [tempArray objectAtIndex:2];
                NSString * level3Desc         = [tempArray objectAtIndex:3];
                NSString * openedDateString         = [tempArray objectAtIndex:4];
//                int        nonBillableFlag    = [[tempArray objectAtIndex:5] intValue];
                NSString * taskType           = [tempArray objectAtIndex:6];
                NSString * level3DescString   = [TLUtilities formatRequest:level3Desc];
                    int    laborFlag          = [[tempArray objectAtIndex:7] intValue];
                NSString * closeDateString    = [tempArray objectAtIndex:8];
                
                Level3_Activity * acitivity = [[Level3_Activity alloc]initWithLevel2Key:level2KeyString
                                                                              level3Key:level3KeyString
                                                                      level3Description:level3DescString
                                                                           openedOnDate:openedDateString
                                                                       withTaskTypeCode:taskType
                                                                              laborFlag:laborFlag
                                                                           andCloseDate:closeDateString];
                
                [self.activityArray addObject:acitivity];
                [self.activityItemList addObject:[NSString stringWithFormat:@"%@", level3KeyString]];
            }
            
            [activityTxtField setItemList:self.activityItemList];
            if (self.activityItemList.count == 1)
            {
                jobcell.activityNameTxtField.text = [self.activityItemList objectAtIndex:0];
                [jobcell.activityNameTxtField setSelectedItem:[self.activityItemList objectAtIndex:0]];
                
                if (showTask == 3) {
                    [self fetchAllTasksForSelectedJobFromDB];
                }
            }
        }
    }
}

-(void) fetchAllTasksForSelectedJobFromDB
{
    TLAddJobTableViewCell *jobCell =  (TLAddJobTableViewCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    IQDropDownTextField *activityTextField = (IQDropDownTextField*)[jobCell.contentView viewWithTag:104];
    
    TaskAndWorkTableViewCell *taskCell =  (TaskAndWorkTableViewCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    IQDropDownTextField *taskTextField = (IQDropDownTextField*)[taskCell.contentView viewWithTag:105];
    taskTextField.userInteractionEnabled = YES;
    [taskTextField setText:@""];
    
    if (activityTextField.text.length>0)
    {
        NSString * level3KeyString = activityTextField.text;
//        int indexOfActivityDesc = (int)[self.activityItemList indexOfObject:activityTextField.text];
//        if (indexOfActivityDesc!=-1) {
//            Level3_Activity * activityObj = [self.activityArray objectAtIndex:indexOfActivityDesc];
//            level3KeyString = activityObj.level3Key;
//        }
        
        NSString * query = [NSString stringWithFormat:@"SELECT * FROM pdd_task WHERE task_type in (select distinct task_type from pdd_level3 where level3_key = '%@' AND level2_key = '%@');",
                            level3KeyString,
                            self.selectedJobItem.level2Key];
        
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
            [taskTextField setItemList:self.tasksItemList];
            if (self.tasksItemList.count == 1)
            {
                taskCell.taskAndWorkTxtField.text = [self.tasksItemList objectAtIndex:0];
                [taskCell.taskAndWorkTxtField setSelectedItem:[self.tasksItemList objectAtIndex:0]];
            }
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
        self.workFuncItemList = [[NSMutableArray alloc] init];
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

#pragma mark - TLAddJobTableCell Delegate Methods

-(BOOL) checkTextFieldForEnteredValues:(UITextField *) textField
{
    BOOL isValidDataEntered = NO;
    
    NSString *rawString = textField.text;
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length] == 0)
    {
        // Text was empty or only whitespace.
        isValidDataEntered = NO;
        textField.text = @"";
    }
    else
    {
        isValidDataEntered = YES;
    }
    
    return isValidDataEntered;
}


-(void) searchClientOnlineForCustomer:(NSString *) customerCode andLevel2Code:(NSString *) level2Code
{
    [[WebservicesManager defaultManager] searchInfoOnServerForCustomer:customerCode andLevel2:level2Code usingURL:kTL_LEVEL_2_CUSTOMER_GET andCriteria:@"Level2CustomerCriteria" CompletionHandler:^(NSError *error, NSDictionary *user) {
        /*
         {
             "Entities": [
                 {
                 "CompanyCode": 2,
                 "CusomterName": "2U",
                 "CustomerCode": "2U001",
                 "LastSyncDate": "/Date(-62135575200000-0600)/",
                 "Level2Key": "2U-00-000"
                 },
                ],
             "Message": null,
             "ResponseType": 0
         }
         */
        if (!error && user)
        {
            int responseType = [[user valueForKey:@"ResponseType"] intValue];
            if (responseType == 0)
            {
                if (self.autoCompleteArray.count>0)
                {
                    [self.autoCompleteArray removeAllObjects];
                }
                NSArray * entitiesArray = [user valueForKey:@"Entities"];
                for (NSDictionary * tempDict in entitiesArray)
                {
                    NSString * query = [NSString stringWithFormat:@"INSERT INTO pdd_level2_customer VALUES(%i,'%@','%@','%@');",
                                        [[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE] intValue],
                                        [tempDict valueForKey:@"CustomerCode"],
                                        [tempDict valueForKey:@"CusomterName"],
                                        [tempDict valueForKey:@"Level2Key"]];
                    [[DataSyncHandler defaultHandler] executeQuery:query];
                }
                //Fetch Level2Job here as well.
                [self searchLevel2JobOnlineForCustomer:customerCode andLevel2Code:level2Code];
            }
            else
            {
                NSString * messageString = [user valueForKey:@"Message"];
                NSLog(@"%@",messageString);
            }
        }
    }];

}

-(void) clientSearchButtonTappedOn:(TLAddJobTableViewCell *)cell
{
    if ([TLUtilities verifyInternetAvailability])
    {
        if (cell.clientNameTxtField.text.length >0)
        {
            if ([self checkTextFieldForEnteredValues:cell.clientNameTxtField])
            {
                MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = WEBSERVICE_CALL_STATUS;
                [self searchClientOnlineForCustomer:cell.clientNameTxtField.text andLevel2Code:cell.jobNameTxtField.text];
            }
            else
            {
                NSString * clientFieldTitle = [self fetchTitleOfField:FIELD_CUSTOMER_DESCRIPTION];
                NSString * messageString = [NSString stringWithFormat:@"Please enter some keyword in %@ field to search", clientFieldTitle];
                
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:messageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            
        }
        else
        {
            // If the Client Field is empty and user pressed the Search Button.
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSString * clientFieldTitle = [self fetchTitleOfField:FIELD_CUSTOMER_DESCRIPTION];
            NSString * messageString = [NSString stringWithFormat:@"Please enter some keyword in %@ field to search", clientFieldTitle];
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:messageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:INTERNET_NOT_AVAILABLE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void) searchLevel2JobOnlineForCustomer:(NSString *) customerCode andLevel2Code:(NSString *) level2Code
{
    [[WebservicesManager defaultManager] searchInfoOnServerForCustomer:customerCode andLevel2:level2Code usingURL:kTL_LEVEL_2_GET andCriteria:@"Level2Criteria" CompletionHandler:^(NSError *error, NSDictionary *user) {
        
        BOOL success = [[DataSyncHandler defaultHandler] parseLevel2ListGetResponseData:user andError:error];
        if (success)
        {
            [[DataSyncHandler defaultHandler] saveFetchedLevel2ListFromServerInLocalDBAfterSynicing:YES];
        }
        [self searchLevel3AcitivtyOnlineForCustomer:customerCode andLevel2Code:level2Code];
        
        }];
}

-(void) searchLevel3AcitivtyOnlineForCustomer:(NSString *) customerCode andLevel2Code:(NSString *) level2Code
{
    /*
     {
         "Entities": [
             {
                 "BillableFlag": false,
                 "CompanyCode": 2,
                 "LaborFlag": 1,
                 "LastSyncDate": "/Date(-62135575200000-0600)/",
                 "Level2Description": "AT&T SEO Consultation Services",
                 "Level2Key": "ATT001-12-001",
                 "Level3Description": "Analytics",
                 "Level3Key": "Analytics",
                 "StrClosedDate": "",
                 "StrOpenDate": "2012-01-01 00:00:00",
                 "TaskTypeCode": 2
             },
     
         "Message": null,
         "ResponseType": 0
     }
     */
    
    
    [[WebservicesManager defaultManager] searchInfoOnServerForCustomer:customerCode andLevel2:level2Code usingURL:kTL_LEVEL_3_GET andCriteria:@"Level3Criteria" CompletionHandler:^(NSError *error, NSDictionary *user) {
        
            BOOL success = [[DataSyncHandler defaultHandler] parseparseLevel3ListGetResponseData:user andError:error];
            if (success)
            {
                [[DataSyncHandler defaultHandler] saveFetchedLevel3ListFromServerInLocalDBAfterSynicing:YES];
            }
        
            [self refreshArraysFromLocalDB];
            if (clientOrJobField == 1)
            {
                [self searchAutocompleteEntriesWithSubstring:customerCode forTextField:1];
            }
            else if (clientOrJobField == 2)
            {
                [self searchAutocompleteEntriesWithSubstring:level2Code forTextField:2];
            }
             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
}

-(void) jobSearchButtonTappedOn:(TLAddJobTableViewCell *)cell
{
    if ([TLUtilities verifyInternetAvailability])
    {
        /*
         {"Authentication":{"AuthenticationKey":"abc123","LoginID":"janet.urciuoli","Password":"sa"},"SearchCriteria":{"__type":"Level2Criteria","CustomerCode":"AARP001","level2Key":"a","SearchString":"","ResourceID":"451"}}
         */
        if (cell.jobNameTxtField.text.length>0)
        {
            if ([self checkTextFieldForEnteredValues:cell.jobNameTxtField])
            {
                MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = WEBSERVICE_CALL_STATUS;
                [self searchLevel2JobOnlineForCustomer:cell.clientNameTxtField.text andLevel2Code:cell.jobNameTxtField.text];
            }
            else
            {
                NSString * jobFieldTitle = [self fetchTitleOfField:TIME_BASED_LEVEL2_DESCRIPTION];
                NSString * messageString = [NSString stringWithFormat:@"Please enter some keyword in %@ field to search", jobFieldTitle];
                
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:messageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }

        }
        else
        {
            // If the Job Field is empty and user pressed the Search Button.
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSString * jobFieldTitle = [self fetchTitleOfField:TIME_BASED_LEVEL2_DESCRIPTION];
            NSString * messageString = [NSString stringWithFormat:@"Please enter some keyword in %@ field to search", jobFieldTitle];
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:messageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:INTERNET_NOT_AVAILABLE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
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
-(TLAddJobTableViewCell *) makeAddJobCellForTableView:(UITableView *) tableView atIndexPath:(NSIndexPath *) indexPath
{
    static NSString * cellIdentifier = @"TLAddJobTableViewCell";
    TLAddJobTableViewCell *  jobcell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    jobcell.delegate = self;
    jobcell.isPinned = NO;
    jobcell.clientNameTxtField.delegate = self;
    jobcell.jobNameTxtField.delegate = self;
    jobcell.activityNameTxtField.userInteractionEnabled = NO;
    
    [jobcell.clientNameTxtField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [jobcell.jobNameTxtField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    NSString * clientHeaderString = [self fetchTitleOfField:FIELD_CUSTOMER_DESCRIPTION];
    if ([settingsCustomerOption isEqual:@"By Name"])
    {
        clientHeaderString = [NSString stringWithFormat:@"%@ Description",clientHeaderString];
    }
    else if ([settingsCustomerOption isEqual:@"By Code"])
    {
        clientHeaderString = [NSString stringWithFormat:@"%@ Code",clientHeaderString];
    }
    
    NSString * jobHeaderString = [self fetchTitleOfField:TIME_BASED_LEVEL2_DESCRIPTION];
    if ([settingsJobOption isEqual:@"By Name"])
    {
        jobHeaderString = [NSString stringWithFormat:@"%@ Description",jobHeaderString];
    }
    else if ([settingsJobOption isEqual:@"By Code"])
    {
        jobHeaderString = [NSString stringWithFormat:@"%@ Code",jobHeaderString];
    }
    
    jobcell.clientNameTxtField.placeholder = clientHeaderString ;
    jobcell.jobNameTxtField.placeholder = jobHeaderString;
    jobcell.level3TitleLabel.text = [self fetchTitleOfField:TIME_BASED_LEVEL3_DESCRIPTION];
    
    jobcell.createdDateLabel.text = [TLUtilities ConvertDate:self.selectedDateString FromFormat:@"yyyy-MM-dd HH:mm:ss z" toFormat:@"EEEE MMMM dd, yyyy"];
    
    UIToolbar *toolbar2 = [[UIToolbar alloc] init];
    [toolbar2 setBarTintColor:[UIColor colorWithRed:238.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0]];
    [toolbar2 setBarStyle:UIBarStyleBlackOpaque];
    [toolbar2 sizeToFit];
    
    UILabel * titleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, 200.0f, 21.0f)];
    [titleLabel2 setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [titleLabel2 setBackgroundColor:[UIColor clearColor]];
    [titleLabel2 setTextColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [titleLabel2 setText:[NSString stringWithFormat:@"%@ List",[self fetchTitleOfField:TIME_BASED_LEVEL3_DESCRIPTION]]];
    [titleLabel2 setTextAlignment:NSTextAlignmentLeft];
    
    UIBarButtonItem *toolBarTitle2 = [[UIBarButtonItem alloc] initWithCustomView:titleLabel2];
    UIBarButtonItem *buttonflxible2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDoneForActivity = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    [buttonDoneForActivity setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    
    buttonDoneForActivity.tag = 1513;
    [toolbar2 setItems:[NSArray arrayWithObjects:toolBarTitle2,buttonflxible2,buttonDoneForActivity, nil]];
    jobcell.activityNameTxtField.inputAccessoryView = toolbar2;
    [jobcell.activityNameTxtField setItemList:self.activityItemList];
    [jobcell.activityNameTxtField setDropDownMode:IQDropDownModeTextPicker];
    
    return   jobcell;

}

-(TaskAndWorkTableViewCell *) makeTaskCellForTableView:(UITableView *) tableView atIndexPath:(NSIndexPath *) indexPath
{
    static NSString *cellIdentifier = @"TaskAndWorkTableViewCell";
    TaskAndWorkTableViewCell * taskCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    taskCell.headingLabel.text = @"Task";
    
    taskCell.taskAndWorkTxtField.userInteractionEnabled = NO;
    taskCell.taskAndWorkTxtField.isOptionalDropDown = YES;
    taskCell.taskAndWorkTxtField.tag = 105;
    
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
    [taskCell.taskAndWorkTxtField setDropDownMode:IQDropDownModeTextPicker];
    
    return taskCell;
}

-(JobHoursTableViewCell *) makeHoursCellForTableView:(UITableView *) tableView atIndexPath:(NSIndexPath *) indexPath
{
    static NSString *cellIdentifier = @"JobHoursTableViewCell";
    JobHoursTableViewCell * jobHourCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    jobHourCell.hoursStepper.value = 0;
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
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarTintColor:[UIColor colorWithRed:238.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0]];
    [toolbar setBarStyle:UIBarStyleBlackOpaque];
    [toolbar sizeToFit];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboardOfTextView)];
    [buttonDone setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    [toolbar setItems:[NSArray arrayWithObjects:buttonflexible,buttonDone, nil]];
    jobHourCell.hoursTxtField.inputAccessoryView = toolbar;
    
    return jobHourCell;
}

-(TaskAndWorkTableViewCell *) makeWorkFunctionCellForTableView:(UITableView *) tableView atIndexPath:(NSIndexPath *) indexPath
{
    static NSString *cellIdentifier = @"TaskAndWorkTableViewCell";
    TaskAndWorkTableViewCell * workFunctionCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    workFunctionCell.headingLabel.text = [self fetchTitleOfField:FIELD_RESOURCE_USAGE];
    
    workFunctionCell.taskAndWorkTxtField.isOptionalDropDown = YES;
    workFunctionCell.taskAndWorkTxtField.tag = 107;
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarTintColor:[UIColor colorWithRed:238.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0]];
    [toolbar setBarStyle:UIBarStyleBlackOpaque];
    [toolbar sizeToFit];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, 200.0f, 21.0f)];
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [titleLabel setText:[NSString stringWithFormat:@"%@ List",[self fetchTitleOfField:FIELD_RESOURCE_USAGE]]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    
    UIBarButtonItem *toolBarTitle = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    [buttonDone setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [toolbar setItems:[NSArray arrayWithObjects:toolBarTitle,buttonflexible,buttonDone, nil]];
    workFunctionCell.taskAndWorkTxtField.inputAccessoryView = toolbar;
    
     NSString * resUsageCode =[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_RES_USAGE_CODE];
     NSString * resUsageDesc = [self fetchWorkFuncDescriptionFromLocalDBForCode:resUsageCode];
    [workFunctionCell.taskAndWorkTxtField setText:resUsageDesc];
    
   
    [workFunctionCell.taskAndWorkTxtField setItemList:self.workFuncItemList];
     workFunctionCell.taskAndWorkTxtField.selectedItem = resUsageDesc;
    [workFunctionCell.taskAndWorkTxtField setDropDownMode:IQDropDownModeTextPicker];
    return workFunctionCell;
}

-(CommentAreaTableViewCell *) makeCommentsCellForTableView:(UITableView *) tableView atIndexPath:(NSIndexPath *) indexPath
{
    static NSString *cellIdentifier = @"CommentAreaTableViewCell";
    CommentAreaTableViewCell * commentsCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    commentsCell.tableView = self.mainTableView;
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarTintColor:[UIColor colorWithRed:238.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0]];
    [toolbar setBarStyle:UIBarStyleBlackOpaque];
    [toolbar sizeToFit];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboardOfTextView)];
    [buttonDone setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    [toolbar setItems:[NSArray arrayWithObjects:buttonflexible,buttonDone, nil]];
    commentsCell.commentsTxtView.inputAccessoryView = toolbar;
    
    return commentsCell;
}

#pragma mark - UITableViewDelegate + UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (tableView.tag == 1000)
    {
        static NSString *AutoCompleteRowIdentifier = @"AutoCompleteTableViewCell";
        AutoCompleteTableViewCell *  autoCompleteCell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier forIndexPath:indexPath];
        
        if (clientOrJobField == 1)
        {
            // Client TextField selected
            Level2_Customer * customer  = [self.autoCompleteArray objectAtIndex:indexPath.row];
            autoCompleteCell.codeLabel.text = customer.customerCode;
            autoCompleteCell.descriptionLabel.text = customer.customerName;
        }
        else if (clientOrJobField == 2)
        {
            // job TextField selected
            Level2_Job * job  = [self.autoCompleteArray objectAtIndex:indexPath.row];
            autoCompleteCell.codeLabel.text = job.level2Key;
            autoCompleteCell.descriptionLabel.text = job.level2Description;
            
        }
        return autoCompleteCell;
    }
    else {
        
        long int sectionNumber = indexPath.section;
            switch (sectionNumber)
            {
                case 0:
                {
                    cell = [self makeAddJobCellForTableView:tableView atIndexPath:indexPath];
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
    }
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if (tableView.tag == 1000) {
        return 1;
    }
    else
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
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 1000)
    {
        NSLog(@"%i", (int)self.autoCompleteArray.count);
        return self.autoCompleteArray.count;
    }
    else
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView.tag == 1000)
    {
        return 20.0;
    }
    else
        return 1.0;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = nil;
    if (tableView.tag == 1000)
    {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 20.0)];
        headerView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0];
        UILabel * codeLable = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 150.0, 20.0)];
        codeLable.backgroundColor = [UIColor clearColor];
        codeLable.font = [UIFont boldSystemFontOfSize:14.0];
        codeLable.textColor = [UIColor blackColor];
        codeLable.text = @"Code";
        
        UILabel * descLable = [[UILabel alloc] initWithFrame:CGRectMake(200.0, 0.0, 150.0, 20.0)];
        descLable.backgroundColor = [UIColor clearColor];
        descLable.font = [UIFont boldSystemFontOfSize:14.0];
        descLable.textColor = [UIColor blackColor];
        descLable.text = @"Description";
        
        [headerView addSubview:codeLable];
        [headerView addSubview:descLable];
    }
    else
    {
        if (section != 0)
        {
            headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 1.0)];
            headerView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0];
        }
        
    }
    return headerView;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float rowHeight = 0.0;

    if (tableView.tag == 1000)
    {
        return 44.0;
    }
    else {
        switch (indexPath.section)
        {
            case 0:
            {
                rowHeight = 175.0;
            }
                break;
            case 1:
            {
                rowHeight = 50.0;
            }
                break;
            case 2:
            {
             
                if ((showTask == 0 || showTask == 1) && (showWorkFunc == 0 || showWorkFunc == 1)) // Task & WorkFunc both not visible
                {
                    rowHeight = 170.0;
                }
                else
                    rowHeight = 50.0;
            }
                break;
            case 3:
            {
                if ((showTask == 0 || showTask == 1) || (showWorkFunc == 0 || showWorkFunc == 1)) // Task OR WorkFunc  not visible
                {
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
    }
    return rowHeight;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView.tag == 1000)
    {
        TLAddJobTableViewCell *jobcell =  (TLAddJobTableViewCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UITextField *clientTextField = (UITextField*)[jobcell.contentView viewWithTag:101];
        UITextField * jobTextField = (UITextField *) [jobcell.contentView viewWithTag:102];
        IQDropDownTextField * activityTextField = (IQDropDownTextField *) [jobcell.contentView viewWithTag:104];

        if (clientOrJobField == 1)
        {
            // Client TextField selected
            Level2_Customer * customer  = [self.autoCompleteArray objectAtIndex:indexPath.row];
            clientTextField.text = customer.customerCode;
            
            self.selectedClientItem = customer;
            clientFieldHasValue = YES;
            [jobTextField setText:@""];
            [activityTextField setText:@""];
            [jobTextField becomeFirstResponder];
        }
        else if (clientOrJobField == 2)
        {
            // job TextField selected
            Level2_Job * job  = [self.autoCompleteArray objectAtIndex:indexPath.row];
            jobTextField.text = job.level2Key;
            
            jobFieldHasValue = YES;
            self.selectedJobItem = job;
            [activityTextField setUserInteractionEnabled:YES];
            [activityTextField setText:@""];
            [self fetchAllActivitesForSelectedJobFromDB];
        }
        
        TaskAndWorkTableViewCell *taskCell =  (TaskAndWorkTableViewCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        IQDropDownTextField *taskTextField = (IQDropDownTextField*)[taskCell.contentView viewWithTag:105];
        [taskTextField setText:@""];
        
        self.autoCompleteTableView.hidden = YES;
        [self.mainTableView setScrollEnabled:YES];
        [self.view endEditing:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
