//
//  RKDocument.h
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-06.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKDictionary;
@class RKRevision;
@class RKValueStorage;


@interface RKDocument : NSObject

- (id)initWithIdentifier:(NSString *)identifierOrNil;

@property (readonly, nonatomic, copy) NSString *identifier;
@property (readonly, nonatomic, retain) RKRevision *currentRevision;
@property (readonly, nonatomic, copy) RKDictionary *root;
- (BOOL)modifyWithBlock:(BOOL (^)(RKDictionary *))modBlock;

@end


@protocol RKCollection <NSObject, NSCopying, NSMutableCopying>

#warning IN FLUX
// Setters are for private collection use only
@property (nonatomic, weak) RKDocument *document;

@property (nonatomic, weak) RKValueStorage *valueStorage;

@end
