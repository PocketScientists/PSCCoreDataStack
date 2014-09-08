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


@interface PSCCoreDataStack : NSObject

+ (void)setupWithModelURL:(NSURL *)modelURL
            storeFileName:(NSString *)storeFileName
                     type:(NSString *)storeType
            configuration:(NSString *)configuration
                  options:(NSDictionary *)options
                  success:(void(^)())successBlock
                    error:(void(^)(NSError *error))errorBlock;

+ (void)setupWithModelURL:(NSURL *)modelURL
autoMigratedSQLiteStoreFileName:(NSString *)storeFileName
                  success:(void(^)())successBlock error:(void(^)(NSError *error))errorBlock;

+ (void)saveAndPersistContextBlocking:(BOOL)wait;
+ (void)saveAndPersistContext;

+ (void)saveAndPersistContextBlocking:(BOOL)wait success:(void(^)())sucessBlock error:(void(^)(NSError *error))errorBlock;
+ (void)saveAndPersistContextWithSuccess:(void(^)())sucessBlock error:(void(^)(NSError *error))errorBlock;

+ (NSManagedObjectContext *)mainContext;
+ (NSManagedObjectContext *)newChildContextWithPrivateQueue;

+ (BOOL)clearSQLiteDatabase:(NSManagedObjectContext *)context;

@end
