//
//  TLDatabaseHandler.m
//  TimeLineApp
//
//  Created by Mac on 12/26/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "TLDatabaseHandler.h"
#import "Transaction.h"

@implementation TLDatabaseHandler

static TLDatabaseHandler * _dbHandler;

+(TLDatabaseHandler *) database{
    
    if (_dbHandler == nil) {
        _dbHandler =[[TLDatabaseHandler alloc] init];
    }
    return _dbHandler;
}

-(id) init {
    if (self = [super init]) {
//        NSString * sqLiteDB = [[NSBundle mainBundle] pathForResource:@"timesheet_db" ofType:@"db"];
//        if (sqlite3_open([sqLiteDB UTF8String], &_database)!= SQLITE_OK) {
//            NSLog(@"Failed to Open database!");
//        }
        
        }
    return self;
}

-(NSArray *) pldTransactionInfos {
    
    NSMutableArray * retrievalArray = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement;
    NSString * query = @"SELECT * FROM pld_transaction ORDER BY submitted_date DESC;";
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
            /*
             pld_transaction(company_code INTEGER,transaction_id TEXT,level2_key  TEXT,level3_key TEXT, applied_date DATE,trx_type INTEGER,resource_id TEXT,res_usage_code TEXT,unit REAL,location_code TEXT,org_unit  TEXT,task_code TEXT, comments TEXT,nonbillable_flag INTEGER,submitted_falg  INTEGER,submitted_date DATE, approval_flag INTEGER,sync_status INTEGER,deleted  INTEGER,modified_datetime DATE,PRIMARY KEY(company_code, transaction_id));
             */
        // 12|TransactionID|Level2Key|Level3Key|2014-12-29|1|resourceID 123456|Resource usage code|2.2|location code|Org Unit|Task Code|Comments here|0|0|2014-12-29|0|0|0|2014-12-29
        while (sqlite3_step(statement) ==  SQLITE_ROW)
        {
            int companyCode =       sqlite3_column_int(statement, 0);
            char * transactionID =  (char *)sqlite3_column_text(statement, 1);
            char * level2Key =      (char *)sqlite3_column_text(statement, 2);
            char * level3Key =      (char *) sqlite3_column_text(statement, 3);
            char * appliedDate =    (char *) sqlite3_column_text(statement, 4);
            int transactionType =   sqlite3_column_int(statement, 5);
            char * resourceID =     (char *) sqlite3_column_text(statement, 6);
            char * resUsageCode =   (char *) sqlite3_column_text(statement, 7);
            double unit  =           sqlite3_column_double(statement, 8);
            char * locationCode =   (char *) sqlite3_column_text(statement, 9);
            char * orgUnit =        (char *) sqlite3_column_text(statement, 10);
            char * taskCode =       (char *) sqlite3_column_text(statement, 11);
            char * comments =       (char *) sqlite3_column_text(statement, 12);
            int nonBillableFlag =   sqlite3_column_int(statement, 13);
            int submittedFlag =     sqlite3_column_int(statement, 14);
            char * submittedDate =  (char *) sqlite3_column_text(statement, 15);
            int approvalFlag =      sqlite3_column_int(statement, 16);
            int syncStatus =        sqlite3_column_int(statement, 17);
            int deleted =           sqlite3_column_int(statement, 18);
            char * modifiedDate =   (char *) sqlite3_column_text(statement, 19);
            
            
//            NSString * nameString = [NSString stringWithUTF8String:nameChar];
//            NSString * cityString = [NSString stringWithUTF8String:cityChar];
//            NSString * stateString = [NSString stringWithUTF8String:stateChar];
            
            Transaction * tempObj = [[Transaction alloc]initTransactionWithID:[NSString stringWithUTF8String:transactionID]
                                                                        ofJob:[NSString stringWithUTF8String:level2Key]
                                                                     activity:[NSString stringWithUTF8String:level3Key]
                                                                     taskCode:[NSString stringWithUTF8String:taskCode]
                                                                      orgUnit:[NSString stringWithUTF8String:orgUnit]
                                                                     comments:[NSString stringWithUTF8String:comments]
                                                                     resource:[NSString stringWithUTF8String:resourceID]
                                                                    createdOn:[NSString stringWithUTF8String:submittedDate]
                                                                   modifiedOn:[NSString stringWithUTF8String:modifiedDate]
                                                                    withFlags:approvalFlag
                                                                   submitFlag:submittedFlag
                                                                 billableFlag:nonBillableFlag
                                                                andSyncedFlag:syncStatus];
            [retrievalArray addObject:tempObj];
            
        }
        
        NSLog(@"%d",sqlite3_step(statement));
        sqlite3_finalize(statement);
    }
    return retrievalArray;
}



@end
