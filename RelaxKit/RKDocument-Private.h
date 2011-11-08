//
//  RKDocument-Private.h
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-07.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKDocument.h"


@interface RKDocument ()

@property (readwrite, nonatomic, retain) RKRevision *currentRevision;
@property (readwrite, nonatomic, copy) RKDictionary *root;

- (BOOL)insideModificationBlock;

#pragma mark Identifier Generation
+ (uint16_t)randomUint16Min:(uint16_t)minVal max:(uint16_t)maxVal; // inclusive
+ (uint32_t)randomUint32;
+ (NSString *)generateIdentifier;

@end
