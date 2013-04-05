#import "PSCPersistenceOperation.h"
#import "PSCCoreDataStack.h"
#import "NSManagedObjectContext+PSCCoreDataHelper.h"
#import "PSCLogging.h"


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
        NSManagedObjectContext *localContext = [parentContext newChildContextWithConcurrencyType:NSConfinementConcurrencyType];
        NSError *error = nil;

        if (block != nil) {
            block(localContext);
        }

        if (![localContext save:&error]) {
            PSCCDLog(@"Error persisting local context in PSCPersistenceAction: %@", error);
        }

        if (completion != nil) {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
    });
}

////////////////////////////////////////////////////////////////////////
#pragma mark - PSCPersisteceOperation
////////////////////////////////////////////////////////////////////////

- (BOOL)persistWithContext:(NSManagedObjectContext *)localContext {
    // do nothing, subclasses can override
    return NO;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSOperation
////////////////////////////////////////////////////////////////////////

- (void)main {
    NSManagedObjectContext *localContext = [self.parentContext newChildContextWithConcurrencyType:NSConfinementConcurrencyType];
    NSError *error = nil;
    BOOL save = NO;

    // either persist via block (if set), or call method in subclass
    if (self.persistenceBlock != nil) {
        save = self.persistenceBlock(localContext);
    } else {
        save = [self persistWithContext:localContext];
    }

    if (save && ![localContext save:&error]) {
        PSCCDLog(@"Error persisting local context in PSCPersistenceAction: %@", error);
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
