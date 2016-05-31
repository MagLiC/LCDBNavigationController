//
//  LCNavigationBarDelegate.h
//  LCDBNavigationController
//
//  Created by Lichao on 16/5/23.
//  Copyright © 2016年 Lichao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LCDBNavigationController;

@protocol LCNavigationBarDelegate <NSObject>

/**
 *  如果想要使用UIBackBarItem的时候来显示pop动画，则必须要实现该协议并return YES。
 */
- (BOOL)lc_navigaitionControllerShouldAnimationShowWhenBackBarItemBeSelected;

@end
