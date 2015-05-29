//
//  Resource.h
//  TimeLineApp
//
//  Created by Mac on 12/29/14.
//  Copyright (c) 2014  Hanny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Resource : NSObject
{
    //pdd_resource(company_code INTEGER,resource_id TEXT,login_id  TEXT,password TEXT, key TEXT,res_usage_code TEXT,org_unit TEXT,location_code TEXT,last_sync_datetime TEXT,PRIMARY KEY(company_code, resource_id));
    
    NSString * _companyCode;
    NSString * _resourceID;
    NSString * _loginId;
    NSString * _password;
    NSString * _authenticationKey;
    NSString * _resourceUsageCode;
    NSString * _orgUnitCode;
    NSString * _locationCode;
    NSString * _firstName;
    NSString * _lastName;
    
    int _showTask;
    int _showWorkFunction;
    int _isUsingActiveDirectory;
    
    
    NSString * _last_sync_date_level2_customer;
    NSString * _last_sync_date_res_usage;
    NSString * _last_sync_date_sys_names;
    NSString * _last_sync_date_task;
    NSString * _last_sync_date_level2;
    NSString * _last_sync_date_level3;
    NSString * _last_sync_date_transaction;
    NSString * _last_sync_date_permanent_line;

}

@property (nonatomic, retain) NSString * companyCode;
@property (nonatomic, retain) NSString * resourceID;
@property (nonatomic, retain) NSString * loginId;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * authenticationKey;
@property (nonatomic, retain) NSString * resourceUsageCode;
@property (nonatomic, retain) NSString * orgUnitCode;
@property (nonatomic, retain) NSString * locationCode;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;

@property (nonatomic, assign) int showTask;
@property (nonatomic, assign) int showWorkFunction;
@property (nonatomic, assign) int isUsingActiveDirectory;


@property (nonatomic, retain) NSString * last_sync_date_level2_customer;
@property (nonatomic, retain) NSString * last_sync_date_res_usage;
@property (nonatomic, retain) NSString * last_sync_date_sys_names;
@property (nonatomic, retain) NSString * last_sync_date_task;
@property (nonatomic, retain) NSString * last_sync_date_level2;
@property (nonatomic, retain) NSString * last_sync_date_level3;
@property (nonatomic, retain) NSString * last_sync_date_transaction;
@property (nonatomic, retain) NSString * last_sync_date_permanent_line;

-(id) initWithResourceID:(NSString *) resourceID firstName:(NSString *)firstName lastName:(NSString *)lastName resCodeUsage:(NSString *)resCodeUsage orgUnit:(NSString *)orgUnit locationCode:(NSString *)locationCode companyCode:(NSString *)companyCode showTaskFlag:(int)showTaskFlag showWorkFunctionFlag:(int) showWorkFunctionFlag andIsUsingActiveDirectory:(int) activeDirectoryFlag;

@end
