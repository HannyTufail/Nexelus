//
//  SysNames.h
//  TimeLineApp
//
//  Created by Mac on 1/6/15.
//  Copyright (c) 2015  Hanny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SysNames : NSObject
{
    NSString *_fieldName;
    NSString *_displayName;
    NSString * _lastSyncDate;
}

@property(retain, nonatomic) NSString *fieldName;
@property(retain, nonatomic) NSString *displayName;
@property(retain, nonatomic) NSString * lastSyncDate;

-(id) initWithFieldName:(NSString *) fieldTitle andDisplayName:(NSString *) displayTitle;
@end
