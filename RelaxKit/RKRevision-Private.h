//
//  RKRevision-Private.h
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-06.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKRevision.h"

@class RKDictionary;


@interface RKRevision ()
- (id)initAsSuccessorOfRev:(RKRevision *)prevRevOrNil;
@property (readonly, nonatomic, retain) RKRevision *previousRev;
@end


@interface RKUnsavedRev : RKRevision
- (void)appendModification:(BOOL (^)(RKDictionary *))modBlock;
- (BOOL)performModificationWithDictionary:(RKDictionary *)dict;
@end


@interface RKSavedRev : RKRevision
- (id)initWithIdentifier:(NSString *)rev asSuccessorOfRev:(RKRevision *)prevRevOrNil;
@property (readonly, nonatomic, copy) NSString *identifier;
@end
