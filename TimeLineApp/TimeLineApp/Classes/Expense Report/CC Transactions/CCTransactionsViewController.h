//
//  CCTransactionsViewController.h
//  Nexelus
//
//  Created by Mac on 5/27/15.
//  Copyright (c) 2015 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionTableViewCell.h"

@interface CCTransactionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TLTransactionsTableViewCellDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)takeMoreImagesButtonTpd:(id)sender;
- (IBAction)nextButtonTpd:(id)sender;


@end
