//
//  AddReportViewController.m
//  Nexelus
//
//  Created by Mac on 5/21/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import "AddReportViewController.h"
#import "AddImageViewController.h"
#import "ImageProcessingViewController.h"

@interface AddReportViewController ()

@end

@implementation AddReportViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeCustomBackButtonWithLogo];
    [self makeBottomViewVisible];
    [self configureRadioButtons];
    [self customizeTextView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Custom Methods

-(void) customizeTextView
{
    UIColor *borderColor = [UIColor colorWithRed:193.0/255.0 green:193.0/255.0 blue:193.0/255.0 alpha:1.0];
    
    self.commentsTxtView.layer.borderColor = borderColor.CGColor;
    self.commentsTxtView.layer.borderWidth = 0.7;
    self.commentsTxtView.layer.cornerRadius = 5.0;
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
    self.navigationItem.title = @"Add New Report";
}

-(void)backButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) makeBottomViewVisible
{
    if (self.isFromPaste)
    {
        [self.addBottomView setHidden:YES];
        [self.pasteBottomView setHidden:NO];
    }
    else
    {
        [self.addBottomView setHidden:NO];
        [self.pasteBottomView setHidden:YES];
    }
}

-(void) configureRadioButtons
{
    for (DLRadioButton *radioButton in self.radioButtons)
    {
        radioButton.ButtonIcon = [UIImage imageNamed:@"radioButton"];
        radioButton.ButtonIconSelected = [UIImage imageNamed:@"radioButtonSelected"];
    }
}

#pragma mark - IBAction Methods

- (IBAction)cancelButtonTpd:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)receiptButtonTpd:(id)sender
{
    AddImageViewController * imageViewController = [[AddImageViewController alloc] initWithNibName:@"AddImageViewController" bundle:nil];
    [self.navigationController pushViewController:imageViewController animated:YES];
}

- (IBAction)noReceiptButtonTpd:(id)sender
{

}

- (IBAction)proceedButtonTpd:(id)sender {
}
@end
