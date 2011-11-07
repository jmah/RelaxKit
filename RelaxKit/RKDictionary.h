//
//  RKDictionary.h
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-06.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKDictionary;
@class RKDocument;

typedef BOOL (^RKModificationBlock)(RKDictionary *localDict);


@interface RKDictionary : NSObject <NSCopying>

- (id)init;
- (id)initWithDictionary:(NSDictionary *)nsdictOrNil; // Designated initializer

@property (readonly, nonatomic, weak) RKDocument *document;

- (NSUInteger)count;
- (NSDictionary *)dictionaryRepresentation;

- (RKDictionary *)dictionaryByModifyingWithBlock:(RKModificationBlock)modBlock;

// To be clear, the main interface to this class is:
- (id)valueForKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key;

@end
