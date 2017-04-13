//
//  GrowUndoPrintViewController.m
//  NewTeacher
//
//  Created by zhangxs on 16/6/22.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "GrowUndoPrintViewController.h"
#import "Toast+UIView.h"
#import "TermGrowDetailModel.h"
#import "GrowPrintStepCell.h"
#import "GrowPrintRecordViewController.h"

@interface GrowUndoPrintViewController ()<UIAlertViewDelegate>
{
    NSIndexPath *_indexPath;
    NSMutableArray *_checkArr;
    UILabel *_numLab;
}
@end
@implementation GrowUndoPrintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.textColor = [UIColor whiteColor];
    self.view.backgroundColor = CreateColor(236, 235, 243);
    
    _checkArr = [NSMutableArray array];
    UIButton *leftBut = (UIButton *)((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView;
    [leftBut setFrame:CGRectMake(0, 0, 40, 30)];
    [leftBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backL@2x" ofType:@"png"]] forState:UIControlStateNormal];
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    [self createTableViewAndRequestAction:@"grow:print_detail" Param:@{@"class_id": user.classid,@"term_id":_termGrow.term_id,@"templist_id":_termGrow.templist_id,@"teacher_id":user.userid,@"print_time":_record.create_time,@"print_teacher":_record.create_teacher} Header:YES Foot:NO];
    [_tableView setAutoresizingMask:UIViewAutoresizingNone];
    [_tableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 51)];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self createBottomView];
    
    [self beginRefresh];
}

- (void)createBottomView
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _tableView.frameBottom, _tableView.frameWidth, 51)];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bottomView];
    
    UIView *marginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bottomView.frameWidth, 7)];
    [marginView setBackgroundColor:_tableView.backgroundColor];
    [bottomView addSubview:marginView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, marginView.frameBottom + 13, 55, 18)];
    [label setText:@"已选择:"];
    [label setFont:[UIFont systemFontOfSize:14]];
    [label setTextColor:[UIColor darkGrayColor]];
    [bottomView addSubview:label];
    
    UILabel *numLab = [[UILabel alloc] initWithFrame:CGRectMake(label.frameRight, marginView.frameBottom + 10, 48, 24)];
    _numLab = numLab;
    [numLab setFont:[UIFont systemFontOfSize:20]];
    [numLab setTextColor:CreateColor(67, 154, 215)];
    [bottomView addSubview:numLab];
    
    UIButton *nextStep = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextStep setFrame:CGRectMake(bottomView.frameWidth - 10 - 90, 10 + marginView.frameBottom, 90, 24)];
    nextStep.layer.masksToBounds = YES;
    nextStep.layer.cornerRadius = 2;
    [nextStep setBackgroundColor:CreateColor(67, 154, 215)];
    [nextStep setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextStep setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [nextStep setTitle:@"确 认" forState:UIControlStateNormal];
    [nextStep.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [nextStep addTarget:self action:@selector(usrSure:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:nextStep];
}

- (void)usrSure:(id)sender
{
    if ([_checkArr count] == 0) {
        [self.view makeToast:@"请选择需要撤销的学生" duration:1.0 position:@"center"];
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请仔细检查撤销打印的用户明细，确认提交后将不能修改！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma mark - 撤销打印
- (void)undoCommitPrint
{
    self.view.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    //针对老接口
    NSString *url = [URLFACE stringByAppendingString:@"grow:print_cancel"];
    NSMutableArray *array = [NSMutableArray array];
    //NSMutableArray *array1 = [NSMutableArray array];
    for (TermStudent *stu in _checkArr) {
        [array addObject:stu.student_id];
        //[array1 addObject:stu.grow_num];
    }
    NSString *grow_ids = [array componentsJoinedByString:@","];
    //NSString *grow_nums = [array1 componentsJoinedByString:@","];
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    NSDictionary *param = @{@"class_id": user.classid,@"term_id":_termGrow.term_id,@"templist_id":_termGrow.templist_id,@"teacher_id":user.userid,@"print_teacher":_record.create_teacher,@"print_time":_record.create_time,@"student_ids":grow_ids/*,@"grow_nums":grow_nums*/};
    __weak typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf commitFinish:success Data:data];
        });
    } failedBlock:^(NSString *description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf commitFinish:NO Data:nil];
        });
    }];
}

- (void)commitFinish:(BOOL)suc Data:(id)result
{
    self.view.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    self.httpOperation = nil;
    if (suc) {
        [self.navigationController.view makeToast:@"已成功撤销打印需求" duration:1.0 position:@"center"];
        for (id controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[GrowPrintRecordViewController class]]) {
                ((GrowPrintRecordViewController *)controller).shouldRefresh = YES;
                ((GrowPrintRecordViewController *)controller).sucPrint = YES;
                break;
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        NSString *tip = @"数据请求失败";
        if (result && [result valueForKey:@"message"]) {
            tip = [result valueForKey:@"message"];
        }
        [self.view makeToast:tip duration:1.0 position:@"center"];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex == 0) {
            NSMutableString *phone = [[NSMutableString alloc] initWithFormat:@"telprompt://%@",@"4000250188"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
        }
    }else {
        if (buttonIndex == 1) {
            [self undoCommitPrint];
        }
    }
}

#pragma mark - 网络请求结束
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    if (!success) {
        NSString *tip = @"数据请求失败";
        if (result && [result valueForKey:@"message"]) {
            tip = [result valueForKey:@"message"];
        }
        [self.view makeToast:tip duration:1.0 position:@"center"];
    }
    else
    {
        id data = [result valueForKey:@"data"];
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            self.titleLable.text = [data valueForKey:@"term_name"] ?: @"";
            id list = [data valueForKey:@"list"];
            if (list && [list isKindOfClass:[NSArray class]]) {
                self.dataSource = [TermStudent arrayOfModelsFromDictionaries:list error:nil];
            }
            
            [_tableView reloadData];
        }
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = CreateColor(67, 154, 215);
    }
    else
    {
        navBar.tintColor = CreateColor(67, 154, 215);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = [UIColor whiteColor];
    }
    else
    {
        navBar.tintColor = CreateColor(233.0, 233.0, 233.0);
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *printCellId = @"UndoprintCellIdentifier";
    GrowPrintStepCell *cell = [tableView dequeueReusableCellWithIdentifier:printCellId];
    if (cell == nil) {
        cell = [[GrowPrintStepCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:printCellId];
    }
    TermStudent *object = self.dataSource[indexPath.row];
    //[cell setIsUndoPrint:YES];
    [cell resetDataSource:object];
    
    if ([_checkArr containsObject:object]) {
        [cell setHasPrintBackView];
    }else {
        cell.isChecked = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _indexPath = indexPath;
    TermStudent *object = self.dataSource[indexPath.row];
    if ([_checkArr containsObject:object]) {
        [_checkArr removeObject:object];
    }
    else{
        if ([object.status integerValue] == 0) {
            [_checkArr addObject:object];
        }else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"使用提示" message:@"无法选择撤销，如需帮助请与客服联系。" delegate:self cancelButtonTitle:@"联系客服" otherButtonTitles:@"我知道了", nil];
            [alert setTag:100];
            [alert show];
            return;
        }
    }
    
    [_numLab setText:[NSString stringWithFormat:@"%ld",(long)[_checkArr count]]];

    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    [headView setBackgroundColor:CreateColor(232, 232, 232)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 20)];
    label.backgroundColor = [UIColor clearColor];
    [label setText:@"请选择需要撤销的学生"];
    [label setTextColor:[UIColor blackColor]];
    [label setFont:[UIFont systemFontOfSize:12]];
    [headView addSubview:label];
    return headView;
}

@end
