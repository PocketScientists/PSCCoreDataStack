//
//  NSManagedObjectContext+PSCCoreDataHelper.m
//  Companion
//
//  Created by Philip Messlehner on 28.02.13.
//  Copyright (c) 2013 Philip Messlehner. All rights reserved.
//

#import "NSManagedObjectContext+PSCCoreDataHelper.h"


@implementation NSManagedObjectContext (PSCCoreDataHelper)

- (NSManagedObjectContext *)newChildContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType {
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
    childContext.parentContext = self;

    return childContext;
}

- (void)saveAndPropagateToParentContextBlocking:(BOOL)wait error:(__autoreleasing NSError **)error {
    dispatch_block_t parentCheck = ^{
        if (wait) {
            [self.parentContext performBlockAndWait:^{
                if (self.parentContext.hasChanges) {
                    [self.parentContext save:error];
                }
            }];
        } else {
            [self.parentContext performBlock:^{
                if (self.parentContext.hasChanges) {
                    [self.parentContext save:error];
                }
            }];
        }
    };

    if (wait) {
        [self performBlockAndWait:^{
            if (self.hasChanges) {
                if ([self save:error]) {
                    parentCheck();
                }
            }
            else {
                parentCheck();
            }
        }];
    } else {
        [self performBlock:^{
            if (self.hasChanges) {
                if ([self save:error]) {
                    parentCheck();
                }
            }
            else {
                parentCheck();
            }
        }];
    }
}

- (void)saveAndPropagateToParentContext:(__autoreleasing NSError **)error {
    [self saveAndPropagateToParentContextBlocking:NO error:error];
}

- (void)saveAndPropagateToParentContextBlocking:(BOOL)wait success:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock {
    dispatch_block_t parentCheck = ^{
        dispatch_block_t saveParent = ^{
            if (self.parentContext.hasChanges) {
                NSError *error = nil;
                if ([self.parentContext save:&error]) {
                    if (successBlock) {
                        successBlock();
                    }
                } else if (failureBlock) {
                    failureBlock(error);
                }
            } else if (successBlock) {
                successBlock();
            }
        };

        if (wait) {
            [self.parentContext performBlockAndWait: saveParent];
        } else {
            [self.parentContext performBlock: saveParent];
        }
    };
    
    if (self.hasChanges) {
        dispatch_block_t saveChild = ^{
            NSError *error = nil;
            if ([self save:&error]) {
                parentCheck();
            }
            else {
                if (failureBlock) {
                    failureBlock(error);
                }
            }
        };

        if (wait) {
            [self performBlockAndWait:saveChild];
        } else {
            [self performBlock:saveChild];
        }
    }
    else {
        parentCheck();
    }
}

- (void)saveAndPropagateToParentContextWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock {
    [self saveAndPropagateToParentContextBlocking:NO success:successBlock failure:failureBlock];
}

@end
