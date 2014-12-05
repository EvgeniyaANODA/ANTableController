//
//  ANTableViewController+UITableViewDelegatesPrivate.m
//
//  Created by Oksana Kovalchuk on 18/11/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANTableController+UITableViewDelegatesPrivate.h"
#import "ANTableController+Private.h"

@implementation ANTableController (UITableViewDelegatesPrivate)

#pragma mark - UITableView Protocols Implementation

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionNumber
{
    return [self _titleForSupplementaryIndex:sectionNumber type:ANSupplementaryViewTypeHeader];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)sectionNumber
{
    return [self _titleForSupplementaryIndex:sectionNumber type:ANSupplementaryViewTypeFooter];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionNumber
{
    return [self _supplementaryViewForIndex:sectionNumber type:ANSupplementaryViewTypeHeader];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)sectionNumber
{
    return [self _supplementaryViewForIndex:sectionNumber type:ANSupplementaryViewTypeFooter];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionNumber
{
    return [self _heightForSupplementaryIndex:sectionNumber type:ANSupplementaryViewTypeHeader];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)sectionNumber
{
    return [self _heightForSupplementaryIndex:sectionNumber type:ANSupplementaryViewTypeFooter];
}

@end
