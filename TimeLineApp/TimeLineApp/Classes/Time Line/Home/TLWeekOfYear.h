
#import <Foundation/Foundation.h>

@interface TLWeekOfYear : NSObject
{
    
}

@property (nonatomic , strong) NSDate *weekStartDate;
@property (nonatomic , strong) NSDate *weekEndDate;


@property (nonatomic , strong) NSString *weekStartDateString;
@property (nonatomic , strong) NSString *weekEndDateString;

@property (nonatomic , readwrite) NSUInteger weekNumber;
@property (nonatomic , readwrite) NSUInteger year;

@end
