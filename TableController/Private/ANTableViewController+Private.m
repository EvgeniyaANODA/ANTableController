//
//  ANTableViewController+Private.m
//
//  Created by Oksana Kovalchuk on 17/11/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANTableViewController+Private.h"

@implementation ANTableViewController (Private)

#pragma mark - Storage

- (void)_attachStorage:(id<DTStorageProtocol>)storage
{
    storage.delegate = (id<DTStorageUpdating>)self;
    [storage setSupplementaryHeaderKind:DTTableViewElementSectionHeader];
    [storage setSupplementaryFooterKind:DTTableViewElementSectionFooter];
}

#pragma mark - UITableView Delegate Helpers

- (ANTableViewSectionStyle)_sectionStyleByType:(ANSupplementaryViewType)type
{
    NSParameterAssert(type == ANSupplementaryViewTypeNone);
    BOOL isHeader = (type == ANSupplementaryViewTypeHeader);
    return isHeader ? self.sectionHeaderStyle : self.sectionFooterStyle;
}


- (NSString *)_titleForSupplementaryIndex:(NSInteger)index type:(ANSupplementaryViewType)type
{
    if (self.sectionHeaderStyle == ANTableViewSectionStyleTitle)
    {
        return [self _supplementaryModelForIndex:index type:ANSupplementaryViewTypeFooter];
    }
    return nil;
}

- (void)_registerSupplementaryClass:(Class)viewClass forModelClass:(Class)modelClass type:(ANSupplementaryViewType)type
{
    NSParameterAssert(viewClass);
    NSParameterAssert(modelClass);
    self.sectionFooterStyle = ANTableViewSectionStyleView;
    [self.cellFactory registerSupplementayClass:viewClass forModelClass:modelClass type:ANSupplementaryViewTypeFooter];
}

- (UIView*)_supplementaryViewForIndex:(NSInteger)index type:(ANSupplementaryViewType)type
{
    id model = [self _supplementaryModelForIndex:index type:ANSupplementaryViewTypeHeader];
    BOOL isViewStyle = (self.sectionHeaderStyle == ANTableViewSectionStyleView);
    if (isViewStyle && model)
    {
        return [self.cellFactory supplementaryViewForModel:model type:type];
    }
    
    return nil;
}

- (id)_supplementaryModelForIndex:(NSInteger)index type:(ANSupplementaryViewType)type
{
    if ([self.currentStorage.sections[index] numberOfObjects] || self.displayHeaderOnEmptySection)
    {
        if ([self.searchingStorage respondsToSelector:@selector(headerModelForSectionIndex:)])
        {
            if (ANSupplementaryViewTypeHeader)
            {
                return [self.currentStorage headerModelForSectionIndex:index];
            }
            else if (ANSupplementaryViewTypeFooter)
            {
                return [self.currentStorage footerModelForSectionIndex:index];
            }
        }
    }
    return nil;
}

- (CGFloat)_heightForSupplementaryIndex:(NSInteger)index type:(ANSupplementaryViewType)type
{
    //apple bug HACK: for plain tables, for bottom section separator visibility
    BOOL shouldMaskSeparator = ((self.tableView.style == UITableViewStylePlain) &&
                                (type == ANSupplementaryViewTypeFooter));
    
    CGFloat minHeight = shouldMaskSeparator ? 0.1 : CGFLOAT_MIN;
    // Default table view section footer titles, size defined by UILabel sizeToFit method
    
    id model = [self _supplementaryModelForIndex:index type:type];
    if (model)
    {
        BOOL isTitleStyle = ([self _sectionStyleByType:type] == ANTableViewSectionStyleTitle);
        if (isTitleStyle)
        {
            return UITableViewAutomaticDimension;
        }
        else
        {
            BOOL isHeader = (type == ANSupplementaryViewTypeHeader);
            return isHeader ? self.tableView.sectionHeaderHeight : self.tableView.sectionFooterHeight;
        }
    }
    else
    {
        return minHeight;
    }
}

@end
