//
//  SysNames.m
//  TimeLineApp
//
//  Created by Mac on 1/6/15.
//  Copyright (c) 2015  Hanny. All rights reserved.
//

#import "SysNames.h"

@implementation SysNames

@synthesize fieldName = _fieldName;
@synthesize displayName = _displayName;
@synthesize lastSyncDate = _lastSyncDate;

-(id) initWithFieldName:(NSString *) fieldTitle andDisplayName:(NSString *) displayTitle
{
    if (self = [super init]) {
        self.fieldName = fieldTitle;
        self.displayName = displayTitle;
    }
    return self;
}
@end
