//
//  PSCContextWatcher.m
//  Companion
//
//  Created by Philip Messlehner on 28.02.13.
//  Copyright (c) 2013 Philip Messlehner. All rights reserved.
//

#import "PSCContextWatcher.h"


@interface PSCContextWatcher ()

@property (nonatomic, strong) NSPredicate *masterPredicate;
@property (nonatomic, strong) NSManagedObjectContext *contextToWatch;

@end


@implementation PSCContextWatcher

////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
////////////////////////////////////////////////////////////////////////

+ (instancetype)watcherWithContext:(NSManagedObjectContext*)context {
    return [[self alloc] initWithManagedObjectContext:context];
}

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)context {
    NSParameterAssert(context != nil);
    
    if ((self = [super init])) {
        _contextToWatch = context;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:_contextToWatch];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:_contextToWatch];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - PSCContextWatcher
////////////////////////////////////////////////////////////////////////

- (void)addEntityToWatch:(NSEntityDescription *)entityDescription withPredicate:(NSPredicate *)predicate {
    [self addEntityNameToWatch:[entityDescription name] withPredicate:predicate];
}

- (void)addEntityClassToWatch:(Class)entityClass withPredicate:(NSPredicate *)predicate {
    NSParameterAssert(entityClass != Nil);
    
    [self addEntityNameToWatch:NSStringFromClass(entityClass) withPredicate:predicate];
}

- (void)reset {
    self.masterPredicate = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)addEntityNameToWatch:(NSString *)name withPredicate:(NSPredicate *)predicate {
    NSParameterAssert(name != nil);
    NSParameterAssert(predicate != nil);

    NSPredicate *entityPredicate = [NSPredicate predicateWithFormat:@"entity.name == %@", name];
    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[entityPredicate, predicate]];

    if (self.masterPredicate == nil) {
        self.masterPredicate = finalPredicate;
    } else {
        self.masterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[self.masterPredicate, finalPredicate]];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSNotification
////////////////////////////////////////////////////////////////////////

- (void)contextDidSave:(NSNotification *)notification {
    if (self.masterPredicate == nil) {
        return;
    }

    NSMutableSet *inserted = [[[notification userInfo] objectForKey:NSInsertedObjectsKey] mutableCopy];
    [inserted filterUsingPredicate:[self masterPredicate]];

    
    NSMutableSet *deleted = [[[notification userInfo] objectForKey:NSDeletedObjectsKey] mutableCopy];
    [deleted filterUsingPredicate:[self masterPredicate]];

    
    NSMutableSet *updated = [[[notification userInfo] objectForKey:NSUpdatedObjectsKey] mutableCopy];
    [updated filterUsingPredicate:[self masterPredicate]];
    
    if ((inserted.count + deleted.count + updated.count) == 0) {
        return;
    }
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];

    if (inserted) {
        [results setObject:inserted forKey:NSInsertedObjectsKey];
    }
    if (deleted) {
        [results setObject:deleted forKey:NSDeletedObjectsKey];
    }
    if (updated) {
        [results setObject:updated forKey:NSUpdatedObjectsKey];
    }
    
    [self.delegate contextWatcher:self observedChanges:results inContext:self.contextToWatch];
}

@end
