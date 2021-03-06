//
//  PSCContextWatcher.h
//  Companion
//
//  Created by Philip Messlehner on 28.02.13.
//  Copyright (c) 2013 Philip Messlehner. All rights reserved.
//
//  Copyright 2010 Zarra Studios, LLC All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
#import <CoreData/CoreData.h>


@protocol PSCContextWatcherDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface PSCContextWatcher : NSObject

@property (nullable, nonatomic, weak) id<PSCContextWatcherDelegate> delegate;

+ (instancetype)watcherWithContext:(NSManagedObjectContext *)context;
- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)context;

- (void)addEntityToWatch:(NSEntityDescription *)entityDescription withPredicate:(NSPredicate *)predicate;
- (void)addEntityClassToWatch:(Class)entityClass withPredicate:(NSPredicate *)predicate;

- (void)addManangedObjectToWatch:(NSManagedObject *)managedObject;

- (void)reset;

@end


@protocol PSCContextWatcherDelegate <NSObject>

- (void)contextWatcher:(PSCContextWatcher *)watcher
    observedInsertions:(nullable NSSet<NSManagedObject *> *)inserts
             deletions:(nullable NSSet<NSManagedObject *> *)deletions
               updates:(nullable NSSet<NSManagedObject *> *)updates
             inContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END
