//
//  JobTableViewCell.h
//  TimeLineApp
//
//  Created by Mac on 12/23/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQDropDownTextField.h"

@class TLAddJobTableViewCell;

@protocol TLAddJobTableViewCellDelegate

@optional
-(void) clientSearchButtonTappedOn:(TLAddJobTableViewCell *) cell;
-(void) jobSearchButtonTappedOn:(TLAddJobTableViewCell *)cell;

@end


@interface TLAddJobTableViewCell : UITableViewCell


@property (nonatomic, weak) id<TLAddJobTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *clientNameTxtField;
@property (weak, nonatomic) IBOutlet UITextField *jobNameTxtField;
@property (weak, nonatomic) IBOutlet IQDropDownTextField *activityNameTxtField;
@property (weak, nonatomic) IBOutlet UILabel *createdDateLabel;

@property (weak, nonatomic) IBOutlet UIButton *clientNameSearchButton;
@property (weak, nonatomic) IBOutlet UIButton *jobNameSearchButton;

@property (weak, nonatomic) IBOutlet UIButton *pinButton;
@property (weak, nonatomic) IBOutlet UIImageView *pinImageView;
@property (nonatomic , readwrite) BOOL isPinned;

@property (weak, nonatomic) IBOutlet UILabel *level3TitleLabel;

- (IBAction)clientNameSearchButtonTpd:(id)sender;
- (IBAction)jobNameSearchButtonTpd:(id)sender;

- (IBAction)textFieldDidEndEditing:(id)sender;
- (IBAction)pinButtonAction:(id)sender;

- (IBAction)acitivityButtonAction:(id)sender;


@end
