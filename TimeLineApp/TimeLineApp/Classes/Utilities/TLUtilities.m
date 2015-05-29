
#import "TLUtilities.h"
#import "TLConstants.h"
#import "EncryptToBase64String.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <AVFoundation/AVFoundation.h>
#import "WebservicesManager.h"
#import "SystemServices.h"
#import "DataSyncHandler.h"


#define SystemSharedServices [SystemServices sharedServices]

@implementation TLUtilities

+ (NSURLRequest*)URLRequestWithMethodName:(NSString*)methodName parameters:(NSString*)parameters{
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                             "<SOAP-ENV:Envelope \n"
                             "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" \n"
                             "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" \n"
                             "xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\" \n"
                             "SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\" \n"
                             "xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"> \n"
                             "<SOAP-ENV:Body> \n"
                             "<%@ xmlns=\"http://tempuri.org/\">%@"
                             "</%@> \n"
                             "</SOAP-ENV:Body> \n"
                             "</SOAP-ENV:Envelope>",methodName,parameters,methodName];
    
    NSURL *url = [NSURL URLWithString:kAuthenticationWebservice];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request addValue:[NSString stringWithFormat: @"%@/%@",kXMLLink,methodName] forHTTPHeaderField:@"SOAPAction"];
    
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:30.0];
    [request setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

#pragma mark - Internet Methods

+(BOOL) verifyInternetAvailability
{
    BOOL netAvailable = NO;
    if ([SystemSharedServices connectedToWiFi])
    {
        netAvailable = [[WebservicesManager defaultManager] pingServerWithHostname];
    }
    else if ([SystemSharedServices connectedToCellNetwork])
    {
        netAvailable = [[WebservicesManager defaultManager] pingServerWithHostname];
    }
    else
        netAvailable = NO;
    
    return NO; //netAvailable;
}


#pragma mark - Other Methods.
+ (NSString*) encryptString:(NSString*)string
{
    NSString *responseString = @"";
    if ([string isKindOfClass:[NSString class]] && [string length] > 0)
    {
        responseString =  [EncryptToBase64String base64StringFromData:[string dataUsingEncoding:NSUTF8StringEncoding] length:[string length]];
    }
    
    return responseString;
}

+ (BOOL)isIPad {
    //if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
   // {
   //     return YES;
   // }
    
    return NO;
}

+ (NSString*)formatRequest:(NSString *)orignalString
{
    NSString * temp = [orignalString stringByReplacingOccurrencesOfString:@"(_amp_)" withString:@"&"];
    temp = [temp stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    if ([temp length] == 0 || temp == NULL) {
        temp = @"";
    }
    
    return temp;
}

+(NSString *) generateTransactionIDusingCounter:(int) counter
{
    NSString * transactionID = @"";
    double currentTimeInMilliSeconds = [TLUtilities GetCurrentEPOCHTime];
    NSString * milliSecondsString = [NSString stringWithFormat:@"%i%i",counter, (int)currentTimeInMilliSeconds];
    NSString * resourceID = [[NSUserDefaults standardUserDefaults] valueForKey:UDKEY_RESOURCE_ID];
    if (resourceID.length > 6)
    {
        // It will select "567890" From "1234567890"
        NSUInteger len = resourceID.length;
        NSUInteger loc = len - 6;
        NSUInteger remainingLen = len - loc;
        resourceID = [resourceID substringWithRange:NSMakeRange(loc, remainingLen)];
    }
    
    
    NSString *hexString = [NSString stringWithFormat:@"%llx",(unsigned long long)[milliSecondsString longLongValue]];
    NSString * tempString = [NSString stringWithFormat:@"%@", resourceID];
    tempString = [tempString stringByAppendingString:hexString];
    
    NSString * query = [NSString stringWithFormat:@"SELECT transaction_id FROM pld_transaction WHERE transaction_id = '%@'", tempString];
    NSArray * dataArray = [[DataSyncHandler defaultHandler].dbManager loadDataFromDB:query];
    if (dataArray.count >0)
    {
        transactionID = [NSString stringWithFormat:@"%@", resourceID];
        transactionID = [transactionID stringByAppendingString:milliSecondsString];
    }
    else
    {
        transactionID = [NSString stringWithFormat:@"%@", resourceID];
        transactionID = [transactionID stringByAppendingString:hexString];
    }
    
    NSLog(@"Converted Transaction ID: %@",transactionID);
    if (transactionID.length > 16)
    {
//        transactionID = [transactionID substringToIndex:16]; // it will select first 16 characters from String.
        
        NSUInteger len = transactionID.length;
        NSUInteger loc = len - 16;
        NSUInteger remainingLen = len - loc;
        transactionID = [transactionID substringWithRange:NSMakeRange(loc, remainingLen)]; // It will select last 16 characters from String.
    }
    return transactionID;
}

+ (BOOL)isSameDayWithDate1:(NSDate*)date1 date2:(NSDate*)date2{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

+ (NSDate *)dateByAddingDays:(int)days inDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = days;
    
    return [calendar dateByAddingComponents:components toDate:date
                             options:0];
}

+ (NSString*)ConvertDate:(NSString*)date FromFormat:(NSString *)format toFormat:(NSString *)toFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:date];
    
    [dateFormatter setDateFormat:toFormat];
    NSString *strindDate = [dateFormatter stringFromDate:dateFromString];

    return strindDate;
}

+ (NSString *) convertServerSideDate:(NSString *)dateString
{
    NSString * date = dateString;
    
    date = [date substringWithRange:NSMakeRange(6, 10)];
    
    if ([date intValue]<0) {
        date = [date stringByAppendingString:@"0"];
    }
    date = [TLUtilities ConvertEPOCHToGMT:[date doubleValue]];
    return date;
}

#pragma mark - EPOCH TIME Methods

// This Method Converts EPOCH time to GMT time and returns it.
+(NSString*)ConvertEPOCHToGMT:(double)epochTime
{
    NSTimeInterval seconds = epochTime;//[epochTime doubleValue];
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+5"]];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString* date = [dateFormatter stringFromDate:epochNSDate];
    
    // (Just for interest) Display your current time zone
//    NSString *currentTimeZone = [[dateFormatter timeZone] abbreviation];
//    NSLog (@"(Your local time zone is: %@)", currentTimeZone);
    return date;
}

// This Method Converts EPOCH time to local time and returns it.
+(NSString*)ConvertEPOCHToLocalTime:(double)epochTime
{
    NSTimeInterval seconds = epochTime;//[epochTime doubleValue];

    // (Step 1) Create NSDate object
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
    //NSLog (@"Epoch time %@ equates to UTC %@", epochTime, epochNSDate);
    
    // (Step 2) Use NSDateFormatter to display epochNSDate in local time zone
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    //NSLog (@"Epoch time %@ equates to %@", epochTime, [dateFormatter stringFromDate:epochNSDate]);
    
    NSString* date = [dateFormatter stringFromDate:epochNSDate];
    
    // (Just for interest) Display your current time zone
    NSString *currentTimeZone = [[dateFormatter timeZone] abbreviation];
    NSLog (@"(Your local time zone is: %@)", currentTimeZone);
    
    return date;
}

// This Method Converts given date time to EPOCH.
+(double)ConvertDateToEPOCH:(NSString*)currdatetime DateFormat:(NSString*)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    
    NSDate* cDateTime = [dateFormatter dateFromString:currdatetime];
    double returnDate = [cDateTime timeIntervalSince1970] * 1000;
    return returnDate;
}

// This Method gets current EPOCH time
+(double)GetCurrentEPOCHTime
{
    NSDate *epochNSDate = [[NSDate alloc] init];
    return [epochNSDate timeIntervalSince1970];
}

+(NSDate *)getCurrentLocalTime
{
    NSDate* sourceDate = [NSDate date];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    return destinationDate;
}

NSString* deviceName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+(NSString *) getDeviceinfo
{
    NSString * deviceVersionString = [NSString stringWithFormat:@"%@ | %@",deviceName(),[[UIDevice currentDevice] systemVersion] ];
    return deviceVersionString;
}
+(NSString *) getIOSVersion
{
    NSString * deviceVersionString = [SystemSharedServices systemsVersion];
    return deviceVersionString;
}


@end
