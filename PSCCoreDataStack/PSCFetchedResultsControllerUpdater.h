//
//  PSCFetchedResultsControllerUpdater.h
//  PSCCoreDataStack
//
//  Created by Matthias Tretter on 22.03.13.
//  Copyright (c) 2013 PocketScience. All rights reserved.
//
//  Derived from MrRooni's Gist: https://gist.github.com/MrRooni/4988922


/**
 Controller that can be used to gather information about animated updates in a UITableView/UICollectionView.
 You need to forward every method of your NSFetchedResultsController to an updater instance.
 
 Sample code in your NSFetchedResultsControllerDelegate's controllerDidChangeContent:
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
        [self.updater controllerDidChangeContent];
    
        if (self.updater.numberOfTotalChanges > 50) {
            [self.tableView reloadData];
        } else {
            [self.tableView beginUpdates];

            [self.tableView deleteSections:self.updater.deletedSectionIndexes withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertSections:self.updater.insertedSectionIndexes withRowAnimation:UITableViewRowAnimationAutomatic];

            [self.tableView deleteRowsAtIndexPaths:self.updater.deletedObjectIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:self.updater.insertedObjectIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadRowsAtIndexPaths:self.updater.updatedObjectIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];

            [self.tableView endUpdates];
        }
 
        // optional
        [self.updater reset];
 }

 */
@interface PSCFetchedResultsControllerUpdater : NSObject <NSFetchedResultsControllerDelegate>

@property (nonatomic, readonly) NSUInteger numberOfTotalChanges;

@property (nonatomic, readonly) NSIndexSet *deletedSectionIndexes;
@property (nonatomic, readonly) NSIndexSet *insertedSectionIndexes;

@property (nonatomic, readonly) NSArray *deletedObjectIndexPaths;
@property (nonatomic, readonly) NSArray *insertedObjectIndexPaths;
@property (nonatomic, readonly) NSArray *updatedObjectIndexPaths;

- (void)reset;

@end
