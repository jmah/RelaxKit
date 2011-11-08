//
//  RKRevision.m
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-06.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKRevision-Private.h"


@implementation RKRevision

@dynamic saved; // For subclasses to implement

#pragma mark <NSCopying>

- (id)copyWithZone:(NSZone *)zone;
{ return self; }


#pragma mark RKRevision

- (NSComparisonResult)compare:(RKRevision *)otherRevision;
{
    NSParameterAssert([otherRevision isKindOfClass:[RKRevision class]]);
    // <# TODO #> stubbed
    return NSOrderedAscending;
}

@end



@implementation RKUnsavedRev

@synthesize previousRev = _previousRev;

#pragma mark NSObject

- (id)init;
{ NSAssert(NO, @"Bad initializer, use -initAsSuccessorOfRev:"); return nil; }


#pragma mark RKRevision

- (BOOL)isSaved;
{ return NO; }


#pragma mark RKUnsavedRev

- (id)initAsSuccessorOfRev:(RKRevision *)prevRevOrNil;
{
    if (!(self = [super init]))
        return nil;
    _previousRev = prevRevOrNil; // If nil, this is a root revision
    return self;
}

@end


@implementation RKSavedRev

@synthesize identifier = _identifier;

#pragma mark NSObject

- (id)init;
{ NSAssert(NO, @"Bad initializer, use -initWithIdentifier:"); return nil; }

- (NSUInteger)hash;
{ return _identifier.hash; }

- (BOOL)isEqual:(id)object;
{
    if (![object isKindOfClass:[RKSavedRev class]])
        return NO;
    RKSavedRev *otherSavedRev = object;
    return [_identifier isEqual:otherSavedRev.identifier];
}


#pragma mark RKRevision

- (BOOL)isSaved;
{ return YES; }


#pragma mark RKSavedRev

- (id)initWithIdentifier:(NSString *)rev;
{
    if (!(self = [super init]))
        return nil;
    if (!rev || [rev length] == 0)
        return nil;
    _identifier = [rev copy];
    return self;
}

@end
