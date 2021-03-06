//
//  PSCCoreDataHelper.m
//  Companion
//
//  Created by Philip Messlehner on 28.02.13.
//  Copyright (c) 2013 Philip Messlehner. All rights reserved.
//

#import "PSCCoreDataStack.h"
#import "PSCLogging.h"


static NSManagedObjectContext *psc_mainContext = nil;
static NSManagedObjectContext *psc_privateContext = nil;


@implementation PSCCoreDataStack

////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
////////////////////////////////////////////////////////////////////////

+ (void)setupWithModelURL:(NSURL *)modelURL
            storeFileName:(NSString *)storeFileName
                     type:(NSString *)storeType
                 storeURL:(NSURL *)storeURL
            configuration:(NSString *)configuration
                  options:(NSDictionary *)options
                  success:(void(^)(void))successBlock
                    error:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(modelURL != nil);
    NSParameterAssert([storeType isEqualToString:NSSQLiteStoreType] || [storeType isEqualToString:NSBinaryStoreType] || [storeType isEqualToString:NSInMemoryStoreType]);
    if (![storeType isEqualToString:NSInMemoryStoreType]) {
        NSParameterAssert((storeFileName != nil) != (storeURL != nil));
    }
    
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(model != nil, @"Failed to initialize model with URL: %@", modelURL);
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSAssert(persistentStoreCoordinator != nil, @"Failed to initialize persistent store coordinator with model: %@", model);
    
    psc_privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    psc_privateContext.persistentStoreCoordinator = persistentStoreCoordinator;
    
    psc_mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    psc_mainContext.parentContext = psc_privateContext;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSURL *url = storeURL;
        
        if (url == nil) {
            url = [[[NSFileManager new] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
            
            if(storeFileName != nil) {
                url = [url URLByAppendingPathComponent:storeFileName];
            }
        }
        
        NSError *error = nil;
        NSPersistentStore *store = [persistentStoreCoordinator addPersistentStoreWithType:storeType
                                                                            configuration:configuration
                                                                                      URL:url
                                                                                  options:options
                                                                                    error:&error];
        
        if (store == nil) {
            PSCCDLog(@"Error adding persistent store to coordinator %@\n%@", [error localizedDescription], [error userInfo]);
            
            if (errorBlock != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorBlock(error);
                });
            }
        } else {
            if (successBlock != nil) {
                dispatch_async(dispatch_get_main_queue(),successBlock);
            }
        }
    });
}

+ (void)setupWithModelURL:(NSURL *)modelURL autoMigratedSQLiteStoreFileName:(NSString *)storeFileName success:(void(^)(void))successBlock error:(void(^)(NSError *error))errorBlock {
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @(YES), NSInferMappingModelAutomaticallyOption: @(YES)};
    
    [self setupWithModelURL:modelURL
              storeFileName:storeFileName
                       type:NSSQLiteStoreType
                   storeURL:nil
              configuration:nil
                    options:options
                    success:successBlock
                      error:errorBlock];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Saving
////////////////////////////////////////////////////////////////////////

+ (void)saveAndPersistContextBlocking:(BOOL)wait {
    [[self mainContext] saveAndPropagateToParentContextBlocking:wait success:nil failure:nil];
}

+ (void)saveAndPersistContext {
    [self saveAndPersistContextBlocking:NO];
}

+ (void)saveAndPersistContextBlocking:(BOOL)wait success:(void(^)(void))sucessBlock error:(void(^)(NSError *error))errorBlock {
    [[self mainContext] saveAndPropagateToParentContextBlocking:wait success:sucessBlock failure:^(NSError *error) {
        PSCCDLog(@"%@ %@", [error localizedDescription], [error userInfo]);
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

+ (void)saveAndPersistContextWithSuccess:(void(^)(void))sucessBlock error:(void(^)(NSError *error))errorBlock {
    [self saveAndPersistContextBlocking:NO success:sucessBlock error:errorBlock];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Parent-Child-Context for Threading
////////////////////////////////////////////////////////////////////////

+ (NSManagedObjectContext *)mainContext {
    return psc_mainContext;
}

+ (NSManagedObjectContext *)newChildContextWithPrivateQueue {
    return [[self mainContext] newChildContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Migration
////////////////////////////////////////////////////////////////////////

+ (void)migratePersistentStoreToURL:(NSURL *)storeURL {
    NSPersistentStoreCoordinator *storeCoordinator = psc_privateContext.persistentStoreCoordinator;
    NSArray *stores = storeCoordinator.persistentStores;
    
    NSAssert([stores count] == 1, @"PSCCoreDataStack doesn't support changing storeURL for multiple Stores");
    
    NSPersistentStore *store = stores[0];
    
    if (![store.URL isEqual:storeURL]) {
        NSError *error;
        [psc_privateContext.persistentStoreCoordinator migratePersistentStore:store toURL:storeURL options:nil withType:store.type error:&error];
        
        NSAssert(error == nil, @"Error migrating persistent store %@ %@\n%@", psc_privateContext, [error localizedDescription], [error userInfo]);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:[store.URL path]]) {
            [fileManager removeItemAtURL:store.URL error:&error];
        }
        
        NSURL *shm = [[store.URL URLByDeletingPathExtension] URLByAppendingPathExtension:@"sqlite-shm"];
        if ([fileManager fileExistsAtPath:[shm path]]) {
            [fileManager removeItemAtURL:shm error:&error];
        }
        
        NSURL *wal = [[store.URL URLByDeletingPathExtension] URLByAppendingPathExtension:@"sqlite-wal"];
        if ([fileManager fileExistsAtPath:[wal path]]) {
            [fileManager removeItemAtURL:wal error:&error];
        }
    }
}

@end
