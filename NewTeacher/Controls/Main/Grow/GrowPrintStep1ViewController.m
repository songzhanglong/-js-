//
//  GrowPrintStep1ViewController.m
//  NewTeacher
//
//  Created by szl on 16/5/11.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "GrowPrintStep1ViewController.h"
#import "TermGrowList.h"
#import "GrowPrintStepCell.h"
#import "Toast+UIView.h"
#import "HorizontalButton.h"
#import "GrowPrintStep2ViewController.h"
#import "GrowPrintRecordViewController.h"

@interface GrowPrintStep1ViewController ()<UIAlertViewDelegate>

@end

@implementation GrowPrintStep1ViewController
{
    NSMutableArray *_checkArr;
    HorizontalButton *_horiBut;
    NSIndexPath *_indexPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = _termGrow.term_name;
    self.titleLable.textColor = [UIColor whiteColor];
    self.view.backgroundColor = CreateColor(236, 235, 243);
    UIButton *leftBut = (UIButton *)((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView;
    [leftBut setFrame:CGRectMake(0, 0, 40, 30)];
    [leftBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backL@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [self createRightButton];
    
    _checkArr = [NSMutableArray array];
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    [self createTableViewAndRequestAction:@"grow:student_list" Param:@{@"class_id": user.classid,@"term_id":_termGrow.term_id,@"templist_id":_termGrow.templist_id,@"teacher_id":user.userid,@"finish_only":@"1"} Header:YES Foot:NO];
    [_tableView setAutoresizingMask:UIViewAutoresizingNone];
    [_tableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 51)];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self beginRefresh];
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
    if (_horiBut) {
        return;
    }
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _tableView.frameBottom, _tableView.frameWidth, 51)];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bottomView];
    
    UIView *marginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bottomView.frameWidth, 7)];
    [marginView setBackgroundColor:_tableView.backgroundColor];
    [bottomView addSubview:marginView];
    
    HorizontalButton *horiBut = [HorizontalButton buttonWithType:UIButtonTypeCustom];
    horiBut.leftText = YES;
    [horiBut setFrame:CGRectMake(10, 12 + marginView.frameBottom, 50, 20)];
    _horiBut = horiBut;
    horiBut.textSize = CGSizeMake(40, 18);
    horiBut.imgSize = CGSizeMake(20, 20);
    [horiBut setTitle:@"全选" forState:UIControlStateNormal];
    [horiBut setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    horiBut.titleLabel.font = [UIFont systemFontOfSize:14];
    horiBut.titleLabel.textAlignment = NSTextAlignmentCenter;
    [horiBut setImage:CREATE_IMG(@"growUnSel") forState:UIControlStateNormal];
    [horiBut setImage:CREATE_IMG(@"growSel") forState:UIControlStateSelected];
    [_horiBut addTarget:self action:@selector(selectAllStudents:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_horiBut];
    
    UIButton *nextStep = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextStep setFrame:CGRectMake(bottomView.frameWidth - 10 - 90, 10 + marginView.frameBottom, 90, 24)];
    nextStep.layer.masksToBounds = YES;
    nextStep.layer.cornerRadius = 2;
    [nextStep setBackgroundColor:CreateColor(67, 154, 215)];
    [nextStep setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextStep setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [nextStep setTitle:@"下一步" forState:UIControlStateNormal];
    [nextStep.titleLabel setFont:_horiBut.titleLabel.font];
    [nextStep addTarget:self action:@selector(gotoNextStep:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:nextStep];
}

- (void)checkRecord:(id)sender
{
    GrowPrintRecordViewController *printRecord = [[GrowPrintRecordViewController alloc] init];
    printRecord.termGrow = _termGrow;
    [self.navigationController pushViewController:printRecord animated:YES];
}

- (void)selectAllStudents:(id)sender
{
    if (!_horiBut.selected) {
        for (TermStudent *object in self.dataSource) {
            if ([object.print_count integerValue] > 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"使用提示" message:@"当前所选学生已存在提交记录，是否继续选择提交？" delegate:self cancelButtonTitle:@"返回重选" otherButtonTitles:@"继续提交", nil];
                [alertView setTag:100];
                [alertView show];
                return;
            }
        }
    }
    
    _horiBut.selected = !_horiBut.selected;
    [_checkArr removeAllObjects];
    if (_horiBut.selected) {
        [_checkArr addObjectsFromArray:self.dataSource];
    }
    [_tableView reloadData];
}

- (void)gotoNextStep:(id)sender
{
    if (_checkArr.count == 0) {
        [self.view makeToast:@"请先选择需要提交打印的学生" duration:1.0 position:@"center"];
        return;
    }
    
    GrowPrintStep2ViewController *step2 = [[GrowPrintStep2ViewController alloc] init];
    step2.termGrow = _termGrow;
    step2.dataSource = _checkArr;
    [self.navigationController pushViewController:step2 animated:YES];
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

- (void)createTableFootView
{
    if ([self.dataSource count] > 0) {
        [_tableView setTableFooterView:[UIView new]];
    }
    else{
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 90 + 40 +  5 + 14 + 2 + 14)];
        [footView setBackgroundColor:_tableView.backgroundColor];
        
        UIImageView *tipImg = [[UIImageView alloc] initWithFrame:CGRectMake((footView.frameWidth - 44) / 2, 90, 44, 40)];
        [tipImg setImage:CREATE_IMG(@"termTip")];
        [footView addSubview:tipImg];
        
        UILabel *tipLab1 = [[UILabel alloc] initWithFrame:CGRectMake(0, tipImg.frameBottom + 5, footView.frameWidth, 14)];
        [tipLab1 setBackgroundColor:footView.backgroundColor];
        [tipLab1 setFont:[UIFont systemFontOfSize:10]];
        [tipLab1 setTextAlignment:NSTextAlignmentCenter];
        [tipLab1 setTextColor:[UIColor darkGrayColor]];
        [tipLab1 setText:@"您学生的成长档案都还没有制作完成哦，"];
        [footView addSubview:tipLab1];
        
        UILabel *tipLab2 = [[UILabel alloc] initWithFrame:CGRectMake(tipLab1.frameX, tipLab1.frameBottom + 2, tipLab1.frameWidth, tipLab1.frameHeight)];
        [tipLab2 setBackgroundColor:tipLab1.backgroundColor];
        [tipLab2 setFont:tipLab1.font];
        [tipLab2 setTextAlignment:NSTextAlignmentCenter];
        [tipLab2 setTextColor:tipLab1.textColor];
        [tipLab2 setText:@"请制作完成选择打印服务。"];
        [footView addSubview:tipLab2];
        
        [_tableView setTableFooterView:footView];
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
            id list = [data valueForKey:@"list"];
            if (list && [list isKindOfClass:[NSArray class]]) {
                self.dataSource = [TermStudent arrayOfModelsFromDictionaries:list error:nil];
                NSMutableArray *array = [NSMutableArray arrayWithArray:_checkArr];
                [_checkArr removeAllObjects];
                for (TermStudent *checkStu in array) {
                    for (TermStudent *stu in self.dataSource) {
                        if ([checkStu.student_id isEqualToString:stu.student_id]) {
                            [_checkArr addObject:stu];
                            break;
                        }
                    }
                }
                [_tableView reloadData];
                if ([self.dataSource count] == 0) {
                    if (_horiBut) {
                        [[_horiBut superview] removeFromSuperview];
                        _horiBut = nil;
                    }
                }
                else{
                    [self createBottomView];
                }
            }
        }
        [self createTableFootView];
    }
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            _horiBut.selected = !_horiBut.selected;
            [_checkArr removeAllObjects];
            if (_horiBut.selected) {
                [_checkArr addObjectsFromArray:self.dataSource];
            }
            [_tableView reloadData];
        }
        
    }else {
        if (buttonIndex == 1) {
            id object = self.dataSource[_indexPath.row];
            if ([_checkArr containsObject:object]) {
                [_checkArr removeObject:object];
            }
            else{
                [_checkArr addObject:object];
            }
            _horiBut.selected = (_checkArr.count == [self.dataSource count]);
            
            [_tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *printCellId = @"printCellIdentifier";
    GrowPrintStepCell *cell = [tableView dequeueReusableCellWithIdentifier:printCellId];
    if (cell == nil) {
        cell = [[GrowPrintStepCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:printCellId];
    }
    
    id object = self.dataSource[indexPath.row];
    [cell resetDataSource:object];
    cell.isChecked = [_checkArr containsObject:object];
    
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
        if ([object.print_count integerValue] > 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"使用提示" message:@"当前所选学生已存在提交记录，是否继续选择提交？" delegate:self cancelButtonTitle:@"返回重选" otherButtonTitles:@"继续提交", nil];
            [alertView show];
            return;
        }else {
            [_checkArr addObject:object];
        }
    }
    
    _horiBut.selected = (_checkArr.count == [self.dataSource count]);
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 90;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 90)];
    [backView setBackgroundColor:_tableView.backgroundColor];
    
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, backView.frameWidth, 83)];
    [upView setBackgroundColor:[UIColor whiteColor]];
    [backView addSubview:upView];
    
    CGFloat imgW = 296,imgH = 38;
    
    UIImageView *stepImg = [[UIImageView alloc] initWithFrame:CGRectMake((upView.frameWidth - imgW) / 2, (upView.frameHeight - imgH - 7 - 14) / 2, imgW, imgH)];
    [stepImg setImage:CREATE_IMG(@"growsStep1")];
    [upView addSubview:stepImg];
    
    CGFloat labelWei = 50,xOri = stepImg.frameX + 45 - labelWei / 2;
    NSArray *array = @[@"选择学生",@"确定信息",@"提交打印"];
    for (NSInteger i = 0; i < array.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xOri + 103 * i, stepImg.frameBottom + 7, labelWei, 14)];
        [label setFont:[UIFont systemFontOfSize:10]];
        [label setBackgroundColor:upView.backgroundColor];
        [label setText:array[i]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:(i == 0) ? [UIColor blackColor] : [UIColor lightGrayColor]];
        [upView addSubview:label];
    }
    
    return backView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

@end
