//
//  WorkFunction.h
//  TimeLineApp
//
//  Created by Mac on 12/26/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorkFunction : NSObject
{
    NSString * _resUsageCode;
    NSString * _resUsageDescription;
}

@property (retain, nonatomic) NSString * resUsageCode;
@property (retain, nonatomic)  NSString * resUsageDescription;

-(id) initWithResUsageCode:(NSString *) resUsgCode andResUsageDescription:(NSString *)desc;

@end
