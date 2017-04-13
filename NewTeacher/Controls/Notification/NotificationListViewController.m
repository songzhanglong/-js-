//
//  NotificationListViewController.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/10.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "NotificationListViewController.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"
#import "NotificationListModel.h"
#import "NotificationListCell.h"
#import "NotificationSendViewController.h"
#import "NotificationDetailViewController.h"

@interface NotificationListViewController ()<NotificationSendSuccessDelegate>
{
    NSInteger   _nPageIndex;
    NSIndexPath *_delPath;
    UIView *_downView;
}

@end

@implementation NotificationListViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.showBack = YES;
    self.titleLable.text = @"园所通知";
    self.useNewInterface = YES;
    _nPageIndex = 1;
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setFrame:CGRectMake(0, 0, 34, 30)];
    [sendButton setTitle:@"新建" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [sendButton addTarget:self action:@selector(sendNotification:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,item];
    
    //表格＋网络
    [self createTableViewAndRequestAction:@"message" Param:nil Header:YES Foot:YES];
    [_tableView registerClass:[NotificationListCell class] forCellReuseIdentifier:@"notificationCellId"];
    [self beginRefresh];
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getMessageTeacher"];
    [param setObject:manager.userInfo.userid forKey:@"teacher_id"];
    [param setObject:manager.userInfo.classid forKey:@"class_id"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_nPageIndex] forKey:@"page"];
    [param setObject:@"10" forKey:@"pageSize"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
}

- (void)startPullRefresh
{
    _nPageIndex = 1;
    [super startPullRefresh];
}

- (void)startPullRefresh2
{
    NSInteger count = [self.dataSource count];
    
    if ((count % 10) > 0) {
        [self.view makeToast:@"已到最后一页" duration:1.0 position:@"center"];
        
        //isStopRefresh
        [self performSelector:@selector(finishRefresh) withObject:nil afterDelay:0.1];
    }
    else
    {
        _nPageIndex = count / 10 + 1;
        [super startPullRefresh2];
    }
    
}

- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        
        NSMutableArray *array = [NSMutableArray array];
        NSArray *data = [ret_data valueForKey:@"data"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        for (id subDic in data) {
            NSError *error = nil;
            NotificationListModel *model = [[NotificationListModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [model calculateNotificationRect];
            
            [array addObject:model];
        }
        
        self.dataSource = array;
        [_tableView reloadData];
    }
}

- (void)requestFinish2:(BOOL)success Data:(id)result
{
    [super requestFinish2:success Data:result];
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSArray *data = [ret_data valueForKey:@"data"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        NSInteger curCount = [self.dataSource count];
        NSMutableArray *indexPaths = [NSMutableArray array];
        NSInteger section = [_tableView numberOfSections] - 1;
        for (id subDic in data) {
            NSError *error = nil;
            NotificationListModel *model = [[NotificationListModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [model calculateNotificationRect];
            if (!self.dataSource) {
                self.dataSource = [NSMutableArray array];
            }
            [self.dataSource addObject:model];
            
            [indexPaths addObject:[NSIndexPath indexPathForRow:curCount++ inSection:section]];
        }
        [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        if (_nPageIndex > 1) {
            _nPageIndex -= 1;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)sendNotification:(id)sender{
    self.navigationController.view.userInteractionEnabled = NO;
    UIView *fullView = [[UIView alloc] initWithFrame:self.navigationController.view.window.bounds];
    [fullView setBackgroundColor:rgba(1, 1, 1, 0.5)];
    [self.navigationController.view.window addSubview:fullView];
    
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, fullView.frameBottom, fullView.frameWidth, 101)];
    [downView setBackgroundColor:[UIColor whiteColor]];
    [fullView addSubview:downView];
    _downView = downView;
    CGFloat hei = (downView.frameHeight - 1) / 2;
    
    UIButton *butNil = [UIButton buttonWithType:UIButtonTypeCustom];
    [butNil setFrame:CGRectMake(0, 0, fullView.frameWidth, fullView.frameHeight - downView.frameHeight)];
    [butNil setBackgroundColor:[UIColor clearColor]];
    [butNil addTarget:self action:@selector(selectNilBut:) forControlEvents:UIControlEventTouchUpInside];
    [fullView addSubview:butNil];
    
    for (NSInteger i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, (hei + 1) * i, downView.frameWidth, hei)];
        [button setTag:i + 1];
        [button setBackgroundColor:[UIColor clearColor]];
        [button addTarget:self action:@selector(selectNoticeType:) forControlEvents:UIControlEventTouchUpInside];
        [downView addSubview:button];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (hei - 40) / 2, downView.frameWidth, 21)];
        [label setFont:[UIFont systemFontOfSize:17]];
        [label setText:(i == 0) ? @"班级通知" : @"办公通知"];
        [label setTextColor:[UIColor blackColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setBackgroundColor:[UIColor clearColor]];
        [button addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, label.frameBottom + 3, downView.frameWidth, 16)];
        [label setFont:[UIFont systemFontOfSize:12]];
        [label setText:(i == 0) ? @"给家长发送通知消息" : @"给同事们发送通知消息"];
        [label setTextColor:[UIColor lightGrayColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setBackgroundColor:[UIColor clearColor]];
        [button addSubview:label];
        
        if (i == 0) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, hei, downView.frameWidth - 20, 1)];
            [line setBackgroundColor:[UIColor lightGrayColor]];
            [downView addSubview:line];
        }
        
    }
    CGFloat yOri = butNil.frameHeight;
    [UIView animateWithDuration:0.3 animations:^{
        [downView setFrameY:yOri];
    } completion:^(BOOL finished) {
        self.navigationController.view.userInteractionEnabled = YES;
    }];
}

- (void)selectNilBut:(id)sender
{
    self.navigationController.view.userInteractionEnabled = NO;
    CGFloat yOri = _downView.frameBottom;
    [UIView animateWithDuration:0.3 animations:^{
        [_downView setFrameY:yOri];
    } completion:^(BOOL finished) {
        [[_downView superview] removeFromSuperview];
        self.navigationController.view.userInteractionEnabled = YES;
    }];
}

- (void)selectNoticeType:(id)sender
{
    self.navigationController.view.userInteractionEnabled = NO;
    NSInteger index = [sender tag] - 1;
    UIView *father = [sender superview];
    CGFloat yOri = father.frameBottom;
    [UIView animateWithDuration:0.3 animations:^{
        [father setFrameY:yOri];
    } completion:^(BOOL finished) {
        [[father superview] removeFromSuperview];
        self.navigationController.view.userInteractionEnabled = YES;
        NotificationSendViewController *send = [[NotificationSendViewController alloc] init];
        send.delegate = self;
        send.sendToIndex = index;
        [self.navigationController pushViewController:send animated:YES];
    }];
}

#pragma mark - 删除通知
- (void)deleteNotice
{
    NotificationListModel *listModel = self.dataSource[_delPath.row];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (![listModel.sender isEqualToString:manager.userInfo.userid]) {
        [self.view makeToast:@"您没有权限删除此通知消息！" duration:1.0 position:@"center"];
        return;
    }
    
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    NSMutableDictionary *param = [manager requestinitParamsWith:@"deleteMessage"];
    [param setObject:listModel.message_id forKey:@"message_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    __weak __typeof(self)weakSelf = self;
    [self.view setUserInteractionEnabled:NO];
    [self.view makeToastActivity];
    
    self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"message"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf deleteNoticeFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf deleteNoticeFinish:NO Data:nil];
    }];
    
}

- (void)deleteNoticeFinish:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    [self.view setUserInteractionEnabled:YES];
    [self.view hideToastActivity];
    if (suc) {
        [self.dataSource removeObjectAtIndex:_delPath.row];
        [_tableView deleteRowsAtIndexPaths:@[_delPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.view makeToast:@"通知已删除" duration:1.0 position:@"center"];
    }
    else
    {
        NSString *str = [result valueForKey:@"ret_msg"];
        NSString *tip = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:tip duration:1.0 position:@"center"];
        
    }
}

#pragma mark - NotificationSendSuccessDelegate
- (void)publistMessageFinish
{
    [self.navigationController popViewControllerAnimated:YES];
    [self startPullRefresh];
    
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCellId" forIndexPath:indexPath];
    [cell resetNotifiCationSource:self.dataSource[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NotificationDetailViewController *notificationDetailViewController = [[NotificationDetailViewController alloc] init];
    notificationDetailViewController.listModel = self.dataSource[indexPath.row];
    [self.navigationController pushViewController:notificationDetailViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationListModel *model = self.dataSource[indexPath.row];
    return MIN(model.conSize.height, 61) + 48 + 20 + 16;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        _delPath = indexPath;
        [self deleteNotice];
    }
}

@end
