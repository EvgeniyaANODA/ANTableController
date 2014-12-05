//
//  ANTableViewController+UITableViewDelegatesPrivate.h
//
//  Created by Oksana Kovalchuk on 18/11/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

@protocol ANTableViewControllerEvents <NSObject>

@optional

// updating content

- (void)tableControllerWillUpdateContent;
- (void)tableControllerDidUpdateContent;

// searching

- (void)tableControllerWillBeginSearch;
- (void)tableControllerDidEndSearch;
- (void)tableControllerDidCancelSearch;

@end
