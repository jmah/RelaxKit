//
//  RKMutableDictionaryTests.m
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-06.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKMutableDictionaryTests.h"
#import <RelaxKit/RelaxKit.h>


static NSString *const firstNameKey = @"firstName";
static NSString *const lastNameKey = @"lastName";
static NSString *const salesCountKey = @"salesCount";


@implementation RKMutableDictionaryTests

#pragma mark - Tests

- (void)testDictionarylike;
{
    RKMutableDictionary *dict = [[RKMutableDictionary alloc] init];
    STAssertTrue([dict count] == 0, @"New dictionary should be empty");
    STAssertNil(dict.document, @"New dictionary should start with no document");
    
    [dict setValue:@"Freddie" forKey:firstNameKey];
    STAssertTrue([dict count] == 1, @"Setting new value should increase count");
    STAssertEqualObjects([dict valueForKey:firstNameKey], @"Freddie", @"Getter should return equal value");
    
    NSDictionary *afterOneDict = [dict copy];
    STAssertTrue([afterOneDict count] == 1, @"Dictionary representation should have same count and values");
    STAssertEqualObjects([afterOneDict valueForKey:firstNameKey], @"Freddie", @"Dictionary representation should have same count and values");
    
    [dict setValue:@"Mercury" forKey:lastNameKey];
    STAssertTrue([dict count] == 2, @"Setting new value should increase count");
    STAssertEqualObjects([dict valueForKey:lastNameKey], @"Mercury", @"Getter should return equal value");
    
    STAssertTrue([afterOneDict count] == 1, @"Dictionary representation should be immutable snapshot");
    STAssertTrue([dict count] == 2, @"Setting new value should increase count");
    
    RKMutableDictionary *copy = [dict mutableCopy];
    
    STAssertEqualObjects(dict, copy, @"Copies should compare equal");
    
    [dict setValue:@"Farrokh" forKey:firstNameKey];
    STAssertTrue([dict count] == 2, @"Setting value for old key should keep count constant");
    STAssertEqualObjects([dict valueForKey:firstNameKey], @"Farrokh", @"Getter should return equal value");
    STAssertEqualObjects([copy valueForKey:firstNameKey], @"Freddie", @"Copy should have separate mutation");
    
    STAssertFalse([dict isEqual:copy], @"Copies should be independent");
}

- (void)testModificationBlocks;
{
    RKMutableDictionary *dict = [[RKMutableDictionary alloc] init];
    BOOL modResult;
    
    RKMutableDictionary *modDict = [dict mutableCopy];
    modResult = [modDict modifyWithBlock:^BOOL(RKMutableDictionary *localDict) {
        STAssertEqualObjects(dict, localDict, @"Argument should have equal values as receiver");
        return YES;
    }];
    STAssertTrue(modResult, NULL);
    
    modResult = [dict modifyWithBlock:^BOOL(RKMutableDictionary *localDict) {
        return NO;
    }];
    STAssertFalse(modResult, NULL);
    
    modResult = [dict modifyWithBlock:^BOOL(RKMutableDictionary *localDict) {
        [localDict setValue:@"Freddie" forKey:firstNameKey];
        return YES;
    }];
    STAssertTrue(modResult, NULL);
    STAssertTrue([dict count] == 1, @"Setting new value should increase count");
    STAssertEqualObjects([dict valueForKey:firstNameKey], @"Freddie", @"Getter should return equal value");
    
    
    __block NSDictionary *beforeDict;
    modResult = [dict modifyWithBlock:^BOOL(RKMutableDictionary *localDict) {
        beforeDict = [localDict copy];
        [localDict setValue:@"Mercury" forKey:lastNameKey];
        return YES;
    }];
    STAssertTrue([beforeDict count] == 1, @"Dictionary representation should be immutable snapshot");
    STAssertTrue([dict count] == 2, @"Setting new value should increase count");
    STAssertEqualObjects([dict valueForKey:lastNameKey], @"Mercury", @"Getter should return equal value");
    
    
    RKModificationBlock lowercaseFirstName = ^BOOL(RKMutableDictionary *localDict) {
        NSString *lowercased = [[localDict valueForKey:firstNameKey] lowercaseString];
        [localDict setValue:lowercased forKey:firstNameKey];
        return YES;
    };
    
    modResult = [dict modifyWithBlock:lowercaseFirstName];
    STAssertTrue(modResult, @"Custom modification block should succeed");
    STAssertEqualObjects([dict valueForKey:firstNameKey], @"freddie", @"Modification block should alter value");
    
    [dict setValue:@"WOWZA" forKey:firstNameKey];
    modResult = [dict modifyWithBlock:lowercaseFirstName];
    STAssertTrue(modResult, @"Custom modification block should succeed");
    STAssertEqualObjects([dict valueForKey:firstNameKey], @"wowza", @"Modification block should alter value");
    
    
    RKModificationBlock incrementSalesCount = ^BOOL(RKMutableDictionary *localDict) {
        NSNumber *salesCount = [localDict valueForKey:salesCountKey];
        [localDict setValue:[NSNumber numberWithLong:([salesCount longValue] + 1)] forKey:salesCountKey];
        return YES;
    };
    
    [dict setValue:[NSNumber numberWithLong:20] forKey:salesCountKey];
    modResult = [dict modifyWithBlock:incrementSalesCount];
    STAssertTrue(modResult, @"Custom modification block should succeed");
    STAssertEqualObjects([dict valueForKey:salesCountKey], [NSNumber numberWithLong:21], @"Modification block should alter value");
}

- (void)testDictionaryHierarchy;
{
    NSString *const childDictKey = @"childDict";
    RKMutableDictionary *parent = [[RKMutableDictionary alloc] init];
    
    RKMutableDictionary *prospectiveChild = [[RKMutableDictionary alloc] init];
    [prospectiveChild setValue:@"Stanley" forKey:firstNameKey];
    STAssertNil(prospectiveChild.parentCollection, @"Dictionary should have no initial parent");
    
    [parent setValue:prospectiveChild forKey:childDictKey];
    RKMutableDictionary *actualChild = [parent valueForKey:childDictKey];
    NSString *const childFirstNameKey = [[NSArray arrayWithObjects:childDictKey, firstNameKey, nil] componentsJoinedByString:@"."];
    STAssertEquals([parent valueForKeyPath:childFirstNameKey], @"Stanley", @"-valueForKeyPath: should traverse child dictionaries");
    
    STAssertNil(prospectiveChild.parentCollection, @"Original dictionary should be unchanged");
    STAssertNil(prospectiveChild.keyInParent, @"Original dictionary should be unchanged");
    STAssertTrue(actualChild.parentCollection == parent, @"Child value's parent should be set");
    STAssertEqualObjects(actualChild.keyInParent, childDictKey, @"Child value's key-in-parent should be set");
    
    STAssertEqualObjects(actualChild.keyPathFromRootCollection, childDictKey, @"Child value's keyPath from parent should be valid");
}

// TODO: Check values are copied (if funneled through -setValue:forKey:)

@end
