//
//  SecondViewController.m
//  LCDBNavigationController
//
//  Created by Lichao on 16/5/24.
//  Copyright © 2016年 Lichao. All rights reserved.
//

#import "SecondViewController.h"
#import "LCNavigationBarDelegate.h"
#import "LCDBNavigationController.h"
#import "ThirdViewController.h"

@interface SecondViewController ()<LCNavigationBarDelegate>

@end

@implementation SecondViewController

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
}
- (IBAction)pop:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)popToRoot:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)pushToTableView:(id)sender {
    ThirdViewController *vc = [[ThirdViewController alloc] initWithNibName:@"ThirdViewController" bundle:nil];;
    [self.navigationController pushViewController:vc animated:YES];
}

-(BOOL)lc_navigaitionControllerShouldAnimationShowWhenBackBarItemBeSelected
{
    return YES;
}


@end
