//
//  Level3_Activity.h
//  TimeLineApp
//
//  Created by Mac on 12/26/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Level3_Activity : NSObject
{
//    level2_key TEXT, level3_key TEXT, level3_description TEXT,date_open DATE, billable_flag INTEGER, task_type INTEGER
    
    NSString * _level2Key;
    NSString * _level3Key;
    NSString * _level3Description;
    NSString * _taskTypeCode;
    
        int _laborFlag;
    NSString * _closeDate;
    NSString * _openDate;
    
}

@property(nonatomic, retain) NSString * level2Key;
@property(nonatomic, retain) NSString * level3Key;
@property(nonatomic, retain) NSString * level3Description;
@property(nonatomic, retain) NSString * taskTypeCode;
@property(nonatomic, retain) NSString * openDate;
@property(nonatomic, retain) NSString * closeDate;
@property(nonatomic, assign) int laborFlag;



-(id) initWithLevel2Key:(NSString *) key1 level3Key:(NSString *)key2 level3Description:(NSString *)description openedOnDate:(NSString *)openDate withTaskTypeCode:(NSString *)code laborFlag:(int)laborCode andCloseDate:(NSString *) closingDate;
@end
