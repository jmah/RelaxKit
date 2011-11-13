//
//  RKCollection.h
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-13.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKDocument;
@class RKRevision;

enum RKAssociationType {
    RKAssociationRetain = 1,
    RKAssociationCopy = 3,
};

typedef BOOL (^RKModificationBlock)(id /*<RKCollection>*/ localCollection);


@protocol RKCollection <NSObject, NSCopying, NSMutableCopying>

@property (readonly, nonatomic, weak) RKDocument *document;
@property (readonly, nonatomic, copy) NSString *keyInParent;
@property (readonly, nonatomic, weak) id <RKCollection> parentCollection;
- (id)mutableCopyWithKey:(NSString *)key inParent:(id <RKCollection>)parentCollection ofDocument:(RKDocument *)document;

- (NSString *)keyPathFromRootCollection;

- (BOOL)modifyWithBlock:(RKModificationBlock)modBlock;
- (BOOL)insideModificationBlock;

// Called by -modifyWithBlock:, can be nested
- (void)beginModifications;
- (void)commitModificationsKeepingChanges:(BOOL)keepChanges;

// NSObject (NSKeyValueCoding) Would add it to the protocol list if it were one
- (id)valueForKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key;
- (void)setValue:(id)value forKeyPath:(NSString *)keyPath;
- (void)setPrimitiveValue:(id)preparedValue forKey:(NSString *)key; // No change notifications, no further processing

- (enum RKAssociationType)associationTypeForKey:(NSString *)key;
- (id)prepareSetValue:(id)value forKey:(NSString *)key; // Returns a copy of the value depending on the associationType; copies and configures sub-collections.

@end
