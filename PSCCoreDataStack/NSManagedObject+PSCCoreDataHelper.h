//
//  NSManagedObject+PSCCoreDataHelper.h
//  Companion
//
//  Created by Philip Messlehner on 28.02.13.
//  Copyright (c) 2013 Philip Messlehner. All rights reserved.
//


@class PSCContextWatcher;


@interface NSManagedObject (PSCCoreDataHelper)

+ (instancetype)newObjectInContext:(NSManagedObjectContext *)context;
+ (instancetype)existingOrNewObjectWithAttribute:(NSString *)attribute matchingValue:(id)value inContext:(NSManagedObjectContext *)context;

+ (NSUInteger)deleteAllMatchingPredicate:(NSPredicate *)predicate
                    requestConfiguration:(NSFetchRequest *(^)(NSFetchRequest *request))requestConfigurationBlock
                               inContext:(NSManagedObjectContext *)context
                                   error:(NSError **)error;
+ (NSUInteger)deleteAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(NSError **)error;

+ (NSFetchRequest *)requestAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(NSError **)error;
+ (NSFetchRequest *)requestFirstMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(NSError **)error;

+ (NSArray *)fetchAllMatchingPredicate:(NSPredicate *)predicate
                  requestConfiguration:(NSFetchRequest *(^)(NSFetchRequest *request))requestConfigurationBlock
                             inContext:(NSManagedObjectContext *)context
                                 error:(NSError **)error;
+ (NSArray *)fetchAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(NSError **)error;
+ (instancetype)fetchFirstMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(NSError **)error;

+ (NSUInteger)countOfObjectsMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(NSError **)error;

/**
 High-level action to update the data in Core Data based on an array of dictionaries.
 There must be a unique key that can be used for the connection between an entity in Core Data and the dictionary.
 This method should be called on a background thread and corresponding background context.

 @param data an array of NSDictionaries to persist
 @param deleteEntitiesNotInDictionary if YES entities which IDs are not present in the dictionaries get deleted from the context
 @param dictionaryIDKeyPath the key path to the value that uniquely identifies a record in the dictionary
 @param databaseIDKey the name of the key thhat uniquely identifies a record in Core Data
 @param context the managed object context to perform the operations on
 @param updateBlock the block that gets executed for each pair of managed object / dictionary that match up.
 This block gets executed for new entities as well as entities that might need an update.
 @param error error object that gets filled in case of an error
 @return YES in case everything worked out, NO otherwise
 */
+ (BOOL)persistEntityDictionaries:(NSArray *)data
    deleteEntitiesNotInDictionary:(BOOL)deleteEntitiesNotInDictionary
            entityKeyInDictionary:(NSString *)dictionaryIDKeyPath
              entityKeyInDatabase:(NSString *)databaseIDKey
                          context:(NSManagedObjectContext *)context
                      updateBlock:(void(^)(id managedObject, NSDictionary *data, NSManagedObjectContext *localContext))updateBlock
                            error:(NSError **)error;

- (void)reset;
- (void)deleteFromContext;

- (id)userInfoValueForKey:(NSString *)key ofProperty:(NSString *)property;

@end
