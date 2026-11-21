#import "SQAPreferences.h"

@implementation SQAPreferences


+ (NSUserDefaults *)defaults {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      NSDictionary *defaults = @{
                                 @"delay": @1000,
                                 @"whitelist": @[],
                                 @"invertList": @NO,
                                 @"displayOverlay": @YES,
                                 @"disableAutostart": @NO
                                 };
      [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    });
    return [NSUserDefaults standardUserDefaults];
}

+ (BOOL)displayOverlay {
    return [[self defaults] boolForKey:@"displayOverlay"];
}

+ (NSInteger)delay {
    NSInteger delay = [[self defaults] integerForKey:@"delay"];
    return delay > 0 ? delay : 1000;
}

+ (NSArray<NSString *> *)whitelist {
    return [[self defaults] stringArrayForKey:@"whitelist"] ?: @[];
}

+ (BOOL)invertList {
    return [[self defaults] boolForKey:@"invertList"];
}

+ (BOOL)disableAutostart {
    return [[self defaults] boolForKey:@"disableAutostart"];
}

@end
