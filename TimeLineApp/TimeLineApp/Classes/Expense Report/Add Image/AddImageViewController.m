//
//  AddImageViewController.m
//  Nexelus
//
//  Created by Mac on 5/27/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import "AddImageViewController.h"
#import "ImageProcessingViewController.h"

@interface AddImageViewController ()
{
    BOOL imageFetched;
    UIImage * originalImage;
}
@end

@implementation AddImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeCustomLeftBarbuttonForNavigation];
    imageFetched = NO;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!imageFetched) {
        [self openCamera];
    }
    
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
    self.navigationItem.title = @"Image Preview";
}

-(void) openCamera
{
    imageFetched = NO;
      BOOL cameraOpened = [self launchCameraControllerFromViewController:self usindDelegate:self];
    
}

-(BOOL) launchCameraControllerFromViewController:(UIViewController *) viewController usindDelegate:(id <UINavigationControllerDelegate, UIImagePickerControllerDelegate>) delegate
{
    BOOL isCameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    if (!isCameraAvailable || (delegate == nil) || (viewController == nil)) {
        NSLog(@"Camera Not Available");
        return NO;
    }
    
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    picker.allowsEditing = NO;
    picker.delegate = delegate;
    
    [viewController presentViewController:picker animated:YES completion:nil];
    
    return YES;
}

#pragma mark - ImagePicker Delegate Methods

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    imageFetched = NO;
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString * mediaTypes = [info objectForKey:UIImagePickerControllerMediaType];
    
    if (CFStringCompare((CFStringRef)mediaTypes, kUTTypeImage, 0) == kCFCompareEqualTo) {
        originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
    }
        
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.imageView setImage:originalImage];
    imageFetched = YES;
}


#pragma mark - IBAction Methods

- (IBAction)processButtonTpd:(id)sender
{
    imageFetched = NO;
    ImageProcessingViewController * imageProcessViewController = [[ImageProcessingViewController alloc] initWithNibName:@"ImageProcessingViewController" bundle:nil];
    [imageProcessViewController setTempImage:originalImage];
    [self.navigationController pushViewController:imageProcessViewController animated:YES];
}

- (IBAction)discardButtonTpd:(id)sender {
    self.imageView.image = nil;
    [self openCamera];
}
@end
