//
//  Transaction.m
//  TimeLineApp
//
//  Created by Mac on 12/26/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "Transaction.h"

@implementation Transaction

@synthesize level2Key = _level2Key;
@synthesize level2Description = _level2Description;
@synthesize level3Key = _level3Key;
@synthesize taskCode = _taskCode;
@synthesize orgUnit = _orgUnit;
@synthesize comments = _comments;
@synthesize resourceID = _resourceID;
@synthesize locationCode = _locationCode;

@synthesize modifyDate = _modifyDate;
@synthesize appliedDate = _appliedDate;
@synthesize submittedDate = _submittedDate;
@synthesize errorDescription = _errorDescription;
@synthesize timeStamp = _timeStamp;

@synthesize syncStatus = _syncStatus;
@synthesize nonBillableFlag = _nonBillableFlag;
@synthesize submitFlag = _submitFlag;
@synthesize approvalStatus = _approvalStatus;
@synthesize transactionID = _transactionID;
@synthesize resUsageCode = _resUsageCode;
@synthesize transactionType = _transactionType;
@synthesize units = _units;
@synthesize isPermanentLine = _isPermanentLine;
@synthesize deletedFlag = _deletedFlag;
@synthesize errorCode = _errorCode;
@synthesize errorFlag = _errorFlag;



-(id) initTransactionWithID:(NSString *) transactID transactionType:(int)transType  ofJob:(NSString *) level2Key activity:(NSString *)level3Key taskCode:(NSString *) taskCode orgUnit:(NSString *) orgUnit comments:(NSString *) comments resource:(NSString *) resourceID resUsageCode:(NSString *)resCode  appliedOn:(NSString *) appliedDate modifiedOn:(NSString *) modifiedDate submittedOn:(NSString *)submitDate withApprovalFlags: (int) approvalFlag submitFlag:(int) submitFlag nonBillableFlag:(int)billableFlag andSyncedFlag:(int) syncStatus Units:(float)unit andLocationCode:(NSString *)locationCode
{
    
    if (self = [super init])
    {
        self.transactionID      = transactID;
        self.transactionType    = transType;
        self.level2Key          = level2Key;
        self.level3Key          = level3Key;
        self.taskCode           = taskCode;
        self.orgUnit            = orgUnit;
        self.comments           = comments;
        self.resourceID         = resourceID;
        self.modifyDate         = modifiedDate;
        self.appliedDate        = appliedDate;
        self.submittedDate      = submitDate;
        self.syncStatus         = syncStatus;
        self.nonBillableFlag    = billableFlag;
        self.submitFlag         = submitFlag;
        self.approvalStatus     = approvalFlag;
        self.resUsageCode       = resCode;
        self.units              = unit;
        self.locationCode       = locationCode;
    }
    return  self;    
}


#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy)
    {
//        // Copy NSObject subclasses
        [copy setTransactionID:[self.transactionID copyWithZone:zone]];
        
        [copy setTransactionID:[self.transactionID copyWithZone:zone]];
//
        [copy setLevel2Key:[self.level2Key copyWithZone:zone]];
        [copy setLevel3Key:[self.level3Key copyWithZone:zone]];
        [copy setTaskCode:[self.taskCode copyWithZone:zone]];
        [copy setOrgUnit:[self.orgUnit copyWithZone:zone]];
        [copy setComments:[self.comments copyWithZone:zone]];
        [copy setResourceID:[self.resourceID copyWithZone:zone]];
        [copy setModifyDate:[self.modifyDate copyWithZone:zone]];
        [copy setAppliedDate:[self.appliedDate copyWithZone:zone]];
        [copy setSubmittedDate:[self.submittedDate copyWithZone:zone]];
        [copy setResUsageCode:[self.resUsageCode copyWithZone:zone]];
        [copy setLocationCode:[self.locationCode copyWithZone:zone]];
        [copy setTimeStamp:[self.timeStamp copyWithZone:zone]];
        [copy setErrorDescription:[self.timeStamp copyWithZone:zone]];
        
        
        [copy setTransactionType:self.transactionType];
        [copy setSyncStatus:self.syncStatus];
        [copy setNonBillableFlag:self.nonBillableFlag];
        [copy setSubmitFlag:self.submitFlag];
        [copy setApprovalStatus:self.approvalStatus];
        [copy setDeletedFlag:self.deletedFlag];
        [copy setUnits:self.units];
        [copy setErrorCode:self.errorCode];
        [copy setErrorFlag:self.errorFlag];
        
        
    }
    
    return copy;
}


@end
