//
//  ImageProcessingViewController.m
//  Nexelus
//
//  Created by Mac on 5/28/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import "ImageProcessingViewController.h"

@interface ImageProcessingViewController ()

@end

@implementation ImageProcessingViewController
@synthesize tempImage;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeCustomLeftBarbuttonForNavigation];
    [self customizeTextView];
    
    [self.imageView setImage:tempImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods

-(void) customizeTextView
{
    UIColor *borderColor = [UIColor colorWithRed:193.0/255.0 green:193.0/255.0 blue:193.0/255.0 alpha:1.0];
    
    self.textView.layer.borderColor = borderColor.CGColor;
    self.textView.layer.borderWidth = 0.7;
    self.textView.layer.cornerRadius = 5.0;
}

-(void) makeCustomLeftBarbuttonForNavigation
{
    UIImage *iconImage = [UIImage imageNamed:@"logo.png"];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, iconImage.size.width, iconImage.size.height)];
    [leftButton setBackgroundImage:iconImage forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = barButtonItem;
    self.navigationItem.title = @"Image Processing";
}

- (IBAction)retakeButtonTpd:(id)sender {
    self.imageView.image = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)acceptButtonTpd:(id)sender {
}

- (IBAction)acceptAndTakeAnotherButtonTpd:(id)sender {
}
@end
