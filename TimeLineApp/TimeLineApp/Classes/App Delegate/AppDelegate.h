//
//  AppDelegate.h
//  TimeLineApp
//
//  Created by Hanny on 12/9/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"


extern BOOL isInternetAvailable;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) Reachability *networkReachability;

-(void) showAlertForAuthenticationKey;

@end

