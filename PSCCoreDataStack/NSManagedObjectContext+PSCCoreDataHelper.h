//
//  NSManagedObjectContext+PSCCoreDataHelper.h
//  Companion
//
//  Created by Philip Messlehner on 28.02.13.
//  Copyright (c) 2013 Philip Messlehner. All rights reserved.
//
#import <CoreData/CoreData.h>


@interface NSManagedObjectContext (PSCCoreDataHelper)

- (NSManagedObjectContext *)newChildContextWithConcurrencyType:(NSUInteger)concurrencyType;

- (void)saveAndPropagateToParentContextBlocking:(BOOL)wait error:(NSError **)error __attribute__((deprecated("use 'saveAndPropagateToParentContextBlocking:success:failure' instead")));
- (void)saveAndPropagateToParentContext:(NSError **)error __attribute__((deprecated("use 'saveAndPropagateToParentContexWithSuccess:failure' instead")));

- (void)saveAndPropagateToParentContextBlocking:(BOOL)wait success:(void(^)(void))sucess failure:(void(^)(NSError *error))failure;
- (void)saveAndPropagateToParentContextWithSuccess:(void(^)(void))sucess failure:(void(^)(NSError *error))failure;

@end
