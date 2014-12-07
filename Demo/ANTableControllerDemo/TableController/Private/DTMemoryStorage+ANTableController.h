//
//  DTMemoryStorage_DTTableViewAdditions.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 21.08.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.

#import "DTMemoryStorage.h"

/**
 This category is used to adapt DTMemoryStorage for table view models. It adds UITableView specific methods like moving items between indexPaths and moving sections in UITableView.
 */
@interface DTMemoryStorage (ANTableViewManagerAdditions)

///---------------------------------------
/// @name Moving items and sections
///---------------------------------------

/**
 Move table item from `sourceIndexPath` to `destinationIndexPath`.
 
 @param sourceIndexPath source indexPath of item to move.
 
 @param destinationIndexPath Index, where item should be moved.
 
 @warning Moving item at index, that is not valid, won't do anything, except logging into console about failure
 */
- (void)moveTableItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

/**
 Moves a section to a new location in the table view.
 
 @param indexFrom The index of the section to move.
 
 @param indexTo The index in the table view that is the destination of the move for the section. The existing section at that location slides up or down to an adjoining index position to make room for it.
 */
- (void)moveTableViewSection:(NSInteger)indexFrom toSection:(NSInteger)indexTo;

///---------------------------------------
/// @name Remove all items
///---------------------------------------

/**
 Removes all tableItems. This method will call UITableView -reloadData method on completion. This method does not remove sections and section header and footer models.
 */
- (void)removeAllTableItems;

@end
