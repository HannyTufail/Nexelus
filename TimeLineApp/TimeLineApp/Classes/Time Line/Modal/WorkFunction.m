//
//  WorkFunction.m
//  TimeLineApp
//
//  Created by Mac on 12/26/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "WorkFunction.h"

@implementation WorkFunction

@synthesize resUsageCode = _resUsageCode;
@synthesize resUsageDescription = _resUsageDescription;

-(id) initWithResUsageCode:(NSString *) resUsgCode andResUsageDescription:(NSString *)desc
{
    if (self = [super init]) {
        self.resUsageCode = resUsgCode;
        self.resUsageDescription = desc;
    }
    return self;
}
@end
