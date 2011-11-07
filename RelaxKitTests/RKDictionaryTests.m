//
//  RKDictionaryTests.m
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-06.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKDictionaryTests.h"
#import <RelaxKit/RelaxKit.h>
#import "RKDictionary-Private.h"


static NSString *const firstNameKey = @"firstName";
static NSString *const lastNameKey = @"lastName";


@implementation RKDictionaryTests

#pragma mark - Tests

- (void)testDictionarylike;
{
    RKDictionary *dict = [[RKDictionary alloc] init];
    STAssertTrue([dict count] == 0, @"New dictionary should be empty");
    STAssertNil(dict.document, @"New dictionary should start with no document");
    
    [dict setValue:@"Freddie" forKey:firstNameKey];
    STAssertTrue([dict count] == 1, @"Setting new value should increase count");
    STAssertEqualObjects([dict valueForKey:firstNameKey], @"Freddie", @"Getter should return equal value");
    
    NSDictionary *afterOneDict = [dict dictionaryRepresentation];
    STAssertTrue([afterOneDict count] == 1, @"Dictionary representation should have same count and values");
    STAssertEqualObjects([afterOneDict valueForKey:firstNameKey], @"Freddie", @"Dictionary representation should have same count and values");
    
    [dict setValue:@"Mercury" forKey:lastNameKey];
    STAssertTrue([dict count] == 2, @"Setting new value should increase count");
    STAssertEqualObjects([dict valueForKey:lastNameKey], @"Mercury", @"Getter should return equal value");
    
    STAssertTrue([afterOneDict count] == 1, @"Dictionary representation should be immutable snapshot");
    STAssertTrue([[dict dictionaryRepresentation] count] == 2, @"Setting new value should increase count");
    
    RKDictionary *copy = [dict copy];
    
    STAssertEqualObjects([dict dictionaryRepresentation], [copy dictionaryRepresentation], @"Copies should have equal dictionary representations");
    
    [dict setValue:@"Farrokh" forKey:firstNameKey];
    STAssertTrue([dict count] == 2, @"Setting value for old key should keep count constant");
    STAssertEqualObjects([dict valueForKey:firstNameKey], @"Farrokh", @"Getter should return equal value");
    STAssertEqualObjects([copy valueForKey:firstNameKey], @"Freddie", @"Copy should have separate mutation");
    
    STAssertFalse([[dict dictionaryRepresentation] isEqual:[copy dictionaryRepresentation]], @"Copies should have equal dictionary representations");
}

- (void)testModificationBlocks;
{
    RKDictionary *dict = [[RKDictionary alloc] init];
    STAssertFalse(dict.insideModificationBlock, NULL);
    
    BOOL modSuccess = [dict modifyWithBlock:^BOOL(RKDictionary *localDict) {
        STAssertTrue(dict == localDict, @"Argument should be same as receiver");
        STAssertTrue(localDict.insideModificationBlock, NULL);
        return YES;
    }];
    STAssertFalse(dict.insideModificationBlock, NULL);
    STAssertTrue(modSuccess, NULL);
    
    modSuccess = [dict modifyWithBlock:^BOOL(RKDictionary *localDict) {
        return NO;
    }];
    STAssertFalse(modSuccess, NULL);
    
    [dict modifyWithBlock:^BOOL(RKDictionary *localDict) {
        [localDict setValue:@"Freddie" forKey:firstNameKey];
        return YES;
    }];
    STAssertTrue([dict count] == 1, @"Setting new value should increase count");
    STAssertEqualObjects([dict valueForKey:firstNameKey], @"Freddie", @"Getter should return equal value");
    
    __block NSDictionary *beforeDict;
    [dict modifyWithBlock:^BOOL(RKDictionary *localDict) {
        beforeDict = [localDict dictionaryRepresentation];
        [localDict modifyWithBlock:^BOOL(RKDictionary *innerDict) {
            STAssertTrue(dict.insideModificationBlock, NULL);
            STAssertTrue(innerDict.insideModificationBlock, NULL);
            [localDict setValue:@"Mercury" forKey:lastNameKey];
            return YES;
        }];
        return YES;
    }];
    STAssertTrue([beforeDict count] == 1, @"Dictionary representation should be immutable snapshot");
    STAssertTrue([dict count] == 2, @"Setting new value should increase count");
    STAssertEqualObjects([dict valueForKey:lastNameKey], @"Mercury", @"Getter should return equal value");
    
    RKModificationBlock setFreddieToFarrokh = [dict modificationBlockToSetValue:@"Farrokh" forKey:firstNameKey];
    STAssertEqualObjects([dict valueForKey:firstNameKey], @"Freddie", @"Generating modification block shouldn't have side effects");
    
    RKDictionary *modDict = [dict dictionaryByModifyingWithBlock:setFreddieToFarrokh];
    STAssertNotNil(modDict, @"Modification should succeed with old value");
    STAssertEqualObjects([modDict valueForKey:firstNameKey], @"Farrokh", @"Modification block should alter value");
    
    RKDictionary *scratchDict = [dict copy];
    [scratchDict setValue:@"Farrokh" forKey:firstNameKey];
    modDict = [scratchDict dictionaryByModifyingWithBlock:setFreddieToFarrokh];
    STAssertNotNil(modDict, @"Modification should succeed if already at new value");
    STAssertEqualObjects([modDict valueForKey:firstNameKey], @"Farrokh", @"Modification block should alter value");
    
    [scratchDict setValue:@"completelyDifferent" forKey:firstNameKey];
    modDict = [scratchDict dictionaryByModifyingWithBlock:setFreddieToFarrokh];
    STAssertNil(modDict, @"Modification should fail if value is neither old nor new");
    
    [scratchDict setValue:nil forKey:firstNameKey];
    modDict = [scratchDict dictionaryByModifyingWithBlock:setFreddieToFarrokh];
    STAssertNil(modDict, @"Modification should fail if value is neither old nor new");
    
    RKModificationBlock noRealChange = [dict modificationBlockToSetValue:@"Freddie" forKey:firstNameKey];
    [scratchDict setValue:@"completelyDifferent" forKey:firstNameKey];
    modDict = [scratchDict dictionaryByModifyingWithBlock:noRealChange];
    STAssertNotNil(modDict, @"Any modification should succeed if setter was identity");
    STAssertEqualObjects([modDict valueForKey:firstNameKey], @"completelyDifferent", @"Any modification should succeed if setter was identity");
    
    [scratchDict setValue:nil forKey:firstNameKey];
    modDict = [scratchDict dictionaryByModifyingWithBlock:noRealChange];
    STAssertNotNil(modDict, @"Any modification should succeed if setter was identity");
    STAssertTrue([modDict count] == 1, @"Any modification should succeed if setter was identity");
    
    
    RKModificationBlock lowercaseFirstName = ^BOOL(RKDictionary *localDict) {
        NSString *lowercased = [[localDict valueForKey:firstNameKey] lowercaseString];
        [localDict setValue:lowercased forKey:firstNameKey];
        return YES;
    };
    
    modDict = [dict dictionaryByModifyingWithBlock:lowercaseFirstName];
    STAssertEqualObjects([modDict valueForKey:firstNameKey], @"freddie", @"Modification block should alter value");
    
    [dict setValue:@"WOWZA" forKey:firstNameKey];
    modDict = [dict dictionaryByModifyingWithBlock:lowercaseFirstName];
    STAssertEqualObjects([modDict valueForKey:firstNameKey], @"wowza", @"Modification block should alter value");
}

@end
