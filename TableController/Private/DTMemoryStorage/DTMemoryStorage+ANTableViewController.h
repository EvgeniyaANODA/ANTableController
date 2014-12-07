
#import "DTMemoryStorage.h"

@interface DTMemoryStorage (ANTableViewManagerAdditions)

- (void)moveTableItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
- (void)moveTableViewSection:(NSInteger)indexFrom toSection:(NSInteger)indexTo;
- (void)removeAllTableItems;

@end
