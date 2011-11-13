//
//  RKValueStorage.m
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-12.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKValueStorage.h"
#import "RKDocument.h"


#define MAKE_VALUE_STORAGE_SUBCLASS(assocType, semanticsInParens)   \
    @interface _RKValueStorage_ ## assocType : RKValueStorage       \
    @property semanticsInParens id value;                           \
    @end                                                            \
    @implementation _RKValueStorage_ ## assocType                   \
    + (RKAssociationPolicy)policy { return assocType; }             \
    @synthesize value;                                              \
    @end

MAKE_VALUE_STORAGE_SUBCLASS(RKAssociationRetainNonatomic, (retain, nonatomic));
MAKE_VALUE_STORAGE_SUBCLASS(RKAssociationCopyNonatomic, (copy, nonatomic));
MAKE_VALUE_STORAGE_SUBCLASS(RKAssociationRetainAtomic, (retain, atomic));
MAKE_VALUE_STORAGE_SUBCLASS(RKAssociationCopyAtomic, (copy, atomic));


@implementation RKValueStorage

#pragma mark NSObject

- (id)init;
{ return [self initWithPolicy:[[self class] policy]]; }


#pragma mark RKValueStorage

+ (id)valueStorageForValue:(id)value withPolicy:(RKAssociationPolicy)policy;
{
    RKValueStorage *storage = [[self alloc] initWithPolicy:policy];
    storage.value = value;
    return storage;
}

- (id)initWithPolicy:(RKAssociationPolicy)policy;
{
    if (!(self = [super init]))
        return nil;
    
    if ([self isMemberOfClass:[RKValueStorage class]]) {
        // Called on cluster; instantiate a member
        switch (policy) {
#define POLICY_CLASS_CASE(assocType) \
    case assocType: return [[_RKValueStorage_ ## assocType alloc] init]
        
            POLICY_CLASS_CASE(RKAssociationRetainNonatomic);
            POLICY_CLASS_CASE(RKAssociationCopyNonatomic);
            POLICY_CLASS_CASE(RKAssociationRetainAtomic);
            POLICY_CLASS_CASE(RKAssociationCopyAtomic);
        }
        [NSException raise:NSInvalidArgumentException format:@"Unknown value storage policy 0x%lx (or inappropriate initializer)", policy];
        return nil;
#undef POLICY_CLASS_CASE
    }
    
    if (policy != self.policy)
        return nil;
    return self;
}

+ (RKAssociationPolicy)policy;
{ return -1; }

- (RKAssociationPolicy)policy;
{ return [[self class] policy]; }

- (id)value;
{
    [NSException raise:NSInvalidArgumentException format:@"Abstract %s must be implemented in a subclass", __func__];
    return nil;
}

- (void)setValue:(id)newValue;
{
    [NSException raise:NSInvalidArgumentException format:@"Abstract %s must be implemented in a subclass", __func__];
}
             
@end


@implementation RKCollectionValueStorage {
    id <RKCollection> _value;
}

@synthesize keyInParent = _keyInParent;
@synthesize parentCollection = _parentCollection;

#pragma mark RKValueStorage

- (id)initWithPolicy:(RKAssociationPolicy)policy;
{
    [NSException raise:NSIllegalSelectorException format:@"Bad initializer for RKCollectionValueStorage, use -initWithKey:inCollection"];
    return nil;
}

+ (RKAssociationPolicy)policy;
{ return RKAssociationRKCollectionNonatomic; }

- (id)value;
{ return _value; }

- (void)setValue:(id)newValue;
{
    NSParameterAssert(!newValue || [newValue conformsToProtocol:@protocol(RKCollection)]);
    if (_value == newValue)
        return;
    _value = [newValue copy];
}


#pragma mark RKCollectionValueStorage

- (id)initWithKey:(NSString *)key inCollection:(id <RKCollection>)parentCollection;
{
    NSParameterAssert(key && parentCollection);
    if (!(self = [super initWithPolicy:[[self class] policy]]))
        return nil;
    
    _keyInParent = [key copy];
    _parentCollection = parentCollection;
    return self;
}

@end
