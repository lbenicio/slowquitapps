//
//  SlowQuitAppsTests.m
//  SlowQuitAppsTests
//
//  Created by Douglas Teoh on 13/06/14.
//  Copyright (c) 2014 Douglas Teoh. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../SlowQuitApps/SQAPreferences.h"

@interface SlowQuitAppsTests : XCTestCase
@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, copy) NSString *defaultsDomain;
@property (nonatomic, copy) NSDictionary *originalDomain;

@end

@implementation SlowQuitAppsTests

- (void)setUp
{
    [super setUp];
    self.defaults = [NSUserDefaults standardUserDefaults];
    self.defaultsDomain = NSBundle.mainBundle.bundleIdentifier ?: @"SlowQuitAppsTests";
    self.originalDomain = [self.defaults persistentDomainForName:self.defaultsDomain];
    [self.defaults setPersistentDomain:@{} forName:self.defaultsDomain];
}

- (void)tearDown
{
    if (self.originalDomain) {
        [self.defaults setPersistentDomain:self.originalDomain forName:self.defaultsDomain];
    } else {
        [self.defaults removePersistentDomainForName:self.defaultsDomain];
    }
    [super tearDown];
}

- (void)testRegisteredDefaultsAndInvalidDelayFallback
{
    XCTAssertEqual([SQAPreferences delay], 1000);
    XCTAssertEqualObjects([SQAPreferences whitelist], @[]);
    XCTAssertFalse([SQAPreferences invertList]);
    XCTAssertTrue([SQAPreferences displayOverlay]);
    XCTAssertFalse([SQAPreferences disableAutostart]);

    [self.defaults setInteger:0 forKey:@"delay"];
    XCTAssertEqual([SQAPreferences delay], 1000);

    [self.defaults setInteger:-25 forKey:@"delay"];
    XCTAssertEqual([SQAPreferences delay], 1000);
}

- (void)testDelayReflectsCurrentPreference
{
    [self.defaults setInteger:2500 forKey:@"delay"];
    XCTAssertEqual([SQAPreferences delay], 2500);

    [self.defaults setInteger:750 forKey:@"delay"];
    XCTAssertEqual([SQAPreferences delay], 750);
}

- (void)testWhitelistReturnsConfiguredArrayAndHandlesInvalidValue
{
    NSArray<NSString *> *expected = @[@"com.apple.Notes", @"com.apple.finder"];
    [self.defaults setObject:expected forKey:@"whitelist"];
    XCTAssertEqualObjects([SQAPreferences whitelist], expected);

    [self.defaults setObject:@"not-an-array" forKey:@"whitelist"];
    XCTAssertEqualObjects([SQAPreferences whitelist], @[]);
}

- (void)testBooleanPreferencesReflectCurrentValues
{
    [self.defaults setBool:YES forKey:@"invertList"];
    [self.defaults setBool:NO forKey:@"displayOverlay"];
    [self.defaults setBool:YES forKey:@"disableAutostart"];

    XCTAssertTrue([SQAPreferences invertList]);
    XCTAssertFalse([SQAPreferences displayOverlay]);
    XCTAssertTrue([SQAPreferences disableAutostart]);

    [self.defaults setBool:NO forKey:@"invertList"];
    [self.defaults setBool:YES forKey:@"displayOverlay"];
    [self.defaults setBool:NO forKey:@"disableAutostart"];

    XCTAssertFalse([SQAPreferences invertList]);
    XCTAssertTrue([SQAPreferences displayOverlay]);
    XCTAssertFalse([SQAPreferences disableAutostart]);
}

@end
