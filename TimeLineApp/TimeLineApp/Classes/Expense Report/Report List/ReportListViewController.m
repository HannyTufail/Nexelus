//
//  ReportListViewController.m
//  Nexelus
//
//  Created by Mac on 5/11/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import "ReportListViewController.h"
#import "EditReportViewController.h"
#import "AddReportViewController.h"
#import "TLConstants.h"

@interface ReportListViewController ()
{
    UIButton *topDropdownButton;
}
@property (retain, nonatomic) NSMutableArray * dataSource;
@property (retain, nonatomic) NSMutableArray * checkedReportsArray;
@property (retain, nonatomic) NSMutableArray * draftsMenuArray;


@end

@implementation ReportListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nibForReportsCell = [UINib nibWithNibName:@"ReportListTableViewCell" bundle:nil];
    [[self tableView] registerNib:nibForReportsCell forCellReuseIdentifier:@"ReportListTableViewCell"];
    
    self.dataSource = [[NSMutableArray alloc] init];
    self.checkedReportsArray = [[NSMutableArray alloc] init];
    self.draftsMenuArray = [[NSMutableArray alloc] initWithObjects:@"Draft",@"Submitted",@"Rejected",@"Approved",@"Finance Approved", nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar setHidden:NO];
    
    [self setupNavigationBarUI];
    [self makeCustomLeftBarbuttonForNavigation];
    [self makeDraftsPickerList];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Custom Methods

-(void) makeCustomLeftBarbuttonForNavigation
{
    UIImage *iconImage = [UIImage imageNamed:@"logo.png"];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, iconImage.size.width, iconImage.size.height)];
    [leftButton setBackgroundImage:iconImage forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

-(void)setupNavigationBarUI
{
    UIImage *dropDownImage = [UIImage imageNamed:@"icn_actions.png"];
    
    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonAction:)];
    
    topDropdownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [topDropdownButton addTarget:self action:@selector(showOptionsViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [topDropdownButton setContentMode:UIViewContentModeScaleAspectFit];
    [topDropdownButton setBackgroundImage:dropDownImage forState:UIControlStateNormal];
    topDropdownButton.frame = CGRectMake(0, 0, 22.0, 22.0);
    UIBarButtonItem *dropDownBarButton = [[UIBarButtonItem alloc] initWithCustomView:topDropdownButton];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    buttonflexible.width = -16;
    [self.navigationItem setRightBarButtonItems:@[addButton,buttonflexible,dropDownBarButton]];
    self.navigationItem.title = @"Expense Report";
}

-(void)showOptionsViewButtonAction:(id)sender
{
    UIImage *downImage = [UIImage imageNamed:@"icn_actions.png"];
    UIImage *upImage = [UIImage imageNamed:@"icn_actions_up.png"];
    
    if (_optionsView.hidden)
    {
        [topDropdownButton setBackgroundImage:upImage forState:UIControlStateNormal];
        [self slidingViewOnVisibilityOfOptionsView:YES];
    }
    else if (!_optionsView.hidden)
    {
        [topDropdownButton setBackgroundImage:downImage forState:UIControlStateNormal];
        [self slidingViewOnVisibilityOfOptionsView:NO];
    }
    _optionsView.hidden = !_optionsView.hidden;
}

-(void) makeDraftsPickerList
{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarTintColor:[UIColor colorWithRed:238.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0]];
    [toolbar setBarStyle:UIBarStyleBlackOpaque];
    [toolbar sizeToFit];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, 200.0f, 21.0f)];
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [titleLabel setText:@"Report Types"];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    
    UIBarButtonItem *toolBarTitle = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    [buttonDone setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [toolbar setItems:[NSArray arrayWithObjects:toolBarTitle,buttonflexible,buttonDone, nil]];
    self.draftsMenuTxtField.inputAccessoryView = toolbar;
    
    [self.draftsMenuTxtField setItemList:self.draftsMenuArray];
    [self.draftsMenuTxtField setSelectedRow:1 animated:YES];
    [self.draftsMenuTxtField setDropDownMode:IQDropDownModeTextPicker];
}

-(void)doneClicked:(UIBarButtonItem*)button
{
    [self.view endEditing:YES];
}

-(void) slidingViewOnVisibilityOfOptionsView:(BOOL) upOrDown
{
    if (upOrDown) // Options view is Visible, slide the Drafts and table view downwards
    {
        
    }
    else // Options view is NOT Visible, slide the Drafts and table view upwards
    {
        
    }
}

#pragma mark - OptionsView Methods

- (IBAction)submitButtonTpd:(id)sender {
}

- (IBAction)submitAllButtonTpd:(id)sender {
}

- (IBAction)deleteButtonTpd:(id)sender {
}

- (IBAction)copyButtonTpd:(id)sender {
}

- (IBAction)pasteButtonTpd:(id)sender
{
    if (!_optionsView.hidden)
    {
        [self showOptionsViewButtonAction:nil];
    }
    
    AddReportViewController * addReportController = [[AddReportViewController alloc] initWithNibName:@"AddReportViewController" bundle:[NSBundle mainBundle]];
    addReportController.isFromPaste = YES;
    [self.navigationController pushViewController:addReportController animated:YES];
}


#pragma mark - IBAction Methods

-(IBAction)addButtonAction:(id)sender
{
    
    if (!_optionsView.hidden)
    {
        [self showOptionsViewButtonAction:nil];
    }
    
    AddReportViewController * addReportController = [[AddReportViewController alloc] initWithNibName:@"AddReportViewController" bundle:[NSBundle mainBundle]];
    addReportController.isFromPaste = NO;
    [self.navigationController pushViewController:addReportController animated:YES];

    
}
- (IBAction)draftsButtonAction:(id)sender
{
    [self.draftsMenuTxtField becomeFirstResponder];
}

- (IBAction)menuButtonAction:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Main Menu",@"Sign Out", nil];
    sheet.delegate = self;
    [sheet showInView:self.view];

}


#pragma mark - UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 102102)
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
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{    
    switch (buttonIndex)
    {
        
        case 0:
        {
            // Main Menu
            [self goBackToMainMenu];
        }
            break;
        case 1:
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
-(void) goBackToMainMenu
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)logoutUser
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CONFIRMATION_REQUIRED_TITLE message:LOG_OUT_MESSAGE delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue to Sign out",nil];
    alert.delegate = self;
    alert.tag = 102102;
    [alert show];
}

#pragma mark - TLReportListTableViewCellDelegate Methods
-(void) checkButtonTappedOnReportCell:(ReportListTableViewCell *)cell
{
    
}


#pragma mark - UITableView Delegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88.0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;//self.dataSource.count;
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
    return 1.0;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 1.0)];
    headerView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"ReportListTableViewCell";
    ReportListTableViewCell *  cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell.countLabel setText:[NSString stringWithFormat:@"%li", (long)indexPath.row+1]];
    [cell.reportInfoLabel setText:[NSString stringWithFormat:@"Expense Report Details here."]];
    [cell.amountLabel setText:@"45.36"];
    [cell.dateLabel setText:@"15-27 May,2015"];
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

    // Checked Logic
    if (self.checkedReportsArray.count >0)
    {
//        BOOL objectPresent = [self.checkedReportsArray containsObject:tempObj];
//        if (objectPresent) {
//            cell.isChecked = YES;
//            [cell.checkedImageView setImage:[UIImage imageNamed:@"icn_selected"]];
//            [cell.checkmarkButton setSelected:YES];
//        }
//        else
//        {
//            cell.isChecked = NO;
//            [cell.checkedImageView setImage:[UIImage imageNamed:@"icn_unselected"]];
//            [cell.checkmarkButton setSelected:NO];
//        }
    }
    else
    {
        cell.isChecked = NO;
        [cell.checkedImageView setImage:[UIImage imageNamed:@"icn_unselected"]];
        [cell.checkmarkButton setSelected:NO];
    }
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditReportViewController * editReportController = [[EditReportViewController alloc] initWithNibName:@"EditReportViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:editReportController animated:YES];
}




@end
