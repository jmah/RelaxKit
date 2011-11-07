//
//  RKDictionaryTests.m
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-06.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKDictionaryTests.h"
#import <RelaxKit/RelaxKit.h>


@implementation RKDictionaryTests

#pragma mark - Tests

- (void)testBasicStringValues;
{
    RKDictionary *dict = [[RKDictionary alloc] init];
    STAssertTrue([dict count] == 0, @"New dictionary should be empty");
    [dict setValue:@"Freddie" forKey:@"firstName"];
    STAssertTrue([dict count] == 1, @"Setting new value should increase count");
    STAssertEqualObjects([dict valueForKey:@"firstName"], @"Freddie", @"Getter should return equal value");
}

@end
