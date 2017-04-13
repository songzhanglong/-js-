//
//  GrowNewViewController.m
//  NewTeacher
//
//  Created by szl on 16/5/4.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "GrowNewViewController.h"
#import "GrowNewCell.h"
#import "SelectCooperateViewController.h"
#import "SetTemplateViewController.h"
#import "AdDetailViewController.h"
#import "GrowNewDetailController.h"
#import "Toast+UIView.h"
#import "GrowPrintStep1ViewController.h"

@interface GrowNewViewController ()<GrowNewCellDelegate,GrowNewDetailControllerDelegate,UIAlertViewDelegate>

@end

@implementation GrowNewViewController
{
    NSIndexPath *_indexPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"成长档案";
    self.titleLable.textColor = [UIColor whiteColor];
    UIButton *leftBut = (UIButton *)((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView;
    [leftBut setFrame:CGRectMake(0, 0, 40, 30)];
    [leftBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backL@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [self createRightButton];
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    [self createTableViewAndRequestAction:@"grow:grow_list" Param:@{@"teacher_id":user.userid,@"class_id":user.classid} Header:YES Foot:NO];
    [_tableView setBackgroundColor:CreateColor(236, 235, 243)];
    
    [self beginRefresh];
}

- (void)createTableHeaderView{
    if (_tableView.tableHeaderView) {
        return;
    }
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    [headView setBackgroundColor:_tableView.backgroundColor];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 4, headView.frameWidth - 20, 16)];
    [titleLab setBackgroundColor:headView.backgroundColor];
    [titleLab setTextColor:[UIColor darkGrayColor]];
    [titleLab setFont:[UIFont systemFontOfSize:12]];
    [titleLab setText:@"如需打印，请务必保证页数为20至30之间的双数"];
    [headView addSubview:titleLab];
    [_tableView setTableHeaderView:headView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_shouldRefresh) {
        [self beginRefresh];
        _shouldRefresh = NO;
    }
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

#pragma mark - GrowNewDetailControllerDelegate
- (void)changeFinishCount
{
    if (_indexPath) {
        [_tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - GrowNewCellDelegate
- (void)selectNewCell:(UITableViewCell *)cell At:(NSInteger)index
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    _indexPath = indexPath;
    switch (index) {
        case 0:
        {
            //设置模板
            TermGrowList *item = self.dataSource[indexPath.section];
            if ([item.term_id length] <= 0) {
                [self.view makeToast:@"您还没有创建学期哦" duration:1.0 position:@"center"];
                return;
            }
            SetTemplateViewController *setTemplate = [[SetTemplateViewController alloc] init];
            setTemplate.termGrow = self.dataSource[indexPath.section];
            [self.navigationController pushViewController:setTemplate animated:YES];
        }
            break;
        case 1:
        {
            
            //开启协作
            TermGrowList *item = self.dataSource[indexPath.section];
            if ([item.term_id length] <= 0) {
                [self.view makeToast:@"您还没有创建学期哦" duration:1.0 position:@"center"];
                return;
            }
            SelectCooperateViewController *cooperate = [[SelectCooperateViewController alloc] init];
            cooperate.termGrow = self.dataSource[indexPath.section];
            [self.navigationController pushViewController:cooperate animated:YES];
        }
            break;
        case 2:{
            TermGrowList *termGrow = self.dataSource[indexPath.section];
            if ([termGrow.tpl_count integerValue] % 2 == 0 && [termGrow.tpl_count integerValue] >= 20 && [termGrow.tpl_count integerValue] <= 30) {
                if ([termGrow.term_id length] <= 0) {
                    [self.view makeToast:@"您还没有创建学期哦" duration:1.0 position:@"center"];
                    return;
                }
                GrowPrintStep1ViewController *print = [[GrowPrintStep1ViewController alloc] init];
                print.termGrow = self.dataSource[indexPath.section];
                [self.navigationController pushViewController:print animated:YES];
            }else{
                NSString *message = @"由于装订方面的原因，模板页数为单数的成长档案无法打印成册，建议您尽快到【设置模板】功能中将模板页数调整为双数。";
                if ([termGrow.tpl_count integerValue] < 20 || [termGrow.tpl_count integerValue] > 30) {
                    message = @"由于装订方面的原因，模板页数必须在20至30之间的成长档案方可打印成册，建议您尽快到【设置模板】功能中设置模板页数";
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
        setTemplate.termGrow = self.dataSource[_indexPath.section];
        [self.navigationController pushViewController:setTemplate animated:YES];
    }
}

- (void)startToMake:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    GrowNewDetailController *detail = [[GrowNewDetailController alloc] init];
    detail.termGrow = self.dataSource[indexPath.section];
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - 网络请求结束
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    if (!success) {
        NSString *ret_msg = [result valueForKey:@"message"];
        ret_msg = ret_msg ?: REQUEST_FAILE_TIP;
        [self.view makeToast:ret_msg duration:1.0 position:@"center"];
    }
    else{
        NSArray *dataList = [result valueForKey:@"data"];
        if (dataList && [dataList isKindOfClass:[NSArray class]]) {
            self.dataSource = [TermGrowList arrayOfModelsFromDictionaries:dataList error:nil];
        }
        else{
            self.dataSource = nil;
        }
        [_tableView reloadData];
    }
    [self createTableHeaderView];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *growNewCell = @"newcell";
    GrowNewCell *cell = [tableView dequeueReusableCellWithIdentifier:growNewCell];
    if (cell == nil) {
        cell = [[GrowNewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:growNewCell];
        cell.delegate = self;
    }
    
    [cell resetDataSource:self.dataSource[indexPath.section]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _indexPath = indexPath;
    GrowNewDetailController *detail = [[GrowNewDetailController alloc] init];
    detail.termGrow = self.dataSource[indexPath.section];
    detail.delegate = self;
    [self.navigationController pushViewController:detail animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? 4 : 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = tableView.backgroundColor;
}

@end
