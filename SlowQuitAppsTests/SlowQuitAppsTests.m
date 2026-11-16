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

@end

@implementation SlowQuitAppsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDelayIsPositive
{
	XCTAssertGreaterThan([SQAPreferences delay], 0);
}

@end
