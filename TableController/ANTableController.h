//
//  ANTableViewController.h
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANModelTransfer.h"
#import "ANMemoryStorage+ANTableViewController.h"
#import "ANTableControllerEvents.h"
#import "ANTableViewFactory.h"

@class ANKeyboardHandler;

typedef NS_ENUM(NSUInteger,ANTableViewSectionStyle)
{
    ANTableViewSectionStyleTitle = 1,
    ANTableViewSectionStyleView
};

@interface ANTableController : NSObject
<
UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate,
ANTableViewControllerEvents
>

@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) BOOL isHandlingKeyboard; // default yes;
@property (nonatomic, retain) ANTableViewFactory * cellFactory;
@property (nonatomic, strong, readonly) id <ANStorageInterface> currentStorage;

@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, strong) UISearchBar* searchBar;

@property (nonatomic, strong) ANKeyboardHandler* keyboardHandler;

#pragma mark - Storages

@property (nonatomic, strong) id <ANStorageInterface> storage;
@property (nonatomic, strong) id <ANStorageInterface> searchingStorage;

- (ANMemoryStorage *)memoryStorage;

#pragma mark - View's related

@property (nonatomic, assign) ANTableViewSectionStyle sectionHeaderStyle;
@property (nonatomic, assign) ANTableViewSectionStyle sectionFooterStyle;
@property (nonatomic, assign) BOOL displayHeaderOnEmptySection;
@property (nonatomic, assign) BOOL displayFooterOnEmptySection;

@property (nonatomic, assign) UITableViewRowAnimation insertSectionAnimation;
@property (nonatomic, assign) UITableViewRowAnimation deleteSectionAnimation;
@property (nonatomic, assign) UITableViewRowAnimation reloadSectionAnimation;
@property (nonatomic, assign) UITableViewRowAnimation insertRowAnimation;
@property (nonatomic, assign) UITableViewRowAnimation deleteRowAnimation;
@property (nonatomic, assign) UITableViewRowAnimation reloadRowAnimation;

@property (nonatomic, assign) BOOL shouldAnimateTableViewUpdates; // default is YES


- (instancetype)initWithTableView:(UITableView*)tableView;

#pragma mark - Mapping

- (void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass;
- (void)registerHeaderClass:(Class)headerClass forModelClass:(Class)modelClass;
- (void)registerFooterClass:(Class)footerClass forModelClass:(Class)modelClass;

/**
 Perform animations you need for changes in UITableView. Method can be used for complex animations, that should be run simultaneously. For example, `DTTableViewManagerAdditions` category on `ANMemoryStorage` uses it to implement moving items between indexPaths.
 
 @param animationBlock AnimationBlock to be executed with UITableView.
 
 @warning You need to update data storage object before executing this method.
 */
- (void)performAnimatedUpdate:(void (^)(UITableView *))animationBlock;


///---------------------------------------
/// @name Search
///---------------------------------------

/**
 Filter presented table items, using searchString as a criteria. Current storage is queried with `searchingStorageForSearchString:inSearchScope:` method. If searchString is not empty, UITableViewDataSource is assigned to searchingStorage and table view is reloaded automatically.
 
 @param searchString Search string used as a criteria for filtering.
 */
-(void)filterTableItemsForSearchString:(NSString *)searchString;

/**
 Filter presented table items, using searchString as a criteria. Current storage is queried with `searchingStorageForSearchString:inSearchScope:` method. If searchString or scopeNUmber is not empty, UITableViewDataSource is assigned to searchingStorage and table view is reloaded automatically.
 
 @param searchString Search string used as a criteria for filtering.
 
 @param scopeNumber Scope number of UISearchBar
 */
-(void)filterTableItemsForSearchString:(NSString *)searchString
                               inScope:(NSInteger)scopeNumber;

/**
 Returns whether search is active, based on current searchString and searchScope, retrieved from UISearchBarDelegate methods.
 */

-(BOOL)isSearching NS_REQUIRES_SUPER;


@end
