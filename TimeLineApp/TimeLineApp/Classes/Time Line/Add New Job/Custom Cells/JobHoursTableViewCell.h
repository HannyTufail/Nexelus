//
//  JobHoursTableViewCell.h
//  TimeLineApp
//
//  Created by Mac on 12/23/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JobHoursTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *hoursTxtField;
@property (weak, nonatomic) IBOutlet UIStepper *hoursStepper;

- (IBAction)hoursStepperValueChanged:(id)sender;

@end
