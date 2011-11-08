//
//  RKDocument.m
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-06.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKDocument-Private.h"
#import "RKDictionary-Private.h"
#import "RKRevision-Private.h"


@implementation RKDocument {
    NSUInteger _insideModificationBlockRef;
}

@synthesize identifier = _identifier;
@synthesize currentRevision = _currentRevision;
@synthesize root = _root;


#pragma mark RKDocument

- (id)initWithIdentifier:(NSString *)identifierOrNil;
{
    if (!(self = [super init]))
        return nil;
    if (identifierOrNil && [identifierOrNil length] == 0)
        return nil;
    
    _identifier = [identifierOrNil copy] ? : [[self class] generateIdentifier];
    self.root = [[RKDictionary alloc] init];
    self.currentRevision = [[RKUnsavedRev alloc] initAsSuccessorOfRev:nil];
    return self;
}

- (BOOL)modifyWithBlock:(RKModificationBlock)modBlock;
{
    _insideModificationBlockRef++;
    // TODO: Save old values in case modification fails
    // TODO: Defer KVO until atomic everything, or all reverted
    BOOL success = modBlock(self.root);
    _insideModificationBlockRef--;
    return success;
}


#pragma mark RKDocument: Private

- (void)setRoot:(RKDictionary *)root;
{
    NSParameterAssert(root);
    _root.document = nil;
    _root = [root copy];
    _root.document = self;
}

- (BOOL)insideModificationBlock;
{
    return _insideModificationBlockRef > 0;
}


#pragma mark RKDocument: Private: Identifier Generation

+ (uint16_t)randomUint16Min:(uint16_t)minVal max:(uint16_t)maxVal;
{
    NSParameterAssert(minVal < maxVal);
    @synchronized ([RKDocument class]) {
        static const NSUInteger bufferSize = 512;
        static NSData *randomBuffer;
        static NSUInteger bufferOffset;
        
        const NSUInteger requestedBytes = sizeof(uint16_t);
        if (!randomBuffer || (bufferOffset + requestedBytes) > bufferSize) {
            bufferOffset = 0;
            randomBuffer = [[NSFileHandle fileHandleForReadingAtPath: @"/dev/random"] readDataOfLength:bufferSize];
            NSAssert(randomBuffer, @"Unable to read entropy source /dev/random");
        }
        
        uint16_t val;
        [randomBuffer getBytes:&val range:NSMakeRange(bufferOffset, requestedBytes)];
        bufferOffset += requestedBytes;
        
        if (minVal == 0 && maxVal == 0xffff) {
            return val;
        } else {
            uint16_t rangeCount = maxVal - minVal + 1;
            unsigned maxForUniform = ((1U << (requestedBytes * 8 - 1)) / rangeCount) * rangeCount;
            
            if (val < maxForUniform)
                return (val % rangeCount) + minVal;
            else
                // Try again
                return [self randomUint16Min:minVal max:maxVal];
        }
    }
}

+ (uint32_t)randomUint32;
{
    uint32_t num = [self randomUint16Min:0 max:0xffff];
    num = (num << 16) | [self randomUint16Min:0 max:0xffff];
    return num;
}

+ (NSString *)generateIdentifier;
{
    // Uses the CouchDB "sequential" algorithm from src/couchdb/couch_uuids.erl
    @synchronized ([RKDocument class]) {
        static NSString *prefix;
        static uint32_t seq;
        
        if (!prefix) {
            // A uint32_t is 4 bytes = 8 hex chars. Want 13 chars here.
            prefix = [NSString stringWithFormat:@"%05x%08x", [self randomUint32], [self randomUint32]];
            seq = 0;
        }
        
        uint16_t increment = [self randomUint16Min:1 max:0x0ffe];
        seq += increment;
        
        NSString *identifier = [prefix stringByAppendingFormat:@"%06x", seq];
        
        if (seq > 0x00fff000)
            prefix = nil;
        
        return identifier;
    }
}

@end
