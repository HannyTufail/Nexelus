//
//  Task.h
//  TimeLineApp
//
//  Created by Mac on 12/26/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject
{
    NSString * _taskCode;
    NSString * _taskDescription;
    int _taskType;
    NSString * _taskTypeDescription;
    
}

@property (nonatomic, assign) int taskType;
@property (nonatomic, retain) NSString * taskDescription;
@property (nonatomic, retain) NSString * taskTypeDescription;
@property (nonatomic, retain) NSString * taskCode;

-(id) initWithTaskCode:(NSString *) taskCode ofType:(int) taskType withTaskDescription:(NSString *)taskDesc andTaskTypeDescription:(NSString *)taskTypeDesc;

@end
