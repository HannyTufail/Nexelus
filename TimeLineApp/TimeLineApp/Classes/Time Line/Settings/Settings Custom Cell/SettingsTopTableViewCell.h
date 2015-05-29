//
//  SettingsTopTableViewCell.h
//  Nexelus
//
//  Created by Mac on 2/22/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQDropDownTextField.h"

@class SettingsTopTableViewCell;

@protocol SettingsTopTableViewCellDelegate

@optional
-(void) settingClientButtonTappedOn:(SettingsTopTableViewCell *) cell;
-(void) settingsJobButtonTappedOn:(SettingsTopTableViewCell *)cell;

@end

@interface SettingsTopTableViewCell : UITableViewCell

@property (weak, nonatomic) id<SettingsTopTableViewCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet IQDropDownTextField *customerTextField;
@property (weak, nonatomic) IBOutlet IQDropDownTextField *projectTextField;

@property (weak, nonatomic) IBOutlet UILabel *level2HeadingLabel;

- (IBAction)clientButtonTapped:(id)sender;
- (IBAction)jobButtonTapped:(id)sender;


@end
