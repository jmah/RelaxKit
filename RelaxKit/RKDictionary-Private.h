//
//  RKDictionary-Private.h
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-07.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKDictionary.h"


@interface RKDictionary (RKPrivate)
// If this returns false, the contents of the dictionary are undefined. (Make a copy before calling this method.)
- (BOOL)modifyWithBlock:(RKModificationBlock)modBlock;
- (RKModificationBlock)modificationBlockToSetValue:(id)newValue forKey:(NSString *)key;
- (BOOL)insideModificationBlock;
@end
