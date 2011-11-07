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


@interface RKDocument : NSObject

@property (readonly, nonatomic) RKRevision *currentRevision;
@property (readonly, nonatomic) RKDictionary *root;
- (BOOL)modifyWithBlock:(BOOL (^)(RKDocument *))modBlock;

@end
