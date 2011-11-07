//
//  RKDictionary-Private.h
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-07.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKDictionary.h"


@interface RKDictionary (RKPrivate)
- (RKModificationBlock)modificationBlockToSetValue:(id)newValue forKey:(NSString *)key;
- (BOOL)insideModificationBlock;
@end
