//
//  TaskAndWorkTableViewCell.m
//  TimeLineApp
//
//  Created by Mac on 12/23/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "TaskAndWorkTableViewCell.h"

@implementation TaskAndWorkTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)taskAndWorkFuncButtonAction:(id)sender
{
    [self.taskAndWorkTxtField becomeFirstResponder];
}

@end
