//
//  RKMutableDictionary.h
//  RelaxKit
//
//  Created by Jonathon Mah on 2011-11-06.
//  Copyright (c) 2011 Jonathon Mah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RelaxKit/RKCollection.h"


@interface RKMutableDictionary : NSMutableDictionary <RKCollection>

// In constrast to NS(Mutable)Dictionary, -objectForKey: and -setObject:forKey: are funneled through -valueForKey: and setValue:forKey:

@end
