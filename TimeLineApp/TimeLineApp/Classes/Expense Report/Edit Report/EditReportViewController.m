//
//  EditReportViewController.m
//  Nexelus
//
//  Created by Mac on 5/19/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import "EditReportViewController.h"
#import "AssignActivityViewController.h"

@interface EditReportViewController ()

@property (retain, nonatomic) NSMutableArray * dataSource;
@property (retain, nonatomic) NSMutableArray * checkedTransactionsArray;

@end

@implementation EditReportViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nibForTransactionsCell = [UINib nibWithNibName:@"TransactionTableViewCell" bundle:nil];
    [[self tableView] registerNib:nibForTransactionsCell forCellReuseIdentifier:@"TransactionTableViewCell"];
    
    self.dataSource = [[NSMutableArray alloc] init];
    self.checkedTransactionsArray = [[NSMutableArray alloc] init];
    [self makeCustomBackButtonWithLogo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupNavigationBarUI];
}

#pragma mark - Custom Methods

-(void)setupNavigationBarUI
{
    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonAction:)];
    
    [self.navigationItem setRightBarButtonItem:addButton];
    self.navigationItem.title = @"Transactions";
}

-(void)addButtonAction:(id)sender
{
    
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
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TLReportListTableViewCellDelegate Methods
-(void) checkButtonTappedOnReportCell:(TransactionTableViewCell *)cell
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
    static NSString * cellIdentifier = @"TransactionTableViewCell";
    TransactionTableViewCell *  cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell.transactionInfoLabel setText:[NSString stringWithFormat:@"Transaction Number %li", (long)indexPath.row]];
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Checked Logic
    if (self.checkedTransactionsArray.count >0)
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
    
}



#pragma mark - IBAction Methods

- (IBAction)selectAllButtonTpd:(id)sender {
}

- (IBAction)assignActivityButtonTpd:(id)sender {
    
    AssignActivityViewController * assignController = [[AssignActivityViewController alloc] initWithNibName:@"AssignActivityViewController" bundle:nil];
}

- (IBAction)additionalImageButtonTpd:(id)sender {
}
@end
