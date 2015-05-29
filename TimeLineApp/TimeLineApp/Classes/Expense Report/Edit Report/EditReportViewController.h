//
//  EditReportViewController.h
//  Nexelus
//
//  Created by Mac on 5/19/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionTableViewCell.h"

@interface EditReportViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TLTransactionsTableViewCellDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)selectAllButtonTpd:(id)sender;
- (IBAction)assignActivityButtonTpd:(id)sender;
- (IBAction)additionalImageButtonTpd:(id)sender;

@end
