//
//  PermanentLines.h
//  TimeLineApp
//
//  Created by Mac on 1/6/15.
//  Copyright (c) 2015  Hanny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PermanentLines : NSObject
{
    NSString * _level2Key;
    NSString * _level2Description;
    NSString * _level3Key;
    NSString * _taskCode;
    NSString * _startDate;
    NSString * _endDate;
    NSString * _resourceID;
    int _syncStatus;
}

@property(retain,nonatomic) NSString * level2Key;
@property(retain,nonatomic) NSString * level2Description;
@property(retain,nonatomic)  NSString * level3Key;
@property(retain,nonatomic)  NSString * taskCode;
@property(retain,nonatomic)  NSString * startDate;
@property(retain,nonatomic)  NSString * endDate;
@property(retain,nonatomic)  NSString * resourceID;
@property(assign, nonatomic) int syncStatus;


-(id) initWithLevel2Key:(NSString *) level2Key level3Key:(NSString *) level3Key withTaskCode:(NSString *)taskCode startingDate:(NSString *) startDate endingDate:(NSString *)endDate andResourceID:(NSString *) resID;
@end
