//
//  EditClientJobTableViewCell.h
//  TimeLineApp
//
//  Created by Mac on 1/23/15.
//  Copyright (c) 2015  Hanny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditClientJobTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *pinButton;
@property (weak, nonatomic) IBOutlet UIImageView *pinImageView;
@property (nonatomic , readwrite) BOOL isPinned;
@property (weak, nonatomic) IBOutlet UILabel *createdDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *level3TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobNameLabel;


- (IBAction)pinButtonAction:(id)sender;



@end
