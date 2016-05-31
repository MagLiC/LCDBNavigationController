//
//  LCDBNavigationController.h
//  LCDBNavigationController
//
//  Created by Lichao on 16/5/23.
//  Copyright © 2016年 Lichao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCDBNavigationController : UINavigationController

@end

@interface UIViewController (LCViewController)
/**
 *  如果leftToRightEnabled为NO，则禁止从左到右的手势，默认是YES.
 */
@property (assign, nonatomic, getter=isLeftToRightEnabled)BOOL leftToRightEnabled;
/**
 *  如果leftToRightEnabled为NO，则禁止从上到下的手势，默认是YES.
 */
@property (assign, nonatomic, getter=isTopToBottomEnabled)BOOL topToBottomEnabled;
/**
 *  在栈的第二个控制器里把hidesBottomBarWhenPushed设为YES，则隐藏tabbarController.
 */
@property (assign, nonatomic, getter=isHidesBottomBarWhenPushed)BOOL hidesBottomBarWhenPushed;

@end
