//
//  ReportListViewController.h
//  Nexelus
//
//  Created by Mac on 5/11/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQDropDownTextField.h"
#import "ReportListTableViewCell.h"

@interface ReportListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, TLReportListTableViewCellDelegate >

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *optionsView;
@property (weak, nonatomic) IBOutlet UIView *draftsMenuView;

@property (weak, nonatomic) IBOutlet IQDropDownTextField *draftsMenuTxtField;
- (IBAction)draftsButtonAction:(id)sender;
- (IBAction)menuButtonAction:(id)sender;


- (IBAction)submitButtonTpd:(id)sender;
- (IBAction)submitAllButtonTpd:(id)sender;
- (IBAction)deleteButtonTpd:(id)sender;
- (IBAction)copyButtonTpd:(id)sender;
- (IBAction)pasteButtonTpd:(id)sender;



@end
