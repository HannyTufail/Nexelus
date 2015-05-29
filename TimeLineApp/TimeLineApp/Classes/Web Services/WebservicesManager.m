//
//  WebservicesManager.m
//  TimeLineApp
//
//  Created by Mac on 12/29/14.
//  Copyright (c) 2014  Hanny. All rights reserved.
//

#import "WebservicesManager.h"
#import "TLConstants.h"
#import "TLUtilities.h"


@implementation WebservicesManager


+ (WebservicesManager *)defaultManager
{
    static WebservicesManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[WebservicesManager alloc] init];
    });
    return defaultManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _requestQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}


#pragma mark - Request Method

-(BOOL) pingServerWithHostname
{
    BOOL internetAvailable = NO;
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kTL_HOST_URL,kTL_PING];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    [request setTimeoutInterval:3];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",jsonString);
    if ([response statusCode] == 200)
    {
        internetAvailable = YES;
    }
    else
    {
        internetAvailable = NO;
    }
    return internetAvailable;
}


- (void)requestLoginWithEmail:(NSString *)email
                     password:(NSString *)password
            completionHandler:(LoginCompletionHandler)handler
{
    //fetch the Authentication Key from NSUserDefaults
    NSString * authenticationKeyString = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_AUTHENTICATION_KEY];
    
    // Prepare request URL
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kTL_HOST_URL,kTL_LOGIN];
    
    //Preparing POST body
    NSDictionary *postBody = @{@"Authentication":@{
                                       @"AuthenticationKey":authenticationKeyString,
                                       @"LoginID":email,
                                       @"Password":password}};
    
    NSError *jsonWriteError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postBody options:kNilOptions error:&jsonWriteError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",jsonString);
    
    //Setting header of HTTP request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    [request setValue:jsonString forHTTPHeaderField:@"json"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOp = op;
    [weakOp addExecutionBlock:^
     {
         if (![weakOp isCancelled])
         {
             // Prepare asynchronous call
             [NSURLConnection sendAsynchronousRequest:request
                                                queue:self.requestQueue
                                    completionHandler:^(NSURLResponse *response,
                                                        NSData *data,
                                                        NSError *error)
              {
                  // response received
                  NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
                  NSInteger statusCode = [urlResponse statusCode];
                  NSLog(@"URL Status Code Login => %ld", (long)statusCode);
                  
                  NSDictionary *user = nil;
                  
                  if (statusCode == 200 && data)
                  {
                      NSError *jsonReadingError = nil;
                      user = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonReadingError];
                      if (user) {
                          // Parsing
                          
                          /*
                           {
                               "Entities": [
                                   {
                                       "CompanyCode": 2,
                                       "LocationCode": "NY",
                                       "NameFirst": "Janet",
                                       "NameLast": "Urciuoli",
                                       "OrgUnitCode": "C&T-C&T Admin",
                                       "ResUsageCode": "ADMIN",
                                       "ResourceID": "451",
                                       "ShowTask": true,
                                       "ShowWorkFunction": true
                                   }
                               ],
                               "Message": null,
                               "ResponseType": 0
                           }
                           */
                      }
                  }
                  
                  else
                  {
                      if ([error code] == NSURLErrorTimedOut)
                      {
                          NSDictionary *userInfo = @{@"title":@"Error",@"text":@"Your request has timed out. Please try again."};
                          error = [NSError errorWithDomain:@"ERROR DOMAIN" code:[urlResponse statusCode] userInfo:userInfo];
                      }
                  }
                  
                  if (handler)
                  {
                      // send back response to caller
                      dispatch_async(dispatch_get_main_queue(), ^
                                     {
                                         handler(error, user);
                                     });
                  }
              }];
         }
     }];
    [self.requestQueue addOperation:op];
    
}

- (void)requestListGet:(NSString *)getURLString OfType:(NSString *)typeString withActionFlag:(int)actionFlag  andLastSyncDate:(NSString *)lastSyncDate CompletionHandler:(DataSyncCompletionHandler) handler
{
    // Prepare request URL
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kTL_HOST_URL,getURLString];
    
    NSString * authenticationKey = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_AUTHENTICATION_KEY];
    NSString * loginID = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_CLIENT_USERNAME];
    NSString * password =[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_PASSWORD];
    NSString * resourceID = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_RESOURCE_ID];
    
    NSString * jsonString = @"";
    if (![lastSyncDate isEqualToString:@""])
    {
        if ([typeString isEqualToString:@"Level2Criteria"] || [typeString isEqualToString:@"Level3Criteria"]) {
            // For Level2 and Level3 we have to send Mode = 1 for syncing as well.
            
            jsonString = [NSString stringWithFormat:@"{\"Authentication\":{\"LoginID\":\"%@\",\"Password\":\"%@\",\"AuthenticationKey\":\"%@\"},\"SearchCriteria\":{\"__type\":\"%@\",\"ResourceID\":\"%@\",\"StrSyncDate\":\"%@\",\"Mode\":\"1\"}}",loginID,password,authenticationKey,typeString,resourceID, lastSyncDate];
        }
        else
            jsonString = [NSString stringWithFormat:@"{\"Authentication\":{\"LoginID\":\"%@\",\"Password\":\"%@\",\"AuthenticationKey\":\"%@\"},\"SearchCriteria\":{\"__type\":\"%@\",\"ResourceID\":\"%@\",\"StrSyncDate\":\"%@\"}}",loginID,password,authenticationKey,typeString,resourceID, lastSyncDate];
    }
    else
    {
        if (actionFlag == -1) {
            jsonString = [NSString stringWithFormat:@"{\"Authentication\":{\"LoginID\":\"%@\",\"Password\":\"%@\",\"AuthenticationKey\":\"%@\"},\"SearchCriteria\":{\"__type\":\"%@\",\"ResourceID\":\"%@\"}}",loginID,password,authenticationKey,typeString,resourceID];
        }
        else
        {
            // This case is set to fetch All deleted lists of Transactions and Level3 from server with Action Flag = 4.
            jsonString = [NSString stringWithFormat:@"{\"Authentication\":{\"LoginID\":\"%@\",\"Password\":\"%@\",\"AuthenticationKey\":\"%@\"},\"SearchCriteria\":{\"__type\":\"%@\",\"ActionFlag\":\"%i\",\"ResourceID\":\"%@\"}}",loginID,password,authenticationKey,typeString,actionFlag,resourceID];
        }
    }
    
    //Preparing POST body
    NSData * jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *convertedString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"URL: %@", urlString);
    NSLog(@"%@",convertedString);
    
    //Setting header of HTTP request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setValue:jsonString forHTTPHeaderField:@"json"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOp = op;
    [weakOp addExecutionBlock:^
     {
         if (![weakOp isCancelled])
         {
             // Prepare asynchronous call
             [NSURLConnection sendAsynchronousRequest:request
                                                queue:self.requestQueue
                                    completionHandler:^(NSURLResponse *response,
                                                        NSData *data,
                                                        NSError *error)
              {
                  // response received
                  NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
                  NSInteger statusCode = [urlResponse statusCode];
                  
                  NSDictionary *user = nil;
                  if (statusCode == 200 && data)
                  {
                      NSError *jsonReadingError = nil;
                      user = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonReadingError];
                  }
                  else
                  {
                      if ([error code] == NSURLErrorTimedOut)
                      {
                          NSDictionary *userInfo = @{@"title":@"Error",@"text":@"Your request has timed out. Please try again."};
                          error = [NSError errorWithDomain:@"ERROR DOMAIN" code:[urlResponse statusCode] userInfo:userInfo];
                      }
                  }
                  if (handler) {
                      // send back response to caller
                      dispatch_async(dispatch_get_main_queue(), ^{
                                         handler(error, user);
                                     });
                  }
              }];
         }
     }];
    [self.requestQueue addOperation:op];
}

#pragma mark - TLAddJob SET Methods
//
//-(void) TransactionSynchronoulsySET:(Transaction *) transactObj withActionFlag:(int) actionFlag CompletionHandler:(AddJobCompletionHandler) handler
//{
//    // Prepare request URL
//    NSString *urlString = [NSString stringWithFormat:@"%@%@",kTL_HOST_URL,kTL_TRANSACTION_SET];
//    NSString * commentsString = transactObj.comments;
//    NSString * timeStampString = transactObj.timeStamp;
//    if (!timeStampString || [timeStampString isEqualToString:@"(null)"])
//    {
//        timeStampString = @"";
//    }
//    
//    if (commentsString==nil || [commentsString isEqualToString:@"Comments here..."])
//    {
//        commentsString = @"";
//    }
//    
//    //Preparing POST body
//    NSDictionary *postBody = @{@"Authentication":@{
//                                       @"AuthenticationKey":[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_AUTHENTICATION_KEY],
//                                       @"LoginID":[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_CLIENT_USERNAME],
//                                       @"Password":[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_PASSWORD]},
//                               @"Entities":@[@{
//                                                 @"TransactionID":transactObj.transactionID,
//                                                 @"Level2Key":transactObj.level2Key,
//                                                 @"Level3Key":transactObj.level3Key,
//                                                 @"TaskCode":transactObj.taskCode,
//                                                 @"ResUsageCode":transactObj.resUsageCode,
//                                                 @"ResourceID":transactObj.resourceID,
//                                                 @"Units":[NSString stringWithFormat:@"%.2f",transactObj.units],
//                                                 @"NonBillableFlag":[NSString stringWithFormat:@"%i",transactObj.nonBillableFlag],
//                                                 @"Deleted":@"0",
//                                                 @"ApprovalFlag":[NSString stringWithFormat:@"%i",transactObj.approvalStatus],
//                                                 @"TrxType":[NSString stringWithFormat:@"%i",transactObj.transactionType],
//                                                 @"SubmittedFlag":[NSString stringWithFormat:@"%i",transactObj.submitFlag],
//                                                 @"ActionFlag":[NSString stringWithFormat:@"%i",actionFlag],
//                                                 @"CompanyCode":[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE],
//                                                 @"ModifyDate":[NSString stringWithFormat:@"/Date(%i)/",(int)[TLUtilities ConvertDateToEPOCH:transactObj.modifyDate DateFormat:@"yyyy-MM-dd HH:mm:ss z"]],
//                                                 @"StrAppliedDate": transactObj.appliedDate,
//                                                 @"Comments":commentsString,
//                                                 @"StrTimeStamp":timeStampString,
//                                                 @"DeviceInfo": [TLUtilities getDeviceinfo]
//                                                 }]
//                               };
//    
//    NSError *jsonWriteError = nil;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postBody options:kNilOptions error:&jsonWriteError];
//    
//    //Setting header of HTTP request
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
//    [request setValue:jsonString forHTTPHeaderField:@"json"];
//    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setHTTPMethod:@"POST"];
//    [request setHTTPBody:jsonData];
//   
//    NSHTTPURLResponse *urlResponse = nil;
//    NSError * error = nil;
//    NSDictionary *user = nil;
//    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
//    NSInteger statusCode = [urlResponse statusCode];
//    NSString *jsonResponseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",jsonResponseString);
//    if (statusCode == 200 && returnData)
//    {
//        NSError *jsonReadingError = nil;
//        user = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&jsonReadingError];
//    }
//    else
//    {
//        if ([error code] == NSURLErrorTimedOut)
//        {
//            NSDictionary *userInfo = @{@"title":@"Error",@"text":@"Your request has timed out. Please try again."};
//            error = [NSError errorWithDomain:@"ERROR DOMAIN" code:[urlResponse statusCode] userInfo:userInfo];
//        }
//    }
//    if (handler)
//    {
//        // send back response to caller
//        dispatch_async(dispatch_get_main_queue(), ^{
//            handler(error, user);
//        });
//    }
//}

-(void) TransactionSET:(Transaction *) transactObj withActionFlag:(int) actionFlag CompletionHandler:(AddJobCompletionHandler) handler
{
    /*
     {
     "Authentication":
         {
             "AuthenticationKey":"abc123",
             "LoginID":"janet.urciuoli",
             "Password":"sa"
         },
         "Entities":
             [
                {
                 "AppliedDate":"/Date(1420278537747)/",
                 "TransactionID":"8d1f2a6d27599581",
                 "Level2Key":"360I ADM-13-002",
                 "Level3Key":"Bereavement",
                 "ResUsageCode":"ADMIN",
                 "ResourceID":"451",
                 "Units":1.5,
                 "NonBillableFlag":0,
                 "Deleted":0,
                 "ApprovalFlag":0,
                 "TrxType":0,
                 "SubmittedFlag":0,
                 "ActionFlag":0,
                 "CompanyCode":2,
                 }
             ]
     }
     ------------------------------------------------------------------------------
     NOTE:
     ActionFlag: 
        Add Transaction = 1
        Update Transaction = 2
        Delete Transaction = 3
     */
    
    // Prepare request URL
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kTL_HOST_URL,kTL_TRANSACTION_SET];
    NSString * commentsString = transactObj.comments;
    NSString * timeStampString = transactObj.timeStamp;
    if (!timeStampString || [timeStampString isEqualToString:@"(null)"])
    {
        timeStampString = @"";
    }
    
    if (commentsString==nil || [commentsString isEqualToString:@"Comments here..."])
    {
        commentsString = @"";
    }
    
    //Preparing POST body
    NSDictionary *postBody = @{@"Authentication":@{
                                       @"AuthenticationKey":[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_AUTHENTICATION_KEY],
                                       @"LoginID":[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_CLIENT_USERNAME],
                                       @"Password":[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_PASSWORD]},
                               @"Entities":@[@{
                                                 @"TransactionID":transactObj.transactionID,
                                                 @"Level2Key":transactObj.level2Key,
                                                 @"Level3Key":transactObj.level3Key,
                                                 @"TaskCode":transactObj.taskCode,
                                                 @"ResUsageCode":transactObj.resUsageCode,
                                                 @"ResourceID":transactObj.resourceID,
                                                 @"Units":[NSString stringWithFormat:@"%.2f",transactObj.units],
                                                 @"NonBillableFlag":[NSString stringWithFormat:@"%i",transactObj.nonBillableFlag],
                                                 @"Deleted":@"0",
                                                 @"ApprovalFlag":[NSString stringWithFormat:@"%i",transactObj.approvalStatus],
                                                 @"TrxType":[NSString stringWithFormat:@"%i",transactObj.transactionType],
                                                 @"SubmittedFlag":[NSString stringWithFormat:@"%i",transactObj.submitFlag],
                                                 @"ActionFlag":[NSString stringWithFormat:@"%i",actionFlag],
                                                 @"CompanyCode":[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_COMPANY_CODE],
                                                 @"ModifyDate":[NSString stringWithFormat:@"/Date(%i)/",(int)[TLUtilities ConvertDateToEPOCH:transactObj.modifyDate DateFormat:@"yyyy-MM-dd HH:mm:ss z"]],
                                                 @"StrAppliedDate": transactObj.appliedDate,
                                                 @"Comments":commentsString,
                                                 @"StrTimeStamp":timeStampString,
                                                 @"DeviceInfo": [TLUtilities getDeviceinfo]
                                                 }]
                               };
    
    NSError *jsonWriteError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postBody options:kNilOptions error:&jsonWriteError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"URL: %@", urlString);
    NSLog(@"%@",jsonString);
    
    //Setting header of HTTP request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setValue:jsonString forHTTPHeaderField:@"json"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOp = op;
    [weakOp addExecutionBlock:^
     {
         if (![weakOp isCancelled])
         {
             // Prepare asynchronous call
             [NSURLConnection sendAsynchronousRequest:request
                                                queue:self.requestQueue
                                    completionHandler:^(NSURLResponse *response,
                                                        NSData *data,
                                                        NSError *error)
              {
                  // response received
                  NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
                  NSInteger statusCode = [urlResponse statusCode];

                  NSString *respString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                  NSLog(@"%@",respString);
                  NSDictionary *user = nil;
                  if (statusCode == 200 && data)
                  {
                      NSError *jsonReadingError = nil;
                      user = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonReadingError];
                  }
                  else
                  {
                      if ([error code] == NSURLErrorTimedOut)
                      {
                          NSDictionary *userInfo = @{@"title":@"Error",@"text":@"Your request has timed out. Please try again."};
                          error = [NSError errorWithDomain:@"ERROR DOMAIN" code:[urlResponse statusCode] userInfo:userInfo];
                      }
                  }
                  if (handler) {
                      // send back response to caller
                      dispatch_async(dispatch_get_main_queue(), ^{
                          handler(error, user);
                      });
                  }
              }];
         }
     }];
    [self.requestQueue addOperation:op];
}

-(void) PermanentLinesSET:(PermanentLines *)permLineObj withActionFlag:(int) actionFlag CompletionHandler:(DataSyncCompletionHandler)handler
{
    // Prepare request URL
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kTL_HOST_URL,kTL_PERMANENT_LINE_SET];
    
    NSString * startDateString = permLineObj.startDate;
    //[NSString stringWithFormat:@"/Date(%.0f)/",(double)[TLUtilities ConvertDateToEPOCH:permLineObj.startDate DateFormat:@"yyyy-MM-dd HH:mm:ss z"]];
    NSString * endDateString = [TLUtilities ConvertDate:permLineObj.endDate FromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM-dd HH:mm:ss"];
    //[NSString stringWithFormat:@"/Date(%.0f)/",(double)[TLUtilities ConvertDateToEPOCH:permLineObj.endDate DateFormat:@"yyyy-MM-dd"]];
    
    
    //Preparing POST body
    NSDictionary *postBody = @{@"Authentication":@{
                                       @"AuthenticationKey":[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_AUTHENTICATION_KEY],
                                       @"LoginID":[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_CLIENT_USERNAME],
                                       @"Password":[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_PASSWORD]},
                               @"Entities":@[@{
                                                 @"Level2Key":permLineObj.level2Key,
                                                 @"Level3Key":permLineObj.level3Key,
                                                 @"ResourceID":permLineObj.resourceID,
                                                 @"TaskCode":permLineObj.taskCode,
                                                 @"ActionFlag":[NSString stringWithFormat:@"%i",actionFlag],
                                                 @"StrStartDate":startDateString,
                                                 @"StrEndDate": endDateString
                                                 }]
                               };

    
    NSError *jsonWriteError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postBody options:kNilOptions error:&jsonWriteError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"URL: %@", urlString);
    NSLog(@"%@",jsonString);
    
    //Setting header of HTTP request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setValue:jsonString forHTTPHeaderField:@"json"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOp = op;
    [weakOp addExecutionBlock:^
     {
         if (![weakOp isCancelled])
         {
             // Prepare asynchronous call
             [NSURLConnection sendAsynchronousRequest:request
                                                queue:self.requestQueue
                                    completionHandler:^(NSURLResponse *response,
                                                        NSData *data,
                                                        NSError *error)
              {
                  // response received
                  NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
                  NSInteger statusCode = [urlResponse statusCode];
                  //                  NSLog(@"Response Code For Level2Get => %ld", (long)statusCode);
                  
                  NSDictionary *user = nil;
                  
                  if (statusCode == 200 && data)
                  {
                      NSError *jsonReadingError = nil;
                      user = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonReadingError];
                  }
                  
                  else
                  {
                      if ([error code] == NSURLErrorTimedOut)
                      {
                          NSDictionary *userInfo = @{@"title":@"Error",@"text":@"Your request has timed out. Please try again."};
                          error = [NSError errorWithDomain:@"ERROR DOMAIN" code:[urlResponse statusCode] userInfo:userInfo];
                      }
                  }
                  
                  if (handler) {
                      // send back response to caller
                      dispatch_async(dispatch_get_main_queue(), ^{
                          handler(error, user);
                      });
                  }
              }];
         }
     }];
    [self.requestQueue addOperation:op];
}

#pragma mark - TLAddJob screen Search Methods

-(void) searchInfoOnServerForCustomer:(NSString *) customerCode andLevel2:(NSString *)level2Key usingURL:(NSString *) urlstring andCriteria:(NSString *)criteriaString CompletionHandler:(AddJobCompletionHandler) handler
{
    
    // Prepare request URL
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kTL_HOST_URL,urlstring];
    NSString * authenticationKey = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_AUTHENTICATION_KEY];
    NSString * loginID = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_CLIENT_USERNAME];
    NSString * password =[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_PASSWORD];
    NSString * resourceID = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_RESOURCE_ID];
    
    
   NSString * jsonString = [NSString stringWithFormat:@"{\"Authentication\":{\"LoginID\":\"%@\",\"Password\":\"%@\",\"AuthenticationKey\":\"%@\"},\"SearchCriteria\":{\"__type\":\"%@\",\"CustomerCode\":\"%@\",\"Level2Key\":\"%@\",\"SearchString\":\"%@\",\"ResourceID\":\"%@\"}}",loginID,password,authenticationKey,criteriaString,customerCode,level2Key,level2Key,resourceID];
    
    NSData * jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *convertedString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",convertedString);
    
    
    //Setting header of HTTP request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setValue:jsonString forHTTPHeaderField:@"json"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOp = op;
    [weakOp addExecutionBlock:^
     {
         if (![weakOp isCancelled])
         {
             // Prepare asynchronous call
             [NSURLConnection sendAsynchronousRequest:request
                                                queue:self.requestQueue
                                    completionHandler:^(NSURLResponse *response,
                                                        NSData *data,
                                                        NSError *error)
              {
                  // response received
                  NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
                  NSInteger statusCode = [urlResponse statusCode];
                  //                  NSLog(@"Response Code For Level2Get => %ld", (long)statusCode);
                  
                  NSDictionary *user = nil;
                  
                  if (statusCode == 200 && data)
                  {
                      NSError *jsonReadingError = nil;
                      user = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonReadingError];
                  }
                  
                  else
                  {
                      if ([error code] == NSURLErrorTimedOut)
                      {
                          NSDictionary *userInfo = @{@"title":@"Error",@"text":@"Your request has timed out. Please try again."};
                          error = [NSError errorWithDomain:@"ERROR DOMAIN" code:[urlResponse statusCode] userInfo:userInfo];
                      }
                  }
                  
                  if (handler) {
                      // send back response to caller
                      dispatch_async(dispatch_get_main_queue(), ^{
                          handler(error, user);
                      });
                  }
              }];
         }
     }];
    [self.requestQueue addOperation:op];
}

#pragma mark - Change Password Method

-(void) requestChangePassword:(NSString *)newPass withCompletionHandler:(DataSyncCompletionHandler)handler
{
    // Prepare request URL
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kTL_HOST_URL,kTL_CHANGE_PASSWORD];
    
    //Preparing POST body
    NSDictionary *postBody = @{@"Authentication":@{
                                       @"AuthenticationKey":[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_AUTHENTICATION_KEY],
                                       @"LoginID":[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_CLIENT_USERNAME],
                                       @"Password":[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_PASSWORD]},
                               @"Entities":@[@{
                                                 @"ResourceID":[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_RESOURCE_ID],
                                                 @"NewPassword":newPass,
                                                 @"OldPassword":[[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_PASSWORD]
                                                 }]
                               };
    
    
    NSError *jsonWriteError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postBody options:kNilOptions error:&jsonWriteError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",jsonString);
    
    //Setting header of HTTP request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setValue:jsonString forHTTPHeaderField:@"json"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOp = op;
    [weakOp addExecutionBlock:^
     {
         if (![weakOp isCancelled])
         {
             // Prepare asynchronous call
             [NSURLConnection sendAsynchronousRequest:request
                                                queue:self.requestQueue
                                    completionHandler:^(NSURLResponse *response,
                                                        NSData *data,
                                                        NSError *error)
              {
                  // response received
                  NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
                  NSInteger statusCode = [urlResponse statusCode];
                  //                  NSLog(@"Response Code For Level2Get => %ld", (long)statusCode);
                  
                  NSDictionary *user = nil;
                  
                  if (statusCode == 200 && data)
                  {
                      NSError *jsonReadingError = nil;
                      user = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonReadingError];
                  }
                  
                  else
                  {
                      if ([error code] == NSURLErrorTimedOut)
                      {
                          NSDictionary *userInfo = @{@"title":@"Error",@"text":@"Your request has timed out. Please try again."};
                          error = [NSError errorWithDomain:@"ERROR DOMAIN" code:[urlResponse statusCode] userInfo:userInfo];
                      }
                  }
                  
                  if (handler) {
                      // send back response to caller
                      dispatch_async(dispatch_get_main_queue(), ^{
                          handler(error, user);
                      });
                  }
              }];
         }
     }];
    [self.requestQueue addOperation:op];

}


@end
