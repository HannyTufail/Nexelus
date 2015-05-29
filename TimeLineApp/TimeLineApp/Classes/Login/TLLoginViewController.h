//
//  TLLoginViewController.h
//  TimeLineApp
//
//  Created by Hanny on 12/9/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Resource.h"
#import "DataSyncHandler.h"

@interface TLLoginViewController : UIViewController <DataSyncHandlerDelegate, UITextFieldDelegate, UIAlertViewDelegate>
{
    Resource * resourceObject;
}
@property (nonatomic, retain) Resource * resourceObject;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *rememberMeButton;
@property (nonatomic) BOOL isChecked;

- (IBAction)signInButtonAction:(id)sender;
- (IBAction)rememberMeButtonTapped:(id)sender;
-(void) generateCallsForWebservices;
@end
