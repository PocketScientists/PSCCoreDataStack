//
//  NSManagedObject+PSCCoreDataHelper.m
//  Companion
//
//  Created by Philip Messlehner on 28.02.13.
//  Copyright (c) 2013 Philip Messlehner. All rights reserved.
//

#import "NSManagedObject+PSCCoreDataHelper.h"
#import "PSCContextWatcher.h"


@implementation NSManagedObject (PSCCoreDataHelper)

+ (instancetype)newObjectInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
}

+ (instancetype)existingOrNewObjectWithAttribute:(NSString *)attribute matchingValue:(id)value inContext:(NSManagedObjectContext *)context {
    id object = nil;
    
    if (value != nil) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
        request.predicate = [NSPredicate predicateWithFormat:@"%K = %@", attribute, value];
        request.fetchLimit = 1;
        NSError *error;
        
        object = [[context executeFetchRequest:request error:&error] lastObject];
    }
    
    if (object == nil) {
        object = [[self class] newObjectInContext:context];
        [object setValue:value forKey:attribute];
    }
    
    return object;
}

+ (void)addToWatcher:(PSCContextWatcher *)watcher withPredicate:(NSPredicate *)predicate {
    [watcher addEntityClassToWatch:[self class] withPredicate:predicate];
}

+ (void)deleteAllMatchingPredicate:(NSPredicate *)predicate requestConfiguration:(NSFetchRequest *(^)(NSFetchRequest *request))requestConfigurationBlock inContext:(NSManagedObjectContext *)context error:(NSError **)error {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    request.predicate = predicate;

    if (requestConfigurationBlock != nil) {
        request = requestConfigurationBlock(request);
    }
    
    NSArray *objects = [context executeFetchRequest:request error:error];
    
    if (objects.count > 0) {
        for (NSManagedObject *object in objects) {
            [context deleteObject:object];
        }
    }
}

+ (void)deleteAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(NSError **)error {
    [self deleteAllMatchingPredicate:predicate requestConfiguration:nil inContext:context error:error];
}

+ (NSArray *)fetchAllMatchingPredicate:(NSPredicate *)predicate requestConfiguration:(NSFetchRequest *(^)(NSFetchRequest *request))requestConfigurationBlock inContext:(NSManagedObjectContext *)context error:(NSError **)error {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    request.predicate = predicate;

    if (requestConfigurationBlock != nil) {
        request = requestConfigurationBlock(request);
    }
    
    NSArray *objects = [context executeFetchRequest:request error:error];

    return objects;
}

+ (NSArray *)fetchAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(NSError **)error {
    return [self fetchAllMatchingPredicate:predicate requestConfiguration:nil inContext:context error:error];
}

- (void)reset {
    if (self.hasChanges) {
        [self.managedObjectContext refreshObject:self mergeChanges:NO];
    }
}

- (void)delete {
    [self.managedObjectContext deleteObject:self];
}

@end
