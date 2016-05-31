//
//  ThirdViewController.m
//  LCDBNavigationController
//
//  Created by Lichao on 16/5/31.
//  Copyright © 2016年 Lichao. All rights reserved.
//

#import "ThirdViewController.h"
#import "LCNavigationBarDelegate.h"
#import "LCDBNavigationController.h"

@interface ThirdViewController ()<UITableViewDelegate, UITableViewDataSource, LCNavigationBarDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic)UITableView *tableView;

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc]init];
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 64);
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellID"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 16;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld行", indexPath.row];
    return cell;
}

- (BOOL)lc_navigaitionControllerShouldAnimationShowWhenBackBarItemBeSelected
{
    return YES;
}



@end
