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

////////////////////////////////////////////////////////////////////////
#pragma mark - Class Methods
////////////////////////////////////////////////////////////////////////

+ (instancetype)newObjectInContext:(NSManagedObjectContext *)context {
    NSParameterAssert(context != nil);
    
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
}

+ (instancetype)existingOrNewObjectWithAttribute:(NSString *)attribute matchingValue:(id)value inContext:(NSManagedObjectContext *)context {
    NSParameterAssert(attribute != nil);
    NSParameterAssert(context != nil);

    id object = nil;
    
    if (value != nil) {
        NSError *error = nil;
        NSFetchRequest *request = [self requestFirstMatchingPredicate:[NSPredicate predicateWithFormat:@"%K = %@", attribute, value]
                                                            inContext:context
                                                                error:&error];

        if (request == nil) {
            NSLog(@"Error fetching first object: %@ - %@", [error localizedDescription], [error userInfo]);
        } else {
            object = [[context executeFetchRequest:request error:&error] lastObject];
        }
    }
    
    if (object == nil) {
        object = [[self class] newObjectInContext:context];
        [object setValue:value forKey:attribute];
    }
    
    return object;
}

+ (NSUInteger)deleteAllMatchingPredicate:(NSPredicate *)predicate requestConfiguration:(NSFetchRequest *(^)(NSFetchRequest *request))requestConfigurationBlock inContext:(NSManagedObjectContext *)context error:(__autoreleasing NSError **)error {
    NSParameterAssert(context != nil);

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];

    request.predicate = predicate;
    request.returnsObjectsAsFaults = YES;
    request.includesPropertyValues =  NO;
    request.includesSubentities = NO;

    if (requestConfigurationBlock != nil) {
        request = requestConfigurationBlock(request);
    }
    
    NSArray *objects = [context executeFetchRequest:request error:error];
    
    if (objects.count > 0) {
        for (NSManagedObject *object in objects) {
            [context deleteObject:object];
        }
    }

    return objects.count;
}

+ (NSUInteger)deleteAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(__autoreleasing NSError **)error {
    return [self deleteAllMatchingPredicate:predicate requestConfiguration:nil inContext:context error:error];
}

+ (NSFetchRequest *)requestAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(__autoreleasing NSError **)error {
    NSParameterAssert(context != nil);

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    request.predicate = predicate;

    return request;
}

+ (NSFetchRequest *)requestFirstMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(NSError **)error {
    NSFetchRequest *request = [self requestAllMatchingPredicate:predicate inContext:context error:error];

    request.fetchLimit = 1;
    return request;
}

+ (NSArray *)fetchAllMatchingPredicate:(NSPredicate *)predicate requestConfiguration:(NSFetchRequest *(^)(NSFetchRequest *request))requestConfigurationBlock inContext:(NSManagedObjectContext *)context error:(__autoreleasing NSError **)error {
    NSFetchRequest *request = [self requestAllMatchingPredicate:predicate inContext:context error:error];

    if (requestConfigurationBlock != nil) {
        request = requestConfigurationBlock(request);
    }
    
    NSArray *objects = [context executeFetchRequest:request error:error];

    return objects;
}

+ (NSArray *)fetchAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(__autoreleasing NSError **)error {
    return [self fetchAllMatchingPredicate:predicate requestConfiguration:nil inContext:context error:error];
}

+ (NSUInteger)countOfObjectsMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(__autoreleasing NSError **)error {
	NSFetchRequest *request = [self requestAllMatchingPredicate:predicate inContext:context error:error];

    if (request != nil) {
        return [context countForFetchRequest:request error:error];
    } else {
        return NSNotFound;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Instance Methods
////////////////////////////////////////////////////////////////////////

- (void)reset {
    if (self.hasChanges) {
        [self.managedObjectContext refreshObject:self mergeChanges:NO];
    }
}

- (void)deleteFromContext {
    [self.managedObjectContext deleteObject:self];
}

- (id)userInfoValueForKey:(NSString *)key ofProperty:(NSString *)property {
    for (NSPropertyDescription *propertyDescription in self.entity.properties) {
        if ([propertyDescription.name isEqualToString:property]) {
            return [[propertyDescription userInfo] valueForKey:key];
        }
    }
    
    return nil;
}

@end
