//
//  TLTransactionsTableViewCell.h
//  Nexelus
//
//  Created by Mac on 2/16/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TLTransactionsTableViewCell;

@protocol TLTransactionsTableViewCellDelegate

@optional
-(void) pinButtonTappedOnTransactionCell:(TLTransactionsTableViewCell *) cell;
-(void) checkButtonTappedOnTransactionCell:(TLTransactionsTableViewCell *) cell;

@end


@interface TLTransactionsTableViewCell : UITableViewCell

@property (nonatomic, weak) id<TLTransactionsTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UIButton *pinButton;
@property (weak, nonatomic) IBOutlet UIButton *checkmarkButton;

@property (nonatomic , readwrite) BOOL isPinned;
@property (nonatomic , readwrite) BOOL isChecked;
@property (weak, nonatomic) IBOutlet UIImageView *pinImageView;
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;


- (IBAction)checkmarkButtonAction:(id)sender;
- (IBAction)pinButtonAction:(id)sender;




@end
