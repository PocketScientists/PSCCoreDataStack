//
//  NSManagedObject+PSCCoreDataHelper.h
//  Companion
//
//  Created by Philip Messlehner on 28.02.13.
//  Copyright (c) 2013 Philip Messlehner. All rights reserved.
//

#import <CoreData/CoreData.h>

@class PSCContextWatcher;

@interface NSManagedObject (PSCCoreDataHelper)

+ (instancetype)newObjectInContext:(NSManagedObjectContext *)context;
+ (instancetype)existingOrNewObjectWithAttribute:(NSString *)attribute matchingValue:(id)value inContext:(NSManagedObjectContext *)context;

+ (void)addToWatcher:(PSCContextWatcher *)watcher withPredicate:(NSPredicate *)predicate;

- (void)reset;

@end
