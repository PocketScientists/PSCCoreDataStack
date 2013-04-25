//
//  PSCFetchedResultsControllerUpdater.m
//  PSCCoreDataStack
//
//  Created by Matthias Tretter on 22.03.13.
//  Copyright (c) 2013 PocketScience. All rights reserved.
//

#import "PSCFetchedResultsControllerUpdater.h"


@implementation PSCFetchedResultsControllerUpdater {
    NSMutableIndexSet *_insertedSectionIndexes;
    NSMutableIndexSet *_deletedSectionIndexes;
    NSMutableArray *_deletedObjectIndexPaths;
    NSMutableArray *_insertedObjectIndexPaths;
    NSMutableArray *_updatedObjectIndexPaths;
    NSMutableArray *_movedObjectIndexPaths;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - PSCFetchedResultsControllerUpdater
////////////////////////////////////////////////////////////////////////

- (void)reset {
    [self resetSectionChanges];
    [self resetObjectChanges];
}

- (void)resetSectionChanges {
    _insertedSectionIndexes = [[NSMutableIndexSet alloc] init];
    _deletedSectionIndexes = [[NSMutableIndexSet alloc] init];
}

- (void)resetObjectChanges {
    _deletedObjectIndexPaths = [[NSMutableArray alloc] init];
    _insertedObjectIndexPaths = [[NSMutableArray alloc] init];
    _updatedObjectIndexPaths = [[NSMutableArray alloc] init];
    _movedObjectIndexPaths = [[NSMutableArray alloc] init];
}

- (NSUInteger)numberOfTotalChanges {
    return (self.numberOfSectionChanges + self.numberOfObjectChanges);
}

- (NSUInteger)numberOfSectionChanges {
    return ([self.deletedSectionIndexes count] + [self.insertedSectionIndexes count]);
}

- (NSUInteger)numberOfObjectChanges {
    return ([self.deletedObjectIndexPaths count] + [self.insertedObjectIndexPaths count] +
            [self.updatedObjectIndexPaths count] + [self.movedObjectIndexPaths count]);
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSFetchedResultsControllerDelegate
////////////////////////////////////////////////////////////////////////

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self reset];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // do nothing specific here
}

- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    // only implemented for safety, if every delegate method gets forwarded
    return [[sectionName substringToIndex:1] uppercaseString];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    if (type == NSFetchedResultsChangeInsert) {
		// If we've already been told that we're adding a section for this inserted row we skip it since it will handled by the section insertion.
        if (![_insertedSectionIndexes containsIndex:newIndexPath.section]) {
            [_insertedObjectIndexPaths addObject:newIndexPath];
        }
    } else if (type == NSFetchedResultsChangeDelete) {
		// If we've already been told that we're deleting a section for this deleted row we skip it since it will handled by the section deletion.
        if (![_deletedSectionIndexes containsIndex:indexPath.section]) {
            [_deletedObjectIndexPaths addObject:indexPath];
        }
    } else if (type == NSFetchedResultsChangeMove) {
        if (![_insertedSectionIndexes containsIndex:newIndexPath.section] || ![_deletedSectionIndexes containsIndex:indexPath.section]) {
            [_movedObjectIndexPaths addObject:@[newIndexPath, indexPath]];
        }
    }

    else if (type == NSFetchedResultsChangeUpdate) {
        [_updatedObjectIndexPaths addObject:indexPath];
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [_insertedSectionIndexes addIndex:sectionIndex];
            break;
        }

        case NSFetchedResultsChangeDelete: {
            [_deletedSectionIndexes addIndex:sectionIndex];
            break;
        }

        default: {
            // Shouldn't have a default
            break;
        }
    }
}

@end
