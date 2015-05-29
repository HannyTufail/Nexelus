//
//  PermanentLines.m
//  TimeLineApp
//
//  Created by Mac on 1/6/15.
//  Copyright (c) 2015  Hanny. All rights reserved.
//

#import "PermanentLines.h"

@implementation PermanentLines

@synthesize level2Key=_level2Key;
@synthesize level3Key=_level3Key;
@synthesize taskCode=_taskCode;
@synthesize startDate=_startDate;
@synthesize endDate=_endDate;
@synthesize resourceID=_resourceID;
@synthesize level2Description = _level2Description;
@synthesize syncStatus = _syncStatus;

-(id) initWithLevel2Key:(NSString *) lev2Key level3Key:(NSString *) lev3Key withTaskCode:(NSString *)taskCde startingDate:(NSString *) startingDate endingDate:(NSString *)endingDate andResourceID:(NSString *) resID
{
    if (self = [super init]) {
        self.level2Key = lev2Key;
        self.level3Key = lev3Key;
        self.taskCode = taskCde;
        self.startDate = startingDate;
        self.endDate = endingDate;
        self.resourceID = resID;
    }
    return self;
}

@end
