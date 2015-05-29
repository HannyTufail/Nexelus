//
//  TLTasksTableViewCell.m
//  TimeLineApp
//
//  Created by Hanny on 12/10/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "TLTasksTableViewCell.h"

@implementation TLTasksTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)pinButtonAction:(id)sender {
    
    UIImage *pinnedImage = [UIImage imageNamed:@"pin.png"];
    UIImage *unpinnedImage = [UIImage imageNamed:@"unpin.png"];
    
    UIImage *tempImage = nil;
    if(_isPinned){
        tempImage = unpinnedImage;
    }
    else{
        tempImage = pinnedImage;
    }
    
    [_pinImageView setImage:tempImage];
    
    _isPinned = !_isPinned;
    [self.delegate pinButtonTappedOnTaskCell:self];
    
}
- (IBAction)checkmarkButtonAction:(id)sender {
    
    UIImage *checkedImage = [UIImage imageNamed:@"icn_selected"];
    UIImage *uncheckedImage = [UIImage imageNamed:@"icn_unselected"];
    
    UIImage * tempImage = nil;
    if(_isChecked){
        tempImage = uncheckedImage;
    }
    else{
        tempImage = checkedImage;
    }
    [_checkImageView setImage:tempImage];
    _isChecked = !_isChecked;
    
    [self.delegate checkButtonTappedOnTaskCell:self];
    
}
@end
