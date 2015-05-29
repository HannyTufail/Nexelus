//
//  JobHoursTableViewCell.m
//  TimeLineApp
//
//  Created by Mac on 12/23/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "JobHoursTableViewCell.h"

@implementation JobHoursTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)hoursStepperValueChanged:(id)sender {
    
    [self.hoursTxtField resignFirstResponder];
    UIStepper * stepper = (UIStepper *) sender;
    [self.hoursTxtField setText:[NSString stringWithFormat:@"%.2f",stepper.value]];
}

#pragma mark - UITextField Delegate Methods.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    if (textField == self.hoursTxtField)
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

        NSString *expression = @"^-?([0-9]+)?(\\.([0-9]{1,2})?)?$";
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, [newString length])];
        if (numberOfMatches == 0)
            return NO;
    }
    
    return YES;
}
- (void) textFieldDidChange:(id)sender {
    UITextField *textField = (UITextField *)sender;
    
    if ([textField.text floatValue] > self.hoursStepper.maximumValue)
    {
        textField.text = [NSString stringWithFormat:@"%.2f",self.hoursStepper.maximumValue];
    }
    else if ([textField.text floatValue]< self.hoursStepper.minimumValue)
    {
        textField.text = [NSString stringWithFormat:@"%.2f",self.hoursStepper.minimumValue];
    }
    self.hoursStepper.value = [textField.text doubleValue];
}

@end
