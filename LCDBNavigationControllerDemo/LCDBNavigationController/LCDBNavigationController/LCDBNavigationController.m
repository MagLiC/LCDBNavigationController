//
//  LCDBNavigationController.m
//  LCDBNavigationController
//
//  Created by Lichao on 16/5/23.
//  Copyright © 2016年 Lichao. All rights reserved.
//

#import "LCDBNavigationController.h"
#import "LCNavigationBarDelegate.h"
#import <objc/runtime.h>

@interface UINavigationController (UINavigationControllerShouldPopItem)

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(nonnull UINavigationItem *)item;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation UINavigationController (UINavigationControllerShouldPopItem)
@end
#pragma clang diagnostic pop

/**
 *  手势结束后页面返回原样的动画的持续时间
 */
static const NSTimeInterval animationTimeInterval = 0.1;
/**
 *  手势滑动结束后判断是否需要切换的比例(越大需要手势滑动的越多)
 */
static const CGFloat panLimitScale = 0.4;
/**
 *  pop返回的动画时间
 */
static const NSTimeInterval popAnimationTimeInterval = 0.4;
/**
 *  navigation切换动画
 */
typedef NS_ENUM(NSUInteger, navigationControllerWayToPop) {
    /**
     *  从上到下切换navigation
     */
    LCNavWayFromTopToBottom,
    /**
     *  从左到右切换navigation
     */
    LCNavWayFromLeftToRight,
};

@interface LCDBNavigationController ()<UINavigationBarDelegate ,UIGestureRecognizerDelegate>
/**
 *  切换时上个界面的截屏
 */
@property (strong, nonatomic)UIView *backView;
/**
 *  半透明黑色遮罩
 */
@property (strong, nonatomic)UIView *blackView;
/**
 *  存储截图的字典
 */
@property (strong, nonatomic)NSMutableDictionary *backImageDic;
@property (strong, nonatomic)UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic)UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer;
@property (assign, nonatomic)navigationControllerWayToPop wayToPop;

@end

@implementation LCDBNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.enabled = NO;
}

- (NSMutableDictionary *)backImageDic
{
    if (!_backImageDic) {
        _backImageDic = [NSMutableDictionary dictionary];
    }
    return _backImageDic;
}

- (UIView *)blackView
{
    if (!_blackView) {
        _blackView = [[UIView alloc]init];
        _blackView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    }
    return _blackView;
}

- (UIPanGestureRecognizer *)panGestureRecognizer
{
    if (!_panGestureRecognizer) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureRecognizerTouch:)];
        _panGestureRecognizer.delegate = self;
        [_panGestureRecognizer delaysTouchesBegan];

        [self.view addGestureRecognizer:_panGestureRecognizer];
    }
    return _panGestureRecognizer;
}

- (UIScreenEdgePanGestureRecognizer *)screenEdgePanGestureRecognizer
{
    if (!_screenEdgePanGestureRecognizer) {
        _screenEdgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(screenEdgePanGestureRecognizerTouch:)];
        [_screenEdgePanGestureRecognizer delaysTouchesBegan];
        _screenEdgePanGestureRecognizer.delegate = self;
        _screenEdgePanGestureRecognizer.edges = UIRectEdgeLeft;
        [self.view addGestureRecognizer:_screenEdgePanGestureRecognizer];
    }
    return _screenEdgePanGestureRecognizer;
}

//得到OC对象的指针字符串
- (NSString *)stringOfPointer:(id)objet {
    return [NSString stringWithFormat:@"%p", objet];
}

//截图
- (UIImage *)capture:(UIView *)view {
    CGSize size = view.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.frame afterScreenUpdates:NO];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGSize size2 = view.frame.size;
    if (fabs(size.height - size2.height) > 0.0001 || fabs(size.width - size2.width) > 0.0001) {
        UIGraphicsBeginImageContextWithOptions(size2, NO, [UIScreen mainScreen].scale);
        [view drawViewHierarchyInRect:view.frame afterScreenUpdates:YES];
        snap = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return snap;
}

//上一个控制器的截图
- (UIView *)lastViewControllerBackImageView
{
    NSInteger index = self.viewControllers.count - 2;
    if (index < 0) {
        index = 0;
    }
    UIViewController *vc = self.viewControllers[index];
    UIView *view = [self.backImageDic valueForKey:[self stringOfPointer:vc]];
    return view;
}

//显示截图
- (void)backImageShowWithView:(UIView *)imageView
{
    if (self.wayToPop == LCNavWayFromTopToBottom) {
        UIView *superView = self.view.superview;
        imageView.frame = self.view.frame;

        self.blackView.frame = imageView.frame;
        [imageView addSubview:self.blackView];
        [superView addSubview:imageView];
        
        [superView insertSubview:imageView belowSubview:self.view];
    } else if (self.wayToPop == LCNavWayFromLeftToRight) {
        [self.blackView removeFromSuperview];
        UIView *superView = self.view.superview;
        self.backView = imageView;
        imageView.frame = CGRectMake(- imageView.frame.size.width / 2, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
        [superView addSubview:imageView];
        [superView insertSubview:imageView belowSubview:self.view];
    }
}

//隐藏截图并将截图从字典里删除
- (void)backImageHideAndDelete:(UIView *)imageView andDicKeys:(NSArray *)keys
{
    [imageView removeFromSuperview];
    NSMutableArray *mKeys = [keys mutableCopy];
    [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        mKeys[idx] = [self stringOfPointer:obj];
    }];
    [self.backImageDic removeObjectsForKeys:mKeys];
}

#pragma mark UINavigationBarDelegate
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    UIViewController *vc = self.topViewController;
    if (item != vc.navigationItem) {
        return [super navigationBar:navigationBar shouldPopItem:item];
    }
    
    if ([vc conformsToProtocol:@protocol(LCNavigationBarDelegate)]) {
        if (![(id<LCNavigationBarDelegate>)vc lc_navigaitionControllerShouldAnimationShowWhenBackBarItemBeSelected]) {
            return [super navigationBar:navigationBar shouldPopItem:item];
        }else {
            [self backImageShowWithView:[self lastViewControllerBackImageView]];
            
            CGPoint selfViewPoint = self.view.frame.origin;
            [self animationWhenPopWithView:[self lastViewControllerBackImageView] Completion:^(BOOL finished) {
                self.view.frame = CGRectMake(selfViewPoint.x, selfViewPoint.y, self.view.frame.size.width, self.view.frame.size.height);
                UIViewController *popVC = [self popViewControllerAnimated:NO];
                [self backImageHideAndDelete:[self lastViewControllerBackImageView] andDicKeys:@[popVC]];
            }];
            return NO;
        }
    } else {
        return [super navigationBar:navigationBar shouldPopItem:item];
    }
}

#pragma mark push与pop方法
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIImage *nowImage = [self capture:self.tabBarController ? self.tabBarController.view: self.view];
    UIImageView *backImageView = [[UIImageView alloc]initWithImage:nowImage];
    [self.backImageDic setValue:backImageView forKey:[self stringOfPointer:self.topViewController]];
    
    [self screenEdgePanGestureRecognizer];
    [self panGestureRecognizer];
    
    [super pushViewController:viewController animated:animated];
}

- (nullable UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if (animated) {
        [self backImageShowWithView:[self lastViewControllerBackImageView]];
        CGPoint selfViewPoint = self.view.frame.origin;
        [self animationWhenPopWithView:[self lastViewControllerBackImageView] Completion:^(BOOL finished) {
            self.view.frame = CGRectMake(selfViewPoint.x, selfViewPoint.y, self.view.frame.size.width, self.view.frame.size.height);
            UIViewController *vc = [super popViewControllerAnimated:NO];
            [self backImageHideAndDelete:[self lastViewControllerBackImageView] andDicKeys:@[vc]];
        }];
    } else {
        return [super popViewControllerAnimated:NO];
    }
    return nil;
}

- (nullable NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (animated) {
        UIView *view = [self.backImageDic valueForKey:[self stringOfPointer:viewController]];
        [self backImageShowWithView:view];
        CGPoint selfViewPoint = self.view.frame.origin;
        [self animationWhenPopWithView:view Completion:^(BOOL finished) {
            self.view.frame = CGRectMake(selfViewPoint.x, selfViewPoint.y, self.view.frame.size.width, self.view.frame.size.height);
            NSArray *vcs = [super popToViewController:viewController animated:NO]; ;
            [self backImageHideAndDelete:view andDicKeys:vcs];
        }];
        
    } else {
        return [super popToViewController:viewController animated:NO];
    }
    return nil;
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
    if (animated && self.viewControllers.count != 1) {
        UIView *view = [self.backImageDic valueForKey:[self stringOfPointer:self.viewControllers[0]]];
        [self backImageShowWithView:view];
        CGPoint selfViewPoint = self.view.frame.origin;
        [self animationWhenPopWithView:view Completion:^(BOOL finished) {
            self.view.frame = CGRectMake(selfViewPoint.x, selfViewPoint.y, self.view.frame.size.width, self.view.frame.size.height);
            NSArray *vcs = [super popToRootViewControllerAnimated:NO];
            [self backImageHideAndDelete:view andDicKeys:vcs];
        }];
    } else {
        return [super popToRootViewControllerAnimated:NO];
    }
    return nil;
}

//pan手势响应方法
- (void)panGestureRecognizerTouch:(UIPanGestureRecognizer *)sender
{
    UIView *view = [self lastViewControllerBackImageView];
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.wayToPop = LCNavWayFromTopToBottom;
        [self backImageShowWithView:view];
    }else if (sender.state == UIGestureRecognizerStateChanged) {
        [self animationChangedWhenGestureRecoginizerTouch:sender];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.view.frame.origin.y < self.view.frame.size.height * panLimitScale) {
            [UIView animateWithDuration:animationTimeInterval animations:^{
                self.view.frame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
            } completion:^(BOOL finished) {
                [self backImageHideAndDelete:view andDicKeys:@[]];
            }];
        } else {
            [UIView animateWithDuration:animationTimeInterval animations:^{
                self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
            } completion:^(BOOL finished) {
                UIViewController *vc = [self popViewControllerAnimated:NO];
                [self backImageHideAndDelete:view andDicKeys:@[vc]];
                self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            }];
        }
    }
}

//screenEdge手势响应方法
- (void)screenEdgePanGestureRecognizerTouch:(UIScreenEdgePanGestureRecognizer *)sender
{
    UIView *view = [self lastViewControllerBackImageView];
    CGPoint selfViewPoint;
    if (sender.state == UIGestureRecognizerStateBegan) {
        selfViewPoint = self.view.frame.origin;
        self.wayToPop = LCNavWayFromLeftToRight;
        [self backImageShowWithView:view];
        
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        [self animationChangedWhenGestureRecoginizerTouch:sender];
        
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.view.frame.origin.x < self.view.frame.size.width * panLimitScale) {
            [UIView animateWithDuration:animationTimeInterval animations:^{
                self.view.frame = CGRectMake(selfViewPoint.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
                self.backView.frame = CGRectMake(- self.backView.frame.size.width / 2 + self.view.frame.origin.x / 2 , self.backView.frame.origin.y, self.backView.frame.size.width, self.backView.frame.size.height);
            } completion:^(BOOL finished) {
                [self backImageHideAndDelete:view andDicKeys:@[]];
            }];
        } else {
            [UIView animateWithDuration:animationTimeInterval animations:^{
                self.view.frame = CGRectMake(self.view.frame.size.width, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
                self.backView.frame = CGRectMake(- self.backView.frame.size.width / 2 + self.view.frame.origin.x / 2 , self.backView.frame.origin.y, self.backView.frame.size.width, self.backView.frame.size.height);
            } completion:^(BOOL finished) {
                UIViewController *vc = [self popViewControllerAnimated:NO];
                [self backImageHideAndDelete:view andDicKeys:@[vc]];
                self.view.frame = CGRectMake(selfViewPoint.x, selfViewPoint.y, self.view.frame.size.width, self.view.frame.size.height);
            }];
        }
    }
}

//防止2手势互相影响--核心代码
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

    if (self.screenEdgePanGestureRecognizer == gestureRecognizer) {
        [self.panGestureRecognizer requireGestureRecognizerToFail:self.screenEdgePanGestureRecognizer];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == self.panGestureRecognizer) {
        return self.viewControllers.count == 1 ? NO : self.topViewController.topToBottomEnabled;
    }
    if (gestureRecognizer == self.screenEdgePanGestureRecognizer) {
        return self.viewControllers.count == 1 ? NO : self.topViewController.leftToRightEnabled;
    }
    return YES;
}

//手势移动时的动画
- (void)animationChangedWhenGestureRecoginizerTouch:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.wayToPop == LCNavWayFromTopToBottom) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint movePoint = [pan translationInView:self.view];
        CGPoint newPoint = CGPointMake(self.view.frame.origin.x, self.view.frame.origin.y + movePoint.y);
        newPoint.y = MAX(newPoint.y, 0);
        self.view.frame = CGRectMake(newPoint.x, newPoint.y, self.view.frame.size.width, self.view.frame.size.height);
        [pan setTranslation:CGPointZero inView:self.view];
        
        CGFloat blackLayerScale = 0.8 * (0.5 - self.view.frame.origin.y / self.view.frame.size.height);
        self.blackView.backgroundColor = [UIColor colorWithWhite:0 alpha:blackLayerScale];
        
    } else if (self.wayToPop == LCNavWayFromLeftToRight) {
        UIScreenEdgePanGestureRecognizer *sender = (UIScreenEdgePanGestureRecognizer *)gestureRecognizer;
        CGPoint movePoint = [sender translationInView:self.view];
        CGPoint newPoint = CGPointMake(self.view.frame.origin.x + movePoint.x, self.view.frame.origin.y);
        newPoint.x = MAX(newPoint.x, 0);
        self.view.frame = CGRectMake(newPoint.x, newPoint.y, self.view.frame.size.width, self.view.frame.size.height);
        [sender setTranslation:CGPointZero inView:self.view];
        
        self.backView.frame = CGRectMake(- self.backView.frame.size.width / 2 + self.view.frame.origin.x / 2 , self.backView.frame.origin.y, self.backView.frame.size.width, self.backView.frame.size.height);
    }
}

//pop时的动画
- (void)animationWhenPopWithView:(UIView *)backView Completion:(void(^)(BOOL finished))completion
{
    if (self.wayToPop == LCNavWayFromTopToBottom) {
        [UIView animateWithDuration:popAnimationTimeInterval animations:^{
            self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
            self.blackView.backgroundColor = [UIColor colorWithWhite:0 alpha:-1];
        } completion:completion];
    } else if (self.wayToPop == LCNavWayFromLeftToRight) {
        [UIView animateWithDuration:popAnimationTimeInterval animations:^{
            self.view.frame = CGRectMake(self.view.frame.size.width, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
            self.backView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            self.blackView.backgroundColor = [UIColor colorWithWhite:0 alpha:-1];
        } completion:completion];
    }
}

@end

@implementation UIViewController (LCViewController)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL viewDidLoadSEL = @selector(viewDidLoad);
        SEL AOP_viewDidLoadSEL = @selector(AOP_viewDidLoad);
        
        Method viewDidLoadMethod = class_getInstanceMethod(class, viewDidLoadSEL);
        Method AOP_viewDidLoadMethod = class_getInstanceMethod(class, AOP_viewDidLoadSEL);
        
        BOOL success1 = class_addMethod(class, viewDidLoadSEL, method_getImplementation(AOP_viewDidLoadMethod), method_getTypeEncoding(AOP_viewDidLoadMethod));
        if (success1) {
            class_replaceMethod(class, AOP_viewDidLoadSEL, method_getImplementation(viewDidLoadMethod), method_getTypeEncoding(viewDidLoadMethod));
        } else {
            method_exchangeImplementations(viewDidLoadMethod, AOP_viewDidLoadMethod);
        }
        
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(AOP_viewWillAppear:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        //如果originalSelector不存在，则添加originalSelector方法，方法实现为AOP方法的实现。如果存在则不添加方法，并返回success为NO
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            //将AOP方法的实现设置成空
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

//初始化控制器的属性写在此处，由子控制器在viewDidLoad中的[super viewDidLoad]调用
- (void)AOP_viewDidLoad
{
    [self AOP_viewDidLoad];
    self.leftToRightEnabled = YES;
    self.topToBottomEnabled = YES;
}

- (void)AOP_viewWillAppear:(BOOL)animated
{
    [self AOP_viewWillAppear:animated];
    if (self.isHidesBottomBarWhenPushed) {
        self.tabBarController.tabBar.hidden = YES;
    } else if (self.navigationController.viewControllers.count == 1) {
        self.tabBarController.tabBar.hidden = NO;
    }
}

//添加属性
- (BOOL)isTopToBottomEnabled
{
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) {
        return number.boolValue;
    }else{
        self.topToBottomEnabled = NO;
        return NO;
    }
}

- (void)setTopToBottomEnabled:(BOOL)topToBottomEnabled
{
    objc_setAssociatedObject(self, @selector(isTopToBottomEnabled), @(topToBottomEnabled) ,OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isLeftToRightEnabled
{
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) {
        return number.boolValue;
    }else{
        self.leftToRightEnabled = NO;
        return NO;
    }
}

- (void)setLeftToRightEnabled:(BOOL)leftToRightEnabled
{
    objc_setAssociatedObject(self, @selector(isLeftToRightEnabled), @(leftToRightEnabled) ,OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isHidesBottomBarWhenPushed
{
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) {
        return number.boolValue;
    }else{
        self.hidesBottomBarWhenPushed = NO;
        return NO;
    }
}

- (void)setHidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed
{
    objc_setAssociatedObject(self, @selector(isHidesBottomBarWhenPushed), @(hidesBottomBarWhenPushed) ,OBJC_ASSOCIATION_ASSIGN);
}

@end


