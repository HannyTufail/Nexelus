//
//  ImageProcessingViewController.h
//  Nexelus
//
//  Created by Mac on 5/28/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageProcessingViewController : UIViewController

@property (retain, nonatomic) UIImage * tempImage;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *dateTxtField;
@property (weak, nonatomic) IBOutlet UITextField *amountTxtField;
@property (weak, nonatomic) IBOutlet UITextView *textView;






- (IBAction)retakeButtonTpd:(id)sender;
- (IBAction)acceptButtonTpd:(id)sender;
- (IBAction)acceptAndTakeAnotherButtonTpd:(id)sender;





@end
