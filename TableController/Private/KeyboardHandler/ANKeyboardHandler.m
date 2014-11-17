//
//  ANKeyboardHandler.m
//  CtrlDo
//
//  Created by Oksana Kovalchuk on 17/11/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANKeyboardHandler.h"

@interface ANKeyboardHandler ()

@property (nonatomic, weak) UIScrollView* target;

@end

@implementation ANKeyboardHandler

+ (instancetype)handlerWithTarget:(id)target
{
    NSAssert([target isKindOfClass:[UIScrollView class]], @"You can't handle keyboard on class %@\n It must me UIScrollView subclass", NSStringFromClass([target class]));
    
    ANKeyboardHandler* instance = [ANKeyboardHandler new];
    instance.target = target;
    
    return instance;
}

- (void)setupKeyboard
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.target addGestureRecognizer:tapRecognizer];
    tapRecognizer.cancelsTouchesInView = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    [self handleKeyboardWithNotification:aNotification visible:YES];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    [self handleKeyboardWithNotification:aNotification visible:NO];
}

- (void)handleKeyboardWithNotification:(NSNotification*)aNotification visible:(BOOL)isVisible
{
    NSDictionary* info = [aNotification userInfo];
    CGFloat kbHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    CGFloat duration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    kbHeight = isVisible ? kbHeight : -kbHeight;
    
    [UIView animateWithDuration:duration animations:^{
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.target.contentInset.top,
                                                      0.0,
                                                      self.target.contentInset.bottom + kbHeight,
                                                      0.0);
        self.target.contentInset = contentInsets;
        self.target.scrollIndicatorInsets = contentInsets;
    }];
}

- (void)hideKeyboard
{
    [self.target endEditing:YES];
}

@end
