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
}

////////////////////////////////////////////////////////////////////////
#pragma mark - PSCFetchedResultsControllerUpdater
////////////////////////////////////////////////////////////////////////

- (void)reset {
    _insertedSectionIndexes = nil;
    _deletedSectionIndexes = nil;
    
    _deletedObjectIndexPaths = nil;
    _insertedObjectIndexPaths = nil;
    _updatedObjectIndexPaths = nil;
}

- (NSUInteger)numberOfTotalChanges {
    return ([self.deletedSectionIndexes count] + [self.insertedSectionIndexes count] +
            [self.deletedObjectIndexPaths count] + [self.insertedObjectIndexPaths count] +
            [self.updatedObjectIndexPaths count]);
}

- (NSIndexSet *)deletedSectionIndexes {
    if (_deletedSectionIndexes == nil) {
        _deletedSectionIndexes = [[NSMutableIndexSet alloc] init];
    }

    return _deletedSectionIndexes;
}

- (NSIndexSet *)insertedSectionIndexes {
    if (_insertedSectionIndexes == nil) {
        _insertedSectionIndexes = [[NSMutableIndexSet alloc] init];
    }

    return _insertedSectionIndexes;
}

- (NSArray *)deletedObjectIndexPaths {
    if (_deletedObjectIndexPaths == nil) {
        _deletedObjectIndexPaths = [[NSMutableArray alloc] init];
    }

    return _deletedObjectIndexPaths;
}

- (NSArray *)insertedObjectIndexPaths {
    if (_insertedObjectIndexPaths == nil) {
        _insertedObjectIndexPaths = [[NSMutableArray alloc] init];
    }

    return _insertedObjectIndexPaths;
}

- (NSArray *)updatedObjectIndexPaths {
    if (_updatedObjectIndexPaths == nil) {
        _updatedObjectIndexPaths = [[NSMutableArray alloc] init];
    }

    return _updatedObjectIndexPaths;
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
    return sectionName;
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    if (type == NSFetchedResultsChangeInsert) {
        if ([_insertedSectionIndexes containsIndex:newIndexPath.section]) {
            // If we've already been told that we're adding a section for this inserted row we skip it since it will handled by the section insertion.
            return;
        }

        [_insertedObjectIndexPaths addObject:newIndexPath];
    } else if (type == NSFetchedResultsChangeDelete) {
        if ([_deletedSectionIndexes containsIndex:indexPath.section]) {
            // If we've already been told that we're deleting a section for this deleted row we skip it since it will handled by the section deletion.
            return;
        }

        [_deletedObjectIndexPaths addObject:indexPath];
    } else if (type == NSFetchedResultsChangeMove) {
        if ([_insertedSectionIndexes containsIndex:newIndexPath.section] == NO) {
            [_insertedObjectIndexPaths addObject:newIndexPath];
        }

        if ([_deletedSectionIndexes containsIndex:indexPath.section] == NO) {
            [_deletedObjectIndexPaths addObject:indexPath];
        }
    } else if (type == NSFetchedResultsChangeUpdate) {
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
