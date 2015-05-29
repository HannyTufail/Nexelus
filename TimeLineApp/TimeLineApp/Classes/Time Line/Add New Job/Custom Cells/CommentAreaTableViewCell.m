//
//  CommentAreaTableViewCell.m
//  TimeLineApp
//
//  Created by Mac on 12/23/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "CommentAreaTableViewCell.h"
#import "TLConstants.h"

@implementation CommentAreaTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UITextView Delegate Methods.

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Comments here..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    
    [textView becomeFirstResponder];
    
    
    NSInteger showTask =  [[NSUserDefaults standardUserDefaults] integerForKey:UDKEY_SHOW_TASKS];
    NSInteger showWorkFunc = [[NSUserDefaults standardUserDefaults] integerForKey:UDKEY_SHOW_RES_USAGE];
    
    NSIndexPath *indexPath = nil;
    if (((showTask == 0 || showTask == 1) && showWorkFunc == 2) || (showTask == 3 && (showWorkFunc == 0 || showWorkFunc == 1)))
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
    }
    else if ((showTask == 0 || showTask == 1) && (showWorkFunc == 0|| showWorkFunc == 1))
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    }
    else if (showTask == 3 && showWorkFunc == 2)
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:4];
    }
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Comments here...";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return (text.length <= COMMENTS_FIELD_LIMIT);
}

#pragma mark -  UITextField methods

@end
