//
//  ANTableViewController+Private.h
//
//  Created by Oksana Kovalchuk on 17/11/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANTableController.h"

@interface ANTableController (Private)

- (ANTableViewSectionStyle)_sectionStyleByType:(ANSupplementaryViewType)type;

//tableView delegate helpers
- (NSString *)_titleForSupplementaryIndex:(NSInteger)index type:(ANSupplementaryViewType)type;
- (void)_registerSupplementaryClass:(Class)viewClass forModelClass:(Class)modelClass type:(ANSupplementaryViewType)type;
- (UIView*)_supplementaryViewForIndex:(NSInteger)index type:(ANSupplementaryViewType)type;
- (id)_supplementaryModelForIndex:(NSInteger)index type:(ANSupplementaryViewType)type;
- (CGFloat)_heightForSupplementaryIndex:(NSInteger)index type:(ANSupplementaryViewType)type;

//storage

- (void)_attachStorage:(id<ANStorageInterface>)storage;

@end
