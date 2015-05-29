//
//  ReportListTableViewCell.m
//  Nexelus
//
//  Created by Mac on 5/11/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import "ReportListTableViewCell.h"

@implementation ReportListTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)checkedButtonTpd:(id)sender
{
    UIImage *checkedImage = [UIImage imageNamed:@"icn_selected"];
    UIImage *uncheckedImage = [UIImage imageNamed:@"icn_unselected"];
    
    UIImage * tempImage = nil;
    if(_isChecked)
    {
        tempImage = uncheckedImage;
    }
    else
    {
        tempImage = checkedImage;
    }
    [_checkedImageView setImage:tempImage];
    _isChecked = !_isChecked;
    
    [self.delegate checkButtonTappedOnReportCell:self];
}
@end
