//
//  Task.m
//  TimeLineApp
//
//  Created by Mac on 12/26/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "Task.h"

@implementation Task

@synthesize taskCode = _taskCode;
@synthesize taskType = _taskType;
@synthesize taskDescription = _taskDescription;
@synthesize taskTypeDescription = _taskTypeDescription;

-(id) initWithTaskCode:(NSString *)taskCode ofType:(int)taskType withTaskDescription:(NSString *)taskDesc andTaskTypeDescription:(NSString *)taskTypeDesc
{
    if (self = [super init]) {
        self.taskCode = taskCode;
        self.taskType = taskType;
        self.taskDescription = taskDesc;
        self.taskTypeDescription = taskTypeDesc;
    }
    return self;
}

@end
