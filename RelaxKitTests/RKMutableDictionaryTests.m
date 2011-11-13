//
//  RKMutableDictionaryTests.m
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-06.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKMutableDictionaryTests.h"
#import <RelaxKit/RelaxKit.h>


#define FN @"firstName"
#define LN @"lastName"
#define CHILD @"childDict"


@implementation RKMutableDictionaryTests

#pragma mark - Tests

- (void)testDictionarylike;
{
    RKMutableDictionary *dict = [[RKMutableDictionary alloc] init];
    STAssertTrue([dict count] == 0, @"New dictionary should be empty");
    STAssertNil(dict.document, @"New dictionary should start with no document");
    
    [dict setValue:@"Freddie" forKey:FN];
    STAssertTrue([dict count] == 1, @"Setting new value should increase count");
    STAssertEqualObjects([dict valueForKey:FN], @"Freddie", @"Getter should return equal value");
    
    NSDictionary *afterOneDict = [dict copy];
    STAssertTrue([afterOneDict count] == 1, @"Dictionary representation should have same count and values");
    STAssertEqualObjects([afterOneDict valueForKey:FN], @"Freddie", @"Dictionary representation should have same count and values");
    
    [dict setValue:@"Mercury" forKey:LN];
    STAssertTrue([dict count] == 2, @"Setting new value should increase count");
    STAssertEqualObjects([dict valueForKey:LN], @"Mercury", @"Getter should return equal value");
    
    STAssertTrue([afterOneDict count] == 1, @"Dictionary representation should be immutable snapshot");
    STAssertTrue([dict count] == 2, @"Setting new value should increase count");
    
    RKMutableDictionary *copy = [dict mutableCopy];
    
    STAssertEquals([dict hash], [copy hash], @"Equal copies should have equal hashes");
    STAssertEqualObjects(dict, copy, @"Copies should compare equal");
    
    [dict setValue:@"Farrokh" forKey:FN];
    STAssertTrue([dict count] == 2, @"Setting value for old key should keep count constant");
    STAssertEqualObjects([dict valueForKey:FN], @"Farrokh", @"Getter should return equal value");
    STAssertEqualObjects([copy valueForKey:FN], @"Freddie", @"Copy should have separate mutation");
    
    STAssertFalse([dict isEqual:copy], @"Copies should be independent");
}

- (void)testCreation;
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"aval", @"akey", @"bval", @"bkey", nil];
    
    RKMutableDictionary *madeWithObjectsAndKeys = [RKMutableDictionary dictionaryWithObjectsAndKeys:
                                                   @"aval", @"akey", @"bval", @"bkey", nil];
    STAssertEqualObjects(madeWithObjectsAndKeys, dict, @"-dictionaryWithObjectsAndKeys: should work for RKMutableDictionary");
    STAssertEqualObjects([RKMutableDictionary dictionaryWithDictionary:dict], dict, @"-dictionaryWithDictionary: should work for RKMutableDictionary");
    
    RKMutableDictionary *withCapacity = [RKMutableDictionary dictionaryWithCapacity:3];
    [withCapacity setObject:@"aval" forKey:@"akey"];
    [withCapacity setObject:@"bval" forKey:@"bkey"];
    STAssertEqualObjects(withCapacity, dict, @"-dictionaryWithCapacity: should work for RKMutableDictionary");
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
        [localDict setValue:@"Freddie" forKey:FN];
        return YES;
    }];
    STAssertTrue(modResult, NULL);
    STAssertTrue([dict count] == 1, @"Setting new value should increase count");
    STAssertEqualObjects([dict valueForKey:FN], @"Freddie", @"Getter should return equal value");
    
    modResult = [dict modifyWithBlock:^BOOL(RKMutableDictionary *localDict) {
        [localDict setValue:@"ZZZ" forKey:FN];
        [localDict setValue:nil forKey:FN];
        return NO;
    }];
    STAssertFalse(modResult, NULL);
    STAssertTrue([dict count] == 1, @"Failed modification block should leave dictionary unchanged");
    STAssertEqualObjects([dict valueForKey:FN], @"Freddie", @"Failed modification block should leave dictionary unchanged");
    
    
    __block NSDictionary *beforeDict;
    modResult = [dict modifyWithBlock:^BOOL(RKMutableDictionary *localDict) {
        beforeDict = [localDict copy];
        [localDict setValue:@"Mercury" forKey:LN];
        return YES;
    }];
    STAssertTrue([beforeDict count] == 1, @"Dictionary representation should be immutable snapshot");
    STAssertTrue([dict count] == 2, @"Setting new value should increase count");
    STAssertEqualObjects([dict valueForKey:LN], @"Mercury", @"Getter should return equal value");
    
    
    RKModificationBlock lowercaseFirstName = ^BOOL(RKMutableDictionary *localDict) {
        NSString *lowercased = [[localDict valueForKey:FN] lowercaseString];
        [localDict setValue:lowercased forKey:FN];
        return YES;
    };
    
    modResult = [dict modifyWithBlock:lowercaseFirstName];
    STAssertTrue(modResult, @"Custom modification block should succeed");
    STAssertEqualObjects([dict valueForKey:FN], @"freddie", @"Modification block should alter value");
    
    [dict setValue:@"WOWZA" forKey:FN];
    modResult = [dict modifyWithBlock:lowercaseFirstName];
    STAssertTrue(modResult, @"Custom modification block should succeed");
    STAssertEqualObjects([dict valueForKey:FN], @"wowza", @"Modification block should alter value");
    
    
    NSString *const salesCountKey = @"salesCount";
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
    RKMutableDictionary *parent = [[RKMutableDictionary alloc] init];
    
    RKMutableDictionary *prospectiveChild = [[RKMutableDictionary alloc] init];
    [prospectiveChild setValue:@"Stanley" forKey:FN];
    STAssertNil(prospectiveChild.parentCollection, @"Dictionary should have no initial parent");
    
    [parent setValue:prospectiveChild forKey:CHILD];
    RKMutableDictionary *actualChild = [parent valueForKey:CHILD];
    STAssertEquals([parent valueForKeyPath:CHILD"."FN], @"Stanley", @"-valueForKeyPath: should traverse child dictionaries");
    
    STAssertNil(prospectiveChild.parentCollection, @"Original dictionary should be unchanged");
    STAssertNil(prospectiveChild.keyInParent, @"Original dictionary should be unchanged");
    STAssertTrue(actualChild.parentCollection == parent, @"Child value's parent should be set");
    STAssertEqualObjects(actualChild.keyInParent, CHILD, @"Child value's key-in-parent should be set");
    
    STAssertEqualObjects(actualChild.keyPathFromRootCollection, CHILD, @"Child value's keyPath from parent should be valid");
    
    [actualChild setValue:[RKMutableDictionary dictionaryWithObject:@"Susan" forKey:FN]
                   forKey:CHILD];
    RKMutableDictionary *actualGrandchild = [actualChild valueForKey:CHILD];
    STAssertEqualObjects([actualGrandchild valueForKey:FN], @"Susan", nil);
    STAssertEqualObjects([actualGrandchild keyPathFromRootCollection], CHILD"."CHILD, @"Grandchild value's keyPath from parent should be valid");
    STAssertEqualObjects([parent valueForKeyPath:CHILD"."CHILD"."FN], @"Susan", nil);
}

// TODO: Check values are copied (if funneled through -setValue:forKey:)

@end
