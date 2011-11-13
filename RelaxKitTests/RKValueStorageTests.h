//
//  RKValueStorageTests.h
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-12.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <RelaxKit/RelaxKit.h>


@interface RKValueStorageTests : SenTestCase

- (void)checkPolicy:(RKAssociationPolicy)policy withValue:(id)value expectCopy:(BOOL)expectCopy;

- (void)testCopyAndRetainStorage;
- (void)testCollectionStorage;

@end
