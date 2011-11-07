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

- (void)testDictionarylike;
{
    RKDictionary *dict = [[RKDictionary alloc] init];
    STAssertTrue([dict count] == 0, @"New dictionary should be empty");
    STAssertNil(dict.document, @"New dictionary should start with no document");
    
    [dict setValue:@"Freddie" forKey:@"firstName"];
    STAssertTrue([dict count] == 1, @"Setting new value should increase count");
    STAssertEqualObjects([dict valueForKey:@"firstName"], @"Freddie", @"Getter should return equal value");
    
    NSDictionary *afterOneDict = [dict dictionaryRepresentation];
    STAssertTrue([afterOneDict count] == 1, @"Dictionary representation should have same count and values");
    STAssertEqualObjects([afterOneDict valueForKey:@"firstName"], @"Freddie", @"Dictionary representation should have same count and values");
    
    [dict setValue:@"Mercury" forKey:@"lastName"];
    STAssertTrue([dict count] == 2, @"Setting new value should increase count");
    STAssertEqualObjects([dict valueForKey:@"lastName"], @"Mercury", @"Getter should return equal value");
    
    STAssertTrue([afterOneDict count] == 1, @"Dictionary representation should be immutable snapshot");
    STAssertTrue([[dict dictionaryRepresentation] count] == 2, @"Setting new value should increase count");
    
    RKDictionary *copy = [dict copy];
    
    STAssertEqualObjects([dict dictionaryRepresentation], [copy dictionaryRepresentation], @"Copies should have equal dictionary representations");
    
    [dict setValue:@"Farrokh" forKey:@"firstName"];
    STAssertTrue([dict count] == 2, @"Setting value for old key should keep count constant");
    STAssertEqualObjects([dict valueForKey:@"firstName"], @"Farrokh", @"Getter should return equal value");
    STAssertEqualObjects([copy valueForKey:@"firstName"], @"Freddie", @"Copy should have separate mutation");
    
    STAssertFalse([[dict dictionaryRepresentation] isEqual:[copy dictionaryRepresentation]], @"Copies should have equal dictionary representations");
}

@end
