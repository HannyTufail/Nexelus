
#import <Foundation/Foundation.h>
#import <sys/utsname.h>

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define kXMLLink @""
#define kAuthenticationWebservice @""
@interface TLUtilities : NSObject

+ (NSURLRequest*)URLRequestWithMethodName:(NSString*)methodName parameters:(NSString*)parameters;

+ (NSString*) encryptString:(NSString*)string;

//method to replace special characters to decided strings
+ (NSString*)formatRequest:(NSString *)orignalString;

//method to return system version of device
//+ (float)systemVersion;
+ (BOOL)isIPad;
//+ (BOOL)canMakecall;
+ (BOOL)isSameDayWithDate1:(NSDate *)date1 date2:(NSDate *)date2;
+ (NSDate *)dateByAddingDays:(int)days inDate:(NSDate *)date;
+ (NSString*)ConvertDate:(NSString*)date FromFormat:(NSString*)format toFormat:(NSString*)toFormat;

//EPOCH TIME METHODS
+(double)GetCurrentEPOCHTime; // I am using it as a TransactionID for time being.
+(NSString*)ConvertEPOCHToGMT:(double)epochTime;
+(NSString*)ConvertEPOCHToLocalTime:(double)epochTime;
+(double)ConvertDateToEPOCH:(NSString*)currdatetime DateFormat:(NSString*)dateFormat;

+ (NSString *) convertServerSideDate:(NSString *)dateString;
+(NSDate *)getCurrentLocalTime;
+(NSString *) generateTransactionIDusingCounter:(int) counter;
+(BOOL) verifyInternetAvailability;
+(NSString *) getDeviceinfo;
+(NSString *) getIOSVersion;

@end
