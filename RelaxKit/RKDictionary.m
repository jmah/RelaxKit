//
//  RKDictionary.m
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-06.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKDictionary.h"
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


#pragma mark API

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

- (BOOL)modifyWithBlock:(BOOL (^)(RKDictionary *))modBlock;
{
    _insideModificationBlockRef++;
    BOOL success = modBlock(self);
    _insideModificationBlockRef--;
    return success;
}

- (BOOL)insideModificationBlock;
{
    return _insideModificationBlockRef > 0;
}

@end
