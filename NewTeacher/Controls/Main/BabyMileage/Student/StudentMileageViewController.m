//
//  StudentMileageViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/8.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "StudentMileageViewController.h"
#import "NSString+Common.h"
#import "BabyMileageViewController.h"
#import "MileageStudentModel.h"
#import "StudentMileageDetailController.h"
#import "MileageListViewCell2.h"

@interface StudentMileageViewController ()<MileageListViewCellDelegate>

@end

@implementation StudentMileageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    ((BabyMileageViewController *)self.parentViewController).titleLable.text = @"学生里程";
}

- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getMileageList"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page"];
    [param setObject:@"0" forKey:@"type"];
    [param setObject:@"2" forKey:@"visual_type"];
    
    BabyMileageViewController *parent = (BabyMileageViewController *)self.parentViewController;
    [param setObject:parent.mileageStu.student_id forKey:@"student_id"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
}

#pragma mark - 重载,不可删除
- (void)resetTitleContent:(id)ret_data
{
    
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *mileageCell = @"mileageCellId";
    MileageListViewCell2 *cell = [_tableView dequeueReusableCellWithIdentifier:mileageCell];
    if (cell == nil) {
        cell = [[MileageListViewCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mileageCell];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    MileageModel *mileage = self.dataSource[indexPath.section];
    [cell resetDataSource:mileage];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    StudentMileageDetailController *mile = [[StudentMileageDetailController alloc] init];
    mile.disanableDelete = YES;
    mile.mileage = self.dataSource[indexPath.section];
    BabyMileageViewController *parent = (BabyMileageViewController *)self.parentViewController;
    mile.mileageStu = parent.mileageStu;
    [parent.navigationController pushViewController:mile animated:YES];
}

@end
