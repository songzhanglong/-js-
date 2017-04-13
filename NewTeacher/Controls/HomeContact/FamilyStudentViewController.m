//
//  FamilyStudentViewController.m
//  NewTeacher
//
//  Created by szl on 16/5/5.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "FamilyStudentViewController.h"
#import "FamilyStudentCell.h"
#import "Toast+UIView.h"
#import "FamilyStudentModel.h"

@interface FamilyStudentViewController ()

@end

@implementation FamilyStudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSDictionary *dic = @{@"school_id":manager.userInfo.schoolid,@"class_id":manager.userInfo.classid,@"grade_id":manager.userInfo.grade_id};
    [self createTableViewAndRequestAction:@"form:student" Param:dic Header:YES Foot:NO];
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
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, footView.frameBottom - 18, winSize.width - 80, 18)];
        [label setTextAlignment:1];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:CreateColor(84, 128, 215)];
        [label setText:@"还未填写过哦"];
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
        NSArray *data = [result valueForKey:@"student_list"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        self.dataSource = [FamilyStudentModel arrayOfModelsFromDictionaries:data error:nil];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *familyStudentCell = @"familyStudentCell";
    FamilyStudentCell *cell = [tableView dequeueReusableCellWithIdentifier:familyStudentCell];
    if (cell == nil) {
        cell = [[FamilyStudentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:familyStudentCell];
    }
    FamilyStudentModel *model = [self.dataSource objectAtIndex:indexPath.row];
    [cell resetDataSource:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = tableView.backgroundColor;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(getTableViewDidSelectRowAtIndexPath:)]) {
        [_delegate getTableViewDidSelectRowAtIndexPath:indexPath];
    }
}

@end
