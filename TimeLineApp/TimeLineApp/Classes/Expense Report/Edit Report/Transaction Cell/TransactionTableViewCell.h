//
//  TransactionTableViewCell.h
//  Nexelus
//
//  Created by Mac on 5/19/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TransactionTableViewCell;

@protocol TLTransactionsTableViewCellDelegate

@optional
-(void) checkButtonTappedOnTransactionCell:(TransactionTableViewCell *) cell;

@end

@interface TransactionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *transactionImageView;
@property (weak, nonatomic) IBOutlet UILabel *transactionInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkedImageView;
@property (weak, nonatomic) IBOutlet UIButton *checkmarkButton;

@property (nonatomic, weak) id<TLTransactionsTableViewCellDelegate> delegate;
@property (nonatomic , readwrite) BOOL isChecked;


- (IBAction)checkedButtonTpd:(id)sender;
@end
