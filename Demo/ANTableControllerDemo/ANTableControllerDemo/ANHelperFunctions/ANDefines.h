//
//  ANDefines.h
//
//  Created by Oksana Kovalchuk on 28/6/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#define SYSTEM_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue])

#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6     ([[UIScreen mainScreen] bounds].size.height == 667.f)
#define IS_IPHONE_6_PLUS     ([[UIScreen mainScreen] bounds].size.height == 736.f)

#define IS_IPHONE_5_OR_HIGHER ([[UIScreen mainScreen] bounds].size.height > 568.0f)

#define IS_RETINA ([UIScreen mainScreen].scale == 2)

#define IOS7            (7.0 <= SYSTEM_VERSION && SYSTEM_VERSION < 8.0)
#define IOS8            (8.0 => SYSTEM_VERSION)
#define IOS7_OR_HIGHER  (7.0 => SYSTEM_VERSION)

#pragma mark Callbacks

typedef void (^ANCodeBlock)(void);
typedef void (^ANCompletionBlock)(NSError *error);
typedef BOOL(^ANValidationBlock)();
