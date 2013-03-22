//
//  NSManagedObjectContext+PSCCoreDataHelper.h
//  Companion
//
//  Created by Philip Messlehner on 28.02.13.
//  Copyright (c) 2013 Philip Messlehner. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface NSManagedObjectContext (PSCCoreDataHelper)

- (NSManagedObjectContext *)newChildContextWithConcurrencyType:(NSUInteger)concurrencyType;
- (NSManagedObjectContext *)newChildContext;

- (void)saveAndPropagateToParentContextBlocking:(BOOL)wait error:(NSError **)error;
- (void)saveAndPropagateToParentContext:(NSError **)error;

@end
