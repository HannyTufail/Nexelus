//
//  Transaction.h
//  TimeLineApp
//
//  Created by Mac on 12/26/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Transaction : NSObject <NSCopying>
{
    NSString * _transactionID;
    NSString * _level2Key;
    NSString * _level2Description;
    NSString * _level3Key;
    NSString * _taskCode;
    NSString * _orgUnit;
    NSString * _comments;
    NSString * _resourceID;
    NSString * _resUsageCode;
    NSString * _locationCode;
    
    NSString * _modifyDate;
    NSString * _appliedDate;
    NSString * _submittedDate;
    
    NSString * _timeStamp;
    NSString * _errorDescription;
    
    int _errorFlag;
    int _errorCode;
    
    int _syncStatus;
    int _nonBillableFlag;
    int _submitFlag;
    int _approvalStatus;
    int _transactionType;
    int _deletedFlag;
    float _units;
    
    BOOL _isPermanentLine;
    
}
@property (nonatomic, retain) NSString * transactionID;
@property (nonatomic, retain) NSString * level2Key;
@property (nonatomic, retain) NSString * level2Description;
@property (nonatomic, retain) NSString * level3Key;
@property (nonatomic, retain) NSString * taskCode;
@property (nonatomic, retain) NSString * orgUnit;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSString * resourceID;
@property (nonatomic, retain) NSString * resUsageCode;
@property (nonatomic, retain) NSString * locationCode;

@property (nonatomic, retain) NSString * modifyDate;
@property (nonatomic, retain) NSString * appliedDate;
@property (nonatomic, retain) NSString * submittedDate;
@property (nonatomic, retain) NSString * timeStamp;
@property (nonatomic, retain) NSString * errorDescription;

@property (nonatomic, assign) int errorFlag;
@property (nonatomic, assign) int errorCode;
@property (nonatomic, assign) int  syncStatus;
@property (nonatomic, assign) int  nonBillableFlag;
@property (nonatomic, assign) int  submitFlag;
@property (nonatomic, assign) int  approvalStatus;
@property (nonatomic, assign) int transactionType;
@property (nonatomic, assign) float units;
@property (nonatomic, assign) int deletedFlag;

@property (nonatomic, assign) BOOL isPermanentLine;


-(id) initTransactionWithID:(NSString *) transactID transactionType:(int )transType ofJob:(NSString *) level2Key activity:(NSString *)level3Key taskCode:(NSString *) taskCode orgUnit:(NSString *) orgUnit comments:(NSString *) comments resource:(NSString *) resourceID resUsageCode:(NSString *)resCode appliedOn:(NSString *) appliedDate modifiedOn:(NSString *) modifiedDate submittedOn:(NSString *)submitDate withApprovalFlags: (int) approvalFlag submitFlag:(int) submitFlag nonBillableFlag:(int)billableFlag andSyncedFlag:(int) syncstatus Units:(float) unit andLocationCode:(NSString *) locationCode;

@end
