//
//  PSCCoreDataHelper.m
//  Companion
//
//  Created by Philip Messlehner on 28.02.13.
//  Copyright (c) 2013 Philip Messlehner. All rights reserved.
//

#import "PSCCoreDataStack.h"


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
    NSAssert(model != nil, @"Failed to initialize model");

    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSAssert(persistentStoreCoordinator != nil, @"Failed to initialize persistent store coordinator");

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

        if (store == nil) {
            NSLog(@"Error adding persistent store to coordinator %@\n%@", [error localizedDescription], [error userInfo]);

            if (errorBlock != nil) {
                errorBlock(error);
            }
        } else {
            if (successBlock != nil) {
                successBlock();
            }
        }
    });
}

+ (void)setupWithModelURL:(NSURL *)modelURL autoMigratedSQLiteStoreFileName:(NSString *)storeFileName success:(void(^)())successBlock error:(void(^)(NSError *error))errorBlock {
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @(YES), NSInferMappingModelAutomaticallyOption: @(YES)};

    [[self class] setupWithModelURL:modelURL
                      storeFileName:storeFileName
                               type:NSSQLiteStoreType
                      configuration:nil
                            options:options
                            success:successBlock
                              error:errorBlock];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Saving
////////////////////////////////////////////////////////////////////////

+ (void)saveAndPersistContextBlocking:(BOOL)wait {
    NSError *error = nil;

    [[self mainContext] saveAndPropagateToParentContextBlocking:wait error:&error];
    NSAssert(error == nil, @"Error saving context %@ %@\n%@", psc_mainContext, [error localizedDescription], [error userInfo]);
}

+ (void)saveAndPersistContext {
    [self saveAndPersistContextBlocking:NO];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Parent-Child-Context for Threading
////////////////////////////////////////////////////////////////////////

+ (NSManagedObjectContext *)mainContext {
    return psc_mainContext;
}

+ (NSManagedObjectContext *)newChildContext {
    return [[self mainContext] newChildContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
}

@end
