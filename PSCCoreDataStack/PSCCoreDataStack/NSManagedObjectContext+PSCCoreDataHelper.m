//
//  NSManagedObjectContext+PSCCoreDataHelper.m
//  Companion
//
//  Created by Philip Messlehner on 28.02.13.
//  Copyright (c) 2013 Philip Messlehner. All rights reserved.
//

#import "NSManagedObjectContext+PSCCoreDataHelper.h"


@implementation NSManagedObjectContext (PSCCoreDataHelper)

- (NSManagedObjectContext *)newChildContextWithConcurrencyType:(NSUInteger)concurrencyType {
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
    childContext.parentContext = self;

    return childContext;
}

- (NSManagedObjectContext *)newChildContext {
    return [self newChildContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
}

- (void)saveAndPropagateToParentContextBlocking:(BOOL)wait error:(__autoreleasing NSError **)error {
    if (self.hasChanges) {
        if (self.concurrencyType == NSConfinementConcurrencyType) {
            [self save:error];
        } else {
            [self performBlockAndWait:^{
                [self save:error];
            }];
        }
    }
    
    if (*error != nil || self.parentContext == nil) {
        return;
    }
    
    void (^saveParent)(void) = ^{
        [self.parentContext save:error];
    };
    
    if (self.parentContext.hasChanges) {
        if (self.parentContext.concurrencyType == NSConfinementConcurrencyType) {
            saveParent();
        } else if (wait) {
            [self.parentContext performBlockAndWait:saveParent];
        } else {
            [self.parentContext performBlock:saveParent];
        }
    }
}

- (void)saveAndPropagateToParentContext:(__autoreleasing NSError **)error {
    [self saveAndPropagateToParentContextBlocking:NO error:error];
}

@end
