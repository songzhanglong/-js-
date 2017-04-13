//
//  FamilyListViewController.m
//  NewTeacher
//
//  Created by szl on 16/5/5.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "FamilyListViewController.h"
#import "FamilyListCell.h"
#import "Toast+UIView.h"
#import "FamilyListModel.h"
#import "NSDate+Calendar.h"
#import "NSDate+Common.h"
#import "NSString+Common.h"

@interface FamilyListViewController ()

@end

@implementation FamilyListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSDictionary *dic = @{@"school_id":manager.userInfo.schoolid,@"class_id":manager.userInfo.classid,@"grade_id":manager.userInfo.grade_id};
    [self createTableViewAndRequestAction:@"form:school_form" Param:dic Header:YES Foot:NO];
    [_tableView setBackgroundColor:CreateColor(235, 235, 241)];
    
    [self beginRefresh];
}

- (void)createTableFooterView
{
    if ([self.dataSource count] > 0) {
        [_tableView setTableFooterView:[[UIView alloc] init]];
    }
    else{
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 150)];
        [footView setBackgroundColor:_tableView.backgroundColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, footView.frameBottom- 18, winSize.width - 80, 18)];
        [label setTextAlignment:1];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:CreateColor(84, 128, 215)];
        [label setText:@"园长还未设置任何家园联系表哦！"];
        [footView addSubview:label];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 100) / 2, 30, 100, 100)];
        imgView.image = CREATE_IMG(@"contact_a");
        [footView addSubview:imgView];
        
        [_tableView setTableFooterView:footView];
    }
}

#pragma mark - refresh data
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if (success) {
        NSMutableArray *indexArray = [NSMutableArray array];
        NSArray *data = [result valueForKey:@"datalist"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        
        NSMutableArray *formArray = [NSMutableArray array];
        NSMutableArray *tempArr = [NSMutableArray array];
        for (id sub in data) {
            for (id tosub in sub) {
                NSError *error;
                FamilyListModel *model = [[FamilyListModel alloc] initWithDictionary:tosub error:&error];
                if (error) {
                    NSLog(@"%@",error.description);
                    continue;
                }
                if ([model.form_date length] <= 0) {
                    [tempArr addObject:model];
                }else{
                    [formArray addObject:model];
                }
            }
        }
        if ([tempArr count] > 0) {
            [indexArray addObject:tempArr];
        }
        NSArray *array = [formArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            FamilyListModel *stu1 = (FamilyListModel *)obj1;
            FamilyListModel *stu2 = (FamilyListModel *)obj2;
            NSArray *array1 = [stu1.form_date componentsSeparatedByString:@"-"];
            NSArray *array2 = [stu2.form_date componentsSeparatedByString:@"-"];
            NSString *str1 = [array1 componentsJoinedByString:@""],*str2 = [array2 componentsJoinedByString:@""];
            if ((array1.count >= 3) && (stu1.repeat_type.integerValue == 2)) {
                str1 = [NSString stringWithFormat:@"%@%@32",array1[0],array1[1]];
            }
            
            if ((array2.count >= 3) && (stu2.repeat_type.integerValue == 2)) {
                str2 = [NSString stringWithFormat:@"%@%@32",array2[0],array2[1]];
            }

            return [str2 compare:str1];
        }];
        
        NSMutableArray *lastArr = [NSMutableArray array];
        NSUInteger month = 0;
        for (FamilyListModel *item in array) {
            if ([item.form_date length] == 0) {
                continue;
            }
            NSDate *date = [NSDate dateFromString:item.form_date formater:@"yyyy-MM-dd"];
            NSInteger tMon = date.month;
            if (tMon != month) {
                month = tMon;
                NSMutableArray *tmpArr = [NSMutableArray arrayWithObject:item];
                [lastArr addObject:tmpArr];
            }
            else{
                NSMutableArray *sufArr = [lastArr lastObject];
                [sufArr addObject:item];
            }
        }
        [indexArray addObjectsFromArray:lastArr];
        self.dataSource = indexArray;
        [self createTableFooterView];
        
        [_tableView reloadData];
    }
    else {
        NSString *str = [result valueForKey:@"message"];
        str = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dataSource objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *familyListCell = @"familyListCell";
    FamilyListCell *cell = [tableView dequeueReusableCellWithIdentifier:familyListCell];
    if (cell == nil) {
        cell = [[FamilyListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:familyListCell];
    }
    FamilyListModel *model = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell resetDataSource:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = tableView.backgroundColor;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(familyListDidSelectIndex:)]) {
        [_delegate familyListDidSelectIndex:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    static NSString *familyListFooter = @"familyListFooter";
    UITableViewHeaderFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:familyListFooter];
    if (footer == nil) {
        footer = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:familyListFooter];
        [footer.contentView setBackgroundColor:tableView.backgroundColor];
    }
    return footer;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *familyListHeader = @"familyListHeader";
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:familyListHeader];
    if (header == nil) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:familyListHeader];
        header.contentView.backgroundColor = tableView.backgroundColor;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-10, 0, 100, 20)];
        label.backgroundColor = CreateColor(53, 175, 81);
        [label setTag:1];
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = 10;
        [label setTextAlignment:NSTextAlignmentCenter];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14];
        [header.contentView addSubview:label];
    }
    
    UILabel *label = (UILabel *)[header.contentView viewWithTag:1];
    
    NSString *str = @"学期";
    NSArray *arr = [self.dataSource objectAtIndex:section];
    FamilyListModel *model;
    if ([arr count] > 0) {
        model = [arr objectAtIndex:0];
    }
    if (model.form_date.length > 0) {
        NSDate *date = [NSString convertStringToDate:model.form_date];
        str = [NSDate stringFromDate:date formater:@"yyyy年MM月"];
    }
    label.text = str;
    
    return header;
}

@end
