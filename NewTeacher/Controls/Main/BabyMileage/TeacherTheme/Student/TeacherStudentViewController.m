//
//  TeacherStudentViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/9.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "TeacherStudentViewController.h"
#import "MileageModel.h"
#import "NSString+Common.h"
#import "TeacherStudent2ViewController.h"

@interface TeacherStudentViewController ()

@end

@implementation TeacherStudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getClassmatePhotoList"];
    [param setObject:self.mileage.album_id ?: @"" forKey:@"album_id"];
    [param setObject:@"2" forKey:@"mileage_type"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
    self.action = @"photo";
}

#pragma mark - 重载
- (void)createTableHeaderView
{
    
}

- (void)createTableFooterView{
    
}

#pragma mark - 请求结束
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if ([self.dataSource count] == 0) {
        TeacherStudent2ViewController *class2 = [[TeacherStudent2ViewController alloc] init];
        class2.mileage = self.mileage;
        class2.view.frame = self.view.bounds;
        [self addChildViewController:class2];
        [self.view addSubview:class2.view];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 18)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    UILabel *firstLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 18)];
    [firstLab setTextAlignment:1];
    [firstLab setBackgroundColor:CreateColor(82, 78, 128)];
    [firstLab setTextColor:[UIColor whiteColor]];
    [firstLab setFont:[UIFont systemFontOfSize:12]];
    [headerView addSubview:firstLab];
    
    ThemeBatchModel *theme = self.dataSource[section];
    UILabel *secondLab = [[UILabel alloc] initWithFrame:CGRectMake(firstLab.frameRight, 0, 95, 18)];
    [secondLab setTextColor:firstLab.backgroundColor];
    [secondLab setFont:[UIFont systemFontOfSize:12]];
    [secondLab setTextAlignment:1];
    [secondLab setBackgroundColor:CreateColor(212, 213, 215)];
    [secondLab setText:[NSString stringWithFormat:@"%@小朋友", theme.name ?: @""]];
    [headerView addSubview:secondLab];
    
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:theme.create_time.doubleValue];
    [firstLab setText:[NSString stringByDate:@"yyyy年MM月dd日" Date:updateDate]];
    
    return headerView;
}

@end
