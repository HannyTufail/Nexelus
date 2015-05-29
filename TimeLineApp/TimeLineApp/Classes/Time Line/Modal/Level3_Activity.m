//
//  Level3_Activity.m
//  TimeLineApp
//
//  Created by Mac on 12/26/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "Level3_Activity.h"

@implementation Level3_Activity

@synthesize level2Key = _level2Key;
@synthesize level3Key = _level3Key;
@synthesize openDate = _openDate;
@synthesize level3Description = _level3Description;
@synthesize taskTypeCode = _taskTypeCode;
@synthesize closeDate = _closeDate;
@synthesize laborFlag = _laborFlag;

-(id) initWithLevel2Key:(NSString *) key1 level3Key:(NSString *)key2 level3Description:(NSString *)description openedOnDate:(NSString *)openDate withTaskTypeCode:(NSString *)code  laborFlag:(int)laborCode andCloseDate:(NSString *) closingDate
{
    if (self = [super init])
    {
        self.level2Key = key1;
        self.level3Key = key2;
        self.openDate = openDate;
        self.level3Description = description;
        self.taskTypeCode = code;
        self.laborFlag = laborCode;
        self.closeDate = closingDate;
    }
    
    return self;
}
@end
