//
//  SettingsTopTableViewCell.m
//  Nexelus
//
//  Created by Mac on 2/22/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import "SettingsTopTableViewCell.h"

@implementation SettingsTopTableViewCell
@synthesize delegate;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - IBAction Methods

- (IBAction)clientButtonTapped:(id)sender
{
    [self.delegate settingClientButtonTappedOn:self];
    [self.customerTextField becomeFirstResponder];
}
- (IBAction)jobButtonTapped:(id)sender
{
    [self.delegate settingsJobButtonTappedOn:self];
    [self.projectTextField becomeFirstResponder];
}



@end
