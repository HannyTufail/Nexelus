//
//  SettingsPasswordTableViewCell.m
//  Nexelus
//
//  Created by Mac on 2/22/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import "SettingsPasswordTableViewCell.h"
#import "TLConstants.h"

@implementation SettingsPasswordTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - UITextField delegate Methods
-(void) textFieldDidBeginEditing:(UITextField *)textField
{
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:PASSWORD_ACCEPTABLE_CHARACTERS] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return (([string isEqualToString:filtered])&&(newLength <= PASSWORD_CHARACTERS_LIMIT));
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.oldPasswordTextField)
    {
        [self.oldPasswordTextField resignFirstResponder];
        [self.newerPasswordTextField becomeFirstResponder];
    }
    else if (textField == self.newerPasswordTextField) {
        [self.newerPasswordTextField resignFirstResponder];
        [self.confirmPasswordTextField becomeFirstResponder];
    }
    else if (textField == self.confirmPasswordTextField)
    {
        [self.confirmPasswordTextField resignFirstResponder];
    }
    return YES;
}



@end
