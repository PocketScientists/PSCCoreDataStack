//
//  PSCCoreDataHelper.m
//  Companion
//
//  Created by Philip Messlehner on 28.02.13.
//  Copyright (c) 2013 Philip Messlehner. All rights reserved.
//

#import "PSCCoreDataHelper.h"


@interface PSCCoreDataHelper ()

@property (nonatomic, strong) NSManagedObjectContext *privateContext;
@property (nonatomic, strong) NSManagedObjectContext *mainContext;

@end


@implementation PSCCoreDataHelper

////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
////////////////////////////////////////////////////////////////////////

+ (PSCCoreDataHelper *)sharedHelper {
    static PSCCoreDataHelper *_sharedHelper = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedHelper = [self new];
    });
    
    return _sharedHelper;
}

+ (void)initializeCoreDataStackWithModelURL:(NSURL *)modelURL storeFileName:(NSString *)storeFileName type:(NSString *)storeType configuration:(NSString *)configuration options:(NSDictionary *)options success:(void(^)())successBlock error:(void(^)(NSError *error))errorBlock {
    NSAssert(modelURL, @"Failed to find model URL");
    
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(model, @"Failed to initialize model");
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSAssert(persistentStoreCoordinator, @"Failed to initialize persistent store coordinator");
    
    [self sharedHelper].privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self sharedHelper].privateContext.persistentStoreCoordinator = persistentStoreCoordinator;
    
    [self sharedHelper].mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self sharedHelper].mainContext.parentContext = [self sharedHelper].privateContext;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *storeURL = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
        storeURL = [storeURL URLByAppendingPathComponent:storeFileName];
        
        NSError *error = nil;
        NSPersistentStore *store = [persistentStoreCoordinator addPersistentStoreWithType:storeType configuration:configuration URL:storeURL options:options error:&error];
        if (store == nil || error != nil) {
            NSLog(@"Error adding persistent store to coordinator %@\n%@", [error localizedDescription], [error userInfo]);
            if (errorBlock) {
                errorBlock(error);
            }
        }
        if (successBlock) {
            successBlock();
        }
    });
}

+ (void)initializeCoreDataStackWithModelURL:(NSURL *)modelURL autoMigratedSQLiteStoreFileName:(NSString *)storeFileName success:(void(^)())successBlock error:(void(^)(NSError *error))errorBlock {
    [[self class] initializeCoreDataStackWithModelURL:modelURL storeFileName:storeFileName type:NSSQLiteStoreType configuration:nil options:@{NSMigratePersistentStoresAutomaticallyOption: @(YES), NSInferMappingModelAutomaticallyOption: @(YES)} success:successBlock error:errorBlock];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Saving
////////////////////////////////////////////////////////////////////////

+ (void)saveAndPersistContextBlocking:(BOOL)wait {
    NSError *error = nil;
    [[self mainContext] saveAndPropagateToParentContextBlocking:wait error:&error];
    NSAssert(error == nil, @"Error saving context %@ %@\n%@", [self sharedHelper].mainContext, [error localizedDescription], [error userInfo]);
}

+ (void)saveAndPersistContext {
    [self saveAndPersistContextBlocking:NO];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Parent-Child-Context for Threading
////////////////////////////////////////////////////////////////////////

+ (NSManagedObjectContext *)newChildContext {
    return [[self mainContext] newChildContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
}

+ (NSManagedObjectContext *)mainContext {
    return [self sharedHelper].mainContext;
}

@end
