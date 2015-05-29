//
//  TLTasksTableViewCell.h
//  TimeLineApp
//
//  Created by Hanny on 12/10/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TLTasksTableViewCell;

@protocol TLTasksTableViewCellDelegate

@optional
-(void) pinButtonTappedOnTaskCell:(TLTasksTableViewCell *) cell;
-(void) checkButtonTappedOnTaskCell:(TLTasksTableViewCell *) cell;

@end

@interface TLTasksTableViewCell : UITableViewCell

@property (nonatomic, weak) id<TLTasksTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UIButton *pinButton;
@property (weak, nonatomic) IBOutlet UIButton *checkmarkButton;
@property (weak, nonatomic) IBOutlet UILabel *jobDescLabel;

@property (nonatomic , readwrite) BOOL isPinned;
@property (nonatomic , readwrite) BOOL isChecked;
@property (weak, nonatomic) IBOutlet UIImageView *pinImageView;
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;

- (IBAction)checkmarkButtonAction:(id)sender;
- (IBAction)pinButtonAction:(id)sender;

@end
