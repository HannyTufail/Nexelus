//
//  EditClientJobTableViewCell.m
//  TimeLineApp
//
//  Created by Mac on 1/23/15.
//  Copyright (c) 2015  Hanny. All rights reserved.
//

#import "EditClientJobTableViewCell.h"

@implementation EditClientJobTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)pinButtonAction:(id)sender
{
    UIImage *pinnedImage = [UIImage imageNamed:@"pin.png"];
    UIImage *unpinnedImage = [UIImage imageNamed:@"unpin.png"];
    
    UIImage *tempImage = nil;
    if(_isPinned)
    {
        tempImage = unpinnedImage;
    }
    else
    {
        tempImage = pinnedImage;
    }
    [_pinImageView setImage:tempImage];
    _isPinned = !_isPinned;
}

@end
