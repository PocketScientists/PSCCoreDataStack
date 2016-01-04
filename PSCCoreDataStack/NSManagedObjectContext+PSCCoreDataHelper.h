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

- (BOOL)saveAndPropagateToParentContextBlocking:(BOOL)wait error:(NSError **)error __attribute__((deprecated("use 'saveAndPropagateToParentContextBlocking:success:failure' instead")));
- (BOOL)saveAndPropagateToParentContext:(NSError **)error __attribute__((deprecated("use 'saveAndPropagateToParentContexWithSuccess:failure' instead")));

- (BOOL)saveAndPropagateToParentContextBlocking:(BOOL)wait success:(void(^)())sucess failure:(void(^)(NSError *error))failure;
- (BOOL)saveAndPropagateToParentContextWithSuccess:(void(^)())sucess failure:(void(^)(NSError *error))failure;

@end
