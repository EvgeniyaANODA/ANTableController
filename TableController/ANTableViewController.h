//
//  ANTableViewController.h
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "DTModelTransfer.h"
#import "DTMemoryStorage+DTTableViewManagerAdditions.h"
#import "ANTableViewControllerEvents.h"
#import "ANTableViewFactory.h"

typedef NS_ENUM(NSUInteger,ANTableViewSectionStyle)
{
    ANTableViewSectionStyleTitle = 1,
    ANTableViewSectionStyleView
};

/**
 `DTTableViewController` manages all `UITableView` datasource methods and provides API for managing your data models in the table. 
*/

@interface ANTableViewController : NSObject
<   UITableViewDataSource,
    UITableViewDelegate,
    UISearchBarDelegate,
    ANTableViewControllerEvents
>

- (instancetype)initWithTableView:(UITableView*)tableView;

///---------------------------------------
/// @name Properties
///---------------------------------------

@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) BOOL isHandlingKeyboard; // default yes;

@property (nonatomic, retain) ANTableViewFactory * cellFactory;

@property (nonatomic, strong, readonly) id <DTStorageProtocol> currentStorage;

/**
 Table view that will present your data models. Delegate and dataSource properties are set automatically.
 */
@property (nonatomic, weak) UITableView * tableView;


/**
 Data storage object. Create storage you need and set this property to populate table view with data. `DTTableViewManager` provides two data storage classes - `DTMemoryStorage` and `DTCoreDataStorage`. `DTMemoryStorage` storage used by default.
 */
@property (nonatomic, strong) id <DTStorageProtocol> storage;

/**
 Convenience method, returning memory storage. If custom storage is used, this method will return nil.
 
 @return DTMemoryStorage instance.
 */
- (DTMemoryStorage *)memoryStorage;

/**
 Searching data storage object. It will be created automatically, responding to changes in UISearchBar, or after method filterTableItemsForSearchString:inScope: is called.
 */
@property (nonatomic, strong) id <DTStorageProtocol> searchingStorage;

/*
 Property to store UISearchBar, attached to your UITableView. Attaching it to this property is completely optional. Delegate for UISearchBar is set to instance of DTTableViewController automatically.
 */
@property (nonatomic, weak) UISearchBar* searchBar;

/**
 Style of section headers for table view. Depending on style, datasource methods will return title for section or view for section. Default is ANTableViewSectionStyleTitle.
 */
@property (nonatomic, assign) ANTableViewSectionStyle sectionHeaderStyle;

/**
 Style of section footers for table view. Depending on style, datasource methods will return title for section or view for section. Default is ANTableViewSectionStyleTitle.
 */
@property (nonatomic, assign) ANTableViewSectionStyle sectionFooterStyle;

/**
 Determines, whether header should be displayed, if section does not contain any items. Default value is YES.
 */
@property (nonatomic, assign) BOOL displayHeaderOnEmptySection;

/**
 Determines, whether footer should be displayed, if section does not contain any items. Default value is YES.
 */
@property (nonatomic, assign) BOOL displayFooterOnEmptySection;

/**
 Animation, used for inserting sections. Default - UITableViewRowAnimationNone.
 */

@property (nonatomic, assign) UITableViewRowAnimation insertSectionAnimation;

/**
 Animation, used for deleting sections. Default - UITableViewRowAnimationAutomatic.
 */

@property (nonatomic, assign) UITableViewRowAnimation deleteSectionAnimation;

/**
 Animation, used for reloading sections. Default - UITableViewRowAnimationAutomatic.
 */
@property (nonatomic, assign) UITableViewRowAnimation reloadSectionAnimation;

/**
 Animation, used for inserting table view rows. Default - UITableViewRowAnimationAutomatic.
 */
@property (nonatomic, assign) UITableViewRowAnimation insertRowAnimation;

/**
 Animation, used for deleting table view rows. Default - UITableViewRowAnimationAutomatic.
 */
@property (nonatomic, assign) UITableViewRowAnimation deleteRowAnimation;

/**
 Animation, used for reloading table view rows. Default - UITableViewRowAnimationAutomatic.
 */
@property (nonatomic, assign) UITableViewRowAnimation reloadRowAnimation;

///---------------------------------------
/// @name Mapping
///---------------------------------------

/**
 Register mapping from model class to custom cell class. Method will automatically check for nib with the same name as `cellClass`. If it exists - nib will be registered instead of class.
 
 @param cellClass Class of the cell you want to be created for model with modelClass.
 
 @param modelClass Class of the model you want to be mapped to cellClass.
 
 @discussion This is the designated mapping method. Best place to call it - in viewDidLoad method.
 
 */
-(void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass;


/**
 Register nib with `headerClass` name. `headerClass` should be a UIView subclass, conforming to `DTModelTransfer` protocol. It can also be a subclass of `UITableViewHeaderFooterView`. Calling this method automatically sets headerStyle property to ANTableViewSectionStyleView.
 
 @param headerClass headerClass to be mapped for `modelClass`
 
 @param modelClass modelClass to be mapped to `headerClass`
 */

-(void)registerHeaderClass:(Class)headerClass forModelClass:(Class)modelClass;

/**
 Register nib with `footerClass` name. `footerClass` should be a UIView subclass, conforming to `DTModelTransfer` protocol. It can also be a subclass of `UITableViewHeaderFooterView`. Calling this method automatically sets footerStyle property to ANTableViewSectionStyleView.
 
 @param footerClass footerClass to be mapped for `modelClass`
 
 @param modelClass modelClass to be mapped to `footerClass`
 */

-(void)registerFooterClass:(Class)footerClass forModelClass:(Class)modelClass;



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

/**
 Perform animations you need for changes in UITableView. Method can be used for complex animations, that should be run simultaneously. For example, `DTTableViewManagerAdditions` category on `DTMemoryStorage` uses it to implement moving items between indexPaths.
 
 @param animationBlock AnimationBlock to be executed with UITableView.
 
 @warning You need to update data storage object before executing this method.
 */
- (void)performAnimatedUpdate:(void (^)(UITableView *))animationBlock;


@end
