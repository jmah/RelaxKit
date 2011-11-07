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
    RKDictionary *copy = [[[self class] alloc] init];
    copy->_backingDictionary = [NSMutableDictionary dictionaryWithDictionary:_backingDictionary];
    return copy;
}


#pragma mark API

- (id)init; // Designated initializer
{
    if (!(self = [super init]))
        return nil;
    _backingDictionary = [[NSMutableDictionary alloc] init];
    return self;
}

- (NSUInteger)count;
{
    return [_backingDictionary count];
}

@end
