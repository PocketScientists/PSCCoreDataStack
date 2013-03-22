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
    NSMutableArray *_deletedRowIndexPaths;
    NSMutableArray *_insertedRowIndexPaths;
    NSMutableArray *_updatedRowIndexPaths;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - PSCFetchedResultsControllerUpdater
////////////////////////////////////////////////////////////////////////

- (void)reset {
    _insertedSectionIndexes = nil;
    _deletedSectionIndexes = nil;

    _deletedRowIndexPaths = nil;
    _insertedRowIndexPaths = nil;
    _updatedRowIndexPaths = nil;
}

- (NSUInteger)numberOfTotalChanges {
    return ([self.deletedSectionIndexes count] + [self.insertedSectionIndexes count] +
            [self.deletedRowIndexPaths count] + [self.insertedRowIndexPaths count] +
            [self.updatedRowIndexPaths count]);
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

- (NSArray *)deletedRowIndexPaths {
    if (_deletedRowIndexPaths == nil) {
        _deletedRowIndexPaths = [[NSMutableArray alloc] init];
    }

    return _deletedRowIndexPaths;
}

- (NSArray *)insertedRowIndexPaths {
    if (_insertedRowIndexPaths == nil) {
        _insertedRowIndexPaths = [[NSMutableArray alloc] init];
    }

    return _insertedRowIndexPaths;
}

- (NSArray *)updatedRowIndexPaths {
    if (_updatedRowIndexPaths == nil) {
        _updatedRowIndexPaths = [[NSMutableArray alloc] init];
    }

    return _updatedRowIndexPaths;
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

        [_insertedRowIndexPaths addObject:newIndexPath];
    } else if (type == NSFetchedResultsChangeDelete) {
        if ([_deletedSectionIndexes containsIndex:indexPath.section]) {
            // If we've already been told that we're deleting a section for this deleted row we skip it since it will handled by the section deletion.
            return;
        }

        [_deletedRowIndexPaths addObject:indexPath];
    } else if (type == NSFetchedResultsChangeMove) {
        if ([_insertedSectionIndexes containsIndex:newIndexPath.section] == NO) {
            [_insertedRowIndexPaths addObject:newIndexPath];
        }

        if ([_deletedSectionIndexes containsIndex:indexPath.section] == NO) {
            [_deletedRowIndexPaths addObject:indexPath];
        }
    } else if (type == NSFetchedResultsChangeUpdate) {
        [_updatedRowIndexPaths addObject:indexPath];
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
