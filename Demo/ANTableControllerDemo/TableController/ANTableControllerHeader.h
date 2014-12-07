//
//  ANTableViewControllerHeader.h
//  CtrlDo
//
//  Created by Oksana Kovalchuk on 18/11/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//


//#ifndef ANTableViewControllerHeader_h
//#define ANTableViewControllerHeader_h

#ifdef AN_TABLE_LOG
#    define ANLog(...) NSLog(__VA_ARGS__)
#else
#    define ANLog(...) /* */
#endif
#define ALog(...) NSLog(__VA_ARGS__)


typedef void (^ANCodeBlock)(void);
typedef BOOL (^DTModelSearchingBlock)(id model, NSString * searchString, NSInteger searchScope, DTSectionModel * section);

//#endif
