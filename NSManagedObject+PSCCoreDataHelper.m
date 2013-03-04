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

@end
