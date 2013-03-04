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

- (void)contextUpdated:(NSNotification*)notification;

@end

@implementation PSCContextWatcher

////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
////////////////////////////////////////////////////////////////////////

+ (instancetype)watcherWithContext:(NSManagedObjectContext*)context {
    return [[self alloc] initWithManagedObjectContext:context];
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context {
    NSAssert(context, @"Context is nil!");
    if ((self = [super init])) {
        _contextToWatch = context;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextUpdated:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:_contextToWatch];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.contextToWatch];
    self.delegate = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - PSCContextWatcher
////////////////////////////////////////////////////////////////////////

- (void)addEntityToWatch:(NSString *)name withPredicate:(NSPredicate *)predicate {
    NSPredicate *entityPredicate = [NSPredicate predicateWithFormat:@"entity.name == %@", name];
    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[entityPredicate, predicate]];
    
    if (self.masterPredicate == nil) {
        self.masterPredicate = finalPredicate;
    } else {
        self.masterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[self.masterPredicate, finalPredicate]];
    }
}

- (void)addEntityClassToWatch:(Class)class withPredicate:(NSPredicate *)predicate {
    [self addEntityToWatch:NSStringFromClass(class) withPredicate:predicate];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Notification Handling
////////////////////////////////////////////////////////////////////////

- (void)contextUpdated:(NSNotification*)notification {
    if (self.masterPredicate == nil) {
        return;
    }
    
    NSInteger totalCount = 0;
    NSSet *temp = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
    NSMutableSet *inserted = [temp mutableCopy];
    [inserted filterUsingPredicate:[self masterPredicate]];
    totalCount += inserted.count;
    
    temp = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    NSMutableSet *deleted = [temp mutableCopy];
    [deleted filterUsingPredicate:[self masterPredicate]];
    totalCount += deleted.count;
    
    temp = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    NSMutableSet *updated = [temp mutableCopy];
    [updated filterUsingPredicate:[self masterPredicate]];
    totalCount += updated.count;
    
    if (totalCount == 0) {
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
    
    if (self.delegate) {
        [self.delegate context:self.contextToWatch didSaveWithResults:results];
    }
}

@end
