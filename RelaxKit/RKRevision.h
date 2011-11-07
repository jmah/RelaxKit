//
//  RKRevision.h
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-06.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RKRevision : NSObject <NSCopying>

@property (readonly, getter=isSaved) BOOL saved;

- (NSUInteger)hash;
- (BOOL)isEqual:(id)object;
- (NSComparisonResult)compare:(RKRevision *)otherRevision;

@end
