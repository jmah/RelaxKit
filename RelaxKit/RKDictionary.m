//
//  RKDictionary.m
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-06.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKDictionary-Private.h"
#import "RKDocument.h"


@implementation RKDictionary {
    NSMutableDictionary *_backingDictionary;
    NSUInteger _insideModificationBlockRef;
}

@synthesize document = _document;

#pragma mark NSObject (NSKeyValueCoding)

+ (BOOL)accessInstanceVariablesDirectly;
{ return NO; }

- (id)valueForKey:(NSString *)key;
{
    return [_backingDictionary valueForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key;
{
    [_backingDictionary setValue:value forKey:key];
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
    RKDictionary *attempt = [self copy];
    if (![attempt modifyWithBlock:modBlock])
        return nil;
    return attempt;
}


#pragma mark RKDictionary (RKPrivate)

- (BOOL)modifyWithBlock:(RKModificationBlock)modBlock;
{
    _insideModificationBlockRef++;
    BOOL success = modBlock(self);
    _insideModificationBlockRef--;
    return success;
}

- (RKModificationBlock)modificationBlockToSetValue:(id)newValue forKey:(NSString *)key;
{
    id oldValue = [self valueForKey:key];
    
    // If unchanged, always succeed (and avoid capturing unneeded values)
    if ((oldValue == newValue) || [oldValue isEqual:newValue])
        return [^BOOL(RKDictionary *localDict) { return YES; } copy];
    
    return [^BOOL(RKDictionary *localDict) {
        id curValue = [localDict valueForKey:key];
        if ([curValue isEqual:oldValue]) {
            [localDict setValue:newValue forKey:key];
            return YES;
        }
        return (curValue == newValue) || [curValue isEqual:newValue];
    } copy];
}

- (BOOL)insideModificationBlock;
{
    return _insideModificationBlockRef > 0;
}

@end
