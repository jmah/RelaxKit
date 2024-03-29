//
//  RKDocument.h
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-06.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RKCollection.h"

@class RKMutableDictionary;
@class RKRevision;


@interface RKDocument : NSObject

- (id)initWithIdentifier:(NSString *)identifierOrNil;

@property (readonly, nonatomic, copy) NSString *identifier;
@property (readonly, nonatomic, retain) RKRevision *currentRevision;
@property (readonly, nonatomic, copy) RKMutableDictionary *root;

- (BOOL)modifyWithBlock:(RKModificationBlock)rootRelativeModBlock;

@end
