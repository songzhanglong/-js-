//
//  FamilyStuListViewController.m
//  NewTeacher
//
//  Created by szl on 16/5/6.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "FamilyStuListViewController.h"
#import "FamilyStuListCell.h"
#import "Toast+UIView.h"
#import "FamilyStudentModel.h"
#import "FamilyNoPiechartDetailViewController.h"
#import "FamilyContactDetailViewController.h"
#import "FamilyViewController.h"

@interface FamilyStuListViewController ()<FamilyStuListCellDelegate>

@end

@implementation FamilyStuListViewController
{
    NSMutableArray *_unfinishedArray,*_finishedArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"学生列表";
    
    //分组数据
    _unfinishedArray = [[NSMutableArray alloc] init];
    _finishedArray = [[NSMutableArray alloc] init];
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSDictionary *dic = @{@"school_id":manager.userInfo.schoolid,@"class_id":manager.userInfo.classid,@"grade_id":manager.userInfo.grade_id,@"form_id":_listItem.form_id,@"form_date":_listItem.form_date};
    [self createTableViewAndRequestAction:@"form:student" Param:dic Header:YES Foot:NO];
    
    [_tableView setBackgroundColor:CreateColor(235, 235, 241)];
    [self beginRefresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_isRefreshData) {
        for (id controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[FamilyViewController class]]) {
                [controller setIsRefreshListData:_isRefreshData];
            }
        }
        [self beginRefresh];
        _isRefreshData = NO;
    }
}

- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if (success) {
        NSArray *wc_data = [result valueForKey:@"wancheng"];
        wc_data = (!wc_data || [wc_data isKindOfClass:[NSNull class]]) ? [NSArray array] : wc_data;
        if ([wc_data count] > 0) {
            NSDictionary *wc_dic = [wc_data objectAtIndex:0];
            NSMutableArray *tempArr = [NSMutableArray array];
            if (wc_dic && [wc_dic count] > 0) {
                NSArray *values_arr = [wc_dic allValues];
                for (id sub in values_arr) {
                    NSError *error;
                    FamilyStudentModel *model = [[FamilyStudentModel alloc] initWithDictionary:sub error:&error];
                    if (error) {
                        NSLog(@"%@",error.description);
                        continue;
                    }
                    [tempArr addObject:model];
                }
            }
            _finishedArray = tempArr;
        }
        NSArray *wwc_data = [result valueForKey:@"weiwancheng"];
        wwc_data = (!wwc_data || [wwc_data isKindOfClass:[NSNull class]]) ? [NSArray array] : wwc_data;
        if ([wwc_data count] > 0) {
            NSMutableArray *tempArr = [NSMutableArray array];
            NSDictionary *wwc_dic = [wwc_data objectAtIndex:0];
            if (wwc_dic && [wwc_dic count] > 0) {
                NSArray *values_arr = [wwc_dic allValues];
                for (id sub in values_arr) {
                    NSError *error;
                    FamilyStudentModel *model = [[FamilyStudentModel alloc] initWithDictionary:sub error:&error];
                    if (error) {
                        NSLog(@"%@",error.description);
                        continue;
                    }
                    [tempArr addObject:model];
                }
            }
            _unfinishedArray = tempArr;
        }
        
        [_tableView reloadData];
    }
    else {
        NSString *str = [result valueForKey:@"message"];
        str = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - FamilyStuListCellDelegate
- (void)selectStuListCell:(UITableViewCell *)cell At:(NSInteger)index
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    FamilyStudentModel *item;
    if (indexPath.section == 0) {
        if ([_unfinishedArray count] > 0) {
            item = [_unfinishedArray objectAtIndex:index];
        }else{
            item = [_finishedArray objectAtIndex:index];
        }
        item = [_unfinishedArray objectAtIndex:index];
        item.form_date = _listItem.form_date;
        item.form_id = _listItem.form_id;
        item.title = _listItem.title;
        FamilyNoPiechartDetailViewController *detailController = [[FamilyNoPiechartDetailViewController alloc] init];
        detailController.listItem = item;
        [self.navigationController pushViewController:detailController animated:YES];
    }else{
        item = [_finishedArray objectAtIndex:index];
        item.form_date = _listItem.form_date;
        item.form_id = _listItem.form_id;
        item.title = _listItem.title;
        FamilyContactDetailViewController *detailController = [[FamilyContactDetailViewController alloc] init];
        detailController.listItem = item;
        detailController.fromType = 1;
        [self.navigationController pushViewController:detailController animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *familyStuListCell = @"familyStuListCell";
    FamilyStuListCell *cell = [tableView dequeueReusableCellWithIdentifier:familyStuListCell];
    if (cell == nil) {
        cell = [[FamilyStuListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:familyStuListCell];
        cell.delegate = self;
    }
    [cell resetDataSource:(indexPath.section == 0) ? _unfinishedArray : _finishedArray];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = (indexPath.section == 0) ? _unfinishedArray.count : _finishedArray.count;
    if (count == 0) {
        return 0;
    }
    NSInteger rows = (count - 1) / 6 + 1;
    return rows * (56 + 10) + 10;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = tableView.backgroundColor;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSInteger count = (section == 0) ? _unfinishedArray.count : _finishedArray.count;
    if (count == 0) {
        return 0;
    }
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *headerStuList = @"headerStuList";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerStuList];
    if (headerView == nil) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerStuList];
        headerView.contentView.backgroundColor = tableView.backgroundColor;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 9.5, 11, 11)];
        [imgView setTag:1];
        [headerView.contentView addSubview:imgView];
        
        UILabel *namLab = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frameRight + 2, 6, 45, 18)];
        namLab.tag = 2;
        namLab.backgroundColor = tableView.backgroundColor;
        [namLab setFont:[UIFont systemFontOfSize:14]];
        [namLab setTextColor:[UIColor darkGrayColor]];
        [headerView.contentView addSubview:namLab];
        
        UILabel *numLab = [[UILabel alloc] initWithFrame:CGRectMake(namLab.frameRight, namLab.frameY, 30, namLab.frameHeight)];
        [numLab setFont:namLab.font];
        [numLab setTag:3];
        numLab.backgroundColor = namLab.backgroundColor;
        [numLab setTextColor:[UIColor redColor]];
        [headerView.contentView addSubview:numLab];
    }
    
    UIImageView *imgView = (UIImageView *)[headerView.contentView viewWithTag:1];
    UILabel *namLab = (UILabel *)[headerView.contentView viewWithTag:2];
    UILabel *numLab = (UILabel *)[headerView.contentView viewWithTag:3];
    
    BOOL unfinished = (section == 0);
    NSInteger count = unfinished ? _unfinishedArray.count : _finishedArray.count;
    if (count == 0) {
        [imgView setHidden:YES];
        [namLab setHidden:YES];
        [numLab setHidden:YES];
    }
    else{
        [imgView setHidden:NO];
        [namLab setHidden:NO];
        [numLab setHidden:NO];
        
        NSString *str = unfinished ? @"contactUnFinished" : @"contactFinished";
        [imgView setImage:CREATE_IMG(str)];
        [namLab setText:unfinished ? @"未完成" : @"已完成"];
        [numLab setText:[NSString stringWithFormat:@"%ld",(long)count]];
    }

    return headerView;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
