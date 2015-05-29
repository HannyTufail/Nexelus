//
//  TLSettingsViewController.m
//  TimeLineApp
//
//  Created by Hanny on 12/12/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "TLSettingsViewController.h"
#import "TLConstants.h"
#import "DataSyncHandler.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "SettingsPasswordTableViewCell.h"
#import "TLUtilities.h"


#define kOFFSET_FOR_KEYBOARD 80.0

@interface TLSettingsViewController ()
{
    int selectedTextFieldNumber;
}
@end

@implementation TLSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    UINib *nibForSettingsTopCell = [UINib nibWithNibName:@"SettingsTopTableViewCell" bundle:nil];
    [[self mainTableView] registerNib:nibForSettingsTopCell forCellReuseIdentifier:@"SettingsTopTableViewCell"];
    
    UINib *nibForSettingsPasswordCell = [UINib nibWithNibName:@"SettingsPasswordTableViewCell" bundle:nil];
    [[self mainTableView] registerNib:nibForSettingsPasswordCell forCellReuseIdentifier:@"SettingsPasswordTableViewCell"];
    
    
    self.title = @"User Settings";
    
    selectedTextFieldNumber = 0;
    
    [self makeCustomBackButtonWithLogo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) makeCustomBackButtonWithLogo
{
    UIImage *iconImage = [UIImage imageNamed:@"logo.png"];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, iconImage.size.width, iconImage.size.height)];
    [leftButton setBackgroundImage:iconImage forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
}

#pragma mark - SettingsTopTableViewCellDelegate Methods

-(void) settingClientButtonTappedOn:(SettingsTopTableViewCell *)cell
{
    selectedTextFieldNumber = 1;
}
-(void) settingsJobButtonTappedOn:(SettingsTopTableViewCell *)cell
{
    selectedTextFieldNumber = 2;
}


#pragma mark - Making Cell Methods

-(SettingsTopTableViewCell *) makeSettingsTopCellForTableView:(UITableView *) tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"SettingsTopTableViewCell";
    SettingsTopTableViewCell *  topCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    topCell.delegate = self;
    
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarTintColor:[UIColor colorWithRed:238.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0]];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    [buttonDone setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [toolbar setItems:[NSArray arrayWithObjects:buttonflexible,buttonDone, nil]];
    
    topCell.customerTextField.inputAccessoryView = toolbar;
    topCell.projectTextField.inputAccessoryView = toolbar;
    
    topCell.customerTextField.isOptionalDropDown = NO;
    [topCell.customerTextField setItemList:[NSArray arrayWithObjects:@"By Name",@"By Code", nil]];
    [topCell.customerTextField setDropDownMode:IQDropDownModeTextPicker];
    
    topCell.projectTextField.isOptionalDropDown = NO;
    [topCell.projectTextField setItemList:[NSArray arrayWithObjects:@"By Name",@"By Code", nil]];
    [topCell.projectTextField setDropDownMode:IQDropDownModeTextPicker];

    
    NSString * jobHeaderString = [self fetchTitleOfField:TIME_BASED_LEVEL2_DESCRIPTION];
    topCell.level2HeadingLabel.text = [NSString stringWithFormat:@"Search %@", jobHeaderString];
    
    NSString * customerOptionString = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_SETTINGS_CUSTOMER_OPTION];
    NSString * projectOptionString = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_SETTINGS_PROJECT_OPTION];
    
    topCell.customerTextField.text = (!customerOptionString)?@"By Name":customerOptionString;
    topCell.projectTextField.text = (!projectOptionString)?@"By Name":projectOptionString;
    
    topCell.customerTextField.selectedItem = topCell.customerTextField.text;
    topCell.projectTextField.selectedItem = topCell.projectTextField.text;
    
    return topCell;
}

-(SettingsPasswordTableViewCell *) makeSettingsPasswordCellForTableView:(UITableView *) tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"SettingsPasswordTableViewCell";
    SettingsPasswordTableViewCell *  passwordCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    return passwordCell;
}

#pragma mark - UITableViewDelegate + UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     UITableViewCell *cell;
    long int sectionNumber = indexPath.section;
    switch (sectionNumber)
    {
        case 0:
        {
            cell = [self makeSettingsTopCellForTableView:tableView atIndexPath:indexPath];
            break;
        }
        case 1:
        {
            cell = [self makeSettingsPasswordCellForTableView:tableView atIndexPath:indexPath];
            break;
        }
        default:
            break;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    float height = 0.0;
    if (section != 0)
    {
        height = 1.0;
    }
    return height;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = nil;

    if (section != 0)
    {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 1.0)];
        headerView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0];
    }
    return headerView;
}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    int sectionsCount = 0;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:UDKEY_IS_USING_ACTIVE_DIRECTORY])
    {
        sectionsCount = 1;
    }
    else{
        sectionsCount = 2;
    }
    return sectionsCount;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 210.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Keyboard Show/Hide observing Methods

-(void)keyboardWillShow
{
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide
{
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)setViewMovedUp:(BOOL)movedUp
{
    if (selectedTextFieldNumber == 1 || selectedTextFieldNumber == 2) {
        
    }
    else
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; // if you want to slide up the view
        
        CGRect rect = self.view.frame;
        if (movedUp)
        {
            // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
            // 2. increase the size of the view so that the area behind the keyboard is covered up.
            rect.origin.y -= kOFFSET_FOR_KEYBOARD;
            rect.size.height += kOFFSET_FOR_KEYBOARD;
        }
        else
        {
            // revert back to the normal state.
            rect.origin.y += kOFFSET_FOR_KEYBOARD;
            rect.size.height -= kOFFSET_FOR_KEYBOARD;
        }
        self.view.frame = rect;
        
        [UIView commitAnimations];
    }
    
}

#pragma mark - IBAction Methods

-(NSString *) fetchTitleOfField:(NSString *) fieldName
{
    NSString *query = [NSString stringWithFormat:@"SELECT display_name FROM pdm_sys_names WHERE field_name = '%@';",fieldName];
    NSString * titleString = [[[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:query] lastObject] lastObject];
    return titleString;
}

-(void)doneClicked:(UIBarButtonItem*)button
{
    [self.view endEditing:YES];
}

- (IBAction)CancelButtonTapped:(id)sender {
 
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)SaveButtonTapped:(id)sender
{
    SettingsTopTableViewCell *topcell =  (SettingsTopTableViewCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSString * selectedOptionForCustomer = topcell.customerTextField.text;
    NSString * selectedOptionForProject = topcell.projectTextField.text;
    
    [[NSUserDefaults standardUserDefaults] setValue:selectedOptionForCustomer forKey:UDKEY_SETTINGS_CUSTOMER_OPTION];
    [[NSUserDefaults standardUserDefaults] setValue:selectedOptionForProject forKey:UDKEY_SETTINGS_PROJECT_OPTION];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:UDKEY_IS_USING_ACTIVE_DIRECTORY])
    {
        SettingsPasswordTableViewCell *passwordcell =  (SettingsPasswordTableViewCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        
        if (passwordcell.oldPasswordTextField.text.length >0 || passwordcell.newerPasswordTextField.text.length >0 || passwordcell.confirmPasswordTextField.text.length >0)
        {
            NSString * alertMessageString = @"";
            BOOL changePasswordNow = YES;
            if (!passwordcell.oldPasswordTextField.text.length >0)
            {
                changePasswordNow = NO;
                alertMessageString = SETTINGS_OLD_PASSWORD_CHECK_MESSAGE;
            }
            else if (!passwordcell.newerPasswordTextField.text.length >0)
            {
                changePasswordNow = NO;
                alertMessageString = SETTINGS_NEW_PASSWORD_CHECK_MESSAGE;
            }
            else if (!passwordcell.confirmPasswordTextField.text.length >0)
            {
                changePasswordNow = NO;
                alertMessageString = SETTINGS_CONFIRM_PASSWORD_CHECK_MESSAGE;
            }
            
            if (changePasswordNow)
            {
                if (![TLUtilities verifyInternetAvailability])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:INTERNET_NOT_AVAILABLE delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                }
                else
                {
                    NSString * oldPasswordString = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_PASSWORD];
                    if ([passwordcell.oldPasswordTextField.text isEqualToString:oldPasswordString])
                    {
                        if (![passwordcell.newerPasswordTextField.text isEqualToString:passwordcell.confirmPasswordTextField.text])
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:SETTINGS_CONFIRM_INVALID_MESSAGE delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                            [alert show];
                        }
                        else
                        {
                            [self changePasswordOnlineWithNewPassword:passwordcell.newerPasswordTextField.text];
                        }
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:SETTINGS_OLD_INVALID_MESSAGE delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                        [alert show];
                    }
                }
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:alertMessageString delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
        }
        else
        {
            // Only Search Search Client and Job criteria updated and left the Screen.
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        // Only Search Search Client and Job criteria updated and left the Screen.
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void) changePasswordOnlineWithNewPassword:(NSString *) newPasswordString;
{
    MBProgressHUD * hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = SETTING_UPDATING_PASSWORD;
    
    [[DataSyncHandler defaultHandler] changePassword:newPasswordString withCompletionHandler:^(BOOL success, NSString *errMsg)
     {
         if (success)
         {
             // Update Password in Local DB and send it to Server as well.
             [self updatePasswordInLocalDBAndUserDefaults:newPasswordString];
             
             hud.labelText = SETTING_PASSWORD_UPDATED;
             double delayInSeconds = 1.0;
             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
             dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                });
         }
         else{
             hud.labelText = errMsg;
             double delayInSeconds = 1.0;
             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
             dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                });
         }
     }];
}

-(void) updatePasswordInLocalDBAndUserDefaults:(NSString *) newPass
{
    [[NSUserDefaults standardUserDefaults] setValue:newPass forKey:UDKEY_PASSWORD];
    
    NSString * userID = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_CLIENT_USERNAME];
    NSString * key = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_AUTHENTICATION_KEY];
    NSString * companyCode = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE];
    NSString * resourceID = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_RESOURCE_ID];

    
    NSString * updateQuery = [NSString stringWithFormat:@"UPDATE pdd_resource SET login_id = '%@',password = '%@',key = '%@' WHERE company_code = %i AND resource_id = '%@';",
                              userID,
                              newPass,
                              key,
                              [companyCode intValue],
                              resourceID];
    [[DataSyncHandler defaultHandler] executeQuery:updateQuery];
}


@end
