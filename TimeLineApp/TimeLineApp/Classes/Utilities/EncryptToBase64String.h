//
//  EncryptToBase64String.h
//  SMS-X_1
//
//  Created by Talat on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EncryptToBase64String : NSObject {
    
}
+ (NSString *) base64StringFromData:(NSData *)data length:(NSUInteger)length;
+ (NSData *) base64DataFromString: (NSString *)string;
@end
