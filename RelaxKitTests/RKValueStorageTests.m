//
//  RKValueStorageTests.m
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-12.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKValueStorageTests.h"
#import <RelaxKit/RelaxKit.h>


@implementation RKValueStorageTests

- (void)checkPolicy:(RKAssociationPolicy)policy withValue:(id)value expectCopy:(BOOL)expectCopy;
{
    void (^checkValueStorage)() = ^(RKValueStorage *storage) {
        STAssertNotNil(storage, @"Couldn't create value storage for policy 0x%lx", policy);
        STAssertTrue(storage.policy == policy, @"Declared policy should match initializer");
        
        if (expectCopy) {
            STAssertTrue(storage.value != value, @"Expected unique copy for policy 0x%lx", policy);
            STAssertEqualObjects(storage.value, value, @"Copied value should be equal");
        } else {
            STAssertTrue(storage.value == value, @"Expected same object for policy 0x%lx", policy);
        }
    };
    
    RKValueStorage *storage = [[RKValueStorage alloc] initWithPolicy:policy];
    STAssertNil(storage.value, @"Initial value of storage should be nil");
    storage.value = value;
    checkValueStorage(storage);
    
    checkValueStorage([RKValueStorage valueStorageForValue:value withPolicy:policy]);
}


- (void)testCopyAndRetainStorage;
{
    id unique = [NSMutableSet setWithObject:@"FancyPants"];
    [self checkPolicy:RKAssociationRetainNonatomic withValue:unique expectCopy:NO];
    [self checkPolicy:RKAssociationRetainAtomic withValue:unique expectCopy:NO];
    [self checkPolicy:RKAssociationCopyNonatomic withValue:unique expectCopy:YES];
    [self checkPolicy:RKAssociationCopyAtomic withValue:unique expectCopy:YES];
}

- (void)testCollectionStorage;
{
    RKDictionary *dict = [[RKDictionary alloc] init];
    RKDictionary *parent = [[RKDictionary alloc] init];
    RKValueStorage *collectionStorage = [[RKCollectionValueStorage alloc] initWithKey:@"foo" inCollection:parent];
    STAssertNotNil(collectionStorage, @"Couldn't create value storage for collection");
    STAssertTrue(collectionStorage.policy == RKAssociationRKCollectionNonatomic, @"Declared policy should match initializer");
    STAssertNil(collectionStorage.value, @"Initial value of storage should be nil");
    
    STAssertNoThrow(collectionStorage.value = dict, nil);
    STAssertNoThrow(collectionStorage.value = nil, nil);
    STAssertThrowsSpecificNamed(collectionStorage.value = @"not a collection", NSException, NSInvalidArgumentException, @"Collection storage should reject storing non-collections");
}

@end
