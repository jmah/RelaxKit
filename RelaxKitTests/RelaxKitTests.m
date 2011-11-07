//
//  RelaxKitTests.m
//  RelaxKitTests
//
//  Created by Jonathon Mah on 2011-11-06.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RelaxKitTests.h"

#import <RelaxKit/RelaxKit.h>


@implementation RelaxKitTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    STAssertNotNil([RKRevision class], @"Not linked correctly");
}

@end
