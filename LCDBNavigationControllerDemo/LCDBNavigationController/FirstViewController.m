//
//  FirstViewController.m
//  LCDBNavigationController
//
//  Created by Lichao on 16/5/23.
//  Copyright © 2016年 Lichao. All rights reserved.
//

#import "FirstViewController.h"
#import "LCNavigationBarDelegate.h"
#import "SecondViewController.h"
#import "LCDBNavigationController.h"

@interface FirstViewController ()<LCNavigationBarDelegate>

@end

@implementation FirstViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor redColor];
}

- (IBAction)push:(id)sender {
    SecondViewController *secondVC = [[SecondViewController alloc]initWithNibName:@"SecondViewController" bundle:nil];
    [self.navigationController pushViewController:secondVC animated:YES];
}

/**
 *  要使用UIBackBarItem的时候必须要实现该协议，并return YES;
 */
- (BOOL)lc_navigaitionControllerShouldAnimationShowWhenBackBarItemBeSelected
{
    return YES;
}

@end
