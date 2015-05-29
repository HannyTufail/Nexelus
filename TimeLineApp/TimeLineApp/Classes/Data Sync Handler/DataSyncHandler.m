 //
//  DataSyncHandler.m
//  TimeLineApp
//
//  Created by Mac on 1/3/15.
//  Copyright (c) 2015  Hanny. All rights reserved.
//

#import "DataSyncHandler.h"
#import "WebservicesManager.h"
#import "Level2_Job.h"
#import "Level3_Activity.h"
#import "Level2_Customer.h"
#import "Task.h"
#import "WorkFunction.h"
#import "Transaction.h"
#import "SysNames.h"
#import "PermanentLines.h"
#import "TLUtilities.h"
#import "TLConstants.h"
#import "AppDelegate.h"
#import "PermanentLines.h"
#import "MBProgressHUD.h"


@implementation DataSyncHandler
@synthesize delegate;
@synthesize level2CustomerLastSyncDateString, level2LastSyncDateString, level3LastSyncDateString, taskLastSyncDateString, workFunctionLastSyncDateString, permanentLinesLastSyncDateString, sysNamesLastSyncDateString, transactionsLastSyncDateString;
@synthesize isDelegateSetFromLogin;
@synthesize isSyncingTransaction;

+ (DataSyncHandler *)defaultHandler
{
    static DataSyncHandler *defaultHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultHandler = [[DataSyncHandler alloc] init];
    });
    return defaultHandler;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _level2Array = [[NSMutableArray alloc] init];
        _level3Array = [[NSMutableArray alloc] init];
        _taskArray = [[NSMutableArray alloc] init];
        _workFunctionArray = [[NSMutableArray alloc] init];
        _level2CustomerArray = [[NSMutableArray alloc] init];
        _permanentLineArray = [[NSMutableArray alloc] init];
        _sysNamesArray = [[NSMutableArray alloc] init];
        _transactionArray = [[NSMutableArray alloc] init];
        
        isSyncingTransaction = YES;
        self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"timesheet.db"];
    }
    return self;
}


#pragma mark - User Defaults
-(void) updateDataInUserDefaultsUsingResource:(Resource *)resourceObject
{
    NSString * clientName = [NSString stringWithFormat:@"%@ %@",resourceObject.firstName, resourceObject.lastName];
    
    [[NSUserDefaults standardUserDefaults] setValue:resourceObject.companyCode forKey:UDKEY_COMPANY_CODE];
    [[NSUserDefaults standardUserDefaults] setValue:clientName forKey:UDKEY_CLIENT_NAME];
    [[NSUserDefaults standardUserDefaults] setValue:resourceObject.resourceID forKey:UDKEY_RESOURCE_ID];
    [[NSUserDefaults standardUserDefaults] setValue:resourceObject.orgUnitCode forKey:UDKEY_ORG_UNIT_CODE];
    [[NSUserDefaults standardUserDefaults] setValue:resourceObject.locationCode forKey:UDKEY_LOCATION_CODE];
    [[NSUserDefaults standardUserDefaults] setValue:resourceObject.resourceUsageCode forKey:UDKEY_RES_USAGE_CODE];
    [[NSUserDefaults standardUserDefaults] setBool:resourceObject.isUsingActiveDirectory forKey:UDKEY_IS_USING_ACTIVE_DIRECTORY];
    
    int showTask = resourceObject.showTask;
    int showWorkFunc = resourceObject.showWorkFunction;
    
    [[NSUserDefaults standardUserDefaults] setInteger:showTask forKey:UDKEY_SHOW_TASKS];
    [[NSUserDefaults standardUserDefaults] setInteger:showWorkFunc forKey:UDKEY_SHOW_RES_USAGE];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark -  Deleting DB File from Documents Directory.
- (void)removeDBFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"timesheet.db"];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success)
    {
        NSLog(@"Successfully Deleted ");
        self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"timesheet.db"];
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

#pragma mark - GET SERVICE and their Parsing Methods

-(void) fetchResouceObjectFromServer
{
    NSString * userName = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_CLIENT_USERNAME];
    NSString * password = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_PASSWORD];
    
    [[WebservicesManager defaultManager] requestLoginWithEmail:userName password:password completionHandler:^(NSError *error, NSDictionary *user)
     {
         BOOL success = [self parseResourceGetResponseData:user andError:error];
         if (success) {
             
         }
         
         [self fetchUserSettingsFromServerWithCompletionHandler:nil];
     }];
}

-(BOOL) parseResourceGetResponseData:(NSDictionary *) respDict andError:(NSError *) error
{
    /*
     
     {
         "Entities": [
             {
                 "CompanyCode": 2,
                 "IsUsingAD": 0,
                 "LastSyncDate": "/Date(-62135575200000-0600)/",
                 "LocationCode": "NY",
                 "NameFirst": "Janet",
                 "NameLast": "Urciuoli",
                 "NewPassword": null,
                 "OldPassword": null,
                 "OrgUnitCode": "C&T-C&T Admin",
                 "ResUsageCode": "ADMIN",
                 "ResourceID": "451",
                 "ShowTask": 1,
                 "ShowWorkFunction": 2
             }
         ],
         "Message": null,
         "ResponseType": 0,
         "SyncDate": "2015-01-28 06:15:29"
     }
     */
    
    NSString * userName = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_CLIENT_USERNAME];
    NSString * password = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_PASSWORD];
    
    BOOL success = NO;
    if (!error && respDict)
    {
        NSString * messageString = [respDict valueForKey:@"Message"];
        
        int responseType = [[respDict valueForKey:@"ResponseType"] intValue];
        if (responseType == 0)
        {
            Resource * resourceObject = [self makeResourceObjectofUser:userName andPassword:password FromServerDictionary:respDict];
            [self insertResourceValuesInLocalDB:resourceObject];
            [self updateDataInUserDefaultsUsingResource:resourceObject];
        }
        else
        {
            NSLog(@"%@", messageString);
        }
    }
    return success;
}

-(void) fetchLevel2ListFromServerWithCompletionHandler:(LoginViewDataSyncCompletionHandler)handler
{
    [[WebservicesManager defaultManager] requestListGet:kTL_LEVEL_2_GET OfType:@"Level2Criteria" withActionFlag:-1 andLastSyncDate:@"" CompletionHandler:^(NSError *error, NSDictionary *user) {
        
        BOOL success = [self parseLevel2ListGetResponseData:user andError:error];
                if (handler) {
                // send back response to caller
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   handler(success);
                               });
            }
    }];
}
-(BOOL) parseLevel2ListGetResponseData:(NSDictionary *) respDict andError:(NSError *) error
{
    /*
     {
     "Entities": [
             {
                 "CompanyCode": 2,
                 "LastSyncDate": "/Date(-62135575200000-0600)/",
                 "Level2Description": "Verify if correct budgets are associated with the level3 - Nov. 21, 2014",
                 "Level2Key": "ZZMEDIA TEMPLATE",
                 "Level2Status": 1,
                 "StrCloseDate": "",
                 "StrOpenDate": "2014-11-21 00:00:00"
             },
         ],
     
         "Message": null,
         "ResponseType": 0
         "SyncDate": "2015-02-25 08:06:15"
     }
     */
    
    BOOL success = NO;
    if (!error && respDict)
    {
        int responseType = [[respDict valueForKey:@"ResponseType"] intValue];
        if (responseType == 0)
        {
            if (self.level2Array.count>0)
            {
                [self.level2Array removeAllObjects];
            }
            
            // Now we are not using "LastSyncDate" inside the Entities Object and using the "SyncDate" outside it.
            self.level2LastSyncDateString = [respDict valueForKey:@"SyncDate"];
            NSArray * entitiesArray = [respDict valueForKey:@"Entities"];
            for (NSDictionary * tempDict in entitiesArray)
            {
                Level2_Job * job = [[Level2_Job alloc] initWithLevel2Key:[tempDict valueForKey:@"Level2Key"]
                                                          andDescription:[tempDict valueForKey:@"Level2Description"]
                                                        syncedLastOnDate:[tempDict valueForKey:@"LastSyncDate"]
                                                        withLevel2Status:[[tempDict valueForKey:@"Level2Status"] intValue]
                                                           onOpeningDate:[tempDict valueForKey:@"StrOpenDate"]
                                                          andClosingDate:[tempDict valueForKey:@"StrCloseDate"]];
                [self.level2Array addObject:job];
            }
            success = YES;
        }
        else
        {
            NSString * messageString = [respDict valueForKey:@"Message"];
            NSLog(@"%@",messageString);
        }
    }
    return success;
}

-(void) fetchLevel3ListFromServerWithCompletionHandler:(LoginViewDataSyncCompletionHandler)handler
{
    [[WebservicesManager defaultManager] requestListGet:kTL_LEVEL_3_GET OfType:@"Level3Criteria" withActionFlag:-1  andLastSyncDate:@"" CompletionHandler:^(NSError *error, NSDictionary *user) {
        
        BOOL success = [self parseparseLevel3ListGetResponseData:user andError:error];
            if (handler) {
                // send back response to caller
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   handler(success);
                               });
            }
    }];

}

-(BOOL) parseparseLevel3ListGetResponseData:(NSDictionary *) respDict andError:(NSError *) error
{
    /*
     {
         "Entities": [
             {
                 "BillableFlag": false,
                 "CompanyCode": 2,
                 "LaborFlag": 1,
                 "LastSyncDate": "/Date(-62135575200000-0600)/",
                 "Level2Description": "",
                 "Level2Key": "~!@#$%^&*()_",
                 "Level3Description": "",
                 "Level3Key": "~!@#$%^&*()_",
                 "StrClosedDate": "",
                 "StrOpenDate": "2015-01-28 00:00:00",
                 "TaskTypeCode": 2
             },
         ],
     
         "Message": null,
         "ResponseType": 0
         "SyncDate": "2015-02-25 08:39:25"
     }
     */
    BOOL success = NO;
    if (!error && respDict)
    {
        int responseType = [[respDict valueForKey:@"ResponseType"] intValue];
        if (responseType == 0)
        {
            if (self.level3Array.count>0) {
                [self.level3Array removeAllObjects];
            }
            
            // Now we are not using "LastSyncDate" inside the Entities Object and using the "SyncDate" outside it.
            self.level3LastSyncDateString = [respDict valueForKey:@"SyncDate"];
            NSArray * entitiesArray = [respDict valueForKey:@"Entities"];
            for (NSDictionary * tempDict in entitiesArray)
            {
                Level3_Activity * activity = [[Level3_Activity alloc] initWithLevel2Key:[tempDict valueForKey:@"Level2Key"]
                                                                              level3Key:[tempDict valueForKey:@"Level3Key"]
                                                                      level3Description:[tempDict valueForKey:@"Level3Description"]
                                                                           openedOnDate:[tempDict valueForKey:@"StrOpenDate"]
                                                                       withTaskTypeCode:[tempDict valueForKey:@"TaskTypeCode"]
                                                                              laborFlag:[[tempDict valueForKey:@"LaborFlag"] intValue]
                                                                           andCloseDate:[tempDict valueForKey:@"StrClosedDate"]];
                [self.level3Array addObject:activity];
            }
            success = YES;
        }
        else
        {
            NSString * messageString = [respDict valueForKey:@"Message"];
            NSLog(@"%@",messageString);
        }
    }
    return  success;
}

-(void) fetchTransactionsListFromServerWithCompletionHandler:(LoginViewDataSyncCompletionHandler)handler
{
    [[WebservicesManager defaultManager] requestListGet:kTL_TRANSACTION_GET OfType:@"TransactionCriteria" withActionFlag:-1 andLastSyncDate:@"" CompletionHandler:^(NSError *error, NSDictionary *user) {
        BOOL success = [self parseTransactionListGetResponseData:user andError:error];
                    if (handler) {
                // send back response to caller
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   handler(success);
                               });
            }
    }];
}

-(BOOL) parseTransactionListGetResponseData:(NSDictionary *) respDict andError:(NSError *) error
{
    /*
     {
         "Entities": [
             {
                 "ActionFlag": 0,
                 "AppliedDate": "/Date(1424066400000-0600)/",
                 "ApprovalFlag": 0,
                 "Comments": "",
                 "CompanyCode": 2,
                 "ErrorCode": 0,
                 "ErrorDescription": "",
                 "ErrorFlag": 0,
                 "LastSyncDate": "/Date(-62135575200000-0600)/",
                 "Level2Key": "01012015",
                 "Level3Key": "001",
                 "LineID": 0,
                 "LocationCode": "NY",
                 "ModifyDate": "/Date(-62135575200000-0600)/",
                 "NonBillableFlag": 0,
                 "OrgUnit": "C&T-C&T Admin",
                 "ResUsageCode": "ADMIN",
                 "ResourceID": "451",
                 "StrAppliedDate": null,
                 "StrTimeStamp": "0|$|0|$|0|$|0|$|0|$|127|$|16|$|26|$|",
                 "SubmittedDate": "/Date(1424845621000-0600)/",
                 "SubmittedFlag": 1,
                 "TaskCode": "Design",
                 "TransactionID": "45114b2b63bd921",
                 "TrxType": 1006,
                 "Units": 5
             },
         ]
         "Message": null,
         "ResponseType": 0
     }
     */
    BOOL success = NO;
    if (!error && respDict)
    {
        int responseType = [[respDict valueForKey:@"ResponseType"] intValue];
        if (responseType == 0)
        {
            if (self.transactionArray.count>0)
            {
                [self.transactionArray removeAllObjects];
            }
            
            // Now we are not using "LastSyncDate" inside the Entities Object and using the "SyncDate" outside it.
            self.transactionsLastSyncDateString = [respDict valueForKey:@"SyncDate"];
            NSArray * entitiesArray = [respDict valueForKey:@"Entities"];
            for (NSDictionary * tempDict in entitiesArray)
            {
                Transaction * transactionObj = [self makeAnTransactionItemFromServerDictionary:tempDict];
                [self.transactionArray addObject:transactionObj];
            }
            success = YES;
        }
        else
        {
            NSString * messageString = [respDict valueForKey:@"Message"];
            NSLog(@"%@",messageString);
        }
    }
    return success;
}

-(void) fetchTaskListFromServerWithCompletionHandler:(LoginViewDataSyncCompletionHandler)handler
{
    [[WebservicesManager defaultManager] requestListGet:kTL_TASK_GET OfType:@"TaskCriteria" withActionFlag:-1 andLastSyncDate:@"" CompletionHandler:^(NSError *error, NSDictionary *user) {
        
        BOOL success = [self parseTaskListGetResponseData:user andError:error];
                if (handler) {
                // send back response to caller
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   handler(success);
                               });
            }
    }];
}
-(BOOL) parseTaskListGetResponseData:(NSDictionary *) respDict andError:(NSError *) error
{
    /*
     {
         "Entities": [
             {
                 "CompanyCode": 2,
                 "LastSyncDate": "/Date(-62135575200000-0600)/",
                 "TaskCode": "Design",
                 "TaskDescription": "Design begins work",
                 "TaskType": 1,
                 "TaskTypeDescription": "DEFAULT TASK - NOT USING"
             },
         ],
         
         "Message": null,
         "ResponseType": 0
     }
     */
    BOOL success = NO;
    if (!error && respDict)
    {
        int responseType = [[respDict valueForKey:@"ResponseType"] intValue];
        if (responseType == 0)
        {
            if (self.taskArray.count>0)
            {
                [self.taskArray removeAllObjects];
            }
            
            // Now we are not using "LastSyncDate" inside the Entities Object and using the "SyncDate" outside it.
            self.taskLastSyncDateString = [respDict valueForKey:@"SyncDate"];
            NSArray * entitiesArray = [respDict valueForKey:@"Entities"];
            for (NSDictionary * tempDict in entitiesArray)
            {
                Task * taskObj = [[Task alloc]initWithTaskCode:[tempDict valueForKey:@"TaskCode"]
                                                        ofType:[[tempDict valueForKey:@"TaskType"] intValue]
                                           withTaskDescription:[tempDict valueForKey:@"TaskDescription"]
                                        andTaskTypeDescription:[tempDict valueForKey:@"TaskTypeDescription"]];
                [self.taskArray addObject:taskObj];
            }
            success = YES;
        }
        else{
            NSString * messageString = [respDict valueForKey:@"Message"];
            NSLog(@"%@",messageString);
        }
    }
    return success;

}

-(void) fetchResUsageListFromServerWithCompletionHandler:(LoginViewDataSyncCompletionHandler)handler
{
    [[WebservicesManager defaultManager] requestListGet:kTL_RES_USAGE_GET OfType:@"ResUsageCriteria" withActionFlag:-1  andLastSyncDate:@"" CompletionHandler:^(NSError *error, NSDictionary *user) {
        
        BOOL success = [self parseResUsageListGetResponseData:user andError:error];
                    if (handler) {
                // send back response to caller
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   handler(success);
                               });
            }
    }];
}

-(BOOL) parseResUsageListGetResponseData:(NSDictionary *) respDict andError:(NSError *) error
{
    /*
     {
         "Entities": [
             {
                 "CompanyCode": 2,
                 "LastSyncDate": "/Date(-62135575200000-0600)/",
                 "ResUsageCode": "D&D_ACCTCORD",
                 "ResUsageDescription": "Account Coordinator"
             },
         ],
         "Message": null,
         "ResponseType": 0
     }
     */
    BOOL success = NO;
    if (!error && respDict)
    {
        int responseType = [[respDict valueForKey:@"ResponseType"] intValue];
        if (responseType == 0)
        {
            if (self.workFunctionArray.count>0) {
                [self.workFunctionArray removeAllObjects];
            }
            
            // Now we are not using "LastSyncDate" inside the Entities Object and using the "SyncDate" outside it.
            self.workFunctionLastSyncDateString = [respDict valueForKey:@"SyncDate"];
            NSArray * entitiesArray = [respDict valueForKey:@"Entities"];
            for (NSDictionary * tempDict in entitiesArray)
            {
                WorkFunction * workFuncObj = [[WorkFunction alloc] initWithResUsageCode:[tempDict valueForKey:@"ResUsageCode"]
                                                                 andResUsageDescription:[tempDict valueForKey:@"ResUsageDescription"]];
                
                [self.workFunctionArray addObject:workFuncObj];
            }
            success = YES;
        }
        else
        {
            NSString * messageString = [respDict valueForKey:@"Message"];
            NSLog(@"%@",messageString);
        }
    }
    return success;
}

-(void) fetchLevel2CustomerListFromServerWithCompletionHandler:(LoginViewDataSyncCompletionHandler)handler
{
    [[WebservicesManager defaultManager] requestListGet:kTL_LEVEL_2_CUSTOMER_GET OfType:@"Level2CustomerCriteria" withActionFlag:-1  andLastSyncDate:@"" CompletionHandler:^(NSError *error, NSDictionary *user) {
        
        BOOL success = [self parseLevel2CustomerListGetResponseData:user andError:error];
                if (handler) {
                // send back response to caller
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   handler(success);
                               });
            }
    }];
}

-(BOOL) parseLevel2CustomerListGetResponseData:(NSDictionary *) respDict andError:(NSError *) error
{
    /*
     {
     "Entities": [
         {
             "CompanyCode": 2,
             "CusomterName": "2U",
             "CustomerCode": "2U001",
             "LastSyncDate": "/Date(-62135575200000-0600)/",
             "Level2Key": "2U-00-000"
         },
        ],
     
         "Message": null,
         "ResponseType": 0
     }
     */
    BOOL success = NO;
    if (!error && respDict)
    {
        int responseType = [[respDict valueForKey:@"ResponseType"] intValue];
        if (responseType == 0)
        {
            if (self.level2CustomerArray.count>0) {
                [self.level2CustomerArray removeAllObjects];
            }
            
            // Now we are not using "LastSyncDate" inside the Entities Object and using the "SyncDate" outside it.
            self.level2CustomerLastSyncDateString = [respDict valueForKey:@"SyncDate"];
            NSArray * entitiesArray = [respDict valueForKey:@"Entities"];
            for (NSDictionary * tempDict in entitiesArray)
            {
                Level2_Customer * level2CustomerObj = [[Level2_Customer alloc] initWithCustomerCode:[tempDict valueForKey:@"CustomerCode"]
                                                                                    andCustomerName:[tempDict valueForKey:@"CusomterName"]
                                                                                       andLevel2Key:[tempDict valueForKey:@"Level2Key"]];
                [self.level2CustomerArray addObject:level2CustomerObj];
            }
            success = YES;
        }
        else
        {
            NSString * messageString = [respDict valueForKey:@"Message"];
            NSLog(@"%@",messageString);
        }
    }
    return success;
}

-(void) fetchPermanentLineListFromServerWithCompletionHandler:(LoginViewDataSyncCompletionHandler)handler
{
    [[WebservicesManager defaultManager] requestListGet:kTL_PERMANENT_LINE_GET OfType:@"PermanentLinesCriteria"  withActionFlag:-1  andLastSyncDate:@"" CompletionHandler:^(NSError *error, NSDictionary *user) {
        
        BOOL success = [self parsePermanentLineListGetResponseData:user andError:error];
                    if (handler) {
                // send back response to caller
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   handler(success);
                               });
            }
    }];
}

-(BOOL) parsePermanentLineListGetResponseData:(NSDictionary *) respDict andError:(NSError *) error
{
    /*
     {
     
     Entities =     (
             {
                 "CompanyCode": 2,
                 "LastSyncDate": "/Date(-62135575200000-0600)/",
                 "ActionFlag": 0,
                 "CustomerCode": "MATTE001",
                 "EndDate": "/Date(-62135575200000-0600)/",
                 "Level2Description": "2013 Mattel Brands SEM",
                 "Level2Key": "MATTE001-12-014",
                 "Level3Description": "",
                 "Level3Key": "208",
                 "ResourceID": "451",
                 "StartDate": "/Date(1425945600000-0500)/",
                 "StrEndDate": null,
                 "StrStartDate": "2015-03-09 19:00:00",
                 "TaskCode": "TIME",
                 "Timestamp": null

             },
         );
         Message = "<null>";
         ResponseType = 0;
     }
     */
    BOOL success = NO;
    if (!error && respDict)
    {
        int responseType = [[respDict valueForKey:@"ResponseType"] intValue];
        if (responseType == 0)
        {
            if (self.permanentLineArray.count>0) {
                [self.permanentLineArray removeAllObjects];
            }
            
            // Now we are not using "LastSyncDate" inside the Entities Object and using the "SyncDate" outside it.
            self.permanentLinesLastSyncDateString = [respDict valueForKey:@"SyncDate"];
            NSArray * entitiesArray = [respDict valueForKey:@"Entities"];
            for (NSDictionary * tempDict in entitiesArray)
            {
                PermanentLines * permanentLinesObj = [[PermanentLines alloc] initWithLevel2Key:[tempDict valueForKey:@"Level2Key"]
                                                                                     level3Key:[tempDict valueForKey:@"Level3Key"]
                                                                                  withTaskCode:[tempDict valueForKey:@"TaskCode"]
                                                                                  startingDate:[tempDict valueForKey:@"StrStartDate"]
                                                                                    endingDate:[tempDict valueForKey:@"StrEndDate"]
                                                                                 andResourceID:[tempDict valueForKey:@"ResourceID"]];
                [self.permanentLineArray addObject:permanentLinesObj];
            }
            success = YES;
        }
        else
        {
            NSString * messageString = [respDict valueForKey:@"Message"];
            NSLog(@"%@",messageString);
        }
    }
    return success;
}

-(void) fetchSysNamesListFromServerWithCompletionHandler:(LoginViewDataSyncCompletionHandler)handler
{
    [[WebservicesManager defaultManager] requestListGet:kTL_SYS_NAMES_GET OfType:@"SysNamesCriteria" withActionFlag:-1  andLastSyncDate:@"" CompletionHandler:^(NSError *error, NSDictionary *user) {
        BOOL success = [self parseSysNamesListGetResponseData:user andError:error];
                   if (handler) {
                // send back response to caller
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   handler(success);
                               });
            }
    }];
}

-(BOOL) parseSysNamesListGetResponseData:(NSDictionary *) respDict andError:(NSError *) error
{
    /*
     {
         "Entities": [
             {
                 "CompanyCode": 2,
                 "DisplayName": "Nexelus",
                 "FieldName": "app_name",
                 "LastSyncDate": "/Date(-62135575200000-0600)/"
             },
         ],
         "Message": null,
         "ResponseType": 0
     }
     */
    BOOL success = NO;
    if (!error && respDict)
    {
        int responseType = [[respDict valueForKey:@"ResponseType"] intValue];
        if (responseType == 0)
        {
            if (self.sysNamesArray.count>0) {
                [self.sysNamesArray removeAllObjects];
            }
            
            // Now we are not using "LastSyncDate" inside the Entities Object and using the "SyncDate" outside it.
            self.sysNamesLastSyncDateString = [respDict valueForKey:@"SyncDate"];
            NSArray * entitiesArray = [respDict valueForKey:@"Entities"];
            for (NSDictionary * tempDict in entitiesArray)
            {
                SysNames * sysObj = [[SysNames alloc] initWithFieldName:[tempDict valueForKey:@"FieldName"]
                                                         andDisplayName:[tempDict valueForKey:@"DisplayName"]];
                sysObj.lastSyncDate = self.sysNamesLastSyncDateString;
                [self.sysNamesArray addObject:sysObj];
            }
            success = YES;
        }
        else
        {
            NSString * messageString = [respDict valueForKey:@"Message"];
            NSLog(@"%@",messageString);
        }
    }
    return success;
}

-(void) fetchUserSettingsFromServerWithCompletionHandler:(LoginViewDataSyncCompletionHandler) handler
{
    [[WebservicesManager defaultManager] requestListGet:kTL_USER_SETTINGS_GET OfType:@"UserSettingCriteria" withActionFlag:-1  andLastSyncDate:@"" CompletionHandler:^(NSError *error, NSDictionary *user) {
        
        NSDictionary * tempDict = [[NSDictionary alloc] initWithDictionary:user];
        NSLog(@"%@", tempDict);
      BOOL success = [self parseUserSettingsGetResponseData:tempDict andError:error];
        if (handler)
        {
            // send back response to caller
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               handler(success);
                           });
        }
    }];
}

-(BOOL) parseUserSettingsGetResponseData:(NSDictionary *)respDict andError:(NSError *) error
{
    /*
     {
         "Entities": [
             {
                 "CompanyCode": 2,
                 "DateFormat": null,
                 "LastSyncDate": "/Date(-62135575200000-0600)/",
                 "MaxHrsDay": 8,
                 "MaxHrsMonth": 800,
                 "MaxHrsWeek": 40,
                 "NewPassword": null,
                 "ResourceID": "451",
                 "SearchCustomerBy": null,
                 "SearchProjectBy": null,
                 "SortBy": 1,
                 "StartUpPage": null,
                 "TimesheetPeriod": null,
                 "WeekStarts": 1
             }
         ],
         "Message": null,
         "ResponseType": 0,
         "SyncDate": "2015-01-28 07:17:57"
     }
     */
    NSLog(@"%@",respDict);
    BOOL success = NO;
    if (!error && respDict)
    {
        int responseType = [[respDict valueForKey:@"ResponseType"] intValue];
        if (responseType == 0)
        {
            NSArray * entitiesArray = [respDict valueForKey:@"Entities"];
            for (NSDictionary * tempDict in entitiesArray)
            {
                NSString * maxHoursDay =[NSString stringWithFormat:@"%@", [tempDict valueForKey:@"MaxHrsDay"]];
                NSString * maxHoursWeek = [NSString stringWithFormat:@"%@", [tempDict valueForKey:@"MaxHrsWeek"]];
                NSString * maxHoursMonth = [NSString stringWithFormat:@"%@", [tempDict valueForKey:@"MaxHrsMonth"]];
                NSString * sortBy = [tempDict valueForKey:@"SortBy"];
                
                NSString * newPasswordString = @"";
                NSString * searchCustomerByString = @"";
                NSString * searchProjectByString = @"";
                
                /*
                 pdd_user_settings(company_code INTEGER NOT NULL,resource_id TEXT NOT NULL,startup_page  TEXT,timesheet_period TEXT, date_format TEXT,sort_by TEXT,max_hrs_day TEXT,max_hrs_week TEXT,max_hrs_month TEXT, new_password TEXT,search_customer_by TEXT,search_project_by TEXT,PRIMARY KEY(company_code, resource_id))
                 */
                NSString * deleteQuery = [NSString stringWithFormat:@"DELETE FROM pdd_user_settings WHERE company_code = %i AND resource_id = '%@'",
                                          [[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE] intValue],
                                          [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_RESOURCE_ID]];
                [self executeQuery:deleteQuery];
                
                NSString * query = [NSString stringWithFormat:@"INSERT INTO pdd_user_settings VALUES (%i,'%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@');",
                                    [[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE] intValue],
                                    [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_RESOURCE_ID],
                                    @"",
                                    @"",
                                    @"",
                                    sortBy,
                                    maxHoursDay,
                                    maxHoursWeek,
                                    maxHoursMonth,
                                    newPasswordString,
                                    searchCustomerByString,
                                    searchProjectByString];
                [self executeQuery:query];
                
                [[NSUserDefaults standardUserDefaults] setValue:maxHoursDay forKey:UDKEY_MAX_HOURS_DAY];
                [[NSUserDefaults standardUserDefaults] setValue:maxHoursWeek forKey:UDKEY_MAX_HOURS_WEEK];
                [[NSUserDefaults standardUserDefaults] setValue:sortBy forKey:UDKEY_SORT_BY];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            success = YES;
        }
        else
        {
            NSString * messageString = [respDict valueForKey:@"Message"];
            NSLog(@"%@",messageString);
        }
    }
    return success;
}




#pragma mark - Local DB interaction Methods.

-(float) getHoursForSelectedDate:(NSString *) dateString withBillableFlag:(BOOL) useBillableFlag
{
    float hours = 0.0;
    NSString * appliedDateString = [TLUtilities ConvertDate:dateString FromFormat:@"yyyy-MM-dd HH:mm:ss z" toFormat:@"yyyy-MM-dd"];
    
    NSString *query = @"";
    
    if (useBillableFlag)
    {
        query = [NSString stringWithFormat:@"SELECT unit FROM pld_transaction WHERE applied_date = '%@' AND deleted = 0 AND nonbillable_flag = 0 ;",appliedDateString];
    }
    else
    {
        query = [NSString stringWithFormat:@"SELECT unit FROM pld_transaction WHERE applied_date = '%@' AND deleted = 0;",appliedDateString];
    }
    
    NSArray *transactionsArray =[self.dbManager loadDataFromDB:query];
    if (transactionsArray.count >0)
    {
        for (NSArray * tempArray in transactionsArray)
        {
            float  unit = [[tempArray lastObject] floatValue];
            hours+=unit;
        }
    }
    return hours;
}

-(void) executeQuery:(NSString *) queryString
{
    // Execute the query.
    [self.dbManager executeQuery:queryString];
    if (self.dbManager.affectedRows != 0)
    {
//       NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else
    {
       NSLog(@"Could not execute the query = %@",queryString);
    }
}

-(void) fetchLastSyncDatesFromResourceTable {
    
    NSString * query = [NSString stringWithFormat:@"SELECT last_sync_date_level2_customer,last_sync_date_level2,last_sync_date_level3,last_sync_date_task,last_sync_date_res_usage ,last_sync_date_sys_names,last_sync_date_transaction,last_sync_date_permanent_line FROM pdd_resource;"];
    NSArray * respArray =  [self.dbManager loadDataFromDB:query];
    if (respArray.count>0)
    {
        for (NSArray *resourceItemArray in respArray) {
           
           self.level2CustomerLastSyncDateString = [resourceItemArray objectAtIndex:0];
           self.level2LastSyncDateString = [resourceItemArray objectAtIndex:1];
           self.level3LastSyncDateString = [resourceItemArray objectAtIndex:2];
           self.taskLastSyncDateString = [resourceItemArray objectAtIndex:3];
           self.workFunctionLastSyncDateString = [resourceItemArray objectAtIndex:4];
           self.sysNamesLastSyncDateString = [resourceItemArray objectAtIndex:5];
           self.transactionsLastSyncDateString = [resourceItemArray objectAtIndex:6];
           self.permanentLinesLastSyncDateString = [resourceItemArray objectAtIndex:7];
        }
    }
    
}

-(void) updateLastSyncDatesInResourceTable
{
    NSString * updateQuery = [NSString stringWithFormat:@"UPDATE pdd_resource SET last_sync_date_level2_customer = '%@',last_sync_date_level2 = '%@',last_sync_date_level3 = '%@',last_sync_date_task = '%@',last_sync_date_res_usage = '%@',last_sync_date_permanent_line = '%@',last_sync_date_sys_names = '%@',last_sync_date_transaction = '%@' WHERE company_code = '%@' AND resource_id = '%@';",
                              self.level2CustomerLastSyncDateString,
                              self.level2LastSyncDateString,
                              self.level3LastSyncDateString,
                              self.taskLastSyncDateString,
                              self.workFunctionLastSyncDateString,
                              self.permanentLinesLastSyncDateString,
                              self.sysNamesLastSyncDateString,
                              self.transactionsLastSyncDateString,
                              [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE],
                              [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_RESOURCE_ID]];
    
    [self.dbManager executeQuery:updateQuery];
}

-(Resource *) makeResourceObjectofUser:(NSString *) userName andPassword:(NSString *)password FromServerDictionary:(NSDictionary *) tempDict
{
    Resource * resourceObject = nil;
    NSArray * entitiesArray = [tempDict valueForKey:@"Entities"];
    for (NSDictionary * dict in entitiesArray)
    {
    
        resourceObject = [[Resource alloc] initWithResourceID:[dict valueForKey:@"ResourceID"]
                                                    firstName:[dict valueForKey:@"NameFirst"]
                                                     lastName:[dict valueForKey:@"NameLast"]
                                                 resCodeUsage:[dict valueForKey:@"ResUsageCode"]
                                                      orgUnit:[dict valueForKey:@"OrgUnitCode"]
                                                 locationCode:[dict valueForKey:@"LocationCode"]
                                                  companyCode:[dict valueForKey:@"CompanyCode"]
                                                 showTaskFlag:[[dict valueForKey:@"ShowTask"] intValue]
                                         showWorkFunctionFlag:[[dict valueForKey:@"ShowWorkFunction"] intValue]
                                    andIsUsingActiveDirectory:[[dict valueForKey:@"IsUsingAD"] intValue]];
        
        resourceObject.loginId = userName;
        resourceObject.password = password;
        resourceObject.authenticationKey = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_AUTHENTICATION_KEY];
        
        resourceObject.last_sync_date_level2 =[tempDict valueForKey:@"SyncDate"];
        resourceObject.last_sync_date_level2_customer = [tempDict valueForKey:@"SyncDate"];
        resourceObject.last_sync_date_level3 = [tempDict valueForKey:@"SyncDate"];
        resourceObject.last_sync_date_permanent_line = [tempDict valueForKey:@"SyncDate"];
        resourceObject.last_sync_date_res_usage = [tempDict valueForKey:@"SyncDate"];
        resourceObject.last_sync_date_sys_names = [tempDict valueForKey:@"SyncDate"];
        resourceObject.last_sync_date_task = [tempDict valueForKey:@"SyncDate"];
        resourceObject.last_sync_date_transaction = [tempDict valueForKey:@"SyncDate"];
    }
    
    return resourceObject;
}

-(void) insertResourceValuesInLocalDB:(Resource *)resObj
{
    NSString * deletionQuery = @"DELETE FROM pdd_resource;";
    [self executeQuery:deletionQuery];
    
    /*
     pdd_resource(company_code INTEGER NOT NULL, resource_id TEXT NOT NULL, login_id  TEXT NOT NULL, password TEXT NOT NULL, key TEXT NOT NULL, res_usage_code TEXT,org_unit TEXT,location_code TEXT,
        last_sync_datetime TEXT,
        last_sync_date_level2_customer DATETIME DEFAULT NULL,
        last_sync_date_res_usage DATETIME DEFAULT NULL,
        last_sync_date_sys_names DATETIME DEFAULT NULL,
        last_sync_date_task DATETIME DEFAULT NULL,
        last_sync_date_level2 DATETIME DEFAULT NULL,
        last_sync_date_level3 DATETIME DEFAULT NULL,
        last_sync_date_transaction DATETIME DEFAULT NULL,
        last_sync_date_permanent_line DATETIME DEFAULT NULL,
        show_task INTEGER DEFAULT 1,
        show_res_usage INTEGER DEFAULT 1
     */
    NSString * resourceQuery = [NSString stringWithFormat:@"INSERT INTO pdd_resource VALUES(%i,'%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@',%i,%i);",
                                [resObj.companyCode intValue],
                                resObj.resourceID,
                                resObj.loginId,
                                resObj.password,
                                resObj.authenticationKey,
                                resObj.resourceUsageCode,
                                resObj.orgUnitCode,
                                resObj.locationCode,
                                @"",
                                resObj.last_sync_date_level2_customer,
                                resObj.last_sync_date_res_usage,
                                resObj.last_sync_date_sys_names,
                                resObj.last_sync_date_task,
                                resObj.last_sync_date_level2,
                                resObj.last_sync_date_level3,
                                resObj.last_sync_date_transaction,
                                resObj.last_sync_date_permanent_line,
                                resObj.showTask,
                                resObj.showWorkFunction];
    
    [self.dbManager executeQuery:resourceQuery];
    if (self.dbManager.affectedRows != 0)
    {
        NSLog(@"Query For Inserting Resource Obj was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else
    {
        NSLog(@"Could not execute the query For Inserting Resource Obj.");
    }
}

-(Resource *) verifyUserCredentialsWithLocalDB
{
    NSString * loginQuery = @"SELECT * FROM pdd_resource;";
    NSArray * resTempArray =[self.dbManager loadDataFromDB:loginQuery];
    Resource * resObj = nil;
    if (resTempArray.count >0)
    {
        for (NSArray *resourceItemArray in resTempArray) {
            
            NSString * companyCode = [resourceItemArray objectAtIndex:0];
            NSString * resourceID = [resourceItemArray objectAtIndex:1];
            NSString * loginID = [resourceItemArray objectAtIndex:2];
            NSString * password = [resourceItemArray objectAtIndex:3];
            NSString * authenticationKey = [resourceItemArray objectAtIndex:4];
            NSString * resUsageCode = [resourceItemArray objectAtIndex:5];
            NSString * orgUnitCode = [resourceItemArray objectAtIndex:6];
            NSString * locationCode = [resourceItemArray objectAtIndex:7];
//            NSString * lastSyncDate = [resourceItemArray objectAtIndex:8];
            
            
            int showTask = [[resourceItemArray objectAtIndex:17] intValue];
            int showWorkFunc = [[resourceItemArray objectAtIndex:18] intValue];
            int isUsingAD = [[NSUserDefaults standardUserDefaults] boolForKey:UDKEY_IS_USING_ACTIVE_DIRECTORY];
            
            resObj  = [[Resource alloc] initWithResourceID:resourceID firstName:@"" lastName:@"" resCodeUsage:resUsageCode orgUnit:orgUnitCode locationCode:locationCode companyCode:companyCode showTaskFlag:showTask showWorkFunctionFlag:showWorkFunc andIsUsingActiveDirectory:isUsingAD];
            
            resObj.loginId = loginID;
            resObj.password = password;
            resObj.authenticationKey = authenticationKey;
            
            resObj.last_sync_date_level2_customer = [resourceItemArray objectAtIndex:9];
            resObj.last_sync_date_res_usage = [resourceItemArray objectAtIndex:10];
            resObj.last_sync_date_sys_names = [resourceItemArray objectAtIndex:11];
            resObj.last_sync_date_task = [resourceItemArray objectAtIndex:12];
            resObj.last_sync_date_level2 = [resourceItemArray objectAtIndex:13];
            resObj.last_sync_date_level3 = [resourceItemArray objectAtIndex:14];
            resObj.last_sync_date_transaction = [resourceItemArray objectAtIndex:15];
            resObj.last_sync_date_permanent_line = [resourceItemArray objectAtIndex:16];
        }
    }
    return  resObj;
}

-(void) saveFetchedLevel2ListFromServerInLocalDBAfterSynicing:(BOOL) isSyncing
{
    if (self.level2Array.count>0)
    {
        if (!isSyncing)
        {
            NSString * deletionQuery = @"DELETE FROM pdd_level2;";
            [self executeQuery:deletionQuery];
        }
        
        
        for (Level2_Job * job in self.level2Array)
        {
            /*
             pdd_level2(company_code INTEGER NOT NULL,level2_key TEXT NOT NULL, level2_description TEXT,level2_status INTEGER,close_date DATE, open_date DATE, PRIMARY KEY(company_code, level2_key))
             */
            
            NSString * query = @"";
            NSString * level2KeyString = [TLUtilities formatRequest:job.level2Key];
            NSString *level2DescString = [TLUtilities formatRequest:job.level2Description];
            NSString * openDateString = [TLUtilities ConvertDate:job.openDate FromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"];
            NSString * closeDateString = [TLUtilities ConvertDate:job.closeDate FromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"];
            
            if (!closeDateString || [closeDateString isEqualToString:@""])
            {
                closeDateString = @"2999-12-30";
            }
            
            int level2Status = job.level2Status;
            
            NSString * searchLevel2Query = [NSString stringWithFormat:@"SELECT * FROM pdd_level2 WHERE level2_key = '%@'",level2KeyString];
            
            NSArray * searchedLevel2Array =  [self.dbManager loadDataFromDB:searchLevel2Query];
            if (searchedLevel2Array.count >0)
            {
                query = [NSString stringWithFormat:@"UPDATE pdd_level2 SET level2_key = '%@', level2_description = '%@', level2_status = %i, close_date = '%@', open_date = '%@' WHERE level2_key = '%@'", level2KeyString, level2DescString, level2Status, closeDateString, openDateString, level2KeyString];
            }
            else
            {
                query = [NSString stringWithFormat:@"INSERT INTO pdd_level2 VALUES(%i,'%@','%@',%i,'%@','%@');",
                         [[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE] intValue],
                         level2KeyString,
                         level2DescString,
                         level2Status,
                         closeDateString,
                         openDateString];
            }
            
            [self executeQuery:query];
        }
    }
}

-(void) saveFetchedLevel3ListFromServerInLocalDBAfterSynicing:(BOOL) isSyncing
{
    if (self.level3Array.count>0)
    {
        if (!isSyncing) {
            NSString * deletionQuery = @"DELETE FROM pdd_level3;";
            [self executeQuery:deletionQuery];
        }
        
        for (Level3_Activity * activity in self.level3Array)
        {
            /*
             pdd_level3(company_code INTEGER NOT NULL,level2_key TEXT NOT NULL, level3_key TEXT NOT NULL, level3_description TEXT, billable_flag INTEGER, task_type INTEGER, labor_flag INTEGER, close_date DATE, open_date DATE, PRIMARY KEY(company_code, level2_key, level3_key))
             */
            NSString * openDateString =  [TLUtilities ConvertDate:activity.openDate FromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"] ;
            NSString * level2KeyString = [TLUtilities formatRequest:activity.level2Key];
            NSString * level3KeyString = [TLUtilities formatRequest:activity.level3Key];
            NSString *level3DescString = [TLUtilities formatRequest:activity.level3Description];
            int taskTypeCode = [activity.taskTypeCode intValue];
            int laborFlag = activity.laborFlag;
            NSString * closeDateString = [TLUtilities ConvertDate:activity.closeDate FromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"];
            
            if (!closeDateString || [closeDateString isEqualToString:@""])
            {
                closeDateString = @"2999-12-30";
            }
            
            
            // This check is suggested by Hamza on 27th Feb, 2015.
            NSString * level2KeyQuery =[ NSString stringWithFormat:@"SELECT * FROM pdd_level2 WHERE level2_key = '%@' AND level2_status = 0",level2KeyString];
            NSArray * searchedLevel2Array =  [self.dbManager loadDataFromDB:level2KeyQuery];
            if (searchedLevel2Array.count >0)
            {
                NSString * updatelevel2StatusQuery =[ NSString stringWithFormat:@"UPDATE pdd_level2 SET level2_status = 1 WHERE level2_key = '%@' ",level2KeyString];
                [self executeQuery:updatelevel2StatusQuery];
            }
            
            
            NSString * query = @"";
            
            NSString * searchLevel3Query = [NSString stringWithFormat:@"SELECT * FROM pdd_level3 WHERE level2_key = '%@' AND level3_key = '%@'",level2KeyString, level3KeyString];
            NSArray * searchedLevel3Array =  [self.dbManager loadDataFromDB:searchLevel3Query];
            
            if (searchedLevel3Array.count >0)
            {
                query = [NSString stringWithFormat:@"UPDATE pdd_level3 SET level2_key = '%@', level3_key = '%@', level3_description = '%@', billable_flag = 0, task_type = %i, labor_flag = %i, close_date = '%@', open_date = '%@' WHERE level2_key = '%@' AND level3_key = '%@'", level2KeyString, level3KeyString, level3DescString, taskTypeCode,laborFlag,closeDateString,openDateString,level2KeyString, level3KeyString];
            }
            else
            {
                query = [NSString stringWithFormat:@"INSERT INTO pdd_level3 VALUES(%i,'%@','%@','%@',%i,%i, %i, '%@','%@');",
                                    [[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE] intValue],
                                    level2KeyString,
                                    level3KeyString,
                                    level3DescString,
                                    0,
                                    taskTypeCode,
                                    laborFlag,
                                    closeDateString,
                                    openDateString];
            }
            [self executeQuery:query];
        }
    }
}
-(void) saveFetchedLevel2CustomerListFromServerInLocalDBAfterSynicing:(BOOL) isSyncing {
    
    if (self.level2CustomerArray.count >0) {
        if (!isSyncing) {
            NSString * deletionQuery = @"DELETE FROM pdd_level2_customer;";
            [self executeQuery:deletionQuery];
        }
        
        for (Level2_Customer * customer in self.level2CustomerArray) {
            /*
             pdd_level2_customer(company_code INTEGER,customer_code TEXT, customer_name TEXT,level2_key TEXT,PRIMARY KEY(company_code, customer_code));
             */
            NSString * level2KeyString = [TLUtilities formatRequest:customer.level2Key];
            NSString * customerCodeString = [TLUtilities formatRequest:customer.customerCode];
            NSString * customerNameString = [TLUtilities formatRequest:customer.customerName];
            
            NSString * query = @"";
            
            NSString * searchLevel2CustomerQuery = [NSString stringWithFormat:@"SELECT * FROM pdd_level2_customer WHERE customer_code = '%@' AND level2_key = '%@'",customerCodeString, level2KeyString];
            NSArray * searchedLevel2CustomerArray =  [self.dbManager loadDataFromDB:searchLevel2CustomerQuery];
            
            if (searchedLevel2CustomerArray.count >0)
            {
                query = [NSString stringWithFormat:@"UPDATE pdd_level2_customer SET customer_code = '%@', customer_name = '%@',level2_key = '%@' WHERE customer_code = '%@' AND level2_key = '%@'", customerCodeString, customerNameString,level2KeyString,customerCodeString, level2KeyString];
            }
            else
            {
                query = [NSString stringWithFormat:@"INSERT INTO pdd_level2_customer VALUES(%i,'%@','%@','%@');",
                                    [[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE] intValue],
                                    customerCodeString,
                                    customerNameString,
                                    level2KeyString];
            }
            [self executeQuery:query];
            
        }
    }
}

-(void) saveFetchedTasksListFromServerInLocalDBAfterSynicing:(BOOL) isSyncing {
    
    if (self.taskArray.count >0)
    {
//        if (!isSyncing)
//        {
            NSString * deletionQuery = @"DELETE FROM pdd_task;";
            [self executeQuery:deletionQuery];
            
            NSString * taskTypeDeletionQuery = @"DELETE FROM pdm_task_type;";
            [self executeQuery:taskTypeDeletionQuery];
//        }
        
        
        
        for (Task * task in self.taskArray)
        {
            
            
            NSString *taskDescString = [TLUtilities formatRequest:task.taskDescription];
            NSString * taskCodeString = task.taskCode;
            int taskType = task.taskType;
            NSString *taskTypeDescString = [TLUtilities formatRequest:task.taskTypeDescription];
            
            
            
            /*
             pdd_task(company_code INTEGER,task_type INTEGER, task_code TEXT,task_description TEXT,PRIMARY KEY(company_code, task_type, task_code));
             */
            NSString * queryForTask = @"";
            
            NSString * searchTaskQuery = [NSString stringWithFormat:@"SELECT * FROM pdd_task WHERE task_code = '%@' AND task_type = %i ",taskCodeString, taskType];
            NSArray * searchedTaskArray =  [self.dbManager loadDataFromDB:searchTaskQuery];
            if (searchedTaskArray.count>0)
            {
                queryForTask = [NSString stringWithFormat:@"UPDATE pdd_task SET task_type = %i, task_code = '%@', task_description = '%@' WHERE task_type = %i AND task_code = '%@'", taskType, taskCodeString, taskDescString, taskType, taskCodeString];
            }
            else
            {
                queryForTask = [NSString stringWithFormat:@"INSERT INTO pdd_task VALUES(%i,%i,'%@','%@');",
                                [[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE] intValue],
                                taskType,
                                taskCodeString,
                                taskDescString];
            }
            [self executeQuery:queryForTask];
            
            
            /*
             pdm_task_type(company_code INTEGER,task_type INTEGER, task_type_name TEXT,PRIMARY KEY(company_code, task_type));
             */
            NSString * queryForTaskType = @"";
            
            NSString * searchTaskTypeQuery = [NSString stringWithFormat:@"SELECT * FROM pdm_task_type WHERE task_type = %i ", taskType];
            NSArray * searchedTaskTypeArray =  [self.dbManager loadDataFromDB:searchTaskTypeQuery];
            if (searchedTaskTypeArray.count>0)
            {
                queryForTaskType = [NSString stringWithFormat:@"UPDATE pdm_task_type SET task_type = %i,task_type_name = '%@' WHERE task_type = %i",taskType, taskTypeDescString, taskType];
            }
            else
            {
                queryForTaskType =[NSString stringWithFormat:@"INSERT INTO pdm_task_type VALUES(%i,%i,'%@');",
                                   [[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE] intValue],
                                   taskType,
                                   taskTypeDescString];
            }
            [self executeQuery:queryForTaskType];
            
        }
        
    }
}

-(void) saveFetchedWorkFuncListFromServerInLocalDBAfterSynicing:(BOOL) isSyncing
{
    if (self.workFunctionArray.count >0)
    {
        // Now delete all WorkFunctions and reload them in DB. As per instructions from Hamza 9th March, 2015.s
//        if (!isSyncing) {
            NSString * deletionQuery = @"DELETE FROM pdm_res_usage;";
            [self executeQuery:deletionQuery];
//        }
        
        for (WorkFunction * workFunction in self.workFunctionArray)
        {
            /*
             pdm_res_usage(company_code INTEGER,res_usage_code TEXT, res_usage_description TEXT,PRIMARY KEY(company_code, res_usage_code));
             */
            NSString * resUsageCodeString = workFunction.resUsageCode;
            NSString *resUsageDescString = [TLUtilities formatRequest:workFunction.resUsageDescription];
            
            NSString * query = @"";
//
//            NSString * searchWorkFuncQuery = [NSString stringWithFormat:@"SELECT * FROM pdm_res_usage WHERE res_usage_code = '%@' ", resUsageCodeString];
//            NSArray * searchWorkFuncArray =  [self.dbManager loadDataFromDB:searchWorkFuncQuery];
//            if (searchWorkFuncArray.count>0)
//            {
//                query = [NSString stringWithFormat:@"UPDATE pdm_res_usage SET res_usage_description = '%@' WHERE res_usage_code = '%@'", resUsageDescString, resUsageCodeString];
//            }
//            else
//            {
                query = [NSString stringWithFormat:@"INSERT INTO pdm_res_usage VALUES(%i,'%@','%@');",
                                    [[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE] intValue],
                                    resUsageCodeString,
                                    resUsageDescString];
//            }
            [self executeQuery:query];
        }
    }
}

-(void) saveFetchedSysNamesListFromServerInLocalDBAfterSynicing:(BOOL) isSyncing
{
    if (self.sysNamesArray.count >0)
    {
        if (!isSyncing)
        {
            NSString * deletionQuery = @"DELETE FROM pdm_sys_names;";
            [self executeQuery:deletionQuery];
        }
        
        for (SysNames * sysNameObj in self.sysNamesArray)
        {
            /*
             pdm_sys_names(company_code INTEGER NOT NULL,field_name TEXT, display_name TEXT,PRIMARY KEY(company_code, field_name));
             */
            
            NSString *fieldNameString = [TLUtilities formatRequest:sysNameObj.fieldName];
            NSString *displayNameString = [TLUtilities formatRequest:sysNameObj.displayName];
            
            NSString * query = @"";
            
            NSString * searchSysNamesQuery = [NSString stringWithFormat:@"SELECT * FROM pdm_sys_names WHERE field_name = '%@' ", fieldNameString];
            NSArray * searchSysNamesArray =  [self.dbManager loadDataFromDB:searchSysNamesQuery];
            if (searchSysNamesArray.count>0)
            {
                query = [NSString stringWithFormat:@"UPDATE pdm_sys_names SET field_name = '%@', display_name = '%@' WHERE field_name = '%@'", fieldNameString, displayNameString, fieldNameString];
            }
            else
            {
                query = [NSString stringWithFormat:@"INSERT INTO pdm_sys_names VALUES(%i,'%@','%@');",
                                    [[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE] intValue],
                                    fieldNameString,
                                    displayNameString];
            }
            [self executeQuery:query];
        }
    }
    if (isSyncing)
    {
        [self updateLastSyncDatesInResourceTable];
    }
}

-(void) saveFetchedPermanentLinesListFromServerInLocalDBAfterSynicing:(BOOL) isSyncing
{
    NSString * deletionQuery = @"DELETE FROM pdm_permanent_line;";
    [self executeQuery:deletionQuery];
    
    if (self.permanentLineArray.count >0)
    {
        for (PermanentLines * permanentLineObj in self.permanentLineArray)
        {
            /*
             pdm_permanent_line(company_code INTEGER NOT NULL,level2_key TEXT NOT NULL, level3_key TEXT NOT NULL,task_code TEXT,start_date DATE,end_date DATE,sync_status INTEGER,deleted INTEGER,PRIMARY KEY(company_code, level2_key, level3_key, task_code));
             */
            
            NSString * startDate = [TLUtilities ConvertDate:permanentLineObj.startDate FromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"];
            NSString * endDateString = permanentLineObj.endDate;
            if (!endDateString || [endDateString isEqual:[NSNull null]]) {
                endDateString = @"2099-12-30";
            }
            else
            {
                endDateString=  [TLUtilities ConvertDate:endDateString FromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"];
            }
            
            NSString * level2Key = [TLUtilities formatRequest:permanentLineObj.level2Key];
            NSString * level3Key = [TLUtilities formatRequest:permanentLineObj.level3Key];
            
            NSString * query = [NSString stringWithFormat:@"INSERT INTO pdm_permanent_line VALUES(%i,'%@','%@','%@','%@','%@',%i,%i);",
                                [[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE] intValue],
                                level2Key,
                                level3Key,
                                permanentLineObj.taskCode,
                                startDate,
                                endDateString,
                                1,
                                0];
            [self executeQuery:query];
        }
    }
}

-(void) saveFetchedTransactionsListFromServerInLocalDBAfterSynicing:(BOOL) isSyncing
{
    if (self.transactionArray.count >0)
    {
        if (!isSyncing)
        {
            NSString * deletionQuery = @"DELETE FROM pld_transaction;";
            [self executeQuery:deletionQuery];
        }
        
        for (Transaction * transactionObj in self.transactionArray)
        {
            // First Check If Transaction is already available in LocalDB
            // If Yes then update it
            //else Add it
            
            NSString * searchTransactionQuery = [NSString stringWithFormat:@"SELECT * FROM pld_transaction WHERE transaction_id = '%@'",transactionObj.transactionID];
            NSArray * searchedTransactionArray =  [self.dbManager loadDataFromDB:searchTransactionQuery];
            if (searchedTransactionArray.count >0)
            {
                [self updateTransactionInLocalDB:transactionObj];
            }
            else
            {
                [self addNewTransactionInLocalDB:transactionObj];
            }
        }
        
    }
}

-(void) syncDataFetchedFromServerWithLocalDB
{
    [self saveFetchedLevel2ListFromServerInLocalDBAfterSynicing:NO];
    [self saveFetchedLevel3ListFromServerInLocalDBAfterSynicing:NO];
    [self saveFetchedLevel2CustomerListFromServerInLocalDBAfterSynicing:NO];
    [self saveFetchedTasksListFromServerInLocalDBAfterSynicing:NO];
    [self saveFetchedWorkFuncListFromServerInLocalDBAfterSynicing:NO];
    [self saveFetchedSysNamesListFromServerInLocalDBAfterSynicing:NO];
    [self saveFetchedPermanentLinesListFromServerInLocalDBAfterSynicing:NO];
    [self saveFetchedTransactionsListFromServerInLocalDBAfterSynicing:NO];
    [self.delegate dataSyncedSuccessfully];
}


#pragma mark - Add/Delete PermanentLine Methods

-(NSString *) fetchTitleOfField:(NSString *) fieldName
{
    NSString *query = [NSString stringWithFormat:@"SELECT display_name FROM pdm_sys_names WHERE field_name = '%@';",fieldName];
    NSString * titleString = [[[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:query] lastObject] lastObject];
    return titleString;
}

-(void) validateLevel2AndLeve3KeyDatesOfPermanentLine:(PermanentLines *) permLineObj
{
    BOOL showErrorAlert = NO;
    
    NSString * queryForLevel2 = [NSString stringWithFormat:@"SELECT * FROM pdd_level2 WHERE level2_key = '%@'", permLineObj.level2Key];
    NSArray * level2Array = [[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:queryForLevel2] lastObject];
    NSString * level2Status = [level2Array objectAtIndex:3];
    NSString * level2CloseDate = [level2Array objectAtIndex:4];
    NSString * level2OpenDate = [level2Array objectAtIndex:5];
    
    
    NSString * errorDescString = @"Cannot save the Permanent Line(s) for this";
    
    NSString * convertedLevel2OpenDate = [TLUtilities ConvertDate:level2OpenDate FromFormat:@"yyyy-MM-dd" toFormat:@"MM/dd/yyyy"];
    NSString * convertedLevel2ClosedDate = [TLUtilities ConvertDate:level2CloseDate FromFormat:@"yyyy-MM-dd" toFormat:@"MM/dd/yyyy"];
    
    NSString * level2SysName = [self fetchTitleOfField:TIME_BASED_LEVEL2_DESCRIPTION];
    NSString * level3SysName = [self fetchTitleOfField:TIME_BASED_LEVEL3_DESCRIPTION];
    
    
    if (level2Status.intValue != 1)
    {
        NSString * tempString = [NSString stringWithFormat:@" %@:%@ is not open", level2SysName,permLineObj.level2Key];
        errorDescString = [errorDescString stringByAppendingString:tempString];
        
        showErrorAlert = YES;
    }
    else if ([permLineObj.startDate compare:level2OpenDate] == NSOrderedAscending)
    {
        NSLog(@"Applied Date is Earlier than Level2 Open Date");
        
        NSString * tempString = [NSString stringWithFormat:@" %@:%@ is not valid earlier than %@", level2SysName,permLineObj.level2Key, convertedLevel2OpenDate];
        errorDescString = [errorDescString stringByAppendingString:tempString];
        
        showErrorAlert = YES;
    }
    else if (!level2CloseDate || ![level2CloseDate isEqualToString:@""])
    {
        if ([permLineObj.startDate compare:level2CloseDate] == NSOrderedDescending) {
            NSLog(@"Applied Date is  Later than Level2 Closed Date");
            
            NSString * tempString = [NSString stringWithFormat:@" %@:%@ is not valid later than %@", level2SysName,permLineObj.level2Key, convertedLevel2ClosedDate];
            errorDescString = [errorDescString stringByAppendingString:tempString];
            
            showErrorAlert = YES;
        }
    }
    
    
    if (showErrorAlert)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:errorDescString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        NSString * queryForLevel3 = [NSString stringWithFormat:@"SELECT * FROM pdd_level3 WHERE level3_key = '%@' AND level2_key = '%@'", permLineObj.level3Key, permLineObj.level2Key];
        NSArray * level3Array = [[[DataSyncHandler defaultHandler].dbManager loadDataFromDB:queryForLevel3] lastObject];
        NSString * level3Labor = [level3Array objectAtIndex:6];
        NSString * level3CloseDate = [level3Array objectAtIndex:7];
        NSString * level3OpenDate = [level3Array objectAtIndex:8];
        
        NSString * convertedLevel3OpenDate = [TLUtilities ConvertDate:level3OpenDate FromFormat:@"yyyy-MM-dd" toFormat:@"MM/dd/yyyy"];
        NSString * convertedLevel3ClosedDate = [TLUtilities ConvertDate:level3CloseDate FromFormat:@"yyyy-MM-dd" toFormat:@"MM/dd/yyyy"];
        
        if (level3Labor.intValue!=1)
        {
            NSString * tempString = [NSString stringWithFormat:@" %@:%@  %@:%@ is not valid for the Time Entry", level2SysName,permLineObj.level2Key, level3SysName, permLineObj.level3Key];
            errorDescString = [errorDescString stringByAppendingString:tempString];
            
            showErrorAlert = YES;
        }
        else if ([permLineObj.startDate compare:level3OpenDate] == NSOrderedAscending)
        {
            NSLog(@"Applied Date is Earlier than Level3 Open Date");
            
            NSString * tempString = [NSString stringWithFormat:@" %@:%@  %@:%@ is not valid earlier than %@", level2SysName,permLineObj.level2Key, level3SysName, permLineObj.level3Key, convertedLevel3OpenDate];
            errorDescString = [errorDescString stringByAppendingString:tempString];
            
            showErrorAlert = YES;
        }
        else if (!level3CloseDate || ![level3CloseDate isEqualToString:@""])
        {
            if ([permLineObj.startDate compare:level3CloseDate] == NSOrderedDescending) {
                NSLog(@"Applied Date is  Later than Level3 Closed Date");
                
                NSString * tempString = [NSString stringWithFormat:@" %@:%@  %@:%@ is not valid later than %@", level2SysName,permLineObj.level2Key, level3SysName, permLineObj.level3Key, convertedLevel3ClosedDate];
                errorDescString = [errorDescString stringByAppendingString:tempString];
                
                showErrorAlert = YES;
            }
        }
        
        if (showErrorAlert)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:errorDescString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        else
        {
            [self savePermanentLineInLocalDB:permLineObj withSyncStatus:0];
        }
    }
}

-(void) savePermanentLineInLocalDB:(PermanentLines *) permLineObj withSyncStatus:(int) syncStatus
{
    
    // If offline then Check if the permanent Line already exists.
    // If it exists the Update its deletedFlag to Zero again.
    // Else create a new Permanent Line.
    
    NSString * companyCode = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE];
    NSInteger showTask = [[NSUserDefaults standardUserDefaults] integerForKey:UDKEY_SHOW_TASKS];
    
    NSString * startDate = [TLUtilities ConvertDate:permLineObj.startDate FromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"];
    
    
    NSString * addPermanentLinesQuery = [NSString stringWithFormat:@"INSERT INTO pdm_permanent_line VALUES (%i,'%@','%@','%@','%@','%@',%i,%i);",
                                         [companyCode intValue],
                                         permLineObj.level2Key,
                                         permLineObj.level3Key,
                                         permLineObj.taskCode,
                                         startDate,
                                         @"2066-12-30",
                                         syncStatus,
                                         0];
    
    NSString * findPermanentLineQuery = @"";
    if (showTask == 3)
    {
        findPermanentLineQuery = [NSString stringWithFormat:@"SELECT * FROM pdm_permanent_line WHERE company_code =%i AND level2_key ='%@' AND level3_key='%@' AND task_code='%@';",[companyCode intValue],permLineObj.level2Key, permLineObj.level3Key, permLineObj.taskCode];
    }
    else
    {
        findPermanentLineQuery = [NSString stringWithFormat:@"SELECT * FROM pdm_permanent_line WHERE company_code =%i AND level2_key ='%@' AND level3_key='%@';",[companyCode intValue],permLineObj.level2Key, permLineObj.level3Key];
    }
    
    NSArray * permLineArray = [self.dbManager loadDataFromDB:findPermanentLineQuery];
    if (permLineArray.count >0)
    {
        for (NSArray * tempArray in permLineArray)
        {
            NSString * level2Key = [tempArray objectAtIndex:1];
            NSString * level3Key = [tempArray objectAtIndex:2];
            NSString * taskCode = [tempArray objectAtIndex:3];
            
            NSString * updateQuery = @"";
            if (showTask == 3)
            {
                updateQuery = [NSString stringWithFormat:@"UPDATE pdm_permanent_line SET sync_status = %i, deleted=0 WHERE company_code =%i AND level2_key ='%@' AND level3_key='%@' AND task_code='%@';",syncStatus,[companyCode intValue],level2Key, level3Key, taskCode];
            }
            else
            {
                updateQuery = [NSString stringWithFormat:@"UPDATE pdm_permanent_line SET sync_status = %i, deleted=0 WHERE company_code =%i AND level2_key ='%@' AND level3_key='%@' ;",syncStatus,[companyCode intValue],level2Key, level3Key];
            }
            
            [self.dbManager executeQuery:updateQuery];
            if (self.dbManager.affectedRows != 0)
            {
                NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
                if (!self.isDelegateSetFromLogin)
                {
                    [self.delegate permanentLineDeletedSuccessfully];
                }
            }
            else
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:@"Could not Delete Permanent Line from DB" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [self.delegate permanentLineNotDeletedDueToError];
            }
        }
    }
    else
    {
        [self.dbManager executeQuery:addPermanentLinesQuery];
        if (self.dbManager.affectedRows != 0)
        {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
            if (!self.isDelegateSetFromLogin) {
                [self.delegate permanentLineAddedSuccessfully];
            }
        }
        else
        {
            NSLog(@"%@",PERMANENT_LINE_NOT_SAVED_IN_DB);
            [self.delegate permanentLineNotAddedDueToError];
        }
    }
}

-(void) addNewPermanentLineWithLevel2Key:(NSString *)level2KeyString level3Key:(NSString *)level3KeyString taskCode:(NSString *)taskCodeString forDate:(NSString *)selectedDateString
{
    /*
     pdm_permanent_line(company_code INTEGER NOT NULL,level2_key TEXT NOT NULL, level3_key TEXT NOT NULL,task_code TEXT,start_date DATE,end_date DATE,sync_status INTEGER,deleted  INTEGER,PRIMARY KEY(company_code, level2_key, level3_key, task_code))
     */
    
    selectedDateString = [TLUtilities ConvertDate:selectedDateString FromFormat:@"yyyy-MM-dd HH:mm:ss z" toFormat:@"yyyy-MM-dd HH:mm:ss"];
    PermanentLines * permLineObj = [[PermanentLines alloc] initWithLevel2Key:level2KeyString level3Key:level3KeyString withTaskCode:taskCodeString startingDate:selectedDateString endingDate:@"2066-12-30" andResourceID:[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_RESOURCE_ID]];
    
    if ([TLUtilities verifyInternetAvailability])
    {
        [[WebservicesManager defaultManager] PermanentLinesSET:permLineObj withActionFlag:1  CompletionHandler:^(NSError *error, NSDictionary *user)
         {
            if (!error && user)
            {
                BOOL success = NO;
                NSString * messageString = [user valueForKey:@"Message"];
                int responseType = [[user valueForKey:@"ResponseType"] intValue];
                if (responseType == 0)
                {
                    success = YES;

                    [self savePermanentLineInLocalDB:permLineObj withSyncStatus:1];
                }
                else
                {
                    if (self._syncTypes != forLogin)
                    {
                        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:messageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
                    }
                    [self.delegate permanentLineNotAddedDueToError];
                }
            }
        }];
    }
    else
    {
        // If offline then Check if the permanent Line already exists.
        // If it exists the Update its deletedFlag to Zero again.
        // Else create a new Permanent Line.
        
        [self validateLevel2AndLeve3KeyDatesOfPermanentLine:permLineObj];
//        [self savePermanentLineInLocalDB:permLineObj withSyncStatus:0];
    }
}
-(void) deletePermanentLineFromLocalDBAndServerForLevel2Key:(NSString *)level2keyString level3Key:(NSString *)level3KeyString taskCode:(NSString *)taskCodeString andStartDate:(NSString *)startDateString
{
     NSString * deleteQueryString = @"";
    
    NSString *companyCode =[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE];
    NSInteger showTask = [[NSUserDefaults standardUserDefaults] integerForKey:UDKEY_SHOW_TASKS];
    
    startDateString = [TLUtilities ConvertDate:startDateString FromFormat:@"yyyy-MM-dd HH:mm:ss z" toFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    if (showTask == 3)
    {
        deleteQueryString = [NSString stringWithFormat:@"DELETE FROM pdm_permanent_line WHERE company_code =%i AND level2_key ='%@' AND level3_key='%@' AND task_code='%@';",[companyCode intValue],level2keyString, level3KeyString, taskCodeString];
    }
    else
        deleteQueryString = [NSString stringWithFormat:@"DELETE FROM pdm_permanent_line WHERE company_code =%i AND level2_key ='%@' AND level3_key='%@';",[companyCode intValue],level2keyString, level3KeyString];
    
    if ([TLUtilities verifyInternetAvailability])
    {
        PermanentLines * permLineObj = [[PermanentLines alloc] initWithLevel2Key:level2keyString level3Key:level3KeyString withTaskCode:taskCodeString startingDate:startDateString endingDate:@"2066-12-30" andResourceID:[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_RESOURCE_ID]];
        
        [[WebservicesManager defaultManager] PermanentLinesSET:permLineObj withActionFlag:3 CompletionHandler:^(NSError *error, NSDictionary *user) {
            
            if (!error && user)
            {
                BOOL success = NO;
                NSString * messageString = [user valueForKey:@"Message"];
                int responseType = [[user valueForKey:@"ResponseType"] intValue];
                if (responseType == 0)
                {
                    success = YES;
                    
                    [self.dbManager executeQuery:deleteQueryString];
                    if (self.dbManager.affectedRows != 0)
                    {
                        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
                        [self.delegate permanentLineDeletedSuccessfully];
                    }
                    else
                    {
                        NSLog(@"%@",PERMANENT_LINE_NOT_DELETED_IN_DB);
                    }
                }
                else
                {
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:messageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                }
            }
            
        }];
    }
    else
     {
         // Changes as per explained by Hamza on 9th Feb, 2015.
         // We shall not delete the Permanent line from LocalDB just update its Deleted Flag to 1 in OFFLINE MODE
         NSString * updateQuery = @"";
        
         if (showTask == 3)
         {
             updateQuery = [NSString stringWithFormat:@"UPDATE pdm_permanent_line SET sync_status = 0 ,deleted=1 WHERE company_code =%i AND level2_key ='%@' AND level3_key='%@' AND task_code='%@';",[companyCode intValue],level2keyString, level3KeyString, taskCodeString];
         }
         else
         {
             updateQuery = [NSString stringWithFormat:@"UPDATE pdm_permanent_line SET sync_status = 0 ,deleted=1 WHERE company_code =%i AND level2_key ='%@' AND level3_key='%@' ;",[companyCode intValue],level2keyString, level3KeyString];
         }
         
        [self.dbManager executeQuery:updateQuery];
        if (self.dbManager.affectedRows != 0)
        {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
            [self.delegate permanentLineDeletedSuccessfully];
        }
        else
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:@"Could not Delete Permanent Line from DB" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }
}

#pragma mark - Add/Update/Delete Transactions Methods

-(void) addNewTransactionInLocalDB:(Transaction *) transactionObj
{
    /*
     pld_transaction(company_code INTEGER NOT NULL,transaction_id TEXT NOT NULL,level2_key  TEXT NOT NULL,level3_key TEXT NOT NULL, applied_date DATE NOT NULL,trx_type INTEGER NOT NULL,resource_id TEXT NOT NULL,res_usage_code TEXT,unit REAL,location_code TEXT,org_unit  TEXT,task_code TEXT, comments TEXT,nonbillable_flag INTEGER,submitted_flag  INTEGER,submitted_date DATE, approval_flag INTEGER,sync_status INTEGER,deleted  INTEGER,modified_datetime DATE,timestamp TEXT, error_flag INTEGER,error_code INTEGER, error_description TEXT, PRIMARY KEY(company_code, transaction_id))
     */
    
    NSString * appliedDateString = [TLUtilities convertServerSideDate: transactionObj.appliedDate];
    NSString * submittedDateString = [TLUtilities convertServerSideDate: transactionObj.submittedDate];
    NSString * modifiedDateString = [TLUtilities convertServerSideDate: transactionObj.modifyDate];
    
    NSString * level2KeyString = [TLUtilities formatRequest:transactionObj.level2Key];
    NSString * level3KeyString = [TLUtilities formatRequest:transactionObj.level3Key];
    NSString * commentsString = [TLUtilities formatRequest:transactionObj.comments];
    NSString * resUsageCodeString = [TLUtilities formatRequest:transactionObj.resUsageCode];
    
    transactionObj.appliedDate = appliedDateString;
    transactionObj.submittedDate = submittedDateString;
    transactionObj.modifyDate = modifiedDateString;
    
    transactionObj.level2Key = level2KeyString;
    transactionObj.level3Key = level3KeyString;
    transactionObj.comments = commentsString;
    transactionObj.resUsageCode = resUsageCodeString;
    
    if (transactionObj.errorFlag>0)
    {
        transactionObj.syncStatus = 0;
    }
    else
    {
        transactionObj.syncStatus = 1;
    }
    
    
    
   NSString * query = [NSString stringWithFormat:@"INSERT INTO pld_transaction VALUES(%i,'%@','%@','%@','%@',%i,'%@','%@',%.2f,'%@','%@','%@','%@',%i,%i,'%@',%i,%i,%i,'%@', '%@', %i, %i, '%@');",[[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE] intValue],
             transactionObj.transactionID,
             transactionObj.level2Key,
             transactionObj.level3Key,
             transactionObj.appliedDate,
             transactionObj.transactionType,
             transactionObj.resourceID,
             transactionObj.resUsageCode,
             transactionObj.units,
             transactionObj.locationCode,
             transactionObj.orgUnit,
             transactionObj.taskCode,
             transactionObj.comments,
             transactionObj.nonBillableFlag,
             transactionObj.submitFlag,
             transactionObj.submittedDate,
             transactionObj.approvalStatus,
             transactionObj.syncStatus,
             0,
             transactionObj.modifyDate,
             transactionObj.timeStamp,
             transactionObj.errorFlag,
             transactionObj.errorCode,
             transactionObj.errorDescription];
    
    [self executeQuery:query];
}

-(void) updateTransactionInLocalDB:(Transaction *) transactionObj
{
    /*
     pld_transaction(company_code INTEGER NOT NULL,transaction_id TEXT NOT NULL,level2_key  TEXT NOT NULL,level3_key TEXT NOT NULL, applied_date DATE NOT NULL,trx_type INTEGER NOT NULL,resource_id TEXT NOT NULL,res_usage_code TEXT,unit REAL,location_code TEXT,org_unit  TEXT,task_code TEXT, comments TEXT,nonbillable_flag INTEGER,submitted_flag  INTEGER,submitted_date DATE, approval_flag INTEGER,sync_status INTEGER,deleted  INTEGER,modified_datetime DATE,timestamp TEXT, error_flag INTEGER,error_code INTEGER, error_description TEXT, PRIMARY KEY(company_code, transaction_id))
     */
    
    NSString * appliedDateString = [TLUtilities convertServerSideDate: transactionObj.appliedDate];
    NSString * submittedDateString = [TLUtilities convertServerSideDate: transactionObj.submittedDate];
    NSString * modifiedDateString = [TLUtilities convertServerSideDate: transactionObj.modifyDate];
    
    NSString * level2KeyString = [TLUtilities formatRequest:transactionObj.level2Key];
    NSString * level3KeyString = [TLUtilities formatRequest:transactionObj.level3Key];
    NSString * commentsString = [TLUtilities formatRequest:transactionObj.comments];
    NSString * resUsageCodeString = [TLUtilities formatRequest:transactionObj.resUsageCode];
    
    transactionObj.appliedDate = appliedDateString;
    transactionObj.submittedDate = submittedDateString;
    transactionObj.modifyDate = modifiedDateString;
    
    transactionObj.level2Key = level2KeyString;
    transactionObj.level3Key = level3KeyString;
    transactionObj.comments = commentsString;
    transactionObj.resUsageCode = resUsageCodeString;
    
    if (transactionObj.errorFlag>0)
    {
        transactionObj.syncStatus = 0;
        transactionObj.submitFlag = 0;
    }
    else
    {
        transactionObj.syncStatus = 1;
    }
    
    
    // Transaction Found. Now update it.
    NSString * query = [NSString stringWithFormat:@"UPDATE pld_transaction SET level2_key = '%@', level3_key = '%@', applied_date = '%@',trx_type = %i,resource_id = '%@', res_usage_code = '%@', unit= %.2f, location_code = '%@', org_unit = '%@', task_code='%@',comments='%@', nonbillable_flag = %i, submitted_flag = %i, submitted_date = '%@', approval_flag = %i, sync_status = %i, deleted = 0, modified_datetime= '%@', timestamp = '%@',error_flag = %i, error_code = %i, error_description = '%@' WHERE  transaction_id = '%@';",
                        transactionObj.level2Key,
                        transactionObj.level3Key,
                        transactionObj.appliedDate,
                        transactionObj.transactionType,
                        transactionObj.resourceID,
                        transactionObj.resUsageCode,
                        transactionObj.units,
                        transactionObj.locationCode,
                        transactionObj.orgUnit,
                        transactionObj.taskCode,
                        transactionObj.comments,
                        transactionObj.nonBillableFlag,
                        transactionObj.submitFlag,
                        transactionObj.submittedDate,
                        transactionObj.approvalStatus,
                        transactionObj.syncStatus,
                        transactionObj.modifyDate,
                        transactionObj.timeStamp,
                        transactionObj.errorFlag,
                        transactionObj.errorCode,
                        transactionObj.errorDescription,
                        transactionObj.transactionID];
             
 
    [self executeQuery:query];
}

-(void) deleteParticularTransactionFromLocalDB:(Transaction *) transactionObj
{
    NSString * deleteQuery = [NSString stringWithFormat:@"DELETE FROM pld_transaction WHERE transaction_id = '%@';",transactionObj.transactionID];
    [self executeQuery:deleteQuery];
}

-(Transaction *) makeAnTransactionItemFromServerDictionary:(NSDictionary *) tempDict
{
    
    Transaction * transactionObj = [[Transaction alloc] initTransactionWithID:[tempDict valueForKey:@"TransactionID"]
                                                              transactionType:[[tempDict valueForKey:@"TrxType"] intValue]
                                                                        ofJob:[tempDict valueForKey:@"Level2Key"]
                                                                     activity:[tempDict valueForKey:@"Level3Key"]
                                                                     taskCode:[tempDict valueForKey:@"TaskCode"]
                                                                      orgUnit:[tempDict valueForKey:@"OrgUnit"]
                                                                     comments:[tempDict valueForKey:@"Comments"]
                                                                     resource:[tempDict valueForKey:@"ResourceID"]
                                                                 resUsageCode:[tempDict valueForKey:@"ResUsageCode"]
                                                                    appliedOn:[tempDict valueForKey:@"AppliedDate"]
                                                                   modifiedOn:[tempDict valueForKey:@"SubmittedDate"]
                                                                  submittedOn:[tempDict valueForKey:@"SubmittedDate"]
                                                            withApprovalFlags:[[tempDict valueForKey:@"ApprovalFlag"] intValue]
                                                                   submitFlag:[[tempDict valueForKey:@"SubmittedFlag"] intValue]
                                                              nonBillableFlag:[[tempDict valueForKey:@"NonBillableFlag"] intValue]
                                                                andSyncedFlag:[[tempDict valueForKey:@"Level2Key"] intValue]
                                                                        Units:[[tempDict valueForKey:@"Units"] floatValue]
                                                              andLocationCode:[tempDict valueForKey:@"LocationCode"]];
    
    transactionObj.errorCode = [[tempDict valueForKey:@"ErrorCode"] floatValue];
    transactionObj.errorFlag = [[tempDict valueForKey:@"ErrorFlag"] floatValue];
    transactionObj.errorDescription = [tempDict valueForKey:@"ErrorDescription"];
    transactionObj.timeStamp = [tempDict valueForKey:@"StrTimeStamp"];
    
    return transactionObj;
}

-(void) addTransactionOnServer:(Transaction *) transactObj completionHandler:(AddJobDataSyncCompletionHandler) handler
{
    [[WebservicesManager defaultManager] TransactionSET:transactObj withActionFlag:1 CompletionHandler:^(NSError *error, NSDictionary *user)
    {
        if (!error && user)
        {
            BOOL success = NO;
            NSString * messageString = [user valueForKey:@"Message"];
            int responseType = [[user valueForKey:@"ResponseType"] intValue];
            if (responseType == 0)
            {
                NSArray * entitiesArray = [user valueForKey:@"Entities"];
                
                for (NSDictionary * tempDict in entitiesArray)
                {
                    Transaction * transactionObj = [self makeAnTransactionItemFromServerDictionary:tempDict];
                    
                    NSString * searchTransactionQuery = [NSString stringWithFormat:@"SELECT * FROM pld_transaction WHERE transaction_id = '%@'",
                                                         transactionObj.transactionID];
                    
                    NSArray * searchedTransactionArray =  [self.dbManager loadDataFromDB:searchTransactionQuery];
                    
                    if (searchedTransactionArray.count >0)
                    {
                        if (self.isSyncingTransaction)
                        {
                            [self updateTransactionInLocalDB:transactionObj];
                            success = YES;
                        }
                        else
                        {
                            if (transactionObj.errorFlag >0) // There is some error.
                            {
                                success = NO;
                                messageString = transactionObj.errorDescription;
                            }
                            else
                            {
                               [self updateTransactionInLocalDB:transactionObj];
                                success = YES;
                            }
                        }
                        
                    }
                    else
                    {
                        if (self.isSyncingTransaction)
                        {
                            [self addNewTransactionInLocalDB:transactionObj];
                            success = YES;
                        }
                        else
                        {
                            if (transactionObj.errorFlag >0) // There is some error.
                            {
                                success = NO;
                                messageString = transactionObj.errorDescription;
                            }
                            else
                            {
                                [self addNewTransactionInLocalDB:transactionObj];
                                success = YES;
                            }
                        }
                    }
                }
                
            }
            else
            {
                NSLog(@"%@",messageString);
            }
            if (handler)
            {
                // send back response to caller
                dispatch_async(dispatch_get_main_queue(), ^
                   {
                       handler(success, messageString);
                   });
            }
        }
    }];
}
-(void) updateTransactionOnServer:(Transaction *) transactObj completionHandler:(EditJobDataSyncCompletionHandler) handler
{
    [[WebservicesManager defaultManager] TransactionSET:transactObj withActionFlag:2 CompletionHandler:^(NSError *error, NSDictionary *user)
     {
        if (!error && user)
        {
            BOOL success = NO;
            NSString * messageString = [user valueForKey:@"Message"];
            int responseType = [[user valueForKey:@"ResponseType"] intValue];
            if (responseType == 0)
            {
                NSArray * entitiesArray = [user valueForKey:@"Entities"];
                for (NSDictionary * tempDict in entitiesArray)
                {
                    Transaction * transactionObj = [self makeAnTransactionItemFromServerDictionary:tempDict];
                    
                    if (self.isSyncingTransaction)
                    {
                        [self updateTransactionInLocalDB:transactionObj];
                        success = YES;
                    }
                    else
                    {
                        if (transactionObj.errorFlag >0) // There is some error.
                        {
                            success = NO;
                            messageString = transactionObj.errorDescription;
                        }
                        else
                        {
                            [self updateTransactionInLocalDB:transactionObj];
                            success = YES;
                        }
                    }
                }
            }
            else
            {
                NSLog(@"%@",messageString);
            }
            if (handler)
            {
                // send back response to caller
                dispatch_async(dispatch_get_main_queue(), ^
                   {
                       handler(success,messageString);
                   });
            }
        }
    }];
}
-(void) deleteTransactionOnServer:(Transaction *) transactObj completionHandler:(EditJobDataSyncCompletionHandler) handler
{
    [[WebservicesManager defaultManager] TransactionSET:transactObj withActionFlag:3 CompletionHandler:^(NSError *error, NSDictionary *user) {
        if (!error && user)
        {
            BOOL success = NO;
            NSString * messageString = [user valueForKey:@"Message"];
            int responseType = [[user valueForKey:@"ResponseType"] intValue];
            if (responseType == 0)
            {
                NSArray * entitiesArray = [user valueForKey:@"Entities"];
                for (NSDictionary * tempDict in entitiesArray)
                {
                    Transaction * transactionObj = [self makeAnTransactionItemFromServerDictionary:tempDict];
                    if (transactionObj.errorFlag>0)
                    {
                        messageString = transactionObj.errorDescription;
                        success = NO;
                    }
                    else
                    {
                        [self deleteParticularTransactionFromLocalDB:transactionObj];
                        success = YES;
                    }
                }
            }
            else
            {
                NSLog(@"%@",messageString);
            }
            if (handler) {
                // send back response to caller
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   handler(success, messageString);
                               });
            }
        }
    }];
}

#pragma mark - User Settings/Change Password with Server Methods

-(void) changePassword:(NSString *)passwordString withCompletionHandler:(UserSettingsSyncCompletionHandler)handler
{
    [[WebservicesManager defaultManager] requestChangePassword:passwordString withCompletionHandler:^(NSError *error, NSDictionary *user) {
        
        /*
         {
             "Entities": [],
             "Message": "Password changed successfully.",
             "ResponseType": 0,
             "SyncDate": "2015-01-28 05:26:03"
         }
         
         */
        
        if (!error && user) {
            BOOL success = NO;
            NSString * messageString = [user valueForKey:@"Message"];
            int responseType = [[user valueForKey:@"ResponseType"] intValue];
            if (responseType == 0)
            {
                success = YES;
            }
            else
            {
                NSLog(@"%@",messageString);
            }
            
            if (handler) {
                // send back response to caller
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   handler(success, messageString);
                               });
            }
        }
        
    }];
}

#pragma mark - Sync Data With Server Methods

-(void) deleteAllTransactionWithZeroUnits
{
    NSString * query = [NSString stringWithFormat:@"DELETE FROM pld_transaction WHERE unit = 0"];
    [self executeQuery:query];
}

-(void) updateLastSyncDateOfRefresh
{
    NSString * refreshStringDate = [NSString stringWithFormat:@"%@",[NSDate date]];
    NSString * convertedDateString = [TLUtilities ConvertDate:refreshStringDate FromFormat:@"yyyy-MM-dd HH:mm:ss z" toFormat:@"MMM dd, yyyy hh:mm a"];
    NSString * lastSyncDateAndTimeForRefresh = [NSString stringWithFormat:@"Last Updated: %@",convertedDateString];
    [[NSUserDefaults standardUserDefaults] setValue:lastSyncDateAndTimeForRefresh forKey:UDKEY_LAST_SYNC_DATE];
}


-(Transaction *) makeAnTransactoinItemFromDBColums:(NSArray *) columsDataArray
{
    NSString *  transactID = [columsDataArray objectAtIndex:1];
    NSString *  level2Key = [columsDataArray objectAtIndex:2];
    NSString * level3Key = [columsDataArray objectAtIndex:3];
    NSString * appliedDate = [columsDataArray objectAtIndex:4];
    int transactType = [[columsDataArray objectAtIndex:5] intValue];
    NSString *  resourceID = [columsDataArray objectAtIndex:6];
    NSString *  resUsageCode = [columsDataArray objectAtIndex:7];
    float unit = [[columsDataArray objectAtIndex:8] floatValue];
    NSString *  locationCode = [columsDataArray objectAtIndex:9];
    NSString *  orgUnit = [columsDataArray objectAtIndex:10];
    NSString *  taskCode = [columsDataArray objectAtIndex:11];
    NSString *  comments = [columsDataArray objectAtIndex:12];
    int nonBillableFlag = [[columsDataArray objectAtIndex:13] intValue];
    int submittedFlag = [[columsDataArray objectAtIndex:14] intValue];
    NSString *  submittedDate = [columsDataArray objectAtIndex:15];
    int approvalFlag = [[columsDataArray objectAtIndex:16] intValue];
    int syncStatus = [[columsDataArray objectAtIndex:17] intValue];
    int deleted = [[columsDataArray objectAtIndex:18] intValue];
    NSString *  modifiedDate = [columsDataArray objectAtIndex:19];
    NSString * timeStampString = [columsDataArray objectAtIndex:20];
    int errorFlag = [[columsDataArray objectAtIndex:21]intValue];
    int errorCode = [[columsDataArray objectAtIndex:22] intValue];
    NSString * errorDescriptionString = [columsDataArray objectAtIndex:23];
    
    Transaction * transactObj = [[Transaction alloc] initTransactionWithID:transactID transactionType:transactType ofJob:level2Key activity:level3Key taskCode:taskCode orgUnit:orgUnit comments:comments resource:resourceID resUsageCode:resUsageCode appliedOn:appliedDate modifiedOn:modifiedDate submittedOn:submittedDate withApprovalFlags:approvalFlag submitFlag:submittedFlag nonBillableFlag:nonBillableFlag andSyncedFlag:syncStatus Units:unit andLocationCode:locationCode];
    transactObj.deletedFlag = deleted;
    transactObj.timeStamp = timeStampString;
    transactObj.errorFlag = errorFlag;
    transactObj.errorCode = errorCode;
    transactObj.errorDescription = errorDescriptionString;
    
    return transactObj;

}

-(void) syncLocalDBTransactionsOnlyWithServerAndFetchLatest
{
//    self.is20MinutesSync = NO;
    
    [self updateLastSyncDateOfRefresh];
    [self deleteAllTransactionWithZeroUnits];
    [self fetchLastSyncDatesFromResourceTable];
    
    // Call fetchListOfDeletedTransactionsFromServer
    // Then Call fetchAllTransactionsToBeDeletedFromLocalDB in repose to  fetchListOfDeletedTransactionsFromServer.
    // Then Call fetchAllUnsyncedTransactionsFromLocalDB in repose to fetchAllTransactionsToBeDeletedFromLocalDB
    // Then Call fetchAllPermanentLinesToBeDeletedFromLocalDB in response to fetchAllUnsyncedTransactionsFromLocalDB
    // Then Call fetchAllUnsyncedPermanentLinesFromLocalDB in response to fetchAllPermanentLinesToBeDeletedFromLocalDB;
    // Then Call fetchLatestPermanentLinesFromServer in response to fetchAllUnsyncedPermanentLinesFromLocalDB
    // Then Call fetchLatestTransactionsDuringSyncingWithSomeLastSyncState at the end. in response to fetchLatestPermanentLinesFromServer
    
    if (self._syncTypes != forLogin)
    {
        [self fetchResouceObjectFromServer];
    }
    
    [self fetchListOfDeletedTransactionsFromServer];
//    [self fetchAllTransactionsToBeDeletedFromLocalDB];
//    [self fetchAllUnsyncedTransactionsFromLocalDB];
//    [self fetchAllPermanentLinesToBeDeletedFromLocalDB];
//    [self fetchAllUnsyncedPermanentLinesFromLocalDB];
//    [self fetchLatestPermanentLinesFromServer];
//    [self fetchLatestTransactionsDuringSyncingWithSomeLastSyncState];
}

-(void) syncLocalDBDataWithServer
{
    // Call fetchListOfDeletedTransactionsFromServer
    // Then Call fetchAllTransactionsToBeDeletedFromLocalDB in reponse to  fetchListOfDeletedTransactionsFromServer.
    // Then Call fetchAllUnsyncedTransactionsFromLocalDB in reponse to fetchAllTransactionsToBeDeletedFromLocalDB
    // Then Call fetchAllPermanentLinesToBeDeletedFromLocalDB in response to fetchAllUnsyncedTransactionsFromLocalDB
    // Then Call fetchAllUnsyncedPermanentLinesFromLocalDB in response to fetchAllPermanentLinesToBeDeletedFromLocalDB;
    // Then Call fetchLatestPermanentLinesFromServer in response to fetchAllUnsyncedPermanentLinesFromLocalDB
    // Then Call fetchListOfDeletedLevel3_ActivitiesFromServer in response to fetchLatestPermanentLinesFromServer
    // Then Call syncAllListsFromServerBasedOnLastSyncDate in response to fetchListOfDeletedLevel3_ActivitiesFromServer
    
//    self.is20MinutesSync = YES;
    [self updateLastSyncDateOfRefresh];
    [self deleteAllTransactionWithZeroUnits];
    
    if (self._syncTypes != forLogin)
    {
        [self fetchResouceObjectFromServer];
    }
    
    [self fetchListOfDeletedTransactionsFromServer];
//    [self fetchAllTransactionsToBeDeletedFromLocalDB];
//    [self fetchAllUnsyncedTransactionsFromLocalDB];
//    [self fetchAllPermanentLinesToBeDeletedFromLocalDB];
//    [self fetchAllUnsyncedPermanentLinesFromLocalDB];
//    [self fetchLatestPermanentLinesFromServer];
    
//    [self fetchListOfDeletedLevel3_ActivitiesFromServer];
//    [self syncAllListsFromServerBasedOnLastSyncDate];
}

-(void) fetchLatestTransactionsDuringSyncingWithSomeLastSyncState
{
    [[WebservicesManager defaultManager] requestListGet:kTL_TRANSACTION_GET OfType:@"TransactionCriteria" withActionFlag:-1 andLastSyncDate:self.transactionsLastSyncDateString CompletionHandler:^(NSError *error, NSDictionary *user)
     {
         BOOL success = [self parseTransactionListGetResponseData:user andError:error];
         if (success)
         {
             [self saveFetchedTransactionsListFromServerInLocalDBAfterSynicing:YES];
             [self updateLastSyncDatesInResourceTable];
         }
         [self callTheDelegateMethodNow:8];
     }];
}

-(void) fetchListOfDeletedTransactionsFromServer
{
    // So that we can delete them from our Local DB as well.
    [[WebservicesManager defaultManager] requestListGet:kTL_TRANSACTION_GET OfType:@"TransactionCriteria" withActionFlag:4  andLastSyncDate:@"" CompletionHandler:^(NSError *error, NSDictionary *user) {
        if (!error && user)
        {
            NSArray * transactionsArray = [user valueForKey:@"Entities"];
            if (transactionsArray.count>0)
            {
                for (NSDictionary * tempDict  in transactionsArray)
                {
                    NSString * transactID = [tempDict valueForKey:@"TransactionID"];
                    NSString * deleteQuery = [NSString stringWithFormat:@"DELETE FROM pld_transaction WHERE transaction_id = '%@';",transactID];
                    
                    [self.dbManager executeQuery:deleteQuery];
                    if (self.dbManager.affectedRows != 0)
                    {
                        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
                    }
                    else
                    {
                        NSLog(@"%@",TRANSACTION_NOT_DELETED_IN_DB);
                    }
                }
            }
        }
        [self fetchAllTransactionsToBeDeletedFromLocalDB];
    }];
}


-(void) fetchListOfDeletedLevel3_ActivitiesFromServer
{
    // So that we can delete them from our Local DB as well.
    [[WebservicesManager defaultManager] requestListGet:kTL_LEVEL_3_GET OfType:@"Level3Criteria" withActionFlag:4  andLastSyncDate:@"" CompletionHandler:^(NSError *error, NSDictionary *user)
    {
        if (!error && user)
        {
            NSArray * transactionsArray = [user valueForKey:@"Entities"];
            if (transactionsArray.count>0)
            {
                for (NSDictionary * tempDict  in transactionsArray)
                {
                    NSString * level2key = [tempDict valueForKey:@"Level2Key"];
                    NSString * level3key = [tempDict valueForKey:@"Level3Key"];
                   
                    if (!level3key || [level3key isEqualToString:@""])
                    {
                        NSString * updateLevel2StatusQuery = [NSString stringWithFormat:@"UPDATE pdd_level2 SET level2_status = 0 WHERE level2_key = '%@'", level2key];
                        [self executeQuery:updateLevel2StatusQuery];
                    }
                    else if (level2key && ![level2key isEqualToString:@""] && level3key && ![level3key isEqualToString:@""])
                    {
                        NSString * checkTransactionsQuery = [NSString stringWithFormat:@"SELECT * FROM pld_transaction WHERE level2_key = '%@' AND level3_key = '%@'", level2key, level3key];
                        NSArray * transactionsArray = [self.dbManager loadDataFromDB:checkTransactionsQuery];
                        if (transactionsArray.count >0) {
                            NSString * updateLevel3Query = [NSString stringWithFormat:@"UPDATE pdd_level3 SET labor_flag = 0 WHERE level2_key = '%@' AND level3_key = '%@'", level2key, level3key];
                            [self executeQuery:updateLevel3Query];
                        }
                        else
                        {
                            NSString * deleteLevel3Query = [NSString stringWithFormat:@"DELETE FROM pdd_level3 WHERE level2_key = '%@' AND level3_key = '%@';",level2key, level3key];
                            [self executeQuery:deleteLevel3Query];
                            
                            NSString * checkLevel3Query = [NSString stringWithFormat:@"Select * FROM pdd_level3 WHERE labor_flag = 1 AND level2_key = '%@'", level2key];
                            NSArray * level3CheckedArray = [self.dbManager loadDataFromDB:checkLevel3Query];
                            if (!level3CheckedArray.count>0)
                            {
                                NSString * updateLevel2StatusQuery = [NSString stringWithFormat:@"UPDATE pdd_level2 SET level2_status = 0 WHERE level2_key = '%@'", level2key];
                                [self executeQuery:updateLevel2StatusQuery];
                            }
                        }
                    }
                }
            }
        }
        
        [self syncAllListsFromServerBasedOnLastSyncDate];
    }];
    
}

- (BOOL) isTheStringDate: (NSString*) theString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateFromString = [[NSDate alloc] init];
    
    dateFromString = [dateFormatter dateFromString:theString];
    
    if (dateFromString !=nil) {
        return true;
    }
    else {
        return false;
    }
}

-(void) fetchAllUnsyncedTransactionsFromLocalDB
{
        NSString * queryString = [NSString stringWithFormat:@"SELECT * FROM pld_transaction WHERE sync_status = 0 AND deleted = 0;"];
        NSArray *transactionsArray =[self.dbManager loadDataFromDB:queryString];
        
        if (transactionsArray.count>0)
        {
            for (NSArray * tempArray in transactionsArray)
            {
                Transaction * transactObj = [self makeAnTransactoinItemFromDBColums:tempArray];
                BOOL checkDateFormat = [self isTheStringDate:transactObj.appliedDate];
                if (checkDateFormat)
                {
                    transactObj.appliedDate = [TLUtilities ConvertDate:transactObj.appliedDate FromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM-dd HH:mm:ss"];
                }
                
                // Syncing Transactions Case
                // These would be the transactions already available in LocalDB but not on Server
                // When they are added successfully on Server, update their sync_status = 1 in LocalDB.
                
                [self addTransactionOnServer:transactObj completionHandler:^(BOOL success, NSString *errMsg)
                {
                    if (success)
                    {
                        // No need to update transaction in LocalDB from here now, because it would automatically be updated into the LocalDB in "addTransactionOnServer" Method in DataSyncHandler class.
                    }
                }];
            }
        }
    [self fetchAllPermanentLinesToBeDeletedFromLocalDB];
}

-(void) fetchAllTransactionsToBeDeletedFromLocalDB
{
    NSString * queryString = [NSString stringWithFormat:@"SELECT * FROM pld_transaction WHERE sync_status = 0 AND deleted = 1;"];
    NSArray *transactionsArray =[self.dbManager loadDataFromDB:queryString];
    
    if (transactionsArray.count>0)
    {
        for (NSArray * tempArray in transactionsArray)
        {
            Transaction * transactObj = [self makeAnTransactoinItemFromDBColums:tempArray];
            transactObj.appliedDate = [TLUtilities ConvertDate:transactObj.appliedDate FromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM-dd HH:mm:ss"];
            [self deleteTransactionOnServer:transactObj completionHandler:nil];
        }
    }
    [self fetchAllUnsyncedTransactionsFromLocalDB];
}

-(void) fetchAllPermanentLinesToBeDeletedFromLocalDB
{
    NSString * queryString = [NSString stringWithFormat:@"SELECT * FROM pdm_permanent_line WHERE sync_status = 0 AND deleted = 1;"];
    NSArray *permArray =[self.dbManager loadDataFromDB:queryString];
    
    if (permArray.count>0) {
        for (NSArray * tempArray in permArray)
        {
            NSString * level2key = [tempArray objectAtIndex:1];
            NSString * level3Key = [tempArray objectAtIndex:2];
            NSString *  taskCode = [tempArray objectAtIndex:3];
            NSString * startDate = [tempArray objectAtIndex:4];
            
            startDate = [TLUtilities ConvertDate:startDate FromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM-dd HH:mm:ss z"]; // From everywhere else it would already be in a format with zone. That is why we are coverting the date format here.
            
            [self deletePermanentLineFromLocalDBAndServerForLevel2Key:level2key level3Key:level3Key taskCode:taskCode andStartDate:startDate];
        }
    }
    [self fetchAllUnsyncedPermanentLinesFromLocalDB];
}

-(void) fetchAllUnsyncedPermanentLinesFromLocalDB
{
    NSString * queryString = [NSString stringWithFormat:@"SELECT * FROM pdm_permanent_line WHERE sync_status = 0 AND deleted = 0;"];
    NSArray *permArray =[self.dbManager loadDataFromDB:queryString];
    
    if (permArray.count>0)
    {
        for (NSArray * tempArray in permArray)
        {
            NSString * level2key = [tempArray objectAtIndex:1];
            NSString * level3Key = [tempArray objectAtIndex:2];
            NSString *  taskCode = [tempArray objectAtIndex:3];
            NSString * startDate = [tempArray objectAtIndex:4];
            
            startDate = [TLUtilities ConvertDate:startDate FromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM-dd HH:mm:ss z"];
            
            [self addNewPermanentLineWithLevel2Key:level2key level3Key:level3Key taskCode:taskCode forDate:startDate];
        }
    }
    [self fetchLatestPermanentLinesFromServer];
}


-(void) fetchLatestPermanentLinesFromServer
{
    [self fetchPermanentLineListFromServerWithCompletionHandler:^(BOOL success)
    {
        if (success)
        {
            [self saveFetchedPermanentLinesListFromServerInLocalDBAfterSynicing:NO];
        }
        
        if (self._syncTypes == forPullToRefresh) // if (!self.is20MinutesSync) // This method should Only be called with "Pull To Refresh" of "Login"
        {
            [self fetchLatestTransactionsDuringSyncingWithSomeLastSyncState];
        }
        else if(self._syncTypes == forLogin || self._syncTypes == forTwentyMinutes) // "20 Minutes Sync" and "Login" case
        {
            [self fetchListOfDeletedLevel3_ActivitiesFromServer];
        }
        
    }];
}

-(void) syncAllListsFromServerBasedOnLastSyncDate
{
    __block int checkForSyncedData = 0;
    [self fetchLastSyncDatesFromResourceTable];
    
        [[WebservicesManager defaultManager] requestListGet:kTL_LEVEL_2_CUSTOMER_GET OfType:@"Level2CustomerCriteria" withActionFlag:-1 andLastSyncDate:self.level2CustomerLastSyncDateString CompletionHandler:^(NSError *error, NSDictionary *user) {
            BOOL success = [self parseLevel2CustomerListGetResponseData:user andError:error];
            if (success) {
                [self saveFetchedLevel2CustomerListFromServerInLocalDBAfterSynicing:YES];
            }
            checkForSyncedData+=1;
            [self callTheDelegateMethodNow: checkForSyncedData];
        }];
        [[WebservicesManager defaultManager] requestListGet:kTL_LEVEL_2_GET OfType:@"Level2Criteria" withActionFlag:-1 andLastSyncDate:self.level2LastSyncDateString CompletionHandler:^(NSError *error, NSDictionary *user) {
            BOOL success = [self parseLevel2ListGetResponseData:user andError:error];
            if (success) {
                [self saveFetchedLevel2ListFromServerInLocalDBAfterSynicing:YES];
            }
            checkForSyncedData+=1;
            [self callTheDelegateMethodNow: checkForSyncedData];
        }];
        
        [[WebservicesManager defaultManager] requestListGet:kTL_LEVEL_3_GET OfType:@"Level3Criteria" withActionFlag:-1 andLastSyncDate:self.level3LastSyncDateString CompletionHandler:^(NSError *error, NSDictionary *user) {
            BOOL success = [self parseparseLevel3ListGetResponseData:user andError:error];
            if (success) {
                [self saveFetchedLevel3ListFromServerInLocalDBAfterSynicing:YES];
            }
            checkForSyncedData+=1;
            [self callTheDelegateMethodNow: checkForSyncedData];
        }];
        
        [[WebservicesManager defaultManager] requestListGet:kTL_TASK_GET OfType:@"TaskCriteria" withActionFlag:-1 andLastSyncDate:@"" CompletionHandler:^(NSError *error, NSDictionary *user) {
            BOOL success = [self parseTaskListGetResponseData:user andError:error];
            if (success) {
                [self saveFetchedTasksListFromServerInLocalDBAfterSynicing:YES];
            }
            checkForSyncedData+=1;
            [self callTheDelegateMethodNow: checkForSyncedData];
        }];
        
        [[WebservicesManager defaultManager] requestListGet:kTL_RES_USAGE_GET OfType:@"ResUsageCriteria" withActionFlag:-1 andLastSyncDate:@"" CompletionHandler:^(NSError *error, NSDictionary *user) {
            BOOL success = [self parseResUsageListGetResponseData:user andError:error];
            if (success) {
                [self saveFetchedWorkFuncListFromServerInLocalDBAfterSynicing:YES];
            }
            checkForSyncedData+=1;
            [self callTheDelegateMethodNow: checkForSyncedData];
        }];
        
        [[WebservicesManager defaultManager] requestListGet:kTL_TRANSACTION_GET OfType:@"TransactionCriteria" withActionFlag:-1 andLastSyncDate:self.transactionsLastSyncDateString CompletionHandler:^(NSError *error, NSDictionary *user) {
            BOOL success = [self parseTransactionListGetResponseData:user andError:error];
            if (success) {
                [self saveFetchedTransactionsListFromServerInLocalDBAfterSynicing:YES];
            }
            checkForSyncedData+=1;
            [self callTheDelegateMethodNow: checkForSyncedData];
        }];
        
        [[WebservicesManager defaultManager] requestListGet:kTL_PERMANENT_LINE_GET OfType:@"PermanentLinesCriteria" withActionFlag:-1 andLastSyncDate:self.permanentLinesLastSyncDateString CompletionHandler:^(NSError *error, NSDictionary *user) {
            BOOL success = [self parsePermanentLineListGetResponseData:user andError:error];
            if (success) {
                [self saveFetchedPermanentLinesListFromServerInLocalDBAfterSynicing:YES];
            }
            checkForSyncedData+=1;
            [self callTheDelegateMethodNow: checkForSyncedData];
        }];
        
        [[WebservicesManager defaultManager] requestListGet:kTL_SYS_NAMES_GET OfType:@"SysNamesCriteria" withActionFlag:-1 andLastSyncDate:self.sysNamesLastSyncDateString CompletionHandler:^(NSError *error, NSDictionary *user) {
            BOOL success = [self parseSysNamesListGetResponseData:user andError:error];
            if (success)
            {
                [self saveFetchedSysNamesListFromServerInLocalDBAfterSynicing:YES];
            }
            checkForSyncedData+=1;
            [self callTheDelegateMethodNow: checkForSyncedData];

        }];
}

-(void) callTheDelegateMethodNow:(int) checkVariable
{
    if (checkVariable == 8)
    {
        if (self.isDelegateSetFromLogin)
        {
            [self.delegate dataRefreshedSuccessfullyAgainstLogin];
        }
        else
        {
            if (self._syncTypes == forTwentyMinutes)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kSyncCompletionNotification object:nil];
            }
            else
            {
                [self.delegate dataRefreshedSuccessfullyAgainstPullToRefresh];
            }
        }
    }
}




@end
