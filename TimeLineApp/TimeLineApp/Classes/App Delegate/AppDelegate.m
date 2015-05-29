//
//  AppDelegate.m
//  TimeLineApp
//
//  Created by Hanny on 12/9/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "AppDelegate.h"
#import "TLLoginViewController.h"
#import "TLConstants.h"
#import "TLUtilities.h"
#import "DataSyncHandler.h"

#import "MBProgressHUD.h"
#import "HomeViewController.h"
#import "PendingJobsViewController.h"


BOOL isInternetAvailable = NO;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:UDKEY_HAS_PROVIDED_CLIENT_ID]) {
        // first time launching
        [self showAlertForAuthenticationKey];
    }
    else
    {
        // app already launched
        [self makeWindowVisible];
    }
    
    return YES;
}

-(void) makeWindowVisible
{
    TLLoginViewController * loginController = [[TLLoginViewController alloc] initWithNibName:@"TLLoginViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
    [navController.navigationBar setTranslucent:YES];
    UIColor *tintColor = [UIColor colorWithRed:238.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0];
    
    [navController.navigationBar setBarTintColor:tintColor];
    [navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    [navController.navigationBar setHidden:YES];
    [navController.navigationBar setBarStyle:UIBarStyleDefault];
    
    NSTimer *fiveSecondTimer = [NSTimer scheduledTimerWithTimeInterval:20*60 target:self selector:@selector(performBackgroundTask) userInfo:nil repeats:YES];
    
 
    isInternetAvailable = [TLUtilities verifyInternetAvailability];
    NSLog(isInternetAvailable ? @"Yes" : @"No");

//    Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

    self.networkReachability = [Reachability reachabilityForInternetConnection];
    [self.networkReachability startNotifier];
  
    
    
    [self.window setRootViewController:navController];
    [self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - UITextField delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:LOGIN_ACCEPTABLE_CHARACTERS] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return (([string isEqualToString:filtered])&&(newLength <= AUTHENTICATION_KEY_CHARACTERS_LIMIT));
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIAlertView Delegate Methods

-(void) showAlertForAuthenticationKey
{    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:AUTHENTICATION_KEY_TITLE message:@"" delegate:self cancelButtonTitle:@"Continue To Login >>" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].delegate = self;
    [alert textFieldAtIndex:0].placeholder = @"Enter Company Key";
    [[alert textFieldAtIndex:0] setSecureTextEntry:YES];
    [alert textFieldAtIndex:0].returnKeyType = UIReturnKeyDone;
    alert.delegate = self;
    alert.tag = 101;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101)
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *companyCode = textField.text;
        
        if (companyCode.length > 0)
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UDKEY_HAS_PROVIDED_CLIENT_ID];
            [[NSUserDefaults standardUserDefaults] setValue:companyCode forKey:UDKEY_AUTHENTICATION_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [textField resignFirstResponder];
             [self makeWindowVisible];
        }
        else
        {
            [self showAlertForAuthenticationKey];
        }
    }
}

#pragma mark - Reachability Methods

- (void) reachabilityChanged:(NSNotification *)note
{
    isInternetAvailable = [TLUtilities verifyInternetAvailability];
    NSLog(isInternetAvailable ? @"Yes" : @"No");
}

#pragma mark - Background Data Syncing Methods
-(void) performBackgroundTask
{
    if ([TLUtilities verifyInternetAvailability] && [[NSUserDefaults standardUserDefaults] boolForKey:UDKEY_USER_HAS_LOGGED_IN]&& [[NSUserDefaults standardUserDefaults] boolForKey:UDKEY_HAS_FETCHED_ENTIRE_DATA])
    {
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:CONFIRMATION_REQUIRED_TITLE message:@"Service started Now" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES",nil];
//        alert.delegate = self;
//        alert.tag =112233;
//        [alert show];
        
        [DataSyncHandler defaultHandler]._syncTypes = forTwentyMinutes;
        [DataSyncHandler defaultHandler].isDelegateSetFromLogin = NO;
        [[DataSyncHandler defaultHandler] syncLocalDBDataWithServer];
    
    }
}

@end
