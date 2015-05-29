//
//  WebservicesManager.h
//  TimeLineApp
//
//  Created by Mac on 12/29/14.
//  Copyright (c) 2014  Hanny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Transaction.h"
#import "PermanentLines.h"

typedef void (^LoginCompletionHandler)(NSError *error, NSDictionary *user);
typedef void (^DataSyncCompletionHandler)(NSError *error, NSDictionary *user);
typedef void (^AddJobCompletionHandler)(NSError *error, NSDictionary* user);

@interface WebservicesManager : NSObject


@property (strong, nonatomic) NSOperationQueue *requestQueue;

+ (WebservicesManager *)defaultManager;

-(BOOL) pingServerWithHostname;
- (void)requestLoginWithEmail:(NSString *)email
                     password:(NSString *)password
            completionHandler:(LoginCompletionHandler)handler;

- (void)requestListGet:(NSString *)getURLString OfType:(NSString *)typeString withActionFlag:(int)actionFlag andLastSyncDate:(NSString *)lastSyncDate CompletionHandler:(DataSyncCompletionHandler) handler;
-(void) TransactionSynchronoulsySET:(Transaction *) transactObj withActionFlag:(int) actionFlag CompletionHandler:(AddJobCompletionHandler) handler;
-(void) TransactionSET:(Transaction *) transactObj withActionFlag:(int) actionFlag CompletionHandler:(DataSyncCompletionHandler) handler;
-(void) PermanentLinesSET:(PermanentLines *) permLineObj withActionFlag:(int) actionFlag CompletionHandler:(DataSyncCompletionHandler) handler;
-(void) searchInfoOnServerForCustomer:(NSString *) customerCode andLevel2:(NSString *)level2Key usingURL:(NSString *) urlString andCriteria:(NSString *)criteriaString CompletionHandler:(AddJobCompletionHandler) handler;
-(void) requestChangePassword:(NSString *)newPass withCompletionHandler:(DataSyncCompletionHandler) handler;

@end
