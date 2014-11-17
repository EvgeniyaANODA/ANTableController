//
//  DTTableViewHeaderFooterView.m
//  CtrlDo
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "DTTableViewHeaderFooterView.h"

@implementation DTTableViewHeaderFooterView

-(void)updateWithModel:(id)model
{
    NSString * reason = [NSString stringWithFormat:@"view %@ should implement updateWithModel: method\n",
                         NSStringFromClass([self class])];
    NSException * exc =
    [NSException exceptionWithName:@"DTTableViewController API exception"
                            reason:reason
                          userInfo:nil];
    [exc raise];
}

-(id)model
{
    return nil;
}

@end
