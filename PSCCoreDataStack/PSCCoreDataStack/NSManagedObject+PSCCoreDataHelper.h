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

+ (void)deleteAllMatchingPredicate:(NSPredicate *)predicate
              requestConfiguration:(NSFetchRequest *(^)(NSFetchRequest *request))requestConfigurationBlock
                         inContext:(NSManagedObjectContext *)context
                             error:(NSError **)error;
+ (void)deleteAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(NSError **)error;

+ (NSFetchRequest *)requestAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(NSError **)error;
+ (NSFetchRequest *)requestFirstMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(NSError **)error;

+ (NSArray *)fetchAllMatchingPredicate:(NSPredicate *)predicate
                  requestConfiguration:(NSFetchRequest *(^)(NSFetchRequest *request))requestConfigurationBlock
                             inContext:(NSManagedObjectContext *)context
                                 error:(NSError **)error;
+ (NSArray *)fetchAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(NSError **)error;

+ (NSUInteger)countOfObjectsMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(NSError **)error;

- (void)reset;
- (void)deleteFromContext;

- (id)userInfoValueForKey:(NSString *)key ofProperty:(NSString *)property;

@end
