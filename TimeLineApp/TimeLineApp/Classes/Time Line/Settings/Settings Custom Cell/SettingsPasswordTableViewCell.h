//
//  SettingsPasswordTableViewCell.h
//  Nexelus
//
//  Created by Mac on 2/22/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsPasswordTableViewCell : UITableViewCell <UITextFieldDelegate>

@property(weak, nonatomic) IBOutlet UITextField * oldPasswordTextField;
@property(weak, nonatomic) IBOutlet UITextField * newerPasswordTextField;
@property(weak, nonatomic) IBOutlet UITextField * confirmPasswordTextField;

@end
