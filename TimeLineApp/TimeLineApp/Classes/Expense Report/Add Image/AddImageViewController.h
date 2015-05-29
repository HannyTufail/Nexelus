//
//  AddImageViewController.h
//  Nexelus
//
//  Created by Mac on 5/27/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface AddImageViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>


 


@property (weak, nonatomic) IBOutlet UIImageView *imageView;



- (IBAction)processButtonTpd:(id)sender;
- (IBAction)discardButtonTpd:(id)sender;

@end
