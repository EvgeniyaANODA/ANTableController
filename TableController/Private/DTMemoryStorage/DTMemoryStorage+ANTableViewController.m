

#import "DTMemoryStorage+ANTableViewController.h"

//TODO: don't like this shitty private protocol
@protocol DTTableViewDataStorageUpdating <DTStorageUpdating>
@optional

- (void)performAnimatedUpdate:(void (^)(UITableView *))animationBlock;

@end

@interface DTMemoryStorage ()

@property (nonatomic, retain) DTStorageUpdate * currentUpdate;

- (DTSectionModel *)createSectionIfNotExist:(NSUInteger)sectionNumber;

- (void)startUpdate;
- (void)finishUpdate;

@end

@implementation DTMemoryStorage(DTTableViewManager_Additions)

- (void)removeAllTableItems
{
    NSArray* objects = [self.sections valueForKey:@"objects"];
    [objects makeObjectsPerformSelector:@selector(removeAllObjects)];

    id<DTTableViewDataStorageUpdating> delegate = (id <DTTableViewDataStorageUpdating>)self.delegate;
    
    [delegate performAnimatedUpdate:^(UITableView * tableView) {
        [tableView reloadData];
    }];
}

- (void)moveTableItemAtIndexPath:(NSIndexPath *)sourceIndexPath  toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self startUpdate];
    
    id item = [self objectAtIndexPath:sourceIndexPath];
    
    if (!sourceIndexPath || !item)
    {
        NSLog(@"DTTableViewManager: source indexPath should not be nil when moving collection item");
        return;
    }
    DTSectionModel * sourceSection = [self createSectionIfNotExist:sourceIndexPath.section];
    DTSectionModel * destinationSection = [self createSectionIfNotExist:destinationIndexPath.section];
    
    if ([destinationSection.objects count] < destinationIndexPath.row)
    {

        NSLog(@"DTTableViewManager: failed moving item to indexPath: %@, only %@ items in section", destinationIndexPath, @([destinationSection.objects count]));
        self.currentUpdate = nil;
        return;
    }
    
    [(id <DTTableViewDataStorageUpdating>)self.delegate performAnimatedUpdate:^(UITableView * tableView)
     {
         [tableView insertSections:self.currentUpdate.insertedSectionIndexes
                  withRowAnimation:UITableViewRowAnimationAutomatic];
         [sourceSection.objects removeObjectAtIndex:sourceIndexPath.row];
         [destinationSection.objects insertObject:item
                                          atIndex:destinationIndexPath.row];
         [tableView moveRowAtIndexPath:sourceIndexPath
                           toIndexPath:destinationIndexPath];
     }];
    self.currentUpdate = nil;
}

#pragma mark - Section management

- (void)moveTableViewSection:(NSInteger)indexFrom toSection:(NSInteger)indexTo
{
    DTSectionModel * validSectionFrom = [self createSectionIfNotExist:indexFrom];
    [self createSectionIfNotExist:indexTo];
    
    [self.sections removeObject:validSectionFrom];
    [self.sections insertObject:validSectionFrom atIndex:indexTo];
    
    id<DTTableViewDataStorageUpdating> delegate = (id <DTTableViewDataStorageUpdating>)self.delegate;
    
    [delegate performAnimatedUpdate:^(UITableView * tableView) {
         [tableView moveSection:indexFrom toSection:indexTo];
    }];
}

@end
