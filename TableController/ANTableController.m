//
//  ANTableViewController.m
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANTableController.h"
#import "ANStorageMovedIndexPath.h"
#import "ANKeyboardHandler.h"
#import "ANTableController+Private.h"
#import "ANTableController+UITableViewDelegatesPrivate.h"
#import "ANHelperFunctions.h"

static const CGFloat kTableAnimationDuration = 0.25f;

@interface ANTableController ()
<
    ANStorageUpdatingInterface,
    ANTableViewFactoryDelegate
>

@property (nonatomic, assign) NSInteger currentSearchScope;
@property (nonatomic, copy) NSString * currentSearchString;

@end

@implementation ANTableController

@synthesize storage = _storage;

- (instancetype)initWithTableView:(UITableView*)tableView
{
    self = [super init];
    if (self)
    {
        self.tableView = tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.isHandlingKeyboard = YES;
        self.shouldAnimateTableViewUpdates = YES;
        
        [self setupTableViewControllerDefaults];
    }
    return self;
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    self.searchBar.delegate = nil;
    self.cellFactory.delegate = nil;
    if ([self.storage respondsToSelector:@selector(setDelegate:)])
    {
        [self.storage setDelegate:nil];
    }
}

- (void)setupTableViewControllerDefaults
{
    _cellFactory = [ANTableViewFactory new];
    _cellFactory.delegate = self;
    
    _currentSearchScope = -1;
    _sectionHeaderStyle = ANTableViewSectionStyleTitle;
    _sectionFooterStyle = ANTableViewSectionStyleTitle;
    _insertSectionAnimation = UITableViewRowAnimationNone;
    _deleteSectionAnimation = UITableViewRowAnimationAutomatic;
    _reloadSectionAnimation = UITableViewRowAnimationAutomatic;
    
    _insertRowAnimation = UITableViewRowAnimationAutomatic;
    _deleteRowAnimation = UITableViewRowAnimationAutomatic;
    _reloadRowAnimation = UITableViewRowAnimationAutomatic;
    
    _displayFooterOnEmptySection = YES;
    _displayHeaderOnEmptySection = YES;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSString * reason = [NSString stringWithFormat:@"You shouldn't init class %@ with method %@\n Please use initWithTableView method.",
                             NSStringFromSelector(_cmd), NSStringFromClass([self class])];
        NSException * exc =
        [NSException exceptionWithName:[NSString stringWithFormat:@"%@ Exception", NSStringFromClass([self class])]
                                reason:reason
                              userInfo:nil];
        [exc raise];
    }
    return self;
}

#pragma mark - getters, setters

- (void)setIsHandlingKeyboard:(BOOL)isHandlingKeyboard
{
    if (isHandlingKeyboard && !self.keyboardHandler)
    {
        self.keyboardHandler = [ANKeyboardHandler handlerWithTarget:self.tableView];
    }
    if (!isHandlingKeyboard)
    {
        self.keyboardHandler = nil;
    }
    _isHandlingKeyboard = isHandlingKeyboard;
}

- (ANMemoryStorage *)memoryStorage
{
    if ([self.storage isKindOfClass:[ANMemoryStorage class]])
    {
        return (ANMemoryStorage *)self.storage;
    }
    return nil;
}

-(id<ANStorageInterface>)storage
{
    if (!_storage)
    {
        _storage = [ANMemoryStorage storage];
        [self _attachStorage:_storage];
        [self storageNeedsReload]; // handling one-section table setup
    }
    return _storage;
}

- (void)setStorage:(id <ANStorageInterface>)storage
{
    _storage = storage;
    [self _attachStorage:_storage];
    [self storageNeedsReload];
}

- (void)setSearchingStorage:(id <ANStorageInterface>)searchingStorage
{
    _searchingStorage = searchingStorage;
    [self _attachStorage:searchingStorage];
}

- (id<ANStorageInterface>)currentStorage
{
    return [self isSearching] ? self.searchingStorage : self.storage;
}

- (void)setSearchBar:(UISearchBar *)searchBar
{
    _searchBar = searchBar;
    _searchBar.delegate = self;
}

#pragma mark - search

- (BOOL)isSearching
{
    BOOL isSearchStringNonEmpty = (self.currentSearchString && self.currentSearchString.length);
    BOOL isSearching = (isSearchStringNonEmpty || self.currentSearchScope > -1);
    
    return isSearching;
}

- (void)filterTableItemsForSearchString:(NSString *)searchString
{
    [self filterTableItemsForSearchString:searchString inScope:-1];
}

- (void)filterTableItemsForSearchString:(NSString *)searchString inScope:(NSInteger)scopeNumber
{
    [self _filterTableItemsForSearchString:searchString inScope:scopeNumber reload:NO];
}

- (void)_filterTableItemsForSearchString:(NSString *)searchString inScope:(NSInteger)scopeNumber reload:(BOOL)shouldReload
{
    BOOL isSearching = [self isSearching];
    
    BOOL isNothingChanged = ([searchString isEqualToString:self.currentSearchString]) &&
    (scopeNumber == self.currentSearchScope);
    
    if (!isNothingChanged || shouldReload)
    {
        self.currentSearchScope = scopeNumber;
        self.currentSearchString = searchString;
        
        if (isSearching && ![self isSearching])
        {
            [self storageNeedsReloadAnimated];
            [self tableControllerDidCancelSearch];
        }
        else if ([self.storage respondsToSelector:@selector(searchingStorageForSearchString:inSearchScope:)])
        {
            [self tableControllerWillBeginSearch];
            self.searchingStorage = [self.storage searchingStorageForSearchString:searchString
                                                                    inSearchScope:scopeNumber];
            [self storageNeedsReloadAnimated];
            [self tableControllerDidEndSearch];
        }
    }
}



#pragma  mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterTableItemsForSearchString:searchText];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self filterTableItemsForSearchString:searchBar.text inScope:selectedScope];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self filterTableItemsForSearchString:nil inScope:-1];
}

#pragma mark - ANStorageUpdate delegate methods

- (void)storageDidPerformUpdate:(ANStorageUpdate *)update
{
    BOOL isUpdateEmpty = [update isEmpty];
    if (update && ![update isEmpty])
    {
        if (self.shouldAnimateTableViewUpdates)
        {
            [self _performAnimatedUpdate:update];
        }
        else
        {
            ANDispatchBlockToMainQueue(^{
                [self storageNeedsReload];
            });
        }
        if ([self isSearching])
        {
            [self _filterTableItemsForSearchString:self.currentSearchString inScope:self.currentSearchScope reload:YES];
        }
    }
}

- (void)_performAnimatedUpdate:(ANStorageUpdate*)update
{
    if (!update.isProcessing)
    {
        update.isProcessing = YES;
        self.isAnimating = YES;
        ANDispatchBlockToMainQueue(^{
            
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                self.isAnimating = NO;
                [self tableControllerDidUpdateContent];
                update.isProcessing = NO;
            }];
            
            [self tableControllerWillUpdateContent];
            
            [self.tableView beginUpdates];

            [self.tableView insertSections:update.insertedSectionIndexes
                          withRowAnimation:self.insertSectionAnimation];
            
            [self.tableView deleteSections:update.deletedSectionIndexes
                          withRowAnimation:self.deleteSectionAnimation];
            
            [self.tableView reloadSections:update.updatedSectionIndexes
                          withRowAnimation:self.reloadSectionAnimation];
            
            [update.movedRowsIndexPaths enumerateObjectsUsingBlock:^(ANStorageMovedIndexPath* obj, NSUInteger idx, BOOL *stop) {
                
                if (![update.deletedSectionIndexes containsIndex:obj.fromIndexPath.section])
                {
                    [self.tableView moveRowAtIndexPath:obj.fromIndexPath toIndexPath:obj.toIndexPath];
                }
            }];
            
            [self.tableView insertRowsAtIndexPaths:update.insertedRowIndexPaths
                                  withRowAnimation:self.insertRowAnimation];
            
            [self.tableView deleteRowsAtIndexPaths:update.deletedRowIndexPaths
                                  withRowAnimation:self.deleteRowAnimation];
            
            [self.tableView reloadRowsAtIndexPaths:update.updatedRowIndexPaths
                                  withRowAnimation:self.reloadRowAnimation];
            
            [self.tableView endUpdates];
            [CATransaction commit];
        });
    }

}

- (void)storageNeedsReload
{
    ANDispatchBlockToMainQueue(^{
        [self.memoryStorage clearStorageUpdate];
        [self tableControllerWillUpdateContent];
        [self.tableView reloadData];
        [self tableControllerDidUpdateContent];
    });
}

- (void)storageNeedsReloadAnimated
{
    [self storageNeedsReload];
    
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFromBottom];
    [animation setSubtype:kCATransitionFromBottom];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFillMode:kCAFillModeBoth];
    [animation setDuration:kTableAnimationDuration];
    [self.tableView.layer addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
}

- (void)performAnimatedUpdate:(void (^)(UITableView *))animationBlock
{
    animationBlock(self.tableView);
}

#pragma mark - ANTableViewControllerEvents Protocol (Override)

- (void)tableControllerWillUpdateContent {}
- (void)tableControllerDidUpdateContent {}
//search
- (void)tableControllerWillBeginSearch
{
    self.storage.delegate = nil;
}
- (void)tableControllerDidEndSearch
{
    self.searchingStorage.delegate = self;
}
- (void)tableControllerDidCancelSearch
{
    self.searchingStorage.delegate = nil;
    self.storage.delegate = self;
}

#pragma mark - UITableView Class Registrations

- (void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass
{
    [self.cellFactory registerCellClass:cellClass forModelClass:modelClass];
}

- (void)registerHeaderClass:(Class)viewClass forModelClass:(Class)modelClass
{
    [self _registerSupplementaryClass:viewClass forModelClass:modelClass type:ANSupplementaryViewTypeHeader];
}

- (void)registerFooterClass:(Class)viewClass forModelClass:(Class)modelClass
{
    [self _registerSupplementaryClass:viewClass forModelClass:modelClass type:ANSupplementaryViewTypeFooter];
}

#pragma mark - UITableView Moving

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath
{
    SEL selector = @selector(moveItemFromIndexPath:toIndexPath:);
    if ([self.storage respondsToSelector:selector])
    {
        //Sorry ARC don't like this,
        //ref:http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.storage performSelector:selector withObject:fromIndexPath withObject:toIndexPath];
#pragma clang diagnostic pop
    }
}

#pragma mark - UITableView Protocols Implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.currentStorage sections].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* sections = [self.currentStorage sections];
    if (sections && sections.count > section)
    {
        id <ANSectionInterface> sectionModel = sections[section];
        return [sectionModel numberOfObjects];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id model = [self.currentStorage objectAtIndexPath:indexPath];;
    return [self.cellFactory cellForModel:model atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
