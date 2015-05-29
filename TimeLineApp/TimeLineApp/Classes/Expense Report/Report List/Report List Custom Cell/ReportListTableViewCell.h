//
//  ReportListTableViewCell.h
//  Nexelus
//
//  Created by Mac on 5/11/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReportListTableViewCell;

@protocol TLReportListTableViewCellDelegate

@optional
-(void) checkButtonTappedOnReportCell:(ReportListTableViewCell *) cell;

@end


@interface ReportListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *reportInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkedImageView;
@property (weak, nonatomic) IBOutlet UIButton *checkmarkButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@property (nonatomic, weak) id<TLReportListTableViewCellDelegate> delegate;
@property (nonatomic , readwrite) BOOL isChecked;

- (IBAction)checkedButtonTpd:(id)sender;
@end
