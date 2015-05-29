//
//  TaskAndWorkTableViewCell.h
//  TimeLineApp
//
//  Created by Mac on 12/23/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQDropDownTextField.h"

@interface TaskAndWorkTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet IQDropDownTextField *taskAndWorkTxtField;
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;

@end
