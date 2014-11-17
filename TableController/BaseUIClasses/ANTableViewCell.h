//
//  ANTableViewController.h
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "DTModelTransfer.h"

@interface ANTableViewCell : UITableViewCell <DTModelTransfer>

@property (nonatomic, assign) BOOL isTransparent;

@end
