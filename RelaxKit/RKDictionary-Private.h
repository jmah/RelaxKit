//
//  RKDictionary-Private.h
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-07.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKDictionary.h"


@interface RKDictionary ()

@property (readwrite, nonatomic, weak) RKDocument *document;

@property (nonatomic, weak) RKDictionary *parent;
@property (nonatomic, copy) NSString *keyInParent;
- (RKModificationBlock)modificationBlockToSetValue:(id)newValue forKeyPath:(NSString *)keyPath;
- (BOOL)insideModificationBlock;

@end
