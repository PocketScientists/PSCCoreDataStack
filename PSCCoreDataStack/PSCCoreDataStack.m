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
            configuration:(NSString *)configuration
                  options:(NSDictionary *)options
                  success:(void(^)())successBlock
                    error:(void(^)(NSError *error))errorBlock {

    NSParameterAssert(modelURL != nil);
    NSParameterAssert([storeType isEqualToString:NSSQLiteStoreType] || [storeType isEqualToString:NSBinaryStoreType] || [storeType isEqualToString:NSInMemoryStoreType]);
    if (![storeType isEqualToString:NSInMemoryStoreType]) {
        NSParameterAssert(storeFileName != nil);
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
        NSURL *storeURL = nil;

        if (storeFileName != nil) {
            storeURL = [[[NSFileManager new] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
            storeURL = [storeURL URLByAppendingPathComponent:storeFileName];
        }

        NSError *error = nil;
        NSPersistentStore *store = [persistentStoreCoordinator addPersistentStoreWithType:storeType
                                                                            configuration:configuration
                                                                                      URL:storeURL
                                                                                  options:options
                                                                                    error:&error];
        if(error != nil){
            if (errorBlock != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorBlock(error);
                });
            }
        }        

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

+ (void)setupWithModelURL:(NSURL *)modelURL autoMigratedSQLiteStoreFileName:(NSString *)storeFileName success:(void(^)())successBlock error:(void(^)(NSError *error))errorBlock {
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @(YES), NSInferMappingModelAutomaticallyOption: @(YES)};

    [self setupWithModelURL:modelURL
              storeFileName:storeFileName
                       type:NSSQLiteStoreType
              configuration:nil
                    options:options
                    success:successBlock
                      error:errorBlock];
}

+ (BOOL)clearSQLiteDatabase:(NSManagedObjectContext *)context {
    // find top most context with store coordinator
    NSManagedObjectContext *topContext = context;
    while (topContext.parentContext != nil) {
        topContext = topContext.parentContext;
    }
    
    NSError * error;
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [topContext persistentStoreCoordinator];
    NSPersistentStore *store = [[persistentStoreCoordinator persistentStores] lastObject];

    // retrieve the store URL, configuration, and options
    NSURL * storeURL = [persistentStoreCoordinator URLForPersistentStore:store];
    NSDictionary *options = [store options];
    NSString *configurationName = [store configurationName];

    // lock the current context
    [context lock];
    // reset all contexts
    NSManagedObjectContext *curContext = context;
    [curContext reset];
    while (curContext.parentContext != nil) {
        curContext = curContext.parentContext;
        [curContext reset];
    }

    // lock the current context
    [topContext lock];
    //delete the store from the current managedObjectContext
    BOOL result = [persistentStoreCoordinator removePersistentStore:store error:&error];
    if (result) {
        // remove the file containing the data
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        //recreate the store like in the  appDelegate method
        [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:configurationName URL:storeURL options:options error:&error]; //recreates the persistent store
    }
    [topContext unlock];
    [context unlock];
    
    return result;
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

+ (void)saveAndPersistContextBlocking:(BOOL)wait success:(void(^)())sucessBlock error:(void(^)(NSError *error))errorBlock {
    [[self mainContext] saveAndPropagateToParentContextBlocking:wait success:sucessBlock failure:^(NSError *error) {
        PSCCDLog(@"%@ %@", [error localizedDescription], [error userInfo]);
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

+ (void)saveAndPersistContextWithSuccess:(void(^)())sucessBlock error:(void(^)(NSError *error))errorBlock {
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

@end
