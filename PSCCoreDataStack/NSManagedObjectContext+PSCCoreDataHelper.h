//
//  NSManagedObjectContext+PSCCoreDataHelper.h
//  Companion
//
//  Created by Philip Messlehner on 28.02.13.
//  Copyright (c) 2013 Philip Messlehner. All rights reserved.
//
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSManagedObjectContext (PSCCoreDataHelper)

- (NSManagedObjectContext *)newChildContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;

- (void)saveAndPropagateToParentContextBlocking:(BOOL)wait error:(NSError * _Nullable * _Nullable)error __attribute__((deprecated("use 'saveAndPropagateToParentContextBlocking:success:failure' instead")));
- (void)saveAndPropagateToParentContext:(NSError * _Nullable * _Nullable)error __attribute__((deprecated("use 'saveAndPropagateToParentContexWithSuccess:failure' instead")));

- (void)saveAndPropagateToParentContextBlocking:(BOOL)wait success:(nullable void(^)(void))sucess failure:(nullable void(^)(NSError *error))failure;
- (void)saveAndPropagateToParentContextWithSuccess:(nullable void(^)(void))sucess failure:(nullable void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
