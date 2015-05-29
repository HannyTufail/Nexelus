//
//  TLSettingsViewController.h
//  TimeLineApp
//
//  Created by Hanny on 12/12/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQDropDownTextField.h"
#import "SettingsTopTableViewCell.h"

@interface TLSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SettingsTopTableViewCellDelegate>


@property (nonatomic , weak) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;


- (IBAction)CancelButtonTapped:(id)sender;
- (IBAction)SaveButtonTapped:(id)sender;

@end
