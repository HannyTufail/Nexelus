//
//  Level2_Job.h
//  TimeLineApp
//
//  Created by Mac on 12/26/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Level2_Job : NSObject
{
    // level2_key TEXT, level2_description TEXT
    
    NSString * _level2Key;
    NSString * _level2Description;
    NSString * _lastSyncDate;
    NSString * _closeDate;
    NSString * _openDate;
    
    int  _level2Status;
    
}

@property (nonatomic, retain) NSString * level2Key;
@property (nonatomic, retain) NSString * level2Description;
@property (nonatomic, retain) NSString * lastSyncDate;

@property (nonatomic, assign) int  level2Status;
@property (nonatomic, retain) NSString * closeDate;
@property (nonatomic, retain) NSString * openDate;

-(id) initWithLevel2Key:(NSString *)key andDescription:(NSString *)description syncedLastOnDate:(NSString *)syncDate withLevel2Status:(int)statusCode onOpeningDate:(NSString *)openingDate andClosingDate:(NSString *)closingDate ;

@end
