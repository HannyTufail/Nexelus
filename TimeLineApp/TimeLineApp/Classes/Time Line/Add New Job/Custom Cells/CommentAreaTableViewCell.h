//
//  CommentAreaTableViewCell.h
//  TimeLineApp
//
//  Created by Mac on 12/23/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentAreaTableViewCell : UITableViewCell <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *commentsTxtView;
@property (weak, nonatomic) UITableView * tableView;


@end
