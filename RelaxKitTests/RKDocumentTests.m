//
//  RKDocumentTests.m
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-07.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKDocumentTests.h"
#import <RelaxKit/RelaxKit.h>
#import "RKDocument-Private.h"


@implementation RKDocumentTests

#pragma mark - Tests

- (void)testIdentifierGeneration;
{
    NSMutableSet *identifiers = [NSMutableSet set];
    NSUInteger generateCount = 10000;
    while (--generateCount) {
        RKDocument *doc = [[RKDocument alloc] initWithIdentifier:nil];
        STAssertNotNil(doc.identifier, @"Document should get auto-generated identifier");
        STAssertFalse([identifiers containsObject:doc.identifier], @"Generated identifiers should be unique");
        [identifiers addObject:doc.identifier];
    }
}

@end
