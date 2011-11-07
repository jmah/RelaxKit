//
//  RKDictionary.h
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-06.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKDocument;


@interface RKDictionary : NSObject <NSCopying>

@property (readonly, nonatomic, weak) RKDocument *document;
- (BOOL)modifyWithBlock:(BOOL (^)(RKDictionary *))modDictBlock;

// To be clear, the main interface to this class is:
- (id)valueForKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key;

@end
