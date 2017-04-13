//
//  SystemStudent2ViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/9.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SystemStudent2ViewController.h"
#import "NSString+Common.h"

@interface SystemStudent2ViewController ()

@end

@implementation SystemStudent2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)startRequestData
{
    [self createTableViewAndRequestAction:nil Param:nil Header:YES Foot:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    [self startPullRefresh];
}

- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getClassmatePhotoList"];
    [param setObject:@"3" forKey:@"mileage_type"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
    self.action = @"photo";
}

#pragma mark - 重载
- (void)createTableHeaderView{
    if (!_tableView.tableHeaderView) {
        BOOL extend = ([self.dataSource count] > 0);
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 30 + 100 + 30 + 18 + 30 + (extend ? 40 : 0))];
        [headView setBackgroundColor:[UIColor whiteColor]];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 100) / 2, 30, 100, 100)];
        imgView.image = CREATE_IMG(@"contact_a");
        [headView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, imgView.frameBottom + 30, winSize.width - 80, 18)];
        [label setTextAlignment:1];
        [label setTextColor:[UIColor darkGrayColor]];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setText:@"暂时还没有同学发布照片或小视频"];
        [headView addSubview:label];
        
        if (extend) {
            UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, label.frameBottom + 30, headView.frameWidth, 40)];
            [downView setBackgroundColor:rgba(231, 231, 231, 1)];
            [headView addSubview:downView];
            
            CGFloat moreWei = 100;
            UILabel *moreLab = [[UILabel alloc] initWithFrame:CGRectMake((downView.frameWidth - moreWei) / 2, 10, moreWei, 20)];
            [moreLab setFont:[UIFont systemFontOfSize:14]];
            moreLab.layer.masksToBounds = YES;
            moreLab.layer.cornerRadius = 10;
            moreLab.textAlignment = NSTextAlignmentCenter;
            moreLab.textColor = label.textColor;
            [moreLab setBackgroundColor:rgba(205, 205, 205, 1)];
            moreLab.text = @"更多精彩内容";
            [downView addSubview:moreLab];
        }
        
        [_tableView setTableHeaderView:headView];
    }
}

- (void)createTableFooterView{
    

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
