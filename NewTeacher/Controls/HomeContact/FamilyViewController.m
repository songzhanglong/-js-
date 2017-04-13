//
//  FamilyViewController.m
//  NewTeacher
//
//  Created by szl on 16/5/5.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "FamilyViewController.h"
#import "FamilyStudentViewController.h"
#import "FamilyListViewController.h"
#import "FamilyContactDetailViewController.h"
#import "LeaveMessageViewController.h"
#import "FamilyStuListViewController.h"
#import "EditFamilyViewController.h"

@interface FamilyViewController ()<UIScrollViewDelegate,FamilyStudentViewControllerDelegate,FamilyListViewControllerDelegate>

@end

@implementation FamilyViewController
{
    UIView *_lineView;
    UIScrollView *_scrollView;
    DJTTableViewController *_listController,*_studentController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"家园联系";
    [self createRightBarButton];
    
    CGFloat wei = SCREEN_WIDTH / 2;
    for (NSInteger i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(wei * i, 0, wei, 32)];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [button setTitle:(i == 0) ? @"学生" : @"列表" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button setTag:i + 1];
        [button addTarget:self action:@selector(changeList:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(wei, 30, wei, 2)];
    [_lineView setBackgroundColor:CreateColor(238, 187, 32)];
    [self.view addSubview:_lineView];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 32, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 32)];
    [scrollView setContentSize:CGSizeMake(SCREEN_WIDTH * 2, scrollView.frameHeight)];
    [scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0)];
    scrollView.pagingEnabled = YES;
    _scrollView = scrollView;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    [scrollView setBackgroundColor:CreateColor(235, 235, 241)];
    [self.view addSubview:scrollView];
    
    _listController = [[FamilyListViewController alloc] init];
    ((FamilyListViewController *)_listController).delegate = self;
    _listController.view.frame = CGRectMake(scrollView.frameWidth, 0, scrollView.frameWidth, scrollView.frameHeight);
    _studentController = [[FamilyStudentViewController alloc] init];
    ((FamilyStudentViewController *)_studentController).delegate = self;
    _studentController.view.frame = CGRectMake(0, 0, scrollView.frameWidth, scrollView.frameHeight);
    [scrollView addSubview:_listController.view];
    [scrollView addSubview:_studentController.view];
}

#pragma  mark - refresh data
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_isRefreshListData) {
        [_listController beginRefresh];
        _isRefreshListData = NO;
    }
    if (_isRefreshStudentData) {
        [_studentController beginRefresh];
        _isRefreshStudentData = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = CreateColor(244, 244, 244);
    }
    else
    {
        navBar.tintColor = CreateColor(244, 244, 244);
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

- (void)createRightBarButton
{
    //返回按钮
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
    sureBtn.backgroundColor = [UIColor clearColor];
    [sureBtn setImage:CREATE_IMG(@"contactInfo") forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(checkMsgInfo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sureBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

- (void)checkMsgInfo:(id)sender
{
    LeaveMessageViewController *leaveMsgController = [[LeaveMessageViewController alloc] init];
    [self.navigationController pushViewController:leaveMsgController animated:YES];
}

- (void)changeList:(id)sender
{
    NSInteger index = [sender tag] - 1;
    [_scrollView setContentOffset:CGPointMake(index * _scrollView.frameWidth, 0) animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_lineView setFrameX:scrollView.contentOffset.x / 2];
}

#pragma mark - FamilyStudentViewControllerDelegate
- (void)getTableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditFamilyViewController *editFanilyController = [[EditFamilyViewController alloc] init];
    editFanilyController.listItem = [_studentController.dataSource objectAtIndex:indexPath.row];
    editFanilyController.create_data = _listController.dataSource;
    [self.navigationController pushViewController:editFanilyController animated:YES];
}

#pragma mark - FamilyListViewControllerDelegate
- (void)familyListDidSelectIndex:(NSIndexPath *)indexPath
{
    FamilyStuListViewController *familyStuList = [[FamilyStuListViewController alloc] init];
    familyStuList.listItem = [[_listController.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:familyStuList animated:YES];
}

@end
