//
//  UIScrollView+AvoidConflict.m
//  LCDBNavigationController
//
//  Created by Lichao on 16/5/31.
//  Copyright © 2016年 Lichao. All rights reserved.
//

#import "UIScrollView+AvoidConflict.h"
#import "LCDBNavigationController.h"

@implementation UIScrollView (AvoidConflict)

//防止UIScrollView的交互与返回手势的交互冲突
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self viewController].topToBottomEnabled) {
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
            CGPoint transition = [pan translationInView:self];
            //修改self.contentOffset.y的值来修改tableView响应手势的位置
            if (self.contentOffset.y <= -64 && transition.y>0) {
                return NO;
            }
        }
    }
    return YES;
}

- (UIViewController *)viewController {
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]))
        if ([responder isKindOfClass: [UIViewController class]])
            return (UIViewController *)responder;
    return nil;
}

@end
