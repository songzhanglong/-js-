//
//  GrowPrintRecordViewController.m
//  NewTeacher
//
//  Created by szl on 16/5/11.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "GrowPrintRecordViewController.h"
#import "TermGrowList.h"
#import "GrowPrintRecordCell.h"
#import "Toast+UIView.h"
#import "GrowUndoPrintViewController.h"
#import "GrowNewViewController.h"

@interface GrowPrintRecordViewController ()<GrowPrintRecordCellDelegate,UIAlertViewDelegate>

@end

@implementation GrowPrintRecordViewController

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
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    NSDictionary *param = @{@"class_id": user.classid,@"term_id":_termGrow.term_id,@"templist_id":_termGrow.templist_id,@"teacher_id":user.userid};
    [self createTableViewAndRequestAction:@"grow:print_list" Param:param Header:YES Foot:NO];
    [_tableView setBackgroundColor:CreateColor(236, 235, 243)];
    [self createTableHeaderView];
    
    [self beginRefresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_shouldRefresh) {
        [self beginRefresh];
        _shouldRefresh = NO;
    }
}

#pragma mark - create right button
- (void)createRightButton
{
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setFrame:CGRectMake(0, 0, 40, 30)];
    [sendButton setImage:CREATE_IMG(@"service") forState:UIControlStateNormal];
    [sendButton setImageEdgeInsets:UIEdgeInsetsMake(2.5, 7.5, 2.5, 7.5)];
    [sendButton addTarget:self action:@selector(serviceAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,item];
}

- (void)backToPreControl:(id)sender
{
    if (_sucPrint) {
        for (UIViewController *subCon in self.navigationController.viewControllers) {
            if ([subCon isKindOfClass:[GrowNewViewController class]]) {
                ((GrowNewViewController *)subCon).shouldRefresh = YES;
                [self.navigationController popToViewController:subCon animated:YES];
                break;
            }
        }
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)serviceAction:(id)sender
{
    NSMutableString *phone = [[NSMutableString alloc] initWithFormat:@"telprompt://%@",@"4000250188"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
}

- (void)createTableHeaderView
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 37)];
    [backView setBackgroundColor:_tableView.backgroundColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, backView.frameWidth, 25)];
    [label setBackgroundColor:CreateColor(243, 219, 135)];
    [label setTextColor:CreateColor(158, 92, 7)];
    [label setText:@"  成长档案已提交打印记录"];
    [label setFont:[UIFont systemFontOfSize:12]];
    [backView addSubview:label];
    
    [_tableView setTableHeaderView:backView];
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
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 90 + 40 +  5 + 14)];
        [footView setBackgroundColor:_tableView.backgroundColor];
        
        UIImageView *tipImg = [[UIImageView alloc] initWithFrame:CGRectMake((footView.frameWidth - 44) / 2, 90, 44, 40)];
        [tipImg setImage:CREATE_IMG(@"termTip")];
        [footView addSubview:tipImg];
        
        UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, tipImg.frameBottom + 5, footView.frameWidth, 14)];
        [tipLab setBackgroundColor:footView.backgroundColor];
        [tipLab setFont:[UIFont systemFontOfSize:10]];
        [tipLab setTextAlignment:NSTextAlignmentCenter];
        [tipLab setTextColor:[UIColor darkGrayColor]];
        [tipLab setText:@"暂无提交记录"];
        [footView addSubview:tipLab];

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
        if (data && [data isKindOfClass:[NSArray class]]) {
            self.dataSource = [TermPrintRecord arrayOfModelsFromDictionaries:data error:nil];
            for (TermPrintRecord *record in self.dataSource) {
                [record calculateNamesHei];
                for (OrderStatus *item in record.student_names_group) {
                    [item calculateNamesHei];
                }
            }
            [_tableView reloadData];
        }
        [self createTableFootView];
    }
}

#pragma mark - GrowPrintRecordCellDelegate
- (void)expandPrintRecordCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    TermPrintRecord *record = self.dataSource[indexPath.row];
    NSMutableArray *paths = [NSMutableArray arrayWithObject:indexPath];
    record.isExpand = !record.isExpand;
    if (record.isExpand) {
        //关闭上一个扩展开的列表
        for (NSInteger i = 0; i < [self.dataSource count]; i++) {
            TermPrintRecord *tmpRecord = self.dataSource[i];
            if (tmpRecord.isExpand && (indexPath.row != i)) {
                tmpRecord.isExpand = NO;
                [paths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                break;
            }
        }
        [_tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else{
        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)undoPrintRecordCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    TermPrintRecord *record = self.dataSource[indexPath.row];
    if ([record.cancel_flag integerValue] == 1) {
        GrowUndoPrintViewController *controller = [[GrowUndoPrintViewController alloc] init];
        controller.record = record;
        controller.termGrow = _termGrow;
        [self.navigationController pushViewController:controller animated:YES];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"使用提示" message:@"无法选择撤销，如需帮助请与客服联系。" delegate:self cancelButtonTitle:@"联系客服" otherButtonTitles:@"我知道了", nil];
        [alert show];
    }
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self serviceAction:nil];
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *printRecordIdentifier = @"printRecordIdentifier";
    GrowPrintRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:printRecordIdentifier];
    if (cell == nil) {
        cell = [[GrowPrintRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:printRecordIdentifier];
        cell.delegate = self;
    }
    [cell resetDataSource:self.dataSource[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TermPrintRecord *record = self.dataSource[indexPath.row];
    CGFloat hei = 8 + 32;
    if (record.isExpand) {
        for (OrderStatus *item in record.student_names_group) {
            hei += MAX(18, item.namesHei) + 5;
        }
        hei += 8 + 18 + 12 + 8 + 20;
    }
    return hei;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *printRecordIdentifier = @"printRecordIdentifier";
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:printRecordIdentifier];
    if (header == nil) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:printRecordIdentifier];
        [header setBackgroundColor:_tableView.backgroundColor];
        
        UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 32)];
        [myView setBackgroundColor:CreateColor(67, 154, 215)];
        [header addSubview:myView];
        
        CGFloat labelWei = (myView.frameWidth - 30) / 3;
        NSArray *tips = @[@"时 间",@"数 量",@"提交用户"];
        for (NSInteger i = 0; i < tips.count; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * labelWei, 7, labelWei, 18)];
            [label setBackgroundColor:myView.backgroundColor];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setText:tips[i]];
            [label setFont:[UIFont boldSystemFontOfSize:14]];
            [label setTextColor:[UIColor whiteColor]];
            [myView addSubview:label];
        }
    }
    return header;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = tableView.backgroundColor;
}

@end
