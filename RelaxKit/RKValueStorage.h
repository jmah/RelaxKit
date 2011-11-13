//
//  RKValueStorage.h
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-12.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKDocument;
@protocol RKCollection;


// Uses existing values from objc_AssociationPolicy
// LSB 0: Storage is strong
// Bit 1: Copy setter argument
// Bit 8: -retain in getter
// Bit 9: -autorelease in getter
// Custom bit:
// Bit 7: Use RKCollection semantics (set up parentCollection, etc.)
enum {
    RKAssociationRetainNonatomic = 0x001,
    RKAssociationCopyNonatomic = 0x003,
    RKAssociationRKCollectionNonatomic = 0x0F3,
    RKAssociationRetainAtomic = 0x301,
    RKAssociationCopyAtomic = 0x303,
    // TODO: Perhaps support RKAssociationRKCollectionNonatomic = 0x3F3,
};

typedef NSInteger RKAssociationPolicy;


@interface RKValueStorage : NSObject

+ (id)valueStorageForValue:(id)value withPolicy:(RKAssociationPolicy)policy;

- (id)initWithPolicy:(RKAssociationPolicy)policy;
+ (RKAssociationPolicy)policy; // Each policy is implemented by a concrete subclass
- (RKAssociationPolicy)policy;

- (id)value;
- (void)setValue:(id)newValue;

@end


@interface RKCollectionValueStorage : RKValueStorage

- (id)initWithPolicy:(RKAssociationPolicy)policy UNAVAILABLE_ATTRIBUTE;

- (id)initWithKey:(NSString *)key inCollection:(id <RKCollection>)parentCollection __attribute__((nonnull(1,2)));
@property (readonly, nonatomic, copy) NSString *keyInParent;
@property (readonly, nonatomic, weak) id <RKCollection> parentCollection;

@end
