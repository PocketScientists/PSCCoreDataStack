//
//  PSCCoreDataHelper.h
//  Companion
//
//  Created by Philip Messlehner on 28.02.13.
//  Copyright (c) 2013 Philip Messlehner. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "NSManagedObject+PSCCoreDataHelper.h"
#import "NSManagedObjectContext+PSCCoreDataHelper.h"
#import "PSCContextWatcher.h"
#import "PSCFetchedResultsControllerUpdater.h"
#import "PSCPersistenceOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSCCoreDataStack : NSObject

+ (void)setupWithModelURL:(NSURL *)modelURL
            storeFileName:(nullable NSString *)storeFileName
                     type:(NSString *)storeType
                 storeURL:(nullable NSURL *)storeURL
            configuration:(nullable NSString *)configuration
                  options:(nullable NSDictionary *)options
                  success:(nullable void(^)(void))successBlock
                    error:(nullable void(^)(NSError *error))errorBlock;

+ (void)setupWithModelURL:(NSURL *)modelURL
autoMigratedSQLiteStoreFileName:(NSString *)storeFileName
                  success:(nullable void(^)(void))successBlock error:(nullable void(^)(NSError *error))errorBlock;

+ (void)saveAndPersistContextBlocking:(BOOL)wait;
+ (void)saveAndPersistContext;

+ (void)saveAndPersistContextBlocking:(BOOL)wait success:(nullable void(^)(void))sucessBlock error:(nullable void(^)(NSError *error))errorBlock;
+ (void)saveAndPersistContextWithSuccess:(nullable void(^)(void))sucessBlock error:(nullable void(^)(NSError *error))errorBlock;

+ (NSManagedObjectContext *)mainContext;
+ (NSManagedObjectContext *)newChildContextWithPrivateQueue;

+ (void)migratePersistentStoreToURL:(NSURL *)storeURL;

@end

NS_ASSUME_NONNULL_END
