//
//  GrowNewDetailController.m
//  NewTeacher
//
//  Created by szl on 16/5/4.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "GrowNewDetailController.h"
#import "AdDetailViewController.h"
#import "Toast+UIView.h"
#import "ProgressLayer.h"
#import "GrowMakedViewController.h"
#import "GrowNewExtendCell.h"
#import "GrowStudentCell.h"
#import "GrowPrintStep1ViewController.h"
#import "SelectCooperateViewController.h"
#import "SetTemplateViewController.h"

@interface GrowNewDetailController ()<GrowNewCellDelegate,GrowStudentCellDelegate,UIAlertViewDelegate>

@property (nonatomic,strong)TermGrowDetailModel *growDetail;

@end

@implementation GrowNewDetailController
{
    NSMutableArray *_unfinishedArray,*_finishedArray;
    BOOL _showTerm,_isEditTemplate;
    UIImageView *_tipView;
    UILabel *_tipLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.showBack = YES;
    self.titleLable.text = @"成长档案";
    self.titleLable.textColor = [UIColor whiteColor];
    _showTerm = YES;
    
    UIButton *leftBut = (UIButton *)((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView;
    [leftBut setFrame:CGRectMake(0, 0, 40, 30)];
    [leftBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backL@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [self createRightButton];
    
    //分组数据
    _unfinishedArray = [NSMutableArray array];
    _finishedArray = [NSMutableArray array];
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    [self createTableViewAndRequestAction:@"grow:student_list" Param:@{@"class_id": user.classid ?: @"",@"term_id":_termGrow.term_id ?: @"",@"templist_id":_termGrow.templist_id ?: @"",@"teacher_id":user.userid ?: @"",@"finish_only":@"0"} Header:YES Foot:NO];
    [_tableView setBackgroundColor:CreateColor(236, 235, 243)];
    [self createTableHeadView];
    
    [self beginRefresh];
}

- (void)createRightButton
{
    //right
    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    infoBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
    infoBtn.backgroundColor = [UIColor clearColor];
    [infoBtn setImage:CREATE_IMG(@"growInfo") forState:UIControlStateNormal];
    [infoBtn setImage:CREATE_IMG(@"growInfoH") forState:UIControlStateHighlighted];
    [infoBtn addTarget:self action:@selector(useHelp:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightButtonItem];
}

- (void)useHelp:(id)sender
{
    //使用帮助
    AdDetailViewController *order = [[AdDetailViewController alloc] init];
    order.url = @"http://h5v2.goonbaby.com/v-U702A2H9QG";
    [self.navigationController pushViewController:order animated:YES];
}

- (void)createTableHeadView
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    [headView setBackgroundColor:_showTerm ? _tableView.backgroundColor : [UIColor whiteColor]];
    
    UIButton *headBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [headBut setFrame:headView.bounds];
    [headBut setBackgroundColor:headView.backgroundColor];
    [headBut addTarget:self action:@selector(expandTableView:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:headBut];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((headView.frameWidth - 33) / 2, 0, 33, 16.5)];
    NSString *name = _showTerm ? @"growDown" : @"growUp";
    [imgView setImage:CREATE_IMG(name)];
    [headView addSubview:imgView];
    
    [_tableView setTableHeaderView:headView];
}

- (void)expandTableView:(id)sender
{
    _showTerm = !_showTerm;
    [self createTableHeadView];
    [_tableView reloadData];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_shouldRefresh) {
        _shouldRefresh = NO;
        [self beginRefresh];
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

#pragma mark - 未开通提示
- (void)setCenterView
{
    if (_unfinishedArray.count == 0 && _finishedArray.count == 0) {
        if (!_tipView) {
            _tipView = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 111) / 2, ([UIScreen mainScreen].bounds.size.height - 64 - 94.5) / 2 - 25, 111, 94.5)];
            [_tipView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"png"]]];
            [self.view addSubview:_tipView];
        }
        else if (![_tipView isDescendantOfView:self.view])
        {
            [self.view addSubview:_tipView];
        }
        if (!_tipLabel) {
            _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, ([UIScreen mainScreen].bounds.size.height - 64 - 94.5) / 2 + 70, [UIScreen mainScreen].bounds.size.width - 100, 50)];
            _tipLabel.backgroundColor = [UIColor clearColor];
            _tipLabel.text = [NSString stringWithFormat:@"请联系园所管理员\n设置成长档案模板"];
            _tipLabel.numberOfLines = 2;
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            [self.view addSubview:_tipLabel];
        }
        else if (![_tipLabel isDescendantOfView:self.view])
        {
            [self.view addSubview:_tipLabel];
        }
    }
    else
    {
        if (_tipView && [_tipView isDescendantOfView:self.view]) {
            [_tipView removeFromSuperview];
            _tipView = nil;
        }
        if (_tipLabel && [_tipLabel isDescendantOfView:self.view]) {
            [_tipLabel removeFromSuperview];
            _tipLabel = nil;
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
            NSError *error;
            TermGrowDetailModel *detail = [[TermGrowDetailModel alloc] initWithDictionary:data error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                return;
            }
            self.growDetail = detail;
            _isEditTemplate = [detail.tpl_edit_flag integerValue];
            
            [_unfinishedArray removeAllObjects];
            [_finishedArray removeAllObjects];
            BOOL hasCheck = NO;
            for (TermStudent *stu in detail.list) {
                if (stu.total_count.integerValue <= stu.finish_count.integerValue) {
                    [_finishedArray addObject:stu];
                }
                else{
                    [_unfinishedArray addObject:stu];
                }
                
                if (!hasCheck) {
                    hasCheck = YES;
                    _termGrow.tpl_count = stu.total_count;
                }
            }
            
            [self setCenterView];
            [_tableView reloadData];
            
            if (detail.finish_stu_count.integerValue != _termGrow.finish_count.integerValue) {
                _termGrow.finish_count = [NSNumber numberWithInteger:detail.finish_stu_count.integerValue];
                if (_delegate && [_delegate respondsToSelector:@selector(changeFinishCount)]) {
                    [_delegate changeFinishCount];
                }
            }
        }
    }
}

#pragma mark - GrowNewCellDelegate
- (void)selectNewCell:(UITableViewCell *)cell At:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            //设置模板
            SetTemplateViewController *setTemplate = [[SetTemplateViewController alloc] init];
            setTemplate.termGrow = _termGrow;
            [self.navigationController pushViewController:setTemplate animated:YES];
        }
            break;
        case 1:
        {
            //开启协作
            SelectCooperateViewController *cooperate = [[SelectCooperateViewController alloc] init];
            cooperate.termGrow = _termGrow;
            [self.navigationController pushViewController:cooperate animated:YES];

        }
            break;
        case 2:
        {
            if ([_termGrow.tpl_count integerValue] % 2 == 0 && [_termGrow.tpl_count integerValue] >= 6) {
                GrowPrintStep1ViewController *print = [[GrowPrintStep1ViewController alloc] init];
                print.termGrow = _termGrow;
                [self.navigationController pushViewController:print animated:YES];
            }else{
                NSString *message = @"由于装订方面的原因，模板页数为单数的成长档案无法打印成册，建议您尽快到【设置模板】功能中将模板页数调整为双数。";
                if ([_termGrow.tpl_count integerValue] < 6) {
                    message = @"由于装订方面的原因，模板页数小于6张的成长档案无法打印成册，建议您尽快到【设置模板】功能中增加模板页数";
                }
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"使用提示" message:message delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:@"去设置模板", nil];
                [alertView show];
            }
        }
            break;
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        SetTemplateViewController *setTemplate = [[SetTemplateViewController alloc] init];
        setTemplate.termGrow = _termGrow;
        [self.navigationController pushViewController:setTemplate animated:YES];
    }
}

#pragma mark - GrowStudentCellDelegate
- (void)selectGrowStudentCell:(UITableViewCell *)cell At:(TermStudent *)student
{
    GrowMakedViewController *maked = [[GrowMakedViewController alloc] init];
    maked.detailModel = _growDetail;
    student.templist_id = _termGrow.templist_id;
    student.term_id = _termGrow.term_id;
    maked.student = student;
    [self.navigationController pushViewController:maked animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _showTerm ? 0 : 1;
    }
    else
    {
        NSArray *array = (section == 1) ? _unfinishedArray : _finishedArray;
        if (array.count == 0) {
            return 0;
        }
        
        NSInteger rows = (array.count - 1) / 4 + 1; //每行4个
        return rows;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = (indexPath.section == 0) ? @"termCellId" : @"stuTermCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        if (indexPath.section == 0) {
            cell = [[GrowNewExtendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            [(GrowNewExtendCell *)cell setDelegate:self];
        }
        else{
            cell = [[GrowStudentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            [(GrowStudentCell *)cell setDelegate:self];
        }
    }
    if (indexPath.section == 0) {
        [(GrowNewExtendCell *)cell resetDataSource:_termGrow];
    }
    else{
        NSArray *array = (indexPath.section == 1) ? _unfinishedArray : _finishedArray;
        NSMutableArray *lastAr = [NSMutableArray array];
        NSInteger preIdx = indexPath.row * 4;
        NSInteger count = MIN(4, array.count - preIdx);
        for (NSInteger i = preIdx; i < count + preIdx; i++) {
            [lastAr addObject:array[i]];
        }
        [(GrowStudentCell *)cell resetDataSource:lastAr];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 115;
    }
    else{
        return 100;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    else{
        NSArray *array = (section == 1) ? _unfinishedArray : _finishedArray;
        return ([array count] == 0) ? 0 : 23;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [UIView new];
    }
    else
    {
        static NSString *growNewDetail = @"growNewDetail";
        UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:growNewDetail];
        if (header == nil) {
            header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:growNewDetail];
            header.contentView.backgroundColor = tableView.backgroundColor;
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 18)];
            [label setBackgroundColor:tableView.backgroundColor];
            [label setTag:1];
            [label setFont:[UIFont systemFontOfSize:14]];
            [label setTextColor:[UIColor blackColor]];
            [header.contentView addSubview:label];
        }
        
        NSArray *array = (section == 1) ? _unfinishedArray : _finishedArray;
        UILabel *label = (UILabel *)[header.contentView viewWithTag:1];
        if (array.count == 0) {
            label.hidden = YES;
        }
        else{
            label.hidden = NO;
            [label setText:(section == 1) ? @"未完成" : @"已完成"];
        }
        
        return header;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    else{
        cell.backgroundColor = tableView.backgroundColor;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
