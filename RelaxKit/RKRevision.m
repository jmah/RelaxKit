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

@synthesize previousRev = _previousRev;

#pragma mark <NSObject>

- (id)init;
{ NSAssert(NO, @"Bad initializer, use -initAsSuccessorOfRev:"); return nil; }

#pragma mark <NSCopying>

- (id)copyWithZone:(NSZone *)zone;
{ return self; }


#pragma mark RKRevision

- (id)initAsSuccessorOfRev:(RKRevision *)prevRevOrNil;
{
    if (!(self = [super init]))
        return nil;
    _previousRev = prevRevOrNil; // If nil, this is a root revision
    return self;
}

- (NSComparisonResult)compare:(RKRevision *)otherRevision;
{
    NSParameterAssert([otherRevision isKindOfClass:[RKRevision class]]);
    if (otherRevision == self)
        return NSOrderedSame;
    if (otherRevision == self.previousRev)
        return NSOrderedDescending;
    if (otherRevision.previousRev == self)
        return NSOrderedAscending;
    
    NSMutableSet *myAncestors = [NSMutableSet set];
    RKRevision *ancestor = self;
    while ((ancestor = ancestor.previousRev))
        [myAncestors addObject:ancestor];
    
    if ([myAncestors containsObject:otherRevision])
        return NSOrderedDescending;
    
    RKRevision *otherAncestor = otherRevision;
    while ((otherAncestor = otherAncestor.previousRev))
        if (otherAncestor == self)
            return NSOrderedAscending;
    
    // On divergent paths; no natural ordering. Should we throw?
    return NSOrderedSame;
}

@end



@implementation RKUnsavedRev

#pragma mark RKRevision

- (BOOL)isSaved;
{ return NO; }


#pragma mark RKUnsavedRev

@end


@implementation RKSavedRev

@synthesize identifier = _identifier;

#pragma mark <NSObject>

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

- (id)initWithIdentifier:(NSString *)rev asSuccessorOfRev:(RKRevision *)prevRevOrNil;
{
    if (!(self = [super initAsSuccessorOfRev:prevRevOrNil]))
        return nil;
    if (!rev || [rev length] == 0)
        return nil;
    _identifier = [rev copy];
    return self;
}

@end
