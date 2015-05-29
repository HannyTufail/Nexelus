//
//  JobTableViewCell.m
//  TimeLineApp
//
//  Created by Mac on 12/23/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "TLAddJobTableViewCell.h"

@implementation TLAddJobTableViewCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)clientNameSearchButtonTpd:(id)sender
{
    NSLog(@"Client Name Search Button Tapped");
    [self.delegate clientSearchButtonTappedOn:self];
}

- (IBAction)jobNameSearchButtonTpd:(id)sender {
    NSLog(@"Job Name Search Button Tapped");
    [self.delegate jobSearchButtonTappedOn:self];
}

- (IBAction)acitivityButtonAction:(id)sender
{
    [self.activityNameTxtField becomeFirstResponder];
}

- (IBAction)textFieldDidEndEditing:(id)sender {
    UITextField * txtField = (UITextField *) sender;
    [txtField resignFirstResponder];
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
    
//    _pinImageView.frame = CGRectMake(_pinImageView.frame.origin.x, _pinImageView.frame.origin.y, tempImage.size.width/2,tempImage.size.height/2);
    
    _isPinned = !_isPinned;
    
}

@end
