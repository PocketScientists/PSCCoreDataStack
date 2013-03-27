//
//  PSCPersistenceOperation.h
//  PSCCoreDataStack
//
//  Created by Matthias Tretter on 26.03.13.
//  Copyright (c) 2013 PocketScience. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef BOOL(^psc_persistence_block)(NSManagedObjectContext *localContext);

// the queue used in persistDataInBackgroundWithParentContext:block:completion:
dispatch_queue_t psc_persistence_queue(void);


@interface PSCPersistenceOperation : NSOperation

/**
 Uses GCD to perform a save operation on a background queue and not NSOperation.
 The completion block is called on the main queue.
 */
+ (void)persistDataInBackgroundWithParentContext:(NSManagedObjectContext *)parentContext
                                           block:(psc_persistence_block)block
                                      completion:(dispatch_block_t)completion;

/**
 Creates an NSOperation subclass that can be used to persist data to a local context
 */
+ (instancetype)operationWithParentContext:(NSManagedObjectContext *)parentContext
                                     block:(psc_persistence_block)block
                                completion:(dispatch_block_t)completion;

/** Subclasses can override to perform a persistence action */
- (BOOL)persistWithContext:(NSManagedObjectContext *)localContext;

@end
