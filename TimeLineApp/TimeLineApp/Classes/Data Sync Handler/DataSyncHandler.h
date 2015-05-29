//
//  DataSyncHandler.h
//  TimeLineApp
//
//  Created by Mac on 1/3/15.
//  Copyright (c) 2015  Hanny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"
#import "Resource.h"
#import "Transaction.h"


typedef enum : NSUInteger
{
    forTwentyMinutes = 1,
    forPullToRefresh = 2,
    forLogin = 3,
    
} syncTypes;

@protocol DataSyncHandlerDelegate <NSObject>

@optional
-(void) dataSyncedSuccessfully;
-(void) dataRefreshedSuccessfullyAgainstPullToRefresh;
-(void) dataRefreshedSuccessfullyAgainstLogin;
-(void) dataRefreshedSuccessfullyAgainstBackServices;

-(void) permanentLineAddedSuccessfully;
-(void) permanentLineNotAddedDueToError;
-(void) permanentLineDeletedSuccessfully;
-(void) permanentLineNotDeletedDueToError;

@end

typedef void (^LoginViewDataSyncCompletionHandler)(BOOL success);
typedef void (^AddJobDataSyncCompletionHandler)(BOOL success, NSString * errMsg);
typedef void (^EditJobDataSyncCompletionHandler)(BOOL success, NSString * errMsg);
typedef void (^UserSettingsSyncCompletionHandler)(BOOL success, NSString * errMsg);

@interface DataSyncHandler : NSObject

@property (nonatomic, assign) syncTypes _syncTypes;
@property (nonatomic) BOOL isSyncingTransaction;

@property (nonatomic) BOOL isDelegateSetFromLogin;
//@property (nonatomic) BOOL is20MinutesSync;

@property (retain, nonatomic) NSMutableArray * level2Array;
@property (retain, nonatomic) NSMutableArray * level3Array;
@property (retain, nonatomic) NSMutableArray * taskArray;
@property (retain, nonatomic) NSMutableArray * workFunctionArray;
@property (retain, nonatomic) NSMutableArray * level2CustomerArray;
@property (retain, nonatomic) NSMutableArray * permanentLineArray;
@property (retain, nonatomic) NSMutableArray * sysNamesArray;
@property (retain, nonatomic) NSMutableArray * transactionArray;

@property (retain, nonatomic) NSString * level2CustomerLastSyncDateString;
@property (retain, nonatomic) NSString * level2LastSyncDateString;
@property (retain, nonatomic) NSString * level3LastSyncDateString;
@property (retain, nonatomic) NSString * taskLastSyncDateString;
@property (retain, nonatomic) NSString * workFunctionLastSyncDateString;
@property (retain, nonatomic) NSString * permanentLinesLastSyncDateString;
@property (retain, nonatomic) NSString * sysNamesLastSyncDateString;
@property (retain, nonatomic) NSString * transactionsLastSyncDateString;

@property (nonatomic, strong) DBManager *dbManager;
@property (weak, nonatomic) id<DataSyncHandlerDelegate> delegate;

+ (DataSyncHandler *)defaultHandler;

-(void) fetchResouceObjectFromServer;
-(void) fetchLevel2ListFromServerWithCompletionHandler:(LoginViewDataSyncCompletionHandler)handler;
-(void) fetchLevel3ListFromServerWithCompletionHandler:(LoginViewDataSyncCompletionHandler)handler;
-(void) fetchTransactionsListFromServerWithCompletionHandler:(LoginViewDataSyncCompletionHandler)handler;
-(void) fetchTaskListFromServerWithCompletionHandler:(LoginViewDataSyncCompletionHandler)handler;
-(void) fetchResUsageListFromServerWithCompletionHandler:(LoginViewDataSyncCompletionHandler)handler;
-(void) fetchLevel2CustomerListFromServerWithCompletionHandler:(LoginViewDataSyncCompletionHandler)handler;
-(void) fetchPermanentLineListFromServerWithCompletionHandler:(LoginViewDataSyncCompletionHandler)handler;
-(void) fetchSysNamesListFromServerWithCompletionHandler:(LoginViewDataSyncCompletionHandler)handler;
-(void) fetchUserSettingsFromServerWithCompletionHandler:(LoginViewDataSyncCompletionHandler) handler;


-(void) changePassword:(NSString *)passwordString withCompletionHandler:(UserSettingsSyncCompletionHandler)handler;
-(void) syncDataFetchedFromServerWithLocalDB;
-(void) syncLocalDBDataWithServer;
-(Resource *) verifyUserCredentialsWithLocalDB;
-(void) insertResourceValuesInLocalDB:(Resource *)resObj;

// Add/Delete Permanent Lines
-(void) addNewPermanentLineWithLevel2Key:(NSString *)level2KeyString level3Key:(NSString *)level3KeyString taskCode:(NSString *)taskCodeString forDate:(NSString *)selectedDateString;
-(void) deletePermanentLineFromLocalDBAndServerForLevel2Key:(NSString *)level2keyString level3Key:(NSString *)level3KeyString taskCode:(NSString *)taskCodeString andStartDate:(NSString *) startDateString;

// Add/Update/Delete Transactions

-(void) addTransactionOnServer:(Transaction *) transactObj completionHandler:(AddJobDataSyncCompletionHandler) handler;
-(void) updateTransactionOnServer:(Transaction *) transactObj  completionHandler:(EditJobDataSyncCompletionHandler) handler;
-(void) deleteTransactionOnServer:(Transaction *) transactObj  completionHandler:(EditJobDataSyncCompletionHandler) handler;

// Syncing Methods
-(void) fetchAllUnsyncedTransactionsFromLocalDB;
-(void) fetchAllTransactionsToBeDeletedFromLocalDB;
-(void) syncLocalDBTransactionsOnlyWithServerAndFetchLatest;

-(float) getHoursForSelectedDate:(NSString *) dateString withBillableFlag:(BOOL) useBillableFlag;
-(void) executeQuery:(NSString *) queryString;
-(Transaction *) makeAnTransactoinItemFromDBColums:(NSArray *) columsDataArray;
-(Resource *) makeResourceObjectofUser:(NSString *) userName andPassword:(NSString *)password FromServerDictionary:(NSDictionary *) tempDict;

// Parsing Methods
-(BOOL) parseLevel2ListGetResponseData:(NSDictionary *) respDict andError:(NSError *) error;
-(BOOL) parseparseLevel3ListGetResponseData:(NSDictionary *) respDict andError:(NSError *) error;

// Saving Methods to Local DB
-(void) saveFetchedLevel2ListFromServerInLocalDBAfterSynicing:(BOOL) isSyncing;
-(void) saveFetchedLevel3ListFromServerInLocalDBAfterSynicing:(BOOL) isSyncing;

// Deleting DB File from Documents Directory.
-(void) removeDBFile;
-(void) updateLastSyncDateOfRefresh;

@end
