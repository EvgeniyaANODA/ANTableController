//
//  ANTableViewControllerHeader.h
//
//  Created by Oksana Kovalchuk on 18/11/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#ifdef AN_TABLE_LOG
#    define ANLog(...) NSLog(__VA_ARGS__)
#else
#    define ANLog(...) /* */
#endif
#define ALog(...) NSLog(__VA_ARGS__)

typedef void (^ANCodeBlock)(void);
