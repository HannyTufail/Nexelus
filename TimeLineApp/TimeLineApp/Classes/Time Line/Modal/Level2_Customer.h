//
//  Customer.h
//  TimeLineApp
//
//  Created by Mac on 12/26/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Level2_Customer : NSObject
{
    NSString * _customerCode;
    NSString * _customerName;
    NSString * _level2Key;
}

@property (nonatomic, retain) NSString * customerCode;
@property (nonatomic, retain) NSString * customerName;
@property (nonatomic, retain) NSString * level2Key;

-(id) initWithCustomerCode:(NSString *) customerCode andCustomerName:(NSString *) customerName andLevel2Key:(NSString *) key;
@end
