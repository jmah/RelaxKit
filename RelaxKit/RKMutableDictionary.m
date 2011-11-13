//
//  RKMutableDictionary.m
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-06.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKMutableDictionary.h"
#import "RKDocument.h"


static NSString *joinKeyPath(NSString *firstKeyOrNil, NSString *secondKey) {
    NSCParameterAssert(secondKey);
    if (!firstKeyOrNil)
        return secondKey;
    NSMutableString *keyPath = [NSMutableString stringWithCapacity:([firstKeyOrNil length] + 1 + [secondKey length])];
    [keyPath appendString:firstKeyOrNil];
    [keyPath appendString:@"."];
    [keyPath appendString:secondKey];
    return keyPath;
}


@implementation RKMutableDictionary {
    NSMutableDictionary *_backingDictionary;
    
    NSUInteger _modificationDepth;
    NSMutableArray *_deferredDidChangeKeysStack; // Objects are NSMutableArray
    NSMutableArray *_rollbackValuesStack; // Objects are NSMutableDictionary
    BOOL _runningDeferredDidChangeKeys;
}

@synthesize document = _document;
@synthesize keyInParent = _keyInParent;
@synthesize parentCollection = _parentCollection;


#pragma mark NSDictionary: Primitives

- (id)init;
{ return [self initWithCapacity:0]; }

- (NSUInteger)count;
{ return [_backingDictionary count]; }

- (id)objectForKey:(id)key;
{ return [self valueForKey:key]; }

- (NSEnumerator *)keyEnumerator;
{ return [_backingDictionary keyEnumerator]; }


#pragma mark NSMutableDictionary: Primitives

- (id)initWithCapacity:(NSUInteger)initialCapacity;
{
    if (!(self = [super init]))
        return nil;
    _backingDictionary = [[NSMutableDictionary alloc] initWithCapacity:initialCapacity];
    return self;
}

- (void)removeObjectForKey:(id)key;
{ [self setValue:nil forKey:key]; }

- (void)setObject:(id)object forKey:(id)key;
{ [self setValue:object forKey:key]; }


#pragma mark <NSMutableCopying>

- (id)mutableCopyWithZone:(NSZone *)zone;
{
    return [[[self class] alloc] initWithDictionary:_backingDictionary];
}


#pragma mark <RKCollection>

- (id)mutableCopyWithKey:(NSString *)key inParent:(id <RKCollection>)parentCollection ofDocument:(RKDocument *)document;
{
    RKMutableDictionary *copy = [self mutableCopy];
    copy->_keyInParent = [key copy];
    copy->_parentCollection = parentCollection;
    copy->_document = document;
    return copy;
}

- (NSString *)keyPathFromRootCollection;
{
    if (!self.keyInParent)
        return nil;
    if (!self.parentCollection)
        return nil; // Used to be in a hierarchy, now released
    
    return joinKeyPath([self.parentCollection keyPathFromRootCollection], self.keyInParent);
}

- (BOOL)insideModificationBlock;
{ return !!_modificationDepth; }

- (BOOL)modifyWithBlock:(RKModificationBlock)modBlock;
{
    [self beginModifications];
    BOOL success = modBlock(self);
    [self commitModificationsKeepingChanges:success];
    return success;
}

- (void)beginModifications;
{
    if (_modificationDepth++ == 0) {
        _deferredDidChangeKeysStack = [NSMutableArray array];
        _rollbackValuesStack = [NSMutableArray array];
    }
    
    [_deferredDidChangeKeysStack addObject:[NSMutableArray array]];
    [_rollbackValuesStack addObject:[NSMutableDictionary dictionary]];
    
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if ([obj conformsToProtocol:@protocol(RKCollection)])
            [obj beginModifications];
    }];
}

- (void)commitModificationsKeepingChanges:(BOOL)keepChanges;
{
    NSParameterAssert(_modificationDepth > 0);
    
#warning Handle collections that came/went, syncing their mod depth or something
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if ([obj conformsToProtocol:@protocol(RKCollection)])
            [obj commitModificationsKeepingChanges:keepChanges];
    }];
    
    NSArray *deferredDidChangeKeys = [_deferredDidChangeKeysStack lastObject];
    NSDictionary *rollbackValues = [_rollbackValuesStack lastObject];
    
    if (!keepChanges) {
        for (NSString *key in [NSSet setWithArray:deferredDidChangeKeys])
            [self setPrimitiveValue:[rollbackValues valueForKey:key] forKey:key];
    }
    
    _runningDeferredDidChangeKeys = YES;
    [deferredDidChangeKeys enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        [self didChangeValueForKey:key];
    }];
    _runningDeferredDidChangeKeys = NO;
    
    [_deferredDidChangeKeysStack removeLastObject];
    [_rollbackValuesStack removeLastObject];
    
    if (--_modificationDepth == 0) {
        _deferredDidChangeKeysStack = nil;
        _rollbackValuesStack = nil;
    }
}

- (id)valueForKey:(NSString *)key;
{ return [_backingDictionary objectForKey:key]; }

- (void)setValue:(id)value forKey:(NSString *)key;
{
    NSParameterAssert([key isKindOfClass:[NSString class]]);
    RKDocument *strongDocument = self.document;
    if ([self insideModificationBlock] || !strongDocument) {
        id preparedValue = [self prepareSetValue:value forKey:key];
        
        [self willChangeValueForKey:key];
        [self setPrimitiveValue:preparedValue forKey:key];
        [self didChangeValueForKey:key];
        
    } else /* (![self insideModificationBlock] && strongDocument) */ {
        // Translate request into a modification block, if we have a document
        // Modification block does a root-relative -setValue:forKeyPath:
        
        NSString *rootRelative = joinKeyPath(self.keyPathFromRootCollection, key);
        RKModificationBlock rootRelativeModBlock = [strongDocument modificationBlockToSetValue:value forRootKeyPath:rootRelative];
        BOOL success = [strongDocument modifyWithBlock:rootRelativeModBlock];
        if (!success)
            [NSException raise:NSInternalInconsistencyException format:@"Failed to apply immediate modification block in -[RKMutableDictionary setValue:%@ forKey:%@]. This is either a logic error, or the dictionary was modified concurrently (which is illegal).", value, key];
        
    }
}

- (void)setPrimitiveValue:(id)preparedValue forKey:(NSString *)key;
{
    [_backingDictionary setValue:preparedValue forKey:key];
}

- (id)prepareSetValue:(id)value forKey:(NSString *)key;
{
    // Promote collections to an <RKCollection> implementation
    if ([value isKindOfClass:[NSDictionary class]])
        value = [RKMutableDictionary dictionaryWithDictionary:value];
    
    if ([value conformsToProtocol:@protocol(RKCollection)])
        return [value mutableCopyWithKey:key inParent:self ofDocument:self.document];
    
    return [value copy];
}


#pragma mark NSObject (NSKeyValueObserverNotification)

- (void)willChangeValueForKey:(NSString *)key;
{
    // Save rollback value only for the first change of key at this modification depth
    if ([self insideModificationBlock] && ![[_deferredDidChangeKeysStack lastObject] containsObject:key])
        [[_rollbackValuesStack lastObject] setValue:[self valueForKey:key] forKey:key];
    [super willChangeValueForKey:key];
}

- (void)didChangeValueForKey:(NSString *)key;
{
    if ([self insideModificationBlock] && !_runningDeferredDidChangeKeys)
        [[_deferredDidChangeKeysStack lastObject] addObject:key];
    [super didChangeValueForKey:key];
}

@end
