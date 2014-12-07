//
//  ANTableViewFactory.h
//
//  Created by Oksana Kovalchuk on 17/11/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

@protocol ANTableViewFactoryDelegate

- (UITableView *)tableView;

@end

typedef NS_ENUM(NSInteger, ANSupplementaryViewType)
{
    ANSupplementaryViewTypeNone,
    ANSupplementaryViewTypeHeader,
    ANSupplementaryViewTypeFooter
};

@interface ANTableViewFactory : NSObject

- (void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass;

- (void)registerSupplementayClass:(Class)supplementaryClass
                    forModelClass:(Class)modelClass
                             type:(ANSupplementaryViewType)type;

- (UITableViewCell *)cellForModel:(id)model atIndexPath:(NSIndexPath *)indexPath;
- (UIView *)supplementaryViewForModel:(id)model type:(ANSupplementaryViewType)type;

@property (nonatomic, weak) id <ANTableViewFactoryDelegate> delegate;

@end
