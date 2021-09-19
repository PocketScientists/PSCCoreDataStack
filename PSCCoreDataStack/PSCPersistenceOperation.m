#import "PSCPersistenceOperation.h"
#import "PSCCoreDataStack.h"
#import "NSManagedObjectContext+PSCCoreDataHelper.h"
#import "PSCLogging.h"

// the queue used in persistDataInBackgroundWithParentContext:block:completion:
static dispatch_queue_t _psc_persistence_queue = NULL;


@interface PSCPersistenceOperation ()

@property (nonatomic, strong) NSManagedObjectContext *parentContext;
@property (nonatomic, copy) psc_persistence_block persistenceBlock;

@end


@implementation PSCPersistenceOperation

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (instancetype)operationWithParentContext:(NSManagedObjectContext *)parentContext
                                     block:(psc_persistence_block)block
                                completion:(dispatch_block_t)completion {
    NSParameterAssert(parentContext != nil);
    NSParameterAssert(block != nil);

    PSCPersistenceOperation *operation = [[self alloc] init];

    operation.parentContext = parentContext;
    operation.persistenceBlock = block;
    operation.completionBlock = completion;

    return operation;
}

+ (void)persistDataInBackgroundWithParentContext:(NSManagedObjectContext *)parentContext
                                           block:(psc_persistence_block)block
                                      completion:(dispatch_block_t)completion {
    NSParameterAssert(parentContext != nil);
    NSParameterAssert(block != nil);

    dispatch_async(psc_persistence_queue(), ^{
        NSManagedObjectContext *localContext = [parentContext newChildContextWithConcurrencyType:NSPrivateQueueConcurrencyType];

        [localContext performBlock:^{
            if (block != nil) {
                block(localContext);
            }

            NSError *error = nil;
            if (![localContext save:&error]) {
                PSCCDLog(@"Error persisting local context in PSCPersistenceAction: %@", error);
            }

            if (completion != nil) {
                dispatch_async(dispatch_get_main_queue(), completion);
            }
        }];
    });
}

////////////////////////////////////////////////////////////////////////
#pragma mark - PSCPersisteceOperation
////////////////////////////////////////////////////////////////////////

- (BOOL)persistWithContext:(NSManagedObjectContext *)localContext {
    // do nothing, subclasses can override
    return NO;
}

- (void)willSaveContext:(NSManagedObjectContext *)localContext {
    // do nothing, subclasses can override
}

- (void)didSaveContext:(NSManagedObjectContext *)localContext {
    // do nothing, subclasses can override
}

- (void)didFailToSaveContext:(NSManagedObjectContext *)localContext error:(NSError *)error {
    PSCCDLog(@"Error persisting local context in PSCPersistenceAction: %@", error);
}

- (void)didNotSaveContext:(NSManagedObjectContext *)localContext {
    // do nothing, subclasses can override
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSOperation
////////////////////////////////////////////////////////////////////////

- (void)main {
    NSManagedObjectContext *localContext = [self.parentContext newChildContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
    BOOL save = NO;

    // either persist via block (if set), or call method in subclass
    if (self.persistenceBlock != nil) {
        save = self.persistenceBlock(localContext);
    } else {
        save = [self persistWithContext:localContext];
    }

    if (save && localContext.hasChanges) {
        NSError *error = nil;
        
        [self willSaveContext:localContext];

        if (![localContext save:&error]) {
            [self didFailToSaveContext:localContext error:error];
        } else {
            [self didSaveContext:localContext];
        }
    } else {
        [self didNotSaveContext:localContext];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Functions
////////////////////////////////////////////////////////////////////////

dispatch_queue_t psc_persistence_queue(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _psc_persistence_queue = dispatch_queue_create("com.pocketscience.persistence-queue", 0);
    });
    
    return _psc_persistence_queue;
}

@end
