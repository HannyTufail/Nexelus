//
//  Level2_Job.m
//  TimeLineApp
//
//  Created by Mac on 12/26/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "Level2_Job.h"

@implementation Level2_Job

@synthesize level2Key = _level2Key;
@synthesize level2Description = _level2Description;
@synthesize lastSyncDate = _lastSyncDate;
@synthesize level2Status = _level2Status;
@synthesize openDate = _openDate;
@synthesize closeDate = _closeDate;


-(id) initWithLevel2Key:(NSString *)key andDescription:(NSString *)description syncedLastOnDate:(NSString *)syncDate withLevel2Status:(int)statusCode onOpeningDate:(NSString *)openingDate andClosingDate:(NSString *)closingDate
{
    if (self = [super init]) {
        self.level2Key = key;
        self.level2Description = description;
        self.lastSyncDate = syncDate;
        self.level2Status = statusCode;
        self.openDate = openingDate;
        self.closeDate = closingDate;
    }
    return self;
}

@end
