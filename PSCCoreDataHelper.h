//
//  PSCCoreDataHelper.h
//  Companion
//
//  Created by Philip Messlehner on 28.02.13.
//  Copyright (c) 2013 Philip Messlehner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSManagedObject+PSCCoreDataHelper.h"
#import "NSManagedObjectContext+PSCCoreDataHelper.h"
#import "PSCContextWatcher.h"

@interface PSCCoreDataHelper : NSObject

+ (PSCCoreDataHelper *)sharedHelper;

- (void)initializeCoreDataStackWithModelURL:(NSURL *)modelURL storeFileName:(NSString *)storeFileName type:(NSString *)storeType configuration:(NSString *)configuration options:(NSDictionary *)options success:(void(^)())successBlock error:(void(^)(NSError *error))errorBlock;
- (void)initializeCoreDataStackWithModelURL:(NSURL *)modelURL autoMigratedSQLiteStoreFileName:(NSString *)storeFileName success:(void(^)())successBlock error:(void(^)(NSError *error))errorBlock;

- (void)saveAndPersistContextBlocking:(BOOL)wait;
- (void)saveAndPersistContext;

- (NSManagedObjectContext *)newChildContext;

@property (nonatomic, strong) NSManagedObjectContext *mainContext;

@end
