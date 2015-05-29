//
//  PendingJobsViewController.m
//  Nexelus
//
//  Created by Mac on 2/24/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import "PendingJobsViewController.h"
#import "PendingJobTableViewCell.h"
#import "PendingJobWithoutDescTableViewCell.h"
#import "TLSettingsViewController.h"
#import "TLBillableHoursViewController.h"
#import "DataSyncHandler.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "Transaction.h"
#import "TLConstants.h"
#import "TLUtilities.h"

@interface PendingJobsViewController ()

@end

@implementation PendingJobsViewController

@synthesize calendarDatesArray, calendarDatesHoursArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Pending Transactions";
    
    UINib *nibForPendingJobCell = [UINib nibWithNibName:@"PendingJobTableViewCell" bundle:nil];
    [[self mainTableView] registerNib:nibForPendingJobCell forCellReuseIdentifier:@"PendingJobTableViewCell"];
    
    UINib *nibFornibForPendingJobCellForDescTaskCell = [UINib nibWithNibName:@"PendingJobWithoutDescTableViewCell" bundle:nil];
    [[self mainTableView] registerNib:nibFornibForPendingJobCellForDescTaskCell forCellReuseIdentifier:@"PendingJobWithoutDescTableViewCell"];
    
    
    refreshControl = [[UIRefreshControl alloc] init];
    [self.mainTableView addSubview:refreshControl];
    refreshControl.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    maxHoursWeekForAddEditScreen = 0.0;
    
    self.dataSourceArray = [[NSMutableArray alloc] init];
    
    [self fetchPendingTransactionsOfCurrentSelectedDate];
    [self makeCustomBackButtonWithLogo];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataRefreshedSuccessfullyAgainstPullToRefresh) name:kSyncCompletionNotification object:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) makeCustomBackButtonWithLogo
{
    UIImage *iconImage = [UIImage imageNamed:@"back_logo.png"];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, iconImage.size.width, iconImage.size.height)];
    [leftButton setBackgroundImage:iconImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(navigationBackBarButtonTpd) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
}

-(void) navigationBackBarButtonTpd
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) updatePendingTransactionsCount
{
    NSString *query = [NSString stringWithFormat:@"SELECT pld_transaction.* , level2_description FROM pld_transaction join pdd_level2 on pld_transaction.level2_key=pdd_level2.level2_key WHERE sync_status = 0 AND deleted = 0  AND unit != 0;"];
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

#pragma mark - DataSyncHandler Delegate Methods

-(void) dataRefreshedSuccessfullyAgainstPullToRefresh
{
    [refreshControl endRefreshing];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    [self fetchPendingTransactionsOfCurrentSelectedDate];
    [self updatePendingTransactionsCount];
    [self.mainTableView reloadData];
}

-(void) permanentLineAddedSuccessfully
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Permanent Line Added Successfully Message from Pending Transaction Class.");
}
-(void) permanentLineNotAddedDueToError
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Permanent Line NOT Added Message from Pending Transaction Class.");
}
-(void) permanentLineDeletedSuccessfully
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Permanent Line Deleted Successfully Message from Pending Transaction Class.");
}

-(void) permanentLineNotDeletedDueToError
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Permanent Line NOT Deleted Message from Pending Transaction Class.");
}

#pragma mark - TLEditJobViewControllerDelegate Methods

-(void) editingJobInfoWasFinished
{
    [self fetchPendingTransactionsOfCurrentSelectedDate];
    [self updatePendingTransactionsCount];
}

#pragma mark - LocalDB methods implementation

-(Transaction *) makeAnTransactoinItemFromDBColums:(NSArray *) columsDataArray
{
    NSString *  transactID = [columsDataArray objectAtIndex:1];
    NSString *  level2Key = [columsDataArray objectAtIndex:2];
    NSString * level3Key = [columsDataArray objectAtIndex:3];
    NSString * appliedDate = [columsDataArray objectAtIndex:4];
    int transactType = [[columsDataArray objectAtIndex:5] intValue];
    NSString *  resourceID = [columsDataArray objectAtIndex:6];
    NSString *  resUsageCode = [columsDataArray objectAtIndex:7];
    float unit = [[columsDataArray objectAtIndex:8] floatValue];
    NSString *  locationCode = [columsDataArray objectAtIndex:9];
    NSString *  orgUnit = [columsDataArray objectAtIndex:10];
    NSString *  taskCode = [columsDataArray objectAtIndex:11];
    NSString *  comments = [columsDataArray objectAtIndex:12];
    int nonBillableFlag = [[columsDataArray objectAtIndex:13] intValue];
    int submittedFlag = [[columsDataArray objectAtIndex:14] intValue];
    NSString *  submittedDate = [columsDataArray objectAtIndex:15];
    int approvalFlag = [[columsDataArray objectAtIndex:16] intValue];
    int syncStatus = [[columsDataArray objectAtIndex:17] intValue];
    int deleted = [[columsDataArray objectAtIndex:18] intValue];
    NSString *  modifiedDate = [columsDataArray objectAtIndex:19];
    
    NSString * timeStampString = [columsDataArray objectAtIndex:20];
    int errorFlag = [[columsDataArray objectAtIndex:21]intValue];
    int errorCode = [[columsDataArray objectAtIndex:22] intValue];
    NSString * errorDescriptionString = [columsDataArray objectAtIndex:23];
    
    NSString *  level2Desc = [columsDataArray objectAtIndex:24];
    
    Transaction * transactObj = [[Transaction alloc] initTransactionWithID:transactID transactionType:transactType ofJob:level2Key activity:level3Key taskCode:taskCode orgUnit:orgUnit comments:comments resource:resourceID resUsageCode:resUsageCode appliedOn:appliedDate modifiedOn:modifiedDate submittedOn:submittedDate withApprovalFlags:approvalFlag submitFlag:submittedFlag nonBillableFlag:nonBillableFlag andSyncedFlag:syncStatus Units:unit andLocationCode:locationCode];
    transactObj.level2Description = level2Desc;
    transactObj.deletedFlag = deleted;
    transactObj.timeStamp = timeStampString;
    transactObj.errorFlag = errorFlag;
    transactObj.errorCode = errorCode;
    transactObj.errorDescription = errorDescriptionString;
    
    return transactObj;
}

-(void) fetchPendingTransactionsOfCurrentSelectedDate
{
    if (self.dataSourceArray.count >0)
    {
        [self.dataSourceArray removeAllObjects];
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT pld_transaction.* , level2_description FROM pld_transaction join pdd_level2 on pld_transaction.level2_key=pdd_level2.level2_key WHERE sync_status = 0 AND deleted = 0 AND unit != 0;"];
   NSArray * pendingTransactionsArray = [[DataSyncHandler defaultHandler].dbManager loadDataFromDB:query];
    
   self.pendingTransactionsLabel.text = [NSString stringWithFormat:@"%@ \nPending Transaction(s): %i",[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_LAST_SYNC_DATE],(int)pendingTransactionsArray.count];

    
    if (pendingTransactionsArray.count >0)
    {
        self.NoTransactionsLabel.hidden = YES;
        for (NSArray * tempArray in pendingTransactionsArray)
        {
            Transaction * transactObj = [self makeAnTransactoinItemFromDBColums:tempArray];
            [self.dataSourceArray addObject:transactObj];
        }
    }
    else
    {
        self.NoTransactionsLabel.hidden = NO;
    }
    
    // Reload the table view.
    [self.mainTableView reloadData];
}

#pragma mark - UITableViewDelegate + UITableViewDataSource

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    Transaction * tempObj = [self.dataSourceArray objectAtIndex:indexPath.row];
    NSString * errorDescriptionString = tempObj.errorDescription;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:errorDescriptionString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Transaction * tempObj = [self.dataSourceArray objectAtIndex:indexPath.row];
    NSString * sortByString = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_SORT_BY]];
    
    static NSString * cellIdentifier = @"";
    PendingJobTableViewCell *  cell = nil;
    // Set the Frames of Activity and hours Label if sortByString!= 3 or there is no description available.
    
    if ([sortByString isEqualToString:@""] || [sortByString isEqualToString:@"1"]  || [sortByString isEqualToString:@"2"] || [tempObj.level2Description isEqualToString:@""])
    {
        cellIdentifier = @"PendingJobWithoutDescTableViewCell";
    }
    else
    {
        cellIdentifier = @"PendingJobTableViewCell";
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
   
    
    
    // setting accessoryview
    if (tempObj.errorFlag > 0) {
        cell.accessoryView = nil;
        cell.accessoryType =  UITableViewCellAccessoryDetailButton;
    }
    else
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(0.0, 0.0, 22.0, 22.0);
        
        button.frame = frame;   // match the button's size with the image size
        cell.backgroundColor = [UIColor clearColor];
        cell.accessoryView = button;
    }
    
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
    
    //Change the colors of the Cells based on SubmittedFlag = 1, color rgb(215,228,188)
    // ApporvalFlag = 1 Color = rgb(209,209,220)
    // ApprovalFlag = 2 Color = rgb(255,111,111)
    // If Approval and Submitted both flags are 1 then ApprovalFlag would have preference.
    
    if ([tempObj.transactionID isEqualToString:@""]){ //isPermanentLine && tempObj.units == 0.00) {
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    }
    else
    {
        if (tempObj.submitFlag == 1)
        {
            cell.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:228.0/255.0 blue:188.0/255.0 alpha:1.0];
        }
        else{
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
  
    /*
    Transaction * tempObj = [self.dataSourceArray objectAtIndex:indexPath.row];
    
    //Change the colors of the Cells based on SubmittedFlag = 1, color rgb(215,228,188)
    // ApporvalFlag = 1 Color = rgb(209,209,220)
    // ApprovalFlag = 2 Color = rgb(255,111,111)
    // If Approval and Submitted both flags are 1 then ApprovalFlag would have preference.
    
    if ([tempObj.transactionID isEqualToString:@""]){ //isPermanentLine && tempObj.units == 0.00) {
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    }
    else
    {
        if (tempObj.submitFlag == 1)
        {
            cell.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:228.0/255.0 blue:188.0/255.0 alpha:1.0];
        }
        else{
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
     */
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.dataSourceArray count];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Transaction * tempObj = [self.dataSourceArray objectAtIndex:indexPath.row];
    TLEditJobViewController *controller = [[TLEditJobViewController alloc] initWithNibName:@"TLEditJobViewController" bundle:nil];
    
    controller._editViewCalled = isFromPendingScreen;
    controller.delegate = self;
    NSString * appliedDateString = [TLUtilities ConvertDate:tempObj.appliedDate FromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM-dd HH:mm:ss z"];
    controller.selectedDateString = [NSString stringWithFormat:@"%@", appliedDateString];
    [controller setTransactionItem:tempObj];
    controller.maxHoursWeek = maxHoursWeekForAddEditScreen;
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -  UIActionsheet Methods

-(void) makeCustomBarButtonForBack:(BOOL) backButton
{
    UIImage *iconImage = [UIImage imageNamed:@"logo.png"];
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
    
    for (NSString * valueString in self.calendarDatesHoursArray)
    {
        if ([valueString floatValue] != 0.00)
        {
            shouldShowCharView = YES;
            break;
        }
        else
            shouldShowCharView = NO;
    }
    if (shouldShowCharView) {
        TLBillableHoursViewController *controller = [[TLBillableHoursViewController alloc] initWithNibName:@"TLBillableHoursViewController" bundle:nil];
        controller.titlesArray = self.calendarDatesArray;
        controller.valuesArray = self.calendarDatesHoursArray;
        
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
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)logoutUser
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CONFIRMATION_REQUIRED_TITLE message:LOG_OUT_MESSAGE delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue to Logout",nil];
    alert.delegate = self;
    alert.tag = 1021;
    [alert show];
}

#pragma mark - UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1021)
    {
        if(buttonIndex == 1)
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:UDKEY_USER_HAS_LOGGED_IN];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
            // Show Settings
            [self openSettings];
        }
            break;
        case 2:
        {
            // Main Menu
            [self goBackToMainMenu];
        }
            break;
        case 3:
        {
            // Logout User
            [self logoutUser];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - IBAction Methods

- (IBAction)menuButtonAction:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Billable Hours Chart",@"User Settings",@"Main Menu",@"Sign Out", nil];
    sheet.delegate = self;
    [sheet showInView:self.view];
}




@end
