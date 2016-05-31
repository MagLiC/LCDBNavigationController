//
//  RootViewController.m
//  LCDBNavigationController
//
//  Created by Lichao on 16/5/23.
//  Copyright © 2016年 Lichao. All rights reserved.
//

#import "RootViewController.h"
#import "FirstViewController.h"
#import "LCDBNavigationController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Root";
    self.view.backgroundColor = [UIColor blueColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (IBAction)push:(id)sender {
    FirstViewController *firstVC = [[FirstViewController alloc]initWithNibName:@"FirstViewController" bundle:nil];
    [self.navigationController pushViewController:firstVC animated:YES];
}


@end
