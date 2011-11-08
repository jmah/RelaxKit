//
//  RKDictionary.m
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-06.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKDictionary-Private.h"
#import "RKDocument-Private.h"


@implementation RKDictionary {
    NSMutableDictionary *_backingDictionary;
}

@synthesize document = _document;
@synthesize parent = _parent;
@synthesize keyInParent = _keyInParent;

#pragma mark <NSObject>

- (BOOL)isEqual:(id)other;
{
    if ([other isKindOfClass:[RKDictionary class]]) {
        RKDictionary *otherDict = other;
        return [_backingDictionary isEqual:otherDict->_backingDictionary];
    }
    return NO;
}

- (NSUInteger)hash;
{ return [_backingDictionary hash]; }

#pragma mark NSObject (NSKeyValueCoding)

+ (BOOL)accessInstanceVariablesDirectly;
{ return NO; }

- (id)valueForKey:(NSString *)key;
{
    return [_backingDictionary valueForKey:key];
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath;
{
    RKDocument *strongDocument = self.document;
    BOOL needsModificationBlock = (strongDocument && ![strongDocument insideModificationBlock]);
    if (needsModificationBlock) {
        BOOL success = [strongDocument modifyWithBlock:[self modificationBlockToSetValue:value forKeyPath:keyPath]];
        if (!success)
            [NSException raise:NSInternalInconsistencyException format:@"Failed to apply immediate modification block in -[RKDictionary setValue:%@ forKeyPath:%@]. This is either a logic error, or the dictionary was modified concurrently (which is illegal).", value, keyPath];
        
    } else {
        [super setValue:value forKeyPath:keyPath];
    }
}

- (void)setValue:(id)value forKey:(NSString *)key;
{
    RKDocument *strongDocument = self.document;
    BOOL needsModificationBlock = (strongDocument && ![strongDocument insideModificationBlock]);
    if (needsModificationBlock) {
        // Translate into a root-relative -setValue:forKeyPath:
        NSMutableArray *keyAcc = [NSMutableArray arrayWithObject:key];
        RKDictionary *curAncestor = self;
        while ((curAncestor.parent)) {
            [keyAcc insertObject:curAncestor.keyInParent atIndex:0];
            curAncestor = curAncestor.parent;
        }
        NSString *keyPath = [keyAcc componentsJoinedByString:@"."];
        
        // This will create the modification in the document
        [self.document.root setValue:value forKeyPath:keyPath];
        
    } else {
        if ([value isKindOfClass:[RKDictionary class]]) {
            RKDictionary *dictValue = [value copy];
            dictValue.parent = self;
            dictValue.keyInParent = key;
            dictValue.document = strongDocument;
            value = dictValue;
        }
        
        [self willChangeValueForKey:key];
        [_backingDictionary setValue:value forKey:key];
        [self didChangeValueForKey:key];
    }
}


#pragma mark <NSCopying>

- (id)copyWithZone:(NSZone *)zone;
{
    return [[[self class] alloc] initWithDictionary:_backingDictionary];
}


#pragma mark RKDictionary

- (id)init;
{
    return [self initWithDictionary:nil];
}

- (id)initWithDictionary:(NSDictionary *)nsdictOrNil; // Designated initializer
{
    if (!(self = [super init]))
        return nil;
    _backingDictionary = [[NSMutableDictionary alloc] initWithDictionary:nsdictOrNil];
    return self;
}

- (NSUInteger)count;
{
    return [_backingDictionary count];
}

- (NSDictionary *)dictionaryRepresentation;
{
    return [NSDictionary dictionaryWithDictionary:_backingDictionary];
}

- (RKDictionary *)dictionaryByModifyingWithBlock:(RKModificationBlock)modBlock;
{
    RKDictionary *candidate = [self copy];
    if (!modBlock(candidate))
        return nil;
    return candidate;
}


#pragma mark RKDictionary: Private

- (RKModificationBlock)modificationBlockToSetValue:(id)newValue forKeyPath:(NSString *)keyPath;
{
    NSAssert(!self.keyInParent, @"-modificationBlockToSetValue:forKeyPath: should only be called on a root dictionary");
    id oldValue = [self valueForKeyPath:keyPath];
    
    // If unchanged, always succeed (and avoid capturing unneeded values)
    if ((oldValue == newValue) || [oldValue isEqual:newValue])
        return [^BOOL(RKDictionary *localRoot) { return YES; } copy];
    
    return [^BOOL(RKDictionary *localRoot) {
        id curValue = [localRoot valueForKeyPath:keyPath];
        if ((curValue == oldValue) || [curValue isEqual:oldValue]) {
            [localRoot setValue:newValue forKeyPath:keyPath];
            return YES;
        }
        return (curValue == newValue) || [curValue isEqual:newValue];
    } copy];
}

@end
