//
//  RKDocumentTests.m
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-07.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import "RKDocumentTests.h"
#import <RelaxKit/RelaxKit.h>


static NSString *const firstNameKey = @"firstName";
static NSString *const lastNameKey = @"lastName";

typedef BOOL (^KVOBlock)(NSString *keyPath, id object, NSDictionary *change, void *context);


@implementation RKDocumentTests {
    KVOBlock _kvoHandlerBlock;
}

#pragma mark NSObject (NSKeyValueObserving)

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    if (!_kvoHandlerBlock || !_kvoHandlerBlock(keyPath, object, change, context))
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


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

- (void)testKVCChangeCapture;
{
    RKDocument *doc = [[RKDocument alloc] initWithIdentifier:nil];
    STAssertNotNil(doc.root, NULL);
    STAssertTrue(doc.root.document == doc, @"Root dictionary should have reference to document");
    
    RKRevision *firstRev = doc.currentRevision;
    STAssertNotNil(firstRev, @"Empty document should have unsaved placeholder revision");
    STAssertFalse(firstRev.saved, @"Empty document should have unsaved placeholder revision");
    
    __block BOOL firstNameKVOFired = NO, rootWasInModBlock = NO;
    __block NSUInteger revisionKVOFireCount = 0;
    _kvoHandlerBlock = ^BOOL(NSString *keyPath, id object, NSDictionary *change, void *context) {
        if (context == &firstNameKVOFired) {
            firstNameKVOFired = YES;
            rootWasInModBlock = [doc.root insideModificationBlock];
            return YES;
        } else if (context == &revisionKVOFireCount) {
            revisionKVOFireCount++;
            return YES;
        }
        return NO;
    };
    
    [doc addObserver:self forKeyPath:@"currentRevision" options:0 context:&revisionKVOFireCount];
    [doc.root addObserver:self forKeyPath:firstNameKey options:0 context:&firstNameKVOFired];
    [doc.root setValue:@"Freddie" forKey:firstNameKey];
    [doc.root removeObserver:self forKeyPath:firstNameKey context:&firstNameKVOFired];
    [doc removeObserver:self forKeyPath:@"currentRevision" context:&revisionKVOFireCount];
    _kvoHandlerBlock = nil;
    
    STAssertTrue(firstNameKVOFired, NULL);
    STAssertTrue(rootWasInModBlock, @"Modification to dictionary should occur within a modification block");
    STAssertEquals(revisionKVOFireCount, 1ul, @"Revision change should have fired exactly once");
    
    RKRevision *secondRev = doc.currentRevision;
    STAssertFalse(firstRev == secondRev, @"Altering dictionary should give new placeholder revision");
    STAssertFalse([firstRev isEqual:secondRev], @"Altering dictionary should give new placeholder revision");
    
    STAssertTrue([firstRev compare:secondRev] == NSOrderedAscending, @"New revision should compare later than first");
    STAssertTrue([secondRev compare:firstRev] == NSOrderedDescending, @"New revision should compare later than first");
}

- (void)testGeneratedModificationBlocks;
{
    RKDocument *doc = [[RKDocument alloc] initWithIdentifier:nil];
    [doc.root setValue:@"Freddie" forKey:firstNameKey];
    [doc.root setValue:@"Mercury" forKey:lastNameKey];
    
    RKModificationBlock setFreddieToFarrokh = [doc modificationBlockToSetValue:@"Farrokh" forRootKeyPath:firstNameKey];
    STAssertEqualObjects([doc.root valueForKey:firstNameKey], @"Freddie", @"Generating modification block shouldn't have side effects");
    
    BOOL modResult = [doc modifyWithBlock:setFreddieToFarrokh];
    STAssertTrue(modResult, @"Modification should succeed with old value");
    STAssertEqualObjects([doc.root valueForKey:firstNameKey], @"Farrokh", @"Modification block should alter value");
    
    // Keep firstName as @"Farrokh"
    modResult = [doc modifyWithBlock:setFreddieToFarrokh];
    STAssertTrue(modResult, @"Modification should succeed if already at new value");
    STAssertEqualObjects([doc.root valueForKey:firstNameKey], @"Farrokh", @"Modification block should alter value");
    
    [doc.root setValue:@"completelyDifferent" forKey:firstNameKey];
    modResult = [doc modifyWithBlock:setFreddieToFarrokh];
    STAssertFalse(modResult, @"Modification should fail if value is neither old nor new");
    STAssertEqualObjects([doc.root valueForKey:firstNameKey], @"completelyDifferent", @"Failed modification block should not change collection");
    
    [doc.root setValue:nil forKey:firstNameKey];
    modResult = [doc.root modifyWithBlock:setFreddieToFarrokh];
    STAssertFalse(modResult, @"Modification should fail if value is neither old nor new");
    STAssertNil([doc.root valueForKey:firstNameKey], @"Failed modification block should not change collection");
    
    [doc.root setValue:@"Freddie" forKey:firstNameKey];
    RKModificationBlock noRealChange = [doc modificationBlockToSetValue:@"Freddie" forRootKeyPath:firstNameKey];
    [doc.root setValue:@"completelyDifferent" forKey:firstNameKey];
    modResult = [doc.root modifyWithBlock:noRealChange];
    STAssertTrue(modResult, @"Any modification should succeed if setter was identity");
    STAssertEqualObjects([doc.root valueForKey:firstNameKey], @"completelyDifferent", @"Any modification should succeed if setter was identity");
    
    [doc.root setValue:nil forKey:firstNameKey];
    modResult = [doc.root modifyWithBlock:noRealChange];
    STAssertTrue(modResult, @"Any modification should succeed if setter was identity");
    STAssertTrue([doc.root count] == 1, @"Any modification should succeed if setter was identity");
}

@end
