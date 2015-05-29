//
//  Customer.m
//  TimeLineApp
//
//  Created by Mac on 12/26/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import "Level2_Customer.h"

@implementation Level2_Customer

@synthesize customerCode = _customerCode;
@synthesize customerName = _customerName;
@synthesize level2Key = _level2Key;


-(id) initWithCustomerCode:(NSString *) customerCode andCustomerName:(NSString *) customerName andLevel2Key:(NSString *)key{
    if (self = [super init]) {
        self.customerCode = customerCode;
        self.customerName = customerName;
        self.level2Key = key;
    }
    return  self;
}
@end
