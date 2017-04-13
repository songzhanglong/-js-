//
//  LeaveMessageViewController.m
//  NewTeacher
//
//  Created by zhangxs on 16/5/4.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "LeaveMessageViewController.h"
#import "LeaveMsgModel.h"
#import "LeaveMessageCell.h"
#import "Toast+UIView.h"
#import "ScreeningFamilyView.h"
#import "FamilyContactDetailViewController.h"
#import "FamilyStudentModel.h"

@interface LeaveMessageViewController () <ScreeningFamilyViewDelegate>
{
    NSMutableArray *_screeningArray;
    ScreeningFamilyView *_screeningView;
    NSInteger _nSelectIdx;
}
@end

@implementation LeaveMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"留言列表";
    [self createRightButton];
    
    [self createTableViewAndRequestAction:@"form:school_form_reply" Param:nil Header:YES Foot:NO];
    [_tableView setBackgroundColor:CreateColor(221, 221, 221)];
    [self beginRefresh];
    
    [self sendReqreeest];
}

- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:manager.userInfo.schoolid,@"school_id",manager.userInfo.classid,@"class_id",nil];
    if (_nSelectIdx > 0) {
        LeaveMsgModel *model = _screeningArray[_nSelectIdx - 1];
        [param setObject:model.form_id forKey:@"form_id"];
        [param setObject:model.form_date forKey:@"form_date"];
    }
    self.param = param;
}

#pragma mark - create right button
- (void)createRightButton
{
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = CGRectMake(0, 0, 30.0, 20.0);
    [sureBtn setImage:CREATE_IMG(@"contact_more") forState:UIControlStateNormal];
    sureBtn.backgroundColor = [UIColor clearColor];
    [sureBtn setImageEdgeInsets:UIEdgeInsetsMake(1.7, 5, 1.7, 5)];
    [sureBtn addTarget:self action:@selector(getScreeningAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sureBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

- (void)getScreeningAction:(id)sender
{
    if (_screeningArray.count == 0) {
        [self.view makeToast:@"暂无筛选数据" duration:1.0 position:@"center"];
        return;
    }
    if (_screeningView) {
        if ([_screeningView isDescendantOfView:self.view]) {
            [_screeningView hiddenInView];
        }
        else{
            [self.view addSubview:_screeningView];
            [_screeningView showInView];
        }
    }
    else{
        CGFloat hei = MIN(self.view.bounds.size.height, 44 * (_screeningArray.count + 1));
        _screeningView = [[ScreeningFamilyView alloc] initWithFrame:self.view.bounds TabHei:hei];
        _screeningView.delegate = self;
        NSMutableArray *array = [NSMutableArray arrayWithObject:@"全部"];
        for (NSInteger i = 0; i < _screeningArray.count; i++) {
            LeaveMsgModel *model = _screeningArray[i];
            [array addObject:model.title];
        }
        _screeningView.dataSource = array;
        [self.view addSubview:_screeningView];
        [_screeningView showInView];
    }
}

#pragma mark - ScreeningFamilyViewDelegate
- (void)screeningActionIndex:(NSInteger)row
{
    if (_nSelectIdx == row) {
        return;
    }
    _nSelectIdx = row;
    [self beginRefresh];
}

#pragma mark - 筛选
- (void)sendReqreeest
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    __weak __typeof(self)weakSelf = self;
    NSString *url = [URLFACE stringByAppendingString:@"form:school_form_select"];
    NSDictionary *dic = @{@"school_id":manager.userInfo.schoolid,@"class_id":manager.userInfo.classid,@"grade_id":manager.userInfo.grade_id,@"userid":manager.userInfo.userid};
    
    [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf screeningFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf screeningFinish:NO Data:nil];
    }];
}

- (void)screeningFinish:(BOOL)success Data:(id)result
{
    if (success) {
        NSArray *ret_data = [result valueForKey:@"datalist"];
        ret_data = (!ret_data || [ret_data isKindOfClass:[NSNull class]]) ? [NSArray array] : ret_data;
        _screeningArray = [LeaveMsgModel arrayOfModelsFromDictionaries:ret_data error:nil];
    }
}

#pragma mark - 网络请求结束
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    if (success) {
        NSArray *ret_data = [result valueForKey:@"datalist"];
        ret_data = (!ret_data || [ret_data isKindOfClass:[NSNull class]]) ? [NSArray array] : ret_data;
        self.dataSource = [LeaveMsgModel arrayOfModelsFromDictionaries:ret_data error:nil];
        [self.dataSource makeObjectsPerformSelector:@selector(caculateContentHei)];
        [self createTableFooterView];
        [_tableView reloadData];
    }
    else {
        NSString *str = [result valueForKey:@"message"];
        str = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
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
        [label setText:@"暂时还没有家长留言哦!"];
        [footView addSubview:label];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 100) / 2, 30, 100, 100)];
        imgView.image = CREATE_IMG(@"contact_a");
        [footView addSubview:imgView];
        
        [_tableView setTableFooterView:footView];
    }
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
    LeaveMsgModel *model = [self.dataSource objectAtIndex:indexPath.section];
    return 60 + 40 + 5 + model.content_hei + 5 + 0.5 + 10 + 30 + 10 + 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *leaveMsgListCell = @"LeaveMsgListCell";
    
    LeaveMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:leaveMsgListCell];
    
    if (cell == nil) {
        cell = [[LeaveMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:leaveMsgListCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    LeaveMsgModel *model = [self.dataSource objectAtIndex:indexPath.section];
    [cell resetLeaveMessageData:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LeaveMsgModel *model = [self.dataSource objectAtIndex:indexPath.section];
    FamilyStudentModel *item = [[FamilyStudentModel alloc] init];
    item.form_date = model.form_date;
    item.form_id = model.form_id;
    item.title = model.title;
    item.student_id = model.student_id;
    item.name = model.student_name;
    FamilyContactDetailViewController *detailController = [[FamilyContactDetailViewController alloc] init];
    detailController.listItem = item;
    detailController.fromType = 1;
    [self.navigationController pushViewController:detailController animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = tableView.backgroundColor;
}

@end
