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


static NSString *const firstNameKey = @"firstName";

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
    
    __block BOOL kvoFired = NO, docWasInModBlock = NO;
    _kvoHandlerBlock = ^BOOL(NSString *keyPath, id object, NSDictionary *change, void *context) {
        if (context == &kvoFired) {
            kvoFired = YES;
            docWasInModBlock = [doc insideModificationBlock];
            return YES;
        }
        return NO;
    };
    
    [doc.root addObserver:self forKeyPath:firstNameKey options:0 context:&kvoFired];
    [doc.root setValue:@"Freddie" forKey:firstNameKey];
    [doc.root removeObserver:self forKeyPath:firstNameKey context:&kvoFired];
    _kvoHandlerBlock = nil;
    
    STAssertTrue(kvoFired, NULL);
    STAssertTrue(docWasInModBlock, @"Modification to dictionary should occur within a modification block");
    
    RKRevision *secondRev = doc.currentRevision;
    STAssertFalse(firstRev == secondRev, @"Altering dictionary should give new placeholder revision");
    STAssertFalse([firstRev isEqual:secondRev], @"Altering dictionary should give new placeholder revision");
    
    STAssertTrue([firstRev compare:secondRev] == NSOrderedAscending, @"New revision should compare later than first");
    STAssertTrue([secondRev compare:firstRev] == NSOrderedDescending, @"New revision should compare later than first");
}

@end
