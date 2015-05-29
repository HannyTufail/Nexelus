//
//  Resource.m
//  TimeLineApp
//
//  Created by Mac on 12/29/14.
//  Copyright (c) 2014  Hanny. All rights reserved.
//

#import "Resource.h"

@implementation Resource

@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize resourceID = _resourceID;
@synthesize companyCode = _companyCode;
@synthesize loginId = _loginId;
@synthesize password = _password;
@synthesize authenticationKey  = _authenticationKey;
@synthesize resourceUsageCode = _resourceUsageCode;
@synthesize orgUnitCode = _orgUnitCode;
@synthesize locationCode = _locationCode;
@synthesize showTask = _showTask;
@synthesize showWorkFunction = _showWorkFunction;
@synthesize isUsingActiveDirectory = _isUsingActiveDirectory;

@synthesize last_sync_date_level2 = _last_sync_date_level2;
@synthesize last_sync_date_level2_customer = _last_sync_date_level2_customer;
@synthesize last_sync_date_level3 = _last_sync_date_level3;
@synthesize last_sync_date_permanent_line = _last_sync_date_permanent_line;
@synthesize last_sync_date_res_usage = _last_sync_date_res_usage;
@synthesize last_sync_date_sys_names = _last_sync_date_sys_names;
@synthesize last_sync_date_task = _last_sync_date_task;
@synthesize last_sync_date_transaction = _last_sync_date_transaction;


-(id) initWithResourceID:(NSString *) resourceID firstName:(NSString *)firstName lastName:(NSString *)lastName resCodeUsage:(NSString *)resCodeUsage orgUnit:(NSString *)orgUnit locationCode:(NSString *)locationCode companyCode:(NSString *)companyCode showTaskFlag:(int)showTaskFlag showWorkFunctionFlag:(int) showWorkFunctionFlag andIsUsingActiveDirectory:(int) activeDirectoryFlag
{
    if (self = [super init]) {
        
        self.firstName = firstName;
        self.lastName = lastName;
        self.resourceID = resourceID;
        self.resourceUsageCode = resCodeUsage;
        self.orgUnitCode = orgUnit;
        self.locationCode = locationCode;
        self.companyCode = companyCode;
        self.showTask = showTaskFlag;
        self.showWorkFunction = showWorkFunctionFlag;
        self.isUsingActiveDirectory = activeDirectoryFlag;
    }
    
    return self;
}

@end
