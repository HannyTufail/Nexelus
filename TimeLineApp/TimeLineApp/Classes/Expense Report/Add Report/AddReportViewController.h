//
//  AddReportViewController.h
//  Nexelus
//
//  Created by Mac on 5/21/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DLRadioButton.h"

@interface AddReportViewController : UIViewController

@property(nonatomic) BOOL isFromPaste;

@property (weak, nonatomic) IBOutlet UITextField *reportNameTxtField;

@property (weak, nonatomic) IBOutlet UITextField *expenseNumberTxtField;

@property (weak, nonatomic) IBOutlet UITextView *commentsTxtView;

@property (weak, nonatomic) IBOutlet UIView *addBottomView;

@property (weak, nonatomic) IBOutlet UIView *pasteBottomView;



- (IBAction)cancelButtonTpd:(id)sender;
- (IBAction)receiptButtonTpd:(id)sender;
- (IBAction)noReceiptButtonTpd:(id)sender;
- (IBAction)proceedButtonTpd:(id)sender;


@property (strong, nonatomic) IBOutletCollection(DLRadioButton) NSArray *radioButtons;

@end
