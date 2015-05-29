//
//  TLLoginViewController.m
//  TimeLineApp
//
//  Created by Hanny on 12/9/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "TLLoginViewController.h"
//#import "HomeViewController.h"
#import "MainMenuViewController.h"
#import "TLConstants.h"
#import "TLUtilities.h"
#import "WebservicesManager.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"


@interface TLLoginViewController ()

@end

@implementation TLLoginViewController

@synthesize resourceObject;
@synthesize isChecked;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:UDKEY_USER_HAS_LOGGED_IN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setNeedsStatusBarAppearanceUpdate];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:YES];
    
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";
    
    NSString * username = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_CLIENT_USERNAME];
    NSString * password = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_PASSWORD];
    
    BOOL rememberMe =[[NSUserDefaults standardUserDefaults] boolForKey:UDKEY_REMEMBER_ME];
    if (rememberMe)
    {
        self.usernameTextField.text = username;
        self.passwordTextField.text = password;
        [self.rememberMeButton setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
        self.isChecked = YES;
    }
    else
    {
        [self.rememberMeButton setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
        self.isChecked = NO;
        if (username.length >0) {
            self.usernameTextField.text =  username;
            [self.passwordTextField becomeFirstResponder];
        }
        else
            [self.usernameTextField becomeFirstResponder];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void) pushHomeViewController
//{
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    HomeViewController *homeController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
//    [self.navigationController pushViewController:homeController animated:YES];
//}

-(void) pushMainMenuViewController
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    MainMenuViewController *mainMenuController = [[MainMenuViewController alloc] initWithNibName:@"MainMenuViewController" bundle:nil];
    [self.navigationController pushViewController:mainMenuController animated:YES];
}

#pragma mark - UITextField delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSCharacterSet * cs;
    if (textField == self.usernameTextField) {
            cs = [[NSCharacterSet characterSetWithCharactersInString:LOGIN_ACCEPTABLE_CHARACTERS] invertedSet];
    }
    else if(textField == self.passwordTextField)
    {
        cs = [[NSCharacterSet characterSetWithCharactersInString:PASSWORD_ACCEPTABLE_CHARACTERS] invertedSet];
    }
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return (([string isEqualToString:filtered])&&(newLength <= USER_ID_CHARACTERS_LIMIT));
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameTextField) {
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField)
    {
        [textField resignFirstResponder];
    }
    return YES;
}
#pragma mark - DataSyncHandler Delegate Methods

-(void) dataSyncedSuccessfully
{
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    // Push HomeVC
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UDKEY_HAS_FETCHED_ENTIRE_DATA];
//    [self pushHomeViewController];
    [self pushMainMenuViewController];
}

-(void) dataRefreshedSuccessfullyAgainstLogin
{
//    [self pushHomeViewController];
    [self pushMainMenuViewController];
}

-(void) permanentLineAddedSuccessfully
{
    NSLog(@"Permanent Line Added Successfully from Login Screen");
}

-(void) permanentLineNotAddedDueToError
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Permanent Line NOT Added Successfully from Login Screen");
}

-(void) permanentLineDeletedSuccessfully
{
    NSLog(@"Permanent Line Deleted Successfully from Login Screen");
}

-(void) permanentLineNotDeletedDueToError
{
    NSLog(@"Permanent Line NOT Deleted Successfully from Login Screen");
}


#pragma mark - UIAlertView Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1517)
    {
        if (buttonIndex == 1)
        {
           [[NSUserDefaults standardUserDefaults] setBool:NO forKey:UDKEY_HAS_FETCHED_ENTIRE_DATA];
            [[DataSyncHandler defaultHandler] removeDBFile];
            [self removeDataFromUserDefaults];
            [self signInWithUserIDIntoApp];
        }
    }
    else if (alertView.tag == 1213)
    {
        NSString * messageString = alertView.message;
        if ([messageString containsString:@"The authentication key is not valid"])
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:UDKEY_AUTHENTICATION_KEY];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:UDKEY_HAS_PROVIDED_CLIENT_ID];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate showAlertForAuthenticationKey];
        }
        else
        {
            // Even if there is an issue with Internet/Response Code. right now,
            // Check if User has already Synced data once then login using Local DB
            // Else Show him an alert that He needs to connect to Internet.
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:UDKEY_HAS_FETCHED_ENTIRE_DATA])
            {
                [self validateUserCredentialsWithLocalDB];
            }
            else
            {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:INTERNET_NOT_AVAILABLE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}


#pragma mark - IBAction Methods.

-(void) removeDataFromUserDefaults
{
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:UDKEY_CLIENT_USERNAME];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:UDKEY_PASSWORD];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:UDKEY_COMPANY_CODE];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:UDKEY_CLIENT_NAME];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:UDKEY_RESOURCE_ID];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:UDKEY_ORG_UNIT_CODE];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:UDKEY_LOCATION_CODE];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:UDKEY_RES_USAGE_CODE];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:UDKEY_IS_USING_ACTIVE_DIRECTORY];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:UDKEY_USER_HAS_LOGGED_IN];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:UDKEY_REMEMBER_ME];
    
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:UDKEY_SETTINGS_CUSTOMER_OPTION];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:UDKEY_SETTINGS_PROJECT_OPTION];
    [[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:UDKEY_SHOW_TASKS];
    [[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:UDKEY_SHOW_RES_USAGE];
    
    [[NSUserDefaults standardUserDefaults] synchronize];

}

-(void) saveDataInUserDefaults
{
    NSString * clientName = [NSString stringWithFormat:@"%@ %@", self.resourceObject.firstName, self.resourceObject.lastName];
    
    [[NSUserDefaults standardUserDefaults] setValue:self.usernameTextField.text forKey:UDKEY_CLIENT_USERNAME];
    [[NSUserDefaults standardUserDefaults] setValue:self.passwordTextField.text forKey:UDKEY_PASSWORD];
    [[NSUserDefaults standardUserDefaults] setValue:self.resourceObject.companyCode forKey:UDKEY_COMPANY_CODE];
    [[NSUserDefaults standardUserDefaults] setValue:clientName forKey:UDKEY_CLIENT_NAME];
    [[NSUserDefaults standardUserDefaults] setValue:self.resourceObject.resourceID forKey:UDKEY_RESOURCE_ID];
    [[NSUserDefaults standardUserDefaults] setValue:self.resourceObject.orgUnitCode forKey:UDKEY_ORG_UNIT_CODE];
    [[NSUserDefaults standardUserDefaults] setValue:self.resourceObject.locationCode forKey:UDKEY_LOCATION_CODE];
    [[NSUserDefaults standardUserDefaults] setValue:self.resourceObject.resourceUsageCode forKey:UDKEY_RES_USAGE_CODE];
    [[NSUserDefaults standardUserDefaults] setBool:self.resourceObject.isUsingActiveDirectory forKey:UDKEY_IS_USING_ACTIVE_DIRECTORY];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UDKEY_USER_HAS_LOGGED_IN];
    [[NSUserDefaults standardUserDefaults] setBool:self.isChecked forKey:UDKEY_REMEMBER_ME];
    
    
    NSString * customerOptionString = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_SETTINGS_CUSTOMER_OPTION];
    NSString * projectOptionString = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_SETTINGS_PROJECT_OPTION];
    if (!customerOptionString || [customerOptionString isEqualToString:@""]) {
        customerOptionString = @"By Code";
    }
    if (!projectOptionString || [projectOptionString isEqualToString:@""]) {
        projectOptionString = @"By Code";
    }
    [[NSUserDefaults standardUserDefaults] setValue:customerOptionString forKey:UDKEY_SETTINGS_CUSTOMER_OPTION];
    [[NSUserDefaults standardUserDefaults] setValue:projectOptionString forKey:UDKEY_SETTINGS_PROJECT_OPTION];
    
    int showTask = self.resourceObject.showTask;
    int showWorkFunc = self.resourceObject.showWorkFunction;
    
    [[NSUserDefaults standardUserDefaults] setInteger:showTask forKey:UDKEY_SHOW_TASKS];
    [[NSUserDefaults standardUserDefaults] setInteger:showWorkFunc forKey:UDKEY_SHOW_RES_USAGE];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) stopCallsAndShowAlert
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:UDKEY_HAS_FETCHED_ENTIRE_DATA];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:INTERNET_NOT_AVAILABLE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void) generateCallsForWebservices
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [DataSyncHandler defaultHandler].delegate = self;
    [DataSyncHandler defaultHandler].isDelegateSetFromLogin = YES;
    [DataSyncHandler defaultHandler]._syncTypes = forLogin;
    
    [[DataSyncHandler defaultHandler] fetchLevel2CustomerListFromServerWithCompletionHandler:^(BOOL success) {
        
        if (success)
        {
            NSLog(@"Level2Customer List fetched Successfully!");
            [[DataSyncHandler defaultHandler] fetchLevel2ListFromServerWithCompletionHandler:^(BOOL success) {
                
                if (success)
                {
                    NSLog(@"Level2 List fetched Successfully!");
                    
                    [[DataSyncHandler defaultHandler] fetchLevel3ListFromServerWithCompletionHandler:^(BOOL success) {
                        
                        if (success)
                        {
                            NSLog(@"Level3 List fetched Successfully!");
                            
                            [[DataSyncHandler defaultHandler] fetchTransactionsListFromServerWithCompletionHandler:^(BOOL success) {
                                
                                if (success)
                                {
                                    NSLog(@"Transactions List fetched Successfully!");
                                    
                                    [[DataSyncHandler defaultHandler] fetchTaskListFromServerWithCompletionHandler:^(BOOL success) {
                                        
                                        if (success)
                                        {
                                            NSLog(@"Tasks List fetched Successfully!");
                                            
                                            [[DataSyncHandler defaultHandler] fetchResUsageListFromServerWithCompletionHandler:^(BOOL success) {
                                                
                                                if (success)
                                                {
                                                    NSLog(@"ResUsage List fetched Successfully!");
                                                    
                                                    [[DataSyncHandler defaultHandler] fetchPermanentLineListFromServerWithCompletionHandler:^(BOOL success) {
                                                        
                                                        if (success)
                                                        {
                                                            NSLog(@"Permanent Lines List fetched Successfully!");
                                                            
                                                            [[DataSyncHandler defaultHandler] fetchSysNamesListFromServerWithCompletionHandler:^(BOOL success) {
                                                                
                                                                if (success)
                                                                {
                                                                    NSLog(@"Sys Names List fetched Successfully!");
                                                                    
                                                                    [[DataSyncHandler defaultHandler] syncDataFetchedFromServerWithLocalDB];
                                                                }
                                                                else
                                                                {
                                                                    [self stopCallsAndShowAlert];
                                                                }
                                                                
                                                            }];
                                                        }
                                                        else
                                                        {
                                                            [self stopCallsAndShowAlert];
                                                        }
                                                        
                                                    }];
                                                }
                                                else
                                                {
                                                    [self stopCallsAndShowAlert];
                                                }
                                                
                                            }];

                                        }
                                        else
                                        {
                                            [self stopCallsAndShowAlert];
                                        }
                                    }];

                                }
                                else
                                {
                                    [self stopCallsAndShowAlert];
                                }
                            }];

                        }
                        else
                        {
                            [self stopCallsAndShowAlert];
                        }
                     }];

                }
                else
                {
                    [self stopCallsAndShowAlert];
                }
            }];

        }
        else
        {
            [self stopCallsAndShowAlert];
        }
    }];
    
}

- (IBAction)signInButtonAction:(id)sender
{
    BOOL isErrorOccured = NO;
    NSString *msgString = @"";
    
    if (self.usernameTextField.text.length == 0) {
        isErrorOccured = YES;
        msgString = USER_ID_REQUIRED;
        [self.usernameTextField becomeFirstResponder];
        
    } else if (self.passwordTextField.text.length == 0) {
        isErrorOccured = YES;
        msgString = PASSWORD_REQUIRED;
        [self.passwordTextField becomeFirstResponder];
    }
    
    if (isErrorOccured)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                            message:msgString
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else{
        // Check If Username is the same or changed. IFF (changed) Prompt the user that entire DB will be deleted for new username.
        // Validate the username and password with the webservice if(internetAvailable),
        // store the verified username/password in UserDefaults and Local DB
        // push the HomeViewController
        
        [self.view endEditing:YES];
        
        NSString * previousUsername = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_CLIENT_USERNAME];
        
        if (previousUsername && ![self.usernameTextField.text isEqualToString:previousUsername])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:CONFIRMATION_REQUIRED_TITLE
                                                                message:SWITCH_USER
                                                               delegate:self
                                                      cancelButtonTitle:@"NO"
                                                      otherButtonTitles:@"YES",nil];
            alertView.tag = 1517;
            [alertView show];
        }
        else
        {
            [self signInWithUserIDIntoApp];
        }
    }
}

-(void) signInWithUserIDIntoApp
{
    if ([TLUtilities verifyInternetAvailability])
    {
        MBProgressHUD * hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:UDKEY_HAS_FETCHED_ENTIRE_DATA]) // First Time Login
        {
            hud.labelText = @"Initial setup and configuration….";
            hud.detailsLabelText = @"This may take few minutes depending upon your connection speed";
        }
        else // eachTime Login
        {
            hud.labelText = @"Authenticating...Please wait";
            hud.detailsLabelText = @"";
        }
        // The case when internet is Available.
        [[WebservicesManager defaultManager] requestLoginWithEmail:self.usernameTextField.text password:self.passwordTextField.text completionHandler:^(NSError *error, NSDictionary *user)
        {
            if (!error && user)
            {
                /*
                 
                 {
                 "Entities": [
                     {
                         "CompanyCode": 2,
                         "IsUsingAD": 0,
                         "LastSyncDate": "/Date(-62135575200000-0600)/",
                         "LocationCode": "NY",
                         "NameFirst": "Janet",
                         "NameLast": "Urciuoli",
                         "NewPassword": null,
                         "OldPassword": null,
                         "OrgUnitCode": "C&T-C&T Admin",
                         "ResUsageCode": "ADMIN",
                         "ResourceID": "451",
                         "ShowTask": 1,
                         "ShowWorkFunction": 2
                     }
                 ],
                 "Message": null,
                 "ResponseType": 0,
                 "SyncDate": "2015-01-28 06:15:29"
                 }
                 */
                
                
                [self.view endEditing:YES];
                NSString * messageString = [user valueForKey:@"Message"];
                
                int responseType = [[user valueForKey:@"ResponseType"] intValue];
                if (responseType == 0)
                {
                    self.resourceObject = [[DataSyncHandler defaultHandler] makeResourceObjectofUser:self.usernameTextField.text andPassword:self.passwordTextField.text FromServerDictionary:user];
                    [self saveDataInUserDefaults];
                    
                    //Fetch UserSettings From Server and Save in LocalDB and after it PUSH HOME VC
                    [[DataSyncHandler defaultHandler] fetchUserSettingsFromServerWithCompletionHandler:^(BOOL success) {
                        
                        if (![[NSUserDefaults standardUserDefaults] boolForKey:UDKEY_HAS_FETCHED_ENTIRE_DATA])
                        {
                            // Save the user Credentials in LocalDB in Table "pdd_resource".
                            [[DataSyncHandler defaultHandler]insertResourceValuesInLocalDB:self.resourceObject];
                            [[DataSyncHandler defaultHandler]updateLastSyncDateOfRefresh];
                            
                            [self generateCallsForWebservices];
                        }
                        else
                        {
                            // doing these changes as per request from QA. 11th Feb, 2015.
                            // Now call Refresh Service on Login eachtime.
                            
                            [DataSyncHandler defaultHandler].delegate = self;
                            [DataSyncHandler defaultHandler].isDelegateSetFromLogin = YES;
                            [DataSyncHandler defaultHandler]._syncTypes = forLogin;
                            [[DataSyncHandler defaultHandler] syncLocalDBTransactionsOnlyWithServerAndFetchLatest];
                        }                        
                    }];
                }
                else
                {
                    
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    if ([messageString containsString:@"The authentication key is not valid"]) {
                     
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:messageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        alert.delegate = self;
                        alert.tag = 1213;
                        [alert show];
                    }
                    else
                    {
                    
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:messageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                }
            }
            else
            {
                // Even if there is an issue with Internet right now,
                // Check if User has already Synced data once then login using Local DB
                // Else Show him an alert that He needs to connect to Internet.
                if ([[NSUserDefaults standardUserDefaults] boolForKey:UDKEY_HAS_FETCHED_ENTIRE_DATA])
                {
                    [self validateUserCredentialsWithLocalDB];
                }
                else
                {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:INTERNET_NOT_AVAILABLE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }
        }];
    }
    else
    {
        // The case when internet is not Available.
        // Check if Entire data has been fetched already.
        // Check If localDB has the username and password stored ? validate from LocalDB and store it in there : Store it in the LocalDB
        // Store the credentials in the NSUserDefaults
        // Dismiss the ActivityView
        // Push HomeViewController
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:UDKEY_HAS_FETCHED_ENTIRE_DATA])
        {
            MBProgressHUD * hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Authenticating...Please Wait";
            [self validateUserCredentialsWithLocalDB];
        }
        else
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:INTERNET_NOT_AVAILABLE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }

        
    }
}

-(void) validateUserCredentialsWithLocalDB
{
    self.resourceObject = [[DataSyncHandler defaultHandler] verifyUserCredentialsWithLocalDB];
    if (self.resourceObject)
    {
        if ([self.usernameTextField.text isEqualToString:self.resourceObject.loginId] && [self.passwordTextField.text isEqualToString:self.resourceObject.password])
        {
            [self saveDataInUserDefaults];
//            [self pushHomeViewController];
            [self pushMainMenuViewController];
        }
        else
        {
            // Invalid credentials case
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            BOOL isErrorOccured = NO;
            NSString *msgString = @"";
            
            if (![self.usernameTextField.text isEqualToString:self.resourceObject.loginId]) {
                isErrorOccured = YES;
                msgString = USER_ID_REQUIRED;
                [self.usernameTextField becomeFirstResponder];
                
            } else if (![self.passwordTextField.text isEqualToString:self.resourceObject.password]) {
                isErrorOccured = YES;
                msgString = LOGIN_INVALID_PASSWORD;
                [self.passwordTextField becomeFirstResponder];
            }
            
            if (isErrorOccured) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                                    message:msgString
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
    }
    else
    {
        
        // if user changes the UserID offline and tries to login with it and there is no Data synced of that user.
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:INTERNET_NOT_AVAILABLE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];

        
    }
}

- (IBAction)rememberMeButtonTapped:(id)sender
{
    UIImage *checkedImage = [UIImage imageNamed:@"checkbox_checked.png"];
    UIImage *uncheckedImage = [UIImage imageNamed:@"checkbox_unchecked.png"];
    
    if(self.isChecked) {
        [_rememberMeButton setImage:uncheckedImage forState:UIControlStateNormal];
    }
    else {
        [_rememberMeButton setImage:checkedImage forState:UIControlStateNormal];
    }
    self.isChecked = !self.isChecked;
}

@end
