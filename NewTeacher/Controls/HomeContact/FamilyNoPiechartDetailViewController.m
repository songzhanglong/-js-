//
//  FamilyNoPiechartDetailViewController.m
//  NewTeacher
//
//  Created by zhangxs on 16/5/6.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "FamilyNoPiechartDetailViewController.h"
#import "FamilyEditCell.h"
#import "EditTextView.h"
#import "Toast+UIView.h"
#import "FamilyDetailModel.h"
#import "FamilyStuListViewController.h"
#import "EditFamilyViewController.h"
#import "LeaveMessageViewController.h"
#import "ReviewsViewController.h"
#import "FamilyEditHeaderCell.h"
#import "FamilyEditFooterCell.h"

@interface FamilyNoPiechartDetailViewController () <EditTextViewDelegate,FamilyEditCellDelegate,FamilyEditFooterCellDelegate>
{
    NSMutableArray *_optionArray;
}
@end
@implementation FamilyNoPiechartDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = _listItem.name ?: @"";
    
    _optionArray = [NSMutableArray array];
    
    self.view.backgroundColor = CreateColor(221, 221, 221);
    
    [self createRightButton];

    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:manager.userInfo.schoolid forKey:@"school_id"];
    [dic setValue:manager.userInfo.classid forKey:@"class_id"];
    [dic setValue:manager.userInfo.grade_id forKey:@"grade_id"];
    [dic setValue:_listItem.student_id forKey:@"student_id"];
    [dic setValue:_listItem.form_date forKey:@"form_date"];
    [dic setValue:_listItem.form_id forKey:@"form_id"];
    if (_score_id) {
        [dic setObject:_score_id forKey:@"score_id"];
    }
    [self createTableViewAndRequestAction:@"form:school_form_score" Param:dic Header:YES Foot:NO];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [self beginRefresh];

    [self createTableHeaderView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([_tableView.tableFooterView isKindOfClass:[EditTextView class]]) {
        [(EditTextView *)_tableView.tableFooterView deleteRecordingToAnimation];
    }
}

- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if (success) {
        NSArray *options = [result valueForKey:@"options"];
        options = (!options || [options isKindOfClass:[NSNull class]]) ? [NSArray array] : options;
        NSMutableArray *o_arr = [NSMutableArray array];
        for (id str in options) {
            [o_arr insertObject:str atIndex:0];
        }
        _optionArray = o_arr;
        
        NSArray *form_item_list = [result valueForKey:@"form_item_list"];
        form_item_list = (!form_item_list || [form_item_list isKindOfClass:[NSNull class]]) ? [NSArray array] : form_item_list;
        NSMutableArray *tempArr = [NSMutableArray array];
        for (id sub in form_item_list) {
            NSError *error;
            FamilyDetailModel *model = [[FamilyDetailModel alloc] initWithDictionary:sub error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            
            for (OptionsItem *item in model.item_list) {
                item.nIdx = -1;
                for (int i = 0; i < [_optionArray count]; i++) {
                    NSString *str = [_optionArray objectAtIndex:i];
                    if ([str isEqualToString:item.checked_option]) {
                        item.nIdx = i;
                    }
                }
                [item caculateClass_contHei];
            }
            [tempArr addObject:model];
        }
        
        self.dataSource = tempArr;
        [_tableView reloadData];
        
        [self createTableFooterView];
    }
    else {
        NSString *str = [result valueForKey:@"message"];
        str = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

- (void)createTableFooterView
{
    EditTextView *editView = [[EditTextView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 160) ToFrom:1];
    [editView setLoactionPath:@""];
    [editView setVoiceUrl:_voiceUrl];
    [editView setDelegate:self];
    [editView setLimitCount:200];
    if ([_voiceUrl length] > 0) {
        [editView.recordingImgView setImage:CREATE_IMG(@"tv36")];
        [editView.recordingButton setHidden:YES];
        [editView.playButton setHidden:NO];
        [editView.changeButton setHidden:NO];
    }
    [editView.textView setText:_indexComent];
    [_tableView setTableFooterView:editView];
}

#pragma mark- EditTextView delegate
- (void)showKeyboardEditTextView:(CGFloat)keyboard Height:(CGFloat)height
{
    CGFloat hei = keyboard;
    CGRect homeRect = _tableView.frame;
    __weak typeof(_tableView)weakView = _tableView;
    
    [UIView animateWithDuration:0.35 animations:^{
        [weakView setFrame:CGRectMake(homeRect.origin.x, -hei, homeRect.size.width, homeRect.size.height)];
    }];
}

- (void)hideKeyboardEditTextView:(CGFloat)height
{
    CGRect homeRect = _tableView.frame;
    __weak typeof(_tableView)weakView = _tableView;
    [UIView animateWithDuration:0.35 animations:^{
        [weakView setFrame:CGRectMake(homeRect.origin.x, 0, homeRect.size.width, homeRect.size.height)];
    }];
}

- (void)replyTeacher:(EditTextView *)editTextView
{
    ReviewsViewController *controller = [[ReviewsViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)createTableHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 20, 30)];
    [titleLabel setBackgroundColor:CreateColor(235, 235, 240)];
    [titleLabel.layer setCornerRadius:2];
    [titleLabel setText:_listItem.title ?: @""];
    [titleLabel setTextColor:[UIColor grayColor]];
    [titleLabel setFont:[UIFont systemFontOfSize:14]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [headerView addSubview:titleLabel];
    
    [_tableView setTableHeaderView:headerView];
}

- (void)setReviewsData:(NSString *)content
{
    [((EditTextView *)_tableView.tableFooterView).textView setText:content ?: @""];
}

#pragma mark - create right button
- (void)createRightButton
{
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setFrame:CGRectMake(0, 0, 40, 30)];
    [sendButton setTitle:@"保存" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [sendButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [sendButton addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,item];
}

- (void)saveAction:(id)sender
{
    for (FamilyDetailModel *model in self.dataSource) {
        for (OptionsItem *item in model.item_list) {
            if ([item.checked_option length] <= 0) {
                [self.view makeToast:@"您还有未评价的项目哦！" duration:1.0 position:@"center"];
                return;
            }
        }
    }
    
    [self sendSaveRequest];
}

- (void)sendSaveRequest
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }

    [self.view makeToastActivity];
    self.view.userInteractionEnabled = NO;
    __weak __typeof(self)weakSelf = self;
    NSString *url = [URLFACE stringByAppendingString:@"form:school_form_save"];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:manager.userInfo.userid forKey:@"userid"];
    [dic setValue:manager.userInfo.schoolid forKey:@"school_id"];
    [dic setValue:manager.userInfo.classid forKey:@"class_id"];
    [dic setValue:manager.userInfo.grade_id forKey:@"grade_id"];
    [dic setValue:_listItem.student_id forKey:@"student_id"];
    EditTextView *edit = (EditTextView *)_tableView.tableFooterView;
    [dic setValue:[edit.textView text] forKey:@"comment"];
    [dic setValue:edit.voiceUrl forKey:@"voice_url"];
    [dic setValue:_listItem.form_date forKey:@"form_date"];
    [dic setValue:_listItem.form_id forKey:@"form_id"];
    [dic setValue:_listItem.title forKey:@"title"];
    if (_score_id) {
        [dic setValue:_score_id forKey:@"score_id"];
    }
    
    NSMutableArray *form_item_list = [NSMutableArray array];
    for (FamilyDetailModel *model in self.dataSource) {
        NSMutableDictionary *selectDic = [NSMutableDictionary dictionary];
        NSMutableArray *tempArr = [NSMutableArray array];
        for (OptionsItem *item in model.item_list) {
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
            [tempDic setValue:item.id forKey:@"item_id"];
            [tempDic setValue:item.p_id forKey:@"p_id"];
            [tempDic setValue:item.checked_option forKey:@"option"];
            [tempArr addObject:tempDic];
        }
        [selectDic setValue:tempArr forKey:@"item_list"];
        [form_item_list addObject:selectDic];
    }

    [dic setObject:form_item_list forKey:@"form_item_list"];
    
    [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf saveEditFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf saveEditFinish:NO Data:nil];
    }];
}

- (void)saveEditFinish:(BOOL)success Data:(id)result
{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    NSString *tip = nil;
    if (success) {
        tip = [result valueForKey:@"message"];
        for (id controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[FamilyStuListViewController class]]) {
                [controller setIsRefreshData:YES];
                [self.navigationController popToViewController:controller animated:YES];
            }
            if ([controller isKindOfClass:[EditFamilyViewController class]]) {
                [controller setIsRefreshData:YES];
                [self.navigationController popToViewController:controller animated:YES];
            }
            if ([controller isKindOfClass:[LeaveMessageViewController class]]) {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    }
    else
    {
        tip = @"保存失败";
    }
    [self.navigationController.view makeToast:tip duration:1.0 position:@"center"];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    FamilyDetailModel *model = [self.dataSource objectAtIndex:section];
    return [model.item_list count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat hei = 60;
    if (indexPath.row != 0) {
        FamilyDetailModel *model = [self.dataSource objectAtIndex:indexPath.section];
        OptionsItem *item = [model.item_list objectAtIndex:indexPath.row - 1];
        hei = item.class_contHei + 5 + 2 + 26;
    }
    return hei;
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
    static NSString *cellId1 = @"NoPiechatDetailCell1";
    static NSString *cellId2 = @"NoPiechatDetailCell2";
    static NSString *cellId3 = @"NoPiechatDetailCell3";
    
    FamilyDetailModel *model = [self.dataSource objectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: (indexPath.row == 0) ? cellId1 : ((indexPath.row == [model.item_list count]) ? cellId3 : cellId2)];
    if (cell == nil) {
        if (indexPath.row == 0) {
            cell = [[FamilyEditHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId1];
        }else if (indexPath.row == [model.item_list count]) {
            cell = [[FamilyEditFooterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId3];
        }else {
            cell = [[FamilyEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId2];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    if (indexPath.row == 0) {
        [(FamilyEditHeaderCell *)cell resetFamilyEditHeaderData:model];
    }else if (indexPath.row == [model.item_list count]){
        OptionsItem *item = [model.item_list objectAtIndex:indexPath.row - 1];
        [(FamilyEditFooterCell *)cell resetFamilyEditFooterData:item Options:_optionArray];
    }else {
        OptionsItem *item = [model.item_list objectAtIndex:indexPath.row - 1];
        [(FamilyEditCell *)cell resetFamilyEditData:item Options:_optionArray];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    id edit = _tableView.tableFooterView;
    if ([edit isKindOfClass:[EditTextView class]]) {
        if (((EditTextView *)edit).textView.isFirstResponder) {
            [((EditTextView *)edit).textView resignFirstResponder];
        }
    }
}

@end
