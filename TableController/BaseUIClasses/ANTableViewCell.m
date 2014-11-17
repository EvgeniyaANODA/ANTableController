//
//  ANTableViewController.h
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANTableViewCell.h"
#import "DTRuntimeHelper.h"

@implementation ANTableViewCell

- (void)updateWithModel:(id)model
{
    NSString * reason = [NSString stringWithFormat:@"cell %@ should implement %@: method\n",
                         NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
    NSException * exc =
    [NSException exceptionWithName:@"ANTableViewController API exception"
                            reason:reason
                          userInfo:nil];
    [exc raise];
}

- (id)model
{
    return nil;
}

- (void)setIsTransparent:(BOOL)isTransparent
{
    if (isTransparent)
    {
        self.backgroundView = [UIView new];
    }
    _isTransparent = isTransparent;
}

@end
