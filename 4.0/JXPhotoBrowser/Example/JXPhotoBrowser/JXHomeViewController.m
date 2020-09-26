//
//  JXHomeViewController.m
//  JXPhotoBrowser_Example
//
//  Created by Jason on 2020/9/6.
//  Copyright © 2020 JiongXing. All rights reserved.
//

#import "JXHomeViewController.h"
#import "JXHomeTableViewCell.h"
#import "JXHomeActionModel.h"

@interface JXHomeViewController ()

@property (nonatomic, strong) NSMutableArray<JXHomeActionModel *> *modelArray;

@end

@implementation JXHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:JXHomeTableViewCell.class forCellReuseIdentifier:JXHomeTableViewCell.defaultId];
    
    [self addModel01];
}

- (void)addModel01
{
    JXHomeActionModel *model = [[JXHomeActionModel alloc] init];
    [self.modelArray addObject:model];
    model.title = @"无限轮播";
    model.desc = @"横向自动轮播，适合场景：广告自动轮播";
    model.clickCallback = ^{
        NSLog(@"click!");
    };
}

- (NSMutableArray<JXHomeActionModel *> *)modelArray
{
    if (!_modelArray)
    {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.modelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JXHomeTableViewCell *cell = (JXHomeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:JXHomeTableViewCell.defaultId];
    JXHomeActionModel *model = self.modelArray[indexPath.row];
    cell.textLabel.text = model.title;
    cell.detailTextLabel.text = model.desc;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    JXHomeActionModel *model = self.modelArray[indexPath.row];
    model.clickCallback();
}

@end
