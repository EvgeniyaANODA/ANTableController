//
//  ANTableViewController.m
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANTableController.h"
#import "DTMemoryStorage+DTTableViewManagerAdditions.h"
#import "ANStorageMovedIndexPath.h"
#import "ANKeyboardHandler.h"
#import "ANTableController+Private.h"
#import "ANTableController+UITableViewDelegatesPrivate.h"
#import "ANHelperFunctions.h"

@interface ANTableController ()
<
    DTStorageUpdating,
    ANTableViewFactoryDelegate
>

@property (nonatomic, assign) NSInteger currentSearchScope;
@property (nonatomic, copy) NSString * currentSearchString;
@property (nonatomic, strong) ANKeyboardHandler* keyboardHandler;

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
        self.searchBar.delegate = self; //TODO:
        self.isHandlingKeyboard = YES;
        
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

- (DTMemoryStorage *)memoryStorage
{
    if ([self.storage isKindOfClass:[DTMemoryStorage class]])
    {
        return (DTMemoryStorage *)self.storage;
    }
    return nil;
}

-(id<DTStorageProtocol>)storage
{
    if (!_storage)
    {
        _storage = [DTMemoryStorage storage];
        [self _attachStorage:_storage];
        [self storageNeedsReload]; // handling one-section table setup
    }
    return _storage;
}

- (void)setStorage:(id <DTStorageProtocol>)storage
{
    _storage = storage;
    [self _attachStorage:_storage];
    [self storageNeedsReload];
}

- (void)setSearchingStorage:(id <DTStorageProtocol>)searchingStorage
{
    _searchingStorage = searchingStorage;
    [self _attachStorage:searchingStorage];
}

- (id<DTStorageProtocol>)currentStorage
{
    return [self isSearching] ? self.searchingStorage : self.storage;
}

#pragma mark - search

- (BOOL)isSearching
{
    BOOL isSearchStringEmpty = (self.currentSearchString && (self.currentSearchString.length != 0));
    BOOL isSearching = (isSearchStringEmpty ||self.currentSearchScope > -1);

    return isSearching;
}

- (void)filterTableItemsForSearchString:(NSString *)searchString
{
    [self filterTableItemsForSearchString:searchString inScope:-1];
}

- (void)filterTableItemsForSearchString:(NSString *)searchString inScope:(NSInteger)scopeNumber
{
    BOOL isSearching = [self isSearching];

    BOOL isNothingChanged = ([searchString isEqualToString:self.currentSearchString]) ||
                          (scopeNumber == self.currentSearchScope); //TODO: this seems uncorrect not a || but &&
    
    if (!isNothingChanged)
    {
        self.currentSearchScope = scopeNumber;
        self.currentSearchString = searchString;
        
        if (isSearching && ![self isSearching])
        {
            [self storageNeedsReload];
            [self tableControllerDidCancelSearch];
        }
        else if ([self.storage respondsToSelector:@selector(searchingStorageForSearchString:inSearchScope:)])
        {
            [self tableControllerWillBeginSearch];
            self.searchingStorage = [self.storage searchingStorageForSearchString:searchString
                                                                    inSearchScope:scopeNumber];
            [self storageNeedsReload];
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

#pragma mark - DTStorageUpdate delegate methods

- (void)storageDidPerformUpdate:(DTStorageUpdate *)update
{
    if (!update)
    {
        return;
    }
    self.isAnimating = YES;
    
    ANDispatchBlockToMainQueue(^{
       
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
        
                self.isAnimating = NO;
                [self tableControllerDidUpdateContent];
            }];
        
        [self tableControllerWillUpdateContent];
        
        [self.tableView beginUpdates];
        
        [self.tableView deleteSections:update.deletedSectionIndexes
                      withRowAnimation:self.deleteSectionAnimation];
        [self.tableView insertSections:update.insertedSectionIndexes
                      withRowAnimation:self.insertSectionAnimation];
        [self.tableView reloadSections:update.updatedSectionIndexes
                      withRowAnimation:self.reloadSectionAnimation];
        
        [update.movedRowsIndexPaths enumerateObjectsUsingBlock:^(ANStorageMovedIndexPath* obj, NSUInteger idx, BOOL *stop) {
            
            if (![update.deletedSectionIndexes containsIndex:obj.fromIndexPath.section])
            {
                [self.tableView moveRowAtIndexPath:obj.fromIndexPath toIndexPath:obj.toIndexPath];
            }
        }];
        
        [self.tableView deleteRowsAtIndexPaths:update.deletedRowIndexPaths
                              withRowAnimation:self.deleteRowAnimation];
        [self.tableView insertRowsAtIndexPaths:update.insertedRowIndexPaths
                              withRowAnimation:self.insertRowAnimation];
        [self.tableView reloadRowsAtIndexPaths:update.updatedRowIndexPaths
                              withRowAnimation:self.reloadRowAnimation];
        
        [self.tableView endUpdates];
        
        [CATransaction commit];
    });
}

- (void)storageNeedsReload
{
    ANDispatchBlockToMainQueue(^{
    
        [self tableControllerWillUpdateContent];
        [self.tableView reloadData];
        [self tableControllerDidUpdateContent];
    });
}

- (void)performAnimatedUpdate:(void (^)(UITableView *))animationBlock
{
    animationBlock(self.tableView);
}

#pragma mark - ANTableViewControllerEvents Protocol (Override)

- (void)tableControllerWillUpdateContent {}
- (void)tableControllerDidUpdateContent {}
//search
- (void)tableControllerWillBeginSearch {}
- (void)tableControllerDidEndSearch {}
- (void)tableControllerDidCancelSearch {}

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
    id <DTSection> sectionModel = [self.currentStorage sections][section];
    return [sectionModel numberOfObjects];
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
