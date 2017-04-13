//
//  ReviewsViewController.m
//  NewTeacher
//
//  Created by zhangxs on 16/5/13.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "ReviewsViewController.h"
#import "Toast+UIView.h"
#import "FamilyNoPiechartDetailViewController.h"

@implementation ReviewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showBack = YES;
    self.titleLable.text = @"评语库";
    self.view.backgroundColor = CreateColor(221, 221, 221);
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSDictionary *dic = @{@"grade_id":manager.userInfo.grade_id};
    [self createTableViewAndRequestAction:@"form:comment" Param:dic Header:YES Foot:NO];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [self beginRefresh];
}

#pragma mark - 网络请求结束
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    if (success) {
        NSArray *ret_data = [result valueForKey:@"list"];
        ret_data = (!ret_data || [ret_data isKindOfClass:[NSNull class]]) ? [NSArray array] : ret_data;
        NSMutableArray *indexArray = [NSMutableArray array];
        [indexArray addObjectsFromArray:ret_data];
        self.dataSource = indexArray;
        [_tableView reloadData];
    }
    else {
        NSString *str = [result valueForKey:@"message"];
        str = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

- (CGFloat)caculateContentToHeight:(NSString *)content
{
    CGFloat _contHei = 0;
    if ([content length] == 0) {
        _contHei = 0;
    }
    else{
        CGSize lastSize = CGSizeZero;
        UIFont *font = [UIFont systemFontOfSize:14];
        CGFloat wei = SCREEN_WIDTH - 20;
        NSDictionary *attribute = @{NSFontAttributeName: font};
        lastSize = [content boundingRectWithSize:CGSizeMake(wei, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        
        _contHei = MAX(20, lastSize.height + 10);
    }
    
    return _contHei;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat hei = [self caculateContentToHeight:[self.dataSource objectAtIndex:indexPath.section]];
    return hei + 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    [label setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    [label setBackgroundColor:[UIColor clearColor]];
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"LeaveMsgListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH - 20, 20)];
        [contentLabel setBackgroundColor:[UIColor clearColor]];
        [contentLabel setFont:[UIFont systemFontOfSize:14]];
        [contentLabel setTag:10];
        contentLabel.numberOfLines = 0;
        [cell.contentView addSubview:contentLabel];
    }
    UILabel *_contentLabel = (UILabel *)[cell.contentView viewWithTag:10];
    if (_contentLabel) {
        CGFloat hei = [self caculateContentToHeight:[self.dataSource objectAtIndex:indexPath.section]];
        [_contentLabel setFrame:CGRectMake(10, 5, SCREEN_WIDTH - 20, hei)];
        [_contentLabel setText:[self.dataSource objectAtIndex:indexPath.section] ?: @""];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    for (id controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[FamilyNoPiechartDetailViewController class]]) {
            [controller setReviewsData:[self.dataSource objectAtIndex:indexPath.section]];
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

@end
