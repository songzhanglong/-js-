//
//  MyCalendarViewController.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/22.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MyCalendarViewController.h"
#import "NSString+Common.h"
#import "MyCalendarView.h"
#import "Toast+UIView.h"
#import "CalendarModel.h"
#import "NotificationListViewController.h"
#import "NSDate+Calendar.h"
#import "CurdatePhotosViewController.h"
#import "AdDetailViewController.h"
#import "DJTDeviceAttence.h"
#import "CalendarNoticeCell.h"
#import "CalendarPhotoCell.h"
#import "CalendarAttenceCell.h"
#import "AppDelegate.h"

@interface MyCalendarViewController ()<MyCalendarViewDelegate>

@end

@implementation MyCalendarViewController
{
    MyCalendarView *_calendarView;
    NSMutableDictionary *_dateDic;
    
    CGFloat _canlendHei;
    BOOL _shouldRefresh;
    UIImageView *navBarHairlineImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.useNewInterface = YES;
    self.showBack = YES;
    UIButton *leftBut = (UIButton *)((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView;
    [leftBut setFrame:CGRectMake(0, 0, 40, 30)];
    [leftBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backL@2x" ofType:@"png"]] forState:UIControlStateNormal];
    
    self.titleLable.text = [NSString stringByDate:@"yyyy年MM月" Date:[NSDate date]];
    self.titleLable.textColor = [UIColor whiteColor];
    _dateDic = [NSMutableDictionary dictionary];
    
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
   
    //今天
    UIButton *todayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [todayButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rl1" ofType:@"png"]] forState:UIControlStateNormal];
    [todayButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rl1_1" ofType:@"png"]] forState:UIControlStateHighlighted];
    [todayButton setFrame:CGRectMake(0, 0, 30, 30)];
    todayButton.hidden = YES;
    [todayButton addTarget:self action:@selector(backToToday:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:todayButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightItem];
    
    //日历
    MyCalendarView *calendar = [[MyCalendarView alloc] initWithFrame:CGRectZero];
    _calendarView = calendar;
    calendar.delegate = self;
    [calendar setCurDate:[NSDate date]];
    _canlendHei = _calendarView.frame.size.height;

    [self createTableViewAndRequestAction:@"calendar" Param:nil Header:YES Foot:NO];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    //表头
    [self resetTableHeaderView];
    [self beginRefresh];
    
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)resetTableHeaderView
{
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, _canlendHei)];
    [headView addSubview:_calendarView];

    [_tableView setTableHeaderView:headView];
}

- (void)backToToday:(id)sender
{
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).customView.hidden = YES;
    [_calendarView changeToToday];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = CreateColor(235.0, 73.0, 65.0);
    }
    else
    {
        navBar.tintColor = CreateColor(235.0, 73.0, 65.0);
    }
    
    navBarHairlineImageView.hidden = YES;
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
    
    navBarHairlineImageView.hidden = NO;
}

#pragma mark - 请求参数
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getCalendar2"];
    [param setObject:manager.userInfo.classid forKey:@"class_id"];
    [param setObject:manager.userInfo.userid forKey:@"userid"];
    [param setObject:@"1" forKey:@"week"];
    NSString *dateStr = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(long)_calendarView.year,(long)_calendarView.month,(long)_calendarView.day];
    [param setObject:dateStr forKey:@"date"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    self.param = param;
}

- (void)startPullRefresh
{
    [super startPullRefresh];
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = NO;
}

- (void)requestFinish:(BOOL)success Data:(id)result
{
    _tableView.userInteractionEnabled = YES;
    self.httpOperation = nil;
    
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = YES;
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        
        NSError *error = nil;
        CalendarModel *model = [[CalendarModel alloc] initWithDictionary:ret_data error:&error];
        if (error) {
            NSLog(@"%@",error.description);
        }
        
        self.calendarModel = model;
        
        [_dateDic setObject:model forKey:[NSString stringWithFormat:@"%ld%ld%ld",(long)_calendarView.year,(long)_calendarView.month,(long)_calendarView.day]];
        [_tableView reloadData];

        [self finishRefresh];
        [self.view hideToastActivity];
    }
    else
    {
        [self finishRefresh];
        [self.view hideToastActivity];
        NSString *ret_code = [result valueForKey:@"ret_code"];
        if (ret_code && [ret_code isEqualToString:@"8888"]) {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app popToLoginViewController];
        }
        else
        {
            NSString *ret_msg = [result valueForKey:@"ret_msg"];
            ret_msg = ret_msg ?: REQUEST_FAILE_TIP;
            [self.view makeToast:ret_msg duration:1.0 position:@"center"];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 1;
    switch (section) {
        case 1:
        {
            DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
            if (manager.userInfo.hasTimeCard) {
                if ([self.dataSource count] == 0) {
                    //count = 0;
                }
            }
        }
            break;
        case 2:
        {
            if (!_calendarModel) {
                count = 0;
            }
            else if (!_calendarModel.photo || (_calendarModel.photo.count == 0))
            {
                count = 0;
            }
        }
            break;
        case 3:
        {
            if (!_calendarModel) {
                count = 0;
            }
            else if (!_calendarModel.message || ([_calendarModel.message.content length] == 0))
            {
                count = 0;
            }
        }
            break;
        default:
            break;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"normalCellId";
    if (indexPath.section == 1) {
        cellId = @"attenceCellId";
    }
    else if (indexPath.section == 2){
        cellId = @"latestPhotoCellId";
    }
    else if (indexPath.section == 3){
        cellId = @"schoolNoticeCellId";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        switch (indexPath.section) {
            case 0:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UILabel *label = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
                [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
                [label setFont:[UIFont systemFontOfSize:16]];
                [label setTextColor:[UIColor blackColor]];
                [label setBackgroundColor:[UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]];
                [label setTag:1];
                [cell.contentView addSubview:label];
            }
                break;
            case 1:
            {
                cell = [[CalendarAttenceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            }
                break;
            case 2:
            {
                cell = [[CalendarPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            }
                break;
            case 3:
            {
                cell = [[CalendarNoticeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            }
                break;
            default:
                break;
        }
    }
    
    switch (indexPath.section) {
        case 0:
        {
            UILabel *label = (UILabel *)[cell.contentView viewWithTag:1];
            BOOL sameDay = [_calendarView.curDate sameDayWithDate:[NSDate date]];
            if (sameDay) {
                [label setText:[NSString stringWithFormat:@"    今天 | %04ld年%02ld月%02ld日",(long)_calendarView.year,(long)_calendarView.month,(long)_calendarView.day]];
            }
            else
            {
                [label setText:[NSString stringWithFormat:@"    %04ld年%02ld月%02ld日",(long)_calendarView.year,(long)_calendarView.month,(long)_calendarView.day]];
            }
        }
            break;
        case 1:
        {
            [(CalendarAttenceCell *)cell resetDataSource:_calendarModel.attence];
        }
            break;
        case 2:
        {
            [(CalendarPhotoCell *)cell resetDataSource:_calendarModel.photo];
        }
            break;
        case 3:
        {
            [(CalendarNoticeCell *)cell resetDataSource:_calendarModel.message];
        }
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 1:
        {
            [self getCKey];
        }
            break;
        case 2:
        {
            CurdatePhotosViewController *curDate = [[CurdatePhotosViewController alloc] init];
            NSString *selDate = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(long)_calendarView.year,(long)_calendarView.month,(long)_calendarView.day];
            curDate.curDate = selDate;
            [self.navigationController pushViewController:curDate animated:YES];
        }
            break;
        case 3:
        {
            NotificationListViewController *notifi = [[NotificationListViewController alloc] init];
            [self.navigationController pushViewController:notifi animated:YES];
        }
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 25;
    }
    return 72;
}


#pragma mark - MyCalendarViewDelegate
- (void)changeMonth:(MyCalendarView *)calendar
{
    CGFloat lastHei = calendar.frame.size.height;
    if (_canlendHei != lastHei) {
        _canlendHei = lastHei;
        [self resetTableHeaderView];
    }
    
    BOOL sameDay = [_calendarView.curDate sameDayWithDate:[NSDate date]];
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).customView.hidden = sameDay;
    
    self.titleLable.text = [NSString stringWithFormat:@"%ld年%ld月",(long)calendar.year,(long)calendar.month];
    
    if (!sameDay && [_calendarView.curDate compare:[NSDate date]] == NSOrderedDescending) {
        self.calendarModel = nil;
        self.dataSource = nil;
        //[_tableView reloadData];
        [self.view makeToast:@"超过今天的日期都没有数据哦~" duration:1.0 position:@"center"];
    }
    else
    {
        NSString *key = [NSString stringWithFormat:@"%ld%ld%ld",(long)_calendarView.year,(long)_calendarView.month,(long)_calendarView.day];
        NSString *device_key = [NSString stringWithFormat:@"device_%ld%ld%ld",(long)_calendarView.year,(long)_calendarView.month,(long)_calendarView.day];
        CalendarModel *model = [_dateDic objectForKey:key];
        if (model) {
            self.calendarModel = model;
            self.dataSource = [_dateDic valueForKey:device_key];
            [_tableView reloadData];
        }
        else
        {
            [_tableView reloadData];
            [self startPullRefresh];
        }
    }
}

- (void)changeDay:(MyCalendarView *)calendar
{
    BOOL sameDay = [_calendarView.curDate sameDayWithDate:[NSDate date]];
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).customView.hidden = sameDay;
    
    if (!sameDay && [_calendarView.curDate compare:[NSDate date]] == NSOrderedDescending) {
        self.calendarModel = nil;
        self.dataSource = nil;
        //[_tableView reloadData];
        [self.view makeToast:@"超过今天的日期都没有数据哦~" duration:1.0 position:@"center"];
    }
    else
    {
        NSString *key = [NSString stringWithFormat:@"%ld%ld%ld",(long)_calendarView.year,(long)_calendarView.month,(long)_calendarView.day];
        NSString *device_key = [NSString stringWithFormat:@"device_%ld%ld%ld",(long)_calendarView.year,(long)_calendarView.month,(long)_calendarView.day];
        CalendarModel *model = [_dateDic objectForKey:key];
        if (model) {
            self.calendarModel = model;
            self.dataSource = [_dateDic valueForKey:device_key];
            [_tableView reloadData];
        }
        else
        {
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self startPullRefresh];
        }
    }
}

#pragma mark - 获取密钥
- (void)getCKey
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];;
        return;
    }
    
    [self.view makeToastActivity];
    _tableView.userInteractionEnabled = NO;
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = NO;
    __weak __typeof(self)weakSelf = self;
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getKey"];
    [param setObject:@"teacher" forKey:@"from"];
    [param setObject:manager.userInfo.classid forKey:@"class_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"token"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf getKeyFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf getKeyFinish:NO Data:nil];
    }];
}

- (void)getKeyFinish:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    [self.view hideToastActivity];
    _tableView.userInteractionEnabled = YES;
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = YES;
    
    if (!suc) {
        NSString *str = [result valueForKey:@"ret_msg"];
        NSString *tip = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:tip duration:1.0 position:@"center"];
    }
    else
    {
        _shouldRefresh = YES;
        //用户数据处理
        id ret_data = [result valueForKey:@"ret_data"];
        if ([ret_data isKindOfClass:[NSNull class]]) {
            ret_data = [ret_data lastObject];
        }
        
        NSString *value = [ret_data valueForKey:@"key"];
        AdDetailViewController *detail = [[AdDetailViewController alloc] init];
        NSString *str = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(long)_calendarView.year,(long)_calendarView.month,(long)_calendarView.day];
        NSString *url = [NSString stringWithFormat:@"http://wx.goonbaby.com/kq/classKqIndex/dt/%@/key/%@/from/2.html",str,value];
        detail.url = url;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

@end
