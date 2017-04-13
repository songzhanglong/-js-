//
//  GrowPrintStep2ViewController.m
//  NewTeacher
//
//  Created by szl on 16/5/11.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "GrowPrintStep2ViewController.h"
#import "TermGrowList.h"
#import "GrowPrintStepCell2.h"
#import "Toast+UIView.h"
#import "Toast+UIView.h"
#import "GrowPrintRecordViewController.h"

@interface GrowPrintStep2ViewController ()<UIAlertViewDelegate,GrowPrintStepCell2Delegate>

@end

@implementation GrowPrintStep2ViewController
{
    NSInteger _nSelectIdx, _indexNum;
    UILabel *_numLabel;
    NSIndexPath *_delIndexPath;
    NSMutableArray *_grow_nums;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = _termGrow.term_name;
    self.titleLable.textColor = [UIColor whiteColor];
    UIButton *leftBut = (UIButton *)((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView;
    [leftBut setFrame:CGRectMake(0, 0, 40, 30)];
    [leftBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backL@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [self createRightButton];
    
    _nSelectIdx = 1;
    _indexNum = 0;
    _grow_nums = [NSMutableArray array];
    
    for (TermStudent *student in self.dataSource) {
        student.grow_num = @"1";
        _indexNum += [student.grow_num integerValue];
    }
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    [_tableView setAutoresizingMask:UIViewAutoresizingNone];
    [_tableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 51)];
    [_tableView setBackgroundColor:CreateColor(236, 235, 243)];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self createBottomView];
}

- (void)createRightButton
{
    //right
    UIButton *recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    recordBtn.frame = CGRectMake(0, 0, 62.0, 18.0);
    recordBtn.backgroundColor = [UIColor clearColor];
    [recordBtn setTitle:@"提交记录" forState:UIControlStateNormal];
    [recordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [recordBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [recordBtn addTarget:self action:@selector(checkRecord:) forControlEvents:UIControlEventTouchUpInside];
    recordBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:recordBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightButtonItem];
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
    [numLab setFont:[UIFont systemFontOfSize:20]];
    [numLab setTextColor:CreateColor(67, 154, 215)];
    _numLabel = numLab;
    [numLab setText:[NSString stringWithFormat:@"%ld",(long)_indexNum]];
    [bottomView addSubview:numLab];
    
    for (int i = 0; i < 2; i++) {
        UIButton *nextStep = [UIButton buttonWithType:UIButtonTypeCustom];
        [nextStep setFrame:CGRectMake(bottomView.frameWidth - 10 - 90 - i * 100, 10 + marginView.frameBottom, 90, 24)];
        nextStep.layer.masksToBounds = YES;
        nextStep.layer.cornerRadius = 2;
        [nextStep setTag:10 + i];
        [nextStep setBackgroundColor:CreateColor(67, 154, 215)];
        [nextStep setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [nextStep setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [nextStep setTitle:(i == 0) ? @"确 认" : @"上一步" forState:UIControlStateNormal];
        [nextStep.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [nextStep addTarget:self action:@selector(usrSure:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:nextStep];
    }
}

- (void)checkRecord:(id)sender
{
    if (self.httpOperation) {
        return;
    }
    
    GrowPrintRecordViewController *printRecord = [[GrowPrintRecordViewController alloc] init];
    printRecord.termGrow = _termGrow;
    [self.navigationController pushViewController:printRecord animated:YES];
}

- (void)usrSure:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    switch ([btn tag] - 10) {
        case 0:
        {
            _nSelectIdx = 2;
            UIView *headView = [_tableView headerViewForSection:0];
            [self resetHeaderSection:headView];
            
            if ([self.dataSource count] == 0) {
                [self.view makeToast:@"您没有要打印明细提交" duration:1.0 position:@"center"];
                return;
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请仔细检查提交打印的用户明细，以免影响您正常的打印服务进展。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        }
            break;
        case 1:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)resetHeaderSection:(UIView *)header
{
    UIImageView *stepImg = (UIImageView *)[header viewWithTag:10];
    NSString *str = [NSString stringWithFormat:@"growsStep%ld",(long)_nSelectIdx + 1];
    [stepImg setImage:CREATE_IMG(str)];
    for (NSInteger i = 0; i < 3; i++) {
        UILabel *label = (UILabel *)[header viewWithTag:i + 1];
        [label setTextColor:(i == _nSelectIdx) ? [UIColor blackColor] : [UIColor lightGrayColor]];
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

#pragma mark - 提交打印
- (void)commitPrint
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        
        [self performSelector:@selector(finishRefresh) withObject:nil afterDelay:0.1];
        return;
    }
    self.view.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    //针对老接口
    
    NSString *url = [URLFACE stringByAppendingString:@"grow:print_submit"];
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *array1 = [NSMutableArray array];
    for (TermStudent *stu in self.dataSource) {
        [array addObject:stu.grow_id];
        [array1 addObject:stu.grow_num];
    }
    NSString *grow_ids = [array componentsJoinedByString:@","];
    NSString *grow_nums = [array1 componentsJoinedByString:@","];
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    NSDictionary *param = @{@"class_id": user.classid,@"term_id":_termGrow.term_id,@"templist_id":_termGrow.templist_id,@"teacher_id":user.userid,@"grow_ids":grow_ids,@"grow_nums":grow_nums};
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
        [self.navigationController.view makeToast:@"已成功提交打印需求" duration:1.0 position:@"center"];
        GrowPrintRecordViewController *printRecord = [[GrowPrintRecordViewController alloc] init];
        printRecord.termGrow = _termGrow;
        printRecord.sucPrint = YES;
        [self.navigationController pushViewController:printRecord animated:YES];
    }
    else{
        NSString *tip = REQUEST_FAILE_TIP;
        if (result && [result valueForKey:@"message"]) {
            tip = [result valueForKey:@"message"];
        }
        [self.view makeToast:tip duration:1.0 position:@"center"];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == 100) {
        if (buttonIndex == 0) {
            GrowPrintStepCell2 *cell = [_tableView cellForRowAtIndexPath:_delIndexPath];
            _indexNum -= cell.num;
            [_numLabel setText:[NSString stringWithFormat:@"%ld",(long)_indexNum]];
            
            [self.dataSource removeObjectAtIndex:_delIndexPath.row];
            [_tableView deleteRowsAtIndexPaths:@[_delIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        _delIndexPath = nil;
    }else {
        if (buttonIndex == 1) {
            [self commitPrint];
        }
        else
        {
            _nSelectIdx = 1;
            UIView *headView = [_tableView headerViewForSection:0];
            [self resetHeaderSection:headView];
        }
    }
}

#pragma mark - UITableViewDataSource
- (void)upDataNumsToController:(BOOL)type
{
    if (type) {
        _indexNum++;
    }else {
        _indexNum--;
    }
    [_numLabel setText:[NSString stringWithFormat:@"%ld",(long)_indexNum]];
}

#pragma mark - GrowPrintStepCell2 delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *printCellId = @"printCellIdentifier2";
    GrowPrintStepCell2 *cell = [tableView dequeueReusableCellWithIdentifier:printCellId];
    if (cell == nil) {
        cell = [[GrowPrintStepCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:printCellId];
        cell.delegate = self;
    }
    
    TermStudent *object = self.dataSource[indexPath.row];
    [cell resetDataSource:object];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 90;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *headerIdentifier = @"step2HeaderIdentifier";
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    if (header == nil) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerIdentifier];
        [header setBackgroundColor:_tableView.backgroundColor];
        
        UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 83)];
        [upView setBackgroundColor:[UIColor whiteColor]];
        [header addSubview:upView];
        
        CGFloat imgW = 296,imgH = 38;
        
        UIImageView *stepImg = [[UIImageView alloc] initWithFrame:CGRectMake((upView.frameWidth - imgW) / 2, (upView.frameHeight - imgH - 7 - 14) / 2, imgW, imgH)];
        [stepImg setTag:10];
        [header addSubview:stepImg];
        
        CGFloat labelWei = 50,xOri = stepImg.frameX + 45 - labelWei / 2;
        NSArray *array = @[@"选择学生",@"确定信息",@"提交打印"];
        for (NSInteger i = 0; i < array.count; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xOri + 103 * i, stepImg.frameBottom + 7, labelWei, 14)];
            [label setFont:[UIFont systemFontOfSize:10]];
            [label setBackgroundColor:upView.backgroundColor];
            [label setText:array[i]];
            [label setTag:i + 1];
            [label setTextAlignment:NSTextAlignmentCenter];
            [header addSubview:label];
        }
    }
    
    [self resetHeaderSection:header];

    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        _delIndexPath = indexPath;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否确定移除本条记录？" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
        [alertView setTag:100];
        [alertView show];
    }
}

@end
