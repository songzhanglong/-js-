//
//  MainViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/23.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "MainViewController.h"
#import "YQSlideMenuController.h"
#import "MobClick.h"
#import "NSString+Common.h"
#import "NSDate+Calendar.h"
#import "Toast+UIView.h"
#import "ClassCircleModel.h"
#import "ClassReplyDetailController.h"
#import "UIImage+Caption.h"
#import "DynamicViewCell.h"
#import "DataBaseOperation.h"
#import "MyMsgModel.h"
#import "MyMsgViewController.h"
#import "ClockView.h"
#import "ClickView.h"
#import "UploadManager.h"
#import "CommonUtil.h"
#import "NSDate+Common.h"
#import "CliassHeaderView.h"
#import "MainViewController1.h"
#import "AdModel.h"
#import "AdDetailViewController.h"
#import "PublicScrollView.h"
#import "DJTDeviceAttence.h"
#import "WeatherViewController.h"

#define CITY_NAME       @"city_name"
#define WEALTHY_DATA    @"weatherData"
#define WEALTHY         @"weather"
#define DAY_IMG         @"day_img"
#define NIGHT_IMG       @"night_img"
#define WEAL_TIME       @"wealTime"
#define LOWEST          @"lowest"


@interface MainViewController ()<ClassReplyDetailDelegate,ClockViewDelegate,ClickViewDelegate,PublicScrollViewDelegate,DynamicViewCellDelegate>

@end
@implementation MainViewController
{
    UILabel     *_tipLabel,*_addressLabel,*_wealLabel,*_lowLabel;
    UIImageView *_wealImage;
    NSInteger   _pageCount;
    BOOL        _lastPage,_refreshAds,_isShow,_firstReq;
    NSIndexPath *_indexPath;
    NSString    *_curId,*_curName;
    AFHTTPRequestOperation *_myOreration;
    ClockView   *_clockView;
    ClickView   *_clickView;
    UIView      *_backView;
    
    UILabel     *_mainTipLab;
    UIImageView *_mainTipView;
    
    int _pmDeviceType;
    BOOL _requestWealthy;
}

- (void)dealloc
{
    if (_myOreration && (!_myOreration.isCancelled && !_myOreration.isFinished)) {
        [_myOreration cancel];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:STOP_SCROLL_ENABLE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:REFRESH_MAIN_HEADVIEW object:nil];
}

- (BOOL)isWorkDay{
    NSDate *todayDate = [NSDate date];
    NSUInteger weekDay = [todayDate weekday];
    if (weekDay==1||weekDay==7) {
        return NO;
    }
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.useNewInterface = YES;
    _pageCount = 10;
    _pmDeviceType = 1;
    //表格＋网络
    [self createTableViewAndRequestAction:@"dynamic" Param:nil Header:YES Foot:YES];
    [_tableView setTableHeaderView:[self createTableHeadView]];
    
    //班级圈点赞
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"adsCell"];
    [_tableView registerClass:[DynamicViewCell class] forCellReuseIdentifier:@"dynamicCell"];
    
    [self beginRefresh];
    
    //leftBut
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(10, 20, 40, 40)];
    [button setImage:[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"s1@2x" ofType:@"png"]] forState:UIControlStateNormal];
    YQSlideMenuController *sideCon = (YQSlideMenuController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
    [button addTarget:sideCon action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    //数量提示
    _mainTipView = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 200) / 2, 80, 200, 29)];
    _mainTipView.hidden = YES;
    _mainTipView.userInteractionEnabled = YES;
    [_mainTipView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"futiao" ofType:@"png"]]];
    [self.view addSubview:_mainTipView];
    _mainTipLab = [[UILabel alloc] initWithFrame:_mainTipView.bounds];
    [_mainTipLab setTextAlignment:1];
    [_mainTipLab setTextColor:[UIColor whiteColor]];
    [_mainTipLab setBackgroundColor:[UIColor clearColor]];
    [_mainTipLab setFont:[UIFont systemFontOfSize:14]];
    [_mainTipView addSubview:_mainTipLab];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeadView:) name:REFRESH_MAIN_HEADVIEW object:nil];
    
    [[DJTGlobalManager shareInstance] checkTeacherAssistant];
}

- (void)refreshHeadView:(id)sendr
{
    [_tableView setTableHeaderView:[self createTableHeadView]];
}

- (UIView *)createTableHeadView
{
    NSArray *array = [[DataBaseOperation shareInstance] selectMyMsgByDateAsc:NO];
    BOOL hasNoti = array.count > 0;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:array.count];
    
    UIView *headView = [[UIView alloc] init];
    //imageview
    CGFloat hei = 0;
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    if (_backView) {
        hei = _backView.frame.size.height;
        [_backView removeFromSuperview];
        [headView addSubview:_backView];
    }
    else
    {
        UIImage *titleImg = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"s6@2x" ofType:@"png"]];
        CGSize imgSize = titleImg.size;
        
        hei = winSize.width * imgSize.height / imgSize.width;
        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, hei)];
        UIImageView *myImg = [[UIImageView alloc] initWithImage:titleImg];
        [myImg setUserInteractionEnabled:YES];
        [myImg addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(weatherAction:)]];
        [myImg setFrame:CGRectMake(0, 0, winSize.width, hei)];
        [_backView addSubview:myImg];
        
        NSString *userId = [DJTGlobalManager shareInstance].userInfo.userid;
        //wealthy
        UIImageView *wealthy = [[UIImageView alloc] init];
        NSString *day_img = [userDef objectForKey:[DAY_IMG stringByAppendingString:userId]];
        if (day_img) {
            [wealthy setImageWithURL:[NSURL URLWithString:day_img]];
        }
        _wealImage = wealthy;
        [wealthy setContentMode:UIViewContentModeScaleAspectFit];
        [wealthy setFrame:CGRectMake((winSize.width - 75) / 2, 30, 75, 65)];
        [_backView addSubview:wealthy];
        
        //lowest
        _lowLabel = [[UILabel alloc] initWithFrame:CGRectMake(wealthy.frame.origin.x + wealthy.frame.size.width + 5, wealthy.frame.origin.y + 5, 100, 16)];
        [_lowLabel setTextColor:[UIColor whiteColor]];
        [_lowLabel setFont:[UIFont systemFontOfSize:14]];
        [_lowLabel setBackgroundColor:[UIColor clearColor]];
        NSString *lowest = [userDef objectForKey:[LOWEST stringByAppendingString:userId]];
        if (![lowest hasPrefix:@"~"]) {
            [_lowLabel setText:lowest];
        }
        [_backView addSubview:_lowLabel];
        
        //tip
        UIImageView *tipView = [[UIImageView alloc] initWithFrame:CGRectMake(5, hei - 10 - 25, 25, 25)];
        [tipView setImage:[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"s3@2x" ofType:@"png"]]];
        [_backView addSubview:tipView];
        
        UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(tipView.frame.origin.x * 2 + tipView.frame.size.width, tipView.frame.origin.y - 1, self.view.frame.size.width - (tipView.frame.origin.x * 2 + tipView.frame.size.width + 15 + 55 + 1), 28)];
        _tipLabel = tipLab;
        [tipLab setFont:[UIFont systemFontOfSize:11]];
        [tipLab setNumberOfLines:2];
        [tipLab setTextColor:[UIColor whiteColor]];
        [tipLab setBackgroundColor:[UIColor clearColor]];
        [tipLab setText:[userDef objectForKey:[WEALTHY_DATA stringByAppendingString:userId]]];
        [_backView addSubview:tipLab];
        
        //虚线
        UIImageView *xuxian = [[UIImageView alloc] initWithFrame:CGRectMake(tipLab.frame.size.width + tipLab.frame.origin.x + 5 , tipLab.frame.origin.y + (tipLab.frame.size.height - 23.5) / 2, 1, 23.5)];
        [xuxian setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"xuxian" ofType:@"png"]]];
        [_backView addSubview:xuxian];
        
        //address
        UIImageView *addressImg = [[UIImageView alloc] initWithFrame:CGRectMake(_backView.frame.size.width - 5 - 16, tipLab.frame.origin.y, 16, 16)];
        [addressImg setImage:[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"s2@2x" ofType:@"png"]]];
        [_backView addSubview:addressImg];
        
        UILabel *addressLab = [[UILabel alloc] initWithFrame:CGRectMake(_backView.frame.size.width - 5 - 55, addressImg.frame.origin.y, 39, 16)];
        _addressLabel = addressLab;
        [addressLab setFont:[UIFont systemFontOfSize:15]];
        [addressLab setTextColor:[UIColor whiteColor]];
        [addressLab setBackgroundColor:[UIColor clearColor]];
        [addressLab setText:[userDef objectForKey:[CITY_NAME stringByAppendingString:userId]]];
        [_backView addSubview:addressLab];
        
        UILabel *wealLab = [[UILabel alloc] initWithFrame:CGRectMake(addressLab.frame.origin.x, addressLab.frame.origin.y + addressLab.frame.size.height, 55, 12)];
        _wealLabel = wealLab;
        [wealLab setFont:[UIFont systemFontOfSize:11]];
        [wealLab setTextColor:[UIColor whiteColor]];
        [wealLab setBackgroundColor:[UIColor clearColor]];
        [wealLab setText:[userDef objectForKey:[WEALTHY stringByAppendingString:userId]]];
        [_backView addSubview:wealLab];
        
        [headView addSubview:_backView];
    }

    //clock
    if (![self isWorkDay]) {
        if (_clockView) {
            [_clockView removeFromSuperview];
            _clockView = nil;
        }
    }
    else
    {
        if ([DJTGlobalManager shareInstance].userInfo.hasTimeCard) {
            _clockView = [[ClockView alloc] initWithFrame:CGRectMake(0, hei, winSize.width, 65)];
            _clockView.delegate = self;
            [_clockView.myImageView setImage:[UIImage imageNamed:@"s12_2.png"]];
            [_clockView.myTipLab setText:@"今日考勤查看"];
            [_backView addSubview:_clockView];
            [headView addSubview:_clockView];
            hei += 65;
            
          /*  NSArray *device_attences = [DJTGlobalManager shareInstance].deviceAttences;
            if ([device_attences count] > 0) {
                _clockView = [[ClockView alloc] initWithFrame:CGRectMake(0, hei, winSize.width, 65)];
                _clockView.delegate = self;
                [_clockView.myImageView setImage:[UIImage imageNamed:@"s12_1.png"]];
                [_backView addSubview:_clockView];
                [headView addSubview:_clockView];
                hei += 65;
                
                BOOL isAbsenteeism = false;
                int total = (int)[[DJTGlobalManager shareInstance].userInfo.students count];
                for (DJTDeviceAttence *model in device_attences) {
                    if ([model.state isEqualToString:@"1"]) {
                        if ([model.cnt integerValue] == total) {
                            isAbsenteeism = YES;
                            break;
                        }
                    }
                }
                if (isAbsenteeism) {
                    [_clockView.myTipLab setText:@"今日全勤"];
                }else{
                    [_clockView.myTipLab setText:@"今日有缺勤"];
                }
            }else{
                if (_clockView) {
                    [_clockView removeFromSuperview];
                    _clockView = nil;
                }
            }*/
        }else{
            NSInteger attanceState = [[DJTGlobalManager shareInstance].userInfo.attence_state integerValue];
            if (attanceState == 0 || attanceState == 1) {
                if (_clockView) {
                    [_clockView removeFromSuperview];
                    _clockView = nil;
                }
            }
            else
            {
                _clockView = [[ClockView alloc] initWithFrame:CGRectMake(0, hei, winSize.width, 65)];
                _clockView.delegate = self;
                [_clockView.myTipLab setText:@"今日未考勤"];
                [_clockView.myImageView setImage:[UIImage imageNamed:@"s12_2.png"]];
                [_backView addSubview:_clockView];
                
                [headView addSubview:_clockView];
                
                hei += 65;
            }
        }
    }
    
    if (hasNoti) {
        
        if (_clickView) {
            [_clickView removeFromSuperview];
            [_clickView setFrame:CGRectMake(0, hei, winSize.width, 75)];
        }
        else
        {
            _clickView = [[ClickView alloc] initWithFrame:CGRectMake(0, hei, winSize.width, 75)];
            _clickView.delegate = self;
        }
        
        MyMsgModel *model = [array firstObject];
        _clickView.numLab.text = (array.count > 9) ? @"n" : [NSString stringWithFormat:@"%ld",(long)array.count];
        [headView addSubview:_clickView];
        
        hei += _clickView.frame.size.height;
        
        if (![_curId isEqualToString:model.sender]) {
            _curId = model.sender;
            DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
            NSMutableDictionary *param = [manager requestinitParamsWith:@"getMemberFace"];
            [param setObject:_curId forKey:@"userids"];
            NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
            [param setObject:text forKey:@"signature"];
            
            __weak __typeof(self)weakSelf = self;
            NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"member"];
            _myOreration = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
                [weakSelf endRefresh:success Data:data Model:model];
                
            } failedBlock:^(NSString *description) {
                [weakSelf endRefresh:NO Data:nil Model:model];
            }];
        }
        else if(_curName != nil)
        {
            _clickView.tipLab.text = [_curName stringByAppendingString:[self getStringBy:model]];
        }
    }
    else
    {
        _curId = nil;
        _curName = nil;
        if (_clickView) {
            [_clickView removeFromSuperview];
            _clickView = nil;
        }
    }
    
    [headView setFrame:CGRectMake(0, 0, winSize.width, hei)];
    return headView;
}

- (void)weatherAction:(id)sender
{
    if (_pmDeviceType == 2) {
        WeatherViewController *weatherController = [[WeatherViewController alloc] init];
        weatherController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:weatherController animated:YES];
    }else if (_pmDeviceType <= 1){
        [self requestPMDevice];
    }
}
#pragma mark is PM2.5 device
- (void)requestPMDevice
{
    if (_requestWealthy) {
        [self.view makeToast:@"天气数据正在请求" duration:1.0 position:@"center"];
        return;
    }

    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    _requestWealthy = YES;
    __weak __typeof(self)weakSelf = self;
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    NSString *url = [URLFACE stringByAppendingString:@"weather:getdevice"];
    NSDictionary *dic = @{@"class_id":user.classid,@"teacher_id":user.userid,@"mobile":[[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_ACCOUNT]};
    [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf pm25DeviceFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf pm25DeviceFinish:NO Data:nil];
    }];
}

- (void)pm25DeviceFinish:(BOOL)success Data:(id)result
{
    _requestWealthy = NO;
    if (success) {
        NSDictionary *dic = [result valueForKey:@"data"];
        if (dic && ![dic isKindOfClass:[NSNull class]]) {
            _pmDeviceType = 2;
            WeatherViewController *weatherController = [[WeatherViewController alloc] init];
            weatherController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:weatherController animated:YES];
        }else {
            _pmDeviceType = 3;
        }
    }
    else
    {
        NSString *str = [result objectForKey:@"message"];
        NSString *tip = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:tip duration:1.0 position:@"center"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    [MobClick beginLogPageView:@"classCircle"];
    
    YQSlideMenuController *side = (YQSlideMenuController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
    side.needSwipeShowMenu = YES;
    
    if (_refreshNotice) {
        _refreshNotice = NO;
        [_tableView setTableHeaderView:[self createTableHeadView]];
    }
    
    [self refreshTipInfo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    YQSlideMenuController *side = (YQSlideMenuController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
    side.needSwipeShowMenu = NO;
    
    [MobClick endLogPageView:@"classCircle"];
    
    _refreshNotice = NO;
}

- (void)reloadSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            [_tableView setTableHeaderView:[self createTableHeadView]];

        }
            break;
        case 1:
        {
            [_tableView setTableHeaderView:[self createTableHeadView]];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 上传进度
- (void)refreshTipInfo
{
    UploadManager *manager = [UploadManager shareInstance];
    _mainTipView.hidden = (manager.totalCount == 0);
    if (!_mainTipView.hidden) {
        [_mainTipLab setText:[NSString stringWithFormat:@"当前图片上传进度:%ld/%ld",(long)manager.curCount,(long)manager.totalCount]];
    }
}

#pragma mark - 头像刷新
- (NSString *)getStringBy:(MyMsgModel *)model
{
    NSString *tipStr = @"发信息了";
    switch (model.mdFlag.integerValue) {
        case 6:
        {
            tipStr = @"园长消息通知";
        }
            break;
        case 7:
        {
            tipStr = @"点赞了你";
        }
            break;
        case 8:
        {
            tipStr = @"评论了你";
        }
            break;
        case 9:
        {
            tipStr = @"回复了你";
        }
            break;
        case 10:
        {
            tipStr = @"园所通知你";
        }
            break;
        case 11:
        {
            tipStr = @"提醒你关注";
        }
            break;
        case 12:
        {
            tipStr = @"完成了考勤";
        }
            break;
        case 13:
        {
            tipStr = @"成长手册更新";
        }
            break;
        case 99:
        {
            tipStr = @"活动通知提醒";
        }
            break;
        default:
            break;
    }
    
    return tipStr;
}

- (void)endRefresh:(BOOL)suc Data:(id)result Model:(MyMsgModel *)msgModel
{
    _myOreration = nil;
    if (suc) {
        
        id ret_data = [result valueForKey:@"ret_data"];
        NSDictionary *dic = ret_data;
        if ([ret_data isKindOfClass:[NSArray class]]) {
            dic = [ret_data firstObject];
        }
        NSDictionary *keyValue = [[dic allValues] firstObject];
        NSString *face = [keyValue valueForKey:@"face"];
        NSString *url = (!face || [face isKindOfClass:[NSNull class]]) ? @"" : face;
        if (![url hasPrefix:@"http"]) {
            url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
        }
        NSString *name = [keyValue valueForKey:@"name"];
        _curName = (!name || [name isKindOfClass:[NSNull class]]) ? @"" : name;;
        NSString *tipStr = [self getStringBy:msgModel];
        _clickView.tipLab.text = [_curName stringByAppendingString:tipStr];
        [_clickView.faceImg setImageWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"s5_big.png"]];
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - 获取资讯列表
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"search"];
    [param setObject:manager.userInfo.classid forKey:@"class_id"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    if (!_firstReq && [self.dataSource count] > 0) {
        ClassCircleModel *lastOne = [self.dataSource lastObject];
        [param setObject:lastOne.dateline forKey:@"dateline"];
    }
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    
    self.param = param;
}

- (void)startPullRefresh
{
    _lastPage = NO;
    _firstReq = YES;
    [super startPullRefresh];
}

- (void)startPullRefresh2
{
    if (_lastPage) {
        [self.view makeToast:@"已到最后一页" duration:1.0 position:@"center"];
        
        //isStopRefresh
        [self performSelector:@selector(finishRefresh) withObject:nil afterDelay:0.1];
    }
    else
    {
        _firstReq = NO;
        [super startPullRefresh2];
    }
    
}

- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        NSMutableArray *array = [NSMutableArray array];
        NSArray *data = [ret_data valueForKey:@"list"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        for (id subDic in data) {
            NSError *error;
            ClassCircleModel *circle = [[ClassCircleModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [circle calculateGroupCircleRects];
            
            [array addObject:circle];
        }
        
        _lastPage = ([array count] < _pageCount);
        
        self.dataSource = array;
        [_tableView reloadData];
        
        //天气请求
        [self startWealthyRequest];
        
        [self requestAds];
    }
}

- (void)requestFinish2:(BOOL)success Data:(id)result
{
    [super requestFinish2:success Data:result];
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        
        NSArray *data = [ret_data valueForKey:@"list"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        NSMutableArray *array = [NSMutableArray array];
        NSMutableArray *indexPaths = [NSMutableArray array];
        NSInteger count = [self.dataSource count];
        NSInteger section = [_tableView numberOfSections] - 1;
        for (id subDic in data) {
            NSError *error;
            ClassCircleModel *circle = [[ClassCircleModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            
            [circle calculateGroupCircleRects];
            
            [array addObject:circle];
            [indexPaths addObject:[NSIndexPath indexPathForRow:count++ inSection:section]];
        }
        
        _lastPage = ([array count] < _pageCount);
        if (!self.dataSource) {
            self.dataSource = [NSMutableArray array];
        }
        [self.dataSource addObjectsFromArray:array];
        [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
}

#pragma mark - 点赞
- (void)diggRequest:(NSString *)tid
{
    if (self.httpOperation) {
        return;
    }
    
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    _tableView.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    __weak __typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"dynamic"];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"digg"];
    [param setObject:tid forKey:@"tid"];
    [param setObject:manager.userInfo.userid forKey:@"userid"];
    [param setObject:@"1" forKey:@"is_teacher"];  //0-家长,1-老师 2-园长
    [param setObject:manager.userInfo.uname forKey:@"user_name"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf diggComplete:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf diggComplete:NO Data:nil];
    }];
}

- (void)diggComplete:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    _tableView.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    if (suc) {
        ClassCircleModel *cricle = [self.dataSource objectAtIndex:_indexPath.row];
        cricle.have_digg = [NSNumber numberWithInt:1];
        DiggItem *item = [[DiggItem alloc] init];
        DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
        item.face = user.face;
        item.is_teacher = @"1";
        item.name = user.uname;
        item.userid = user.userid;
        if (!cricle.digg) {
            [cricle setDigg:(NSMutableArray<DiggItem> *)[NSMutableArray array]];
        }
        [cricle.digg addObject:item];
        cricle.digg_count = [NSNumber numberWithInteger:cricle.digg_count.integerValue + 1];
        [cricle calculateGroupCircleRects];

        [_tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - 广告
- (void)requestAds
{
    if (_refreshAds) {
        return;
    }
    
    _refreshAds = YES;
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *dic = [manager requestinitParamsWith:@"getAd"];
    [dic setObject:@"1" forKey:@"position_id"];
    [dic setObject:manager.userInfo.schoolid ?: @"" forKey:@"school_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:dic];
    [dic setObject:text forKey:@"signature"];
    __weak typeof(self)weakSelf = self;
    [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"ad"] parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf requestAdsFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf requestAdsFinish:NO Data:nil];
    }];
}

- (void)requestAdsFinish:(BOOL)success Data:(id)result
{
    _refreshAds = NO;
    NSMutableArray *array = [NSMutableArray array];
    if (success) {
        NSArray *ret_data = [result valueForKey:@"ret_data"];
        ret_data = (!ret_data || [ret_data isKindOfClass:[NSNull class]]) ? [NSArray array] : ret_data;
        for (NSDictionary *subDic in ret_data) {
            NSError *error;
            AdModel *adModel = [[AdModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [array addObject:adModel];
        }
    }
    DJTUser *user = [[DJTGlobalManager shareInstance] userInfo];
    if (![array isEqualToArray:user.adsSource] && [array count] > 0) {
        [user setAdsSource:array];
        [_tableView reloadData];
    }
}

#pragma mark - 天气
- (void)startWealthyRequest
{
    //天气请求
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *userId = [DJTGlobalManager shareInstance].userInfo.userid;
    NSString *str = [userDef objectForKey:[WEAL_TIME stringByAppendingString:userId]];
    if (str && [str isEqualToString:[NSString stringByDate:@"yyyyMMdd" Date:[NSDate date]]]) {
        //[self requestWealthy];
    }
    else
    {
        NSLog(@"天气请求");
        //天气请求
        [self requestWealthy];
    }
}

- (void)requestWealthy
{
    NSMutableDictionary *dic = [[DJTGlobalManager shareInstance] requestinitParamsWith:@"weather"];
    [dic setObject:[DJTGlobalManager shareInstance].userInfo.classid forKey:@"class_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:dic];
    [dic setObject:text forKey:@"signature"];
    __weak typeof(self)weakSelf = self;
    [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"weather"] parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf requestWealthyFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf requestWealthyFinish:NO Data:nil];
    }];
}

- (NSString *)getStr:(NSString *)key Dic:(id)result
{
    NSString *lastStr = [result valueForKey:key];
    if ([lastStr isKindOfClass:[NSNull class]]) {
        lastStr = @"";
    }
    return lastStr;
}

- (void)requestWealthyFinish:(BOOL)success Data:(id)result
{
    if (success) {
        NSDictionary *dic = [result valueForKey:@"ret_data"];
        
        NSString *weather = [self getStr:@"weather" Dic:dic];
        NSString *weatherData = [self getStr:@"weatherData" Dic:dic];
        NSString *city_name = [self getStr:@"city_name" Dic:dic];
        
        NSString *today = [NSString stringByDate:@"yyyyMMdd" Date:[NSDate date]];
        [_addressLabel setText:city_name];
        [_wealLabel setText:weather];
        [_tipLabel setText:weatherData];
        
        NSString *day_img = [self getStr:@"day_img" Dic:dic];
        NSString *night_img = [self getStr:@"night_img" Dic:dic];
        [_wealImage setImageWithURL:[NSURL URLWithString:day_img]];
        
        NSString *lowest = [self getStr:@"lowest" Dic:dic];
        NSString *hightest = [self getStr:@"hightest" Dic:dic];
        NSString *lowToHigh = [lowest stringByAppendingString:[NSString stringWithFormat:@"~%@°C",hightest]];
        if (![lowToHigh hasPrefix:@"~"]) {
            [_lowLabel setText:lowToHigh];
        }

        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
        NSString *userId = [DJTGlobalManager shareInstance].userInfo.userid;
        [userDef setObject:weatherData forKey:[WEALTHY_DATA stringByAppendingString:userId]];
        [userDef setObject:weather forKey:[WEALTHY stringByAppendingString:userId]];
        [userDef setObject:city_name forKey:[CITY_NAME stringByAppendingString:userId]];
        [userDef setObject:today forKey:[WEAL_TIME stringByAppendingString:userId]];
        [userDef setObject:day_img forKey:[DAY_IMG stringByAppendingString:userId]];
        [userDef setObject:night_img forKey:[NIGHT_IMG stringByAppendingString:userId]];
        [userDef setObject:lowToHigh forKey:[LOWEST stringByAppendingString:userId]];
        [userDef synchronize];
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - 视频播放
/**
 *	@brief	视频播放
 *
 *	@param 	filePath 	视频路径
 */
- (void)playVideo:(NSString *)filePath
{
    if (![filePath hasPrefix:@"http"]) {
        filePath = [G_IMAGE_ADDRESS stringByAppendingString:filePath ?: @""];
    }
    NSURL *movieURL = [NSURL URLWithString:[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self.movieController = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    self.movieController.scalingMode = MPMovieScalingModeAspectFill;
    [self.movieController prepareToPlay];
    [self.view addSubview:self.movieController.view];//设置写在添加之后   // 这里是addSubView
    self.movieController.shouldAutoplay=YES;
    [self.movieController setControlStyle:MPMovieControlStyleDefault];
    [self.movieController setFullscreen:YES];
    [self.movieController.view setFrame:self.view.bounds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
}

- (void)movieFinishedCallback:(NSNotification*)notify {
    
    MPMoviePlayerController* theMovie = [notify object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    
    [theMovie.view removeFromSuperview];
    
    self.movieController = nil;
}

#pragma mark - DynamicViewCellDelegate
- (void)touchImageCell:(UITableViewCell *)cell At:(NSInteger)idx
{
    if (idx < 100) {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        
        //检测视频
        ClassCircleModel *circle = self.dataSource[indexPath.row];
        NSArray *pics = [circle.picture componentsSeparatedByString:@"|"];
        NSArray *thumbs = [circle.picture_thumb componentsSeparatedByString:@"|"];
        
        //图片
        _browserPhotos = [NSMutableArray array];
        for (int i = 0; i < pics.count; i++) {
            NSString *path = pics[i];
            if (![path hasPrefix:@"http"]) {
                 path = [G_IMAGE_ADDRESS stringByAppendingString:path ?: @""];
            }
            
            MWPhoto *photo = nil;
            NSString *name = [path lastPathComponent];
            //NSURL *nsurl = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            if ([[[name pathExtension] lowercaseString] isEqualToString:@"mp4"]) {
                NSString *tmpThumb = thumbs[i];
                if ([[[tmpThumb pathExtension] lowercaseString] isEqualToString:@"mp4"]) {
                    photo = [MWPhoto photoWithImage:[UIImage thumbnailPlaceHolderImageForVideo:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
                }
                else
                {
                    if (![tmpThumb hasPrefix:@"http"]) {
                        tmpThumb = [G_IMAGE_ADDRESS stringByAppendingString:tmpThumb ?: @""];
                    }
                    photo = [MWPhoto photoWithURL:[NSURL URLWithString:tmpThumb]];
                }
                photo.videoUrl = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                photo.isVideo = YES;
            }
            else
            {
                CGFloat scale_screen = [UIScreen mainScreen].scale;
                NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
                path = [NSString getPictureAddress:@"2" width:width height:@"0" original:path];
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            }
            [_browserPhotos addObject:photo];
        }
        
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        [browser setCurrentPhotoIndex:idx];
        browser.displayActionButton = NO;
        browser.displayNavArrows = YES;
        
        [self.navigationController pushViewController:browser animated:YES];
    }
}

- (void)diggAndCommentCell:(UITableViewCell *)cell At:(NSInteger)idx
{
    _indexPath = [_tableView indexPathForCell:cell];
    
    ClassCircleModel *cricle = [self.dataSource objectAtIndex:_indexPath.row];
    if ([cricle isNotUpload]) {
        return;
    }
    
    if (idx == 0) {
        if ([cricle.have_digg integerValue] == 1) {
            [self.view makeToast:@"不可重复点赞" duration:1.0 position:@"center"];
        }
        else
        {
            [self diggRequest:cricle.tid];
        }
    }
    else
    {
        ClassReplyDetailController *reply = [[ClassReplyDetailController alloc] init];
        reply.delegate = self;
        reply.circleModel = self.dataSource[_indexPath.row];
        reply.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:reply animated:YES];
    }
    
}

- (void)selectListByPeople:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    ClassCircleModel *circleModel = self.dataSource[indexPath.row];
    MainViewController1 *main1 = [[MainViewController1 alloc]init];
    main1.activityModel = circleModel;
    main1.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:main1 animated:YES];
}

#pragma mark - PublicScrollViewDelegate
- (void)touchImageAtIndex:(NSInteger)index ScrollView:(PublicScrollView *)pubSro
{
    AdModel *model = [DJTGlobalManager shareInstance].userInfo.adsSource[index];
    AdDetailViewController *adverDetail = [[AdDetailViewController alloc]init];
    adverDetail.url = model.url;
    adverDetail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:adverDetail animated:YES];
}

#pragma mark - ClassReplyDetailDelegate
- (void)changeReplyDetail
{
    [_tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deleteThisCircleDetail
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.dataSource removeObjectAtIndex:_indexPath.row];
    [_tableView deleteRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - ClockViewDelegate
- (void)touchEndClockView:(ClockView *)clock
{
    [self getCKey];
}

#pragma mark - 获取密钥
- (void)getCKey
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    __weak __typeof(self)weakSelf = self;
    
    self.tabBarController.view.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getKey"];
    [param setObject:@"teacher" forKey:@"from"];
    [param setObject:manager.userInfo.classid forKey:@"class_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"token"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf getKeyFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf getKeyFinish:NO Data:nil];
    }];
}

- (void)getKeyFinish:(BOOL)suc Data:(id)result
{
    self.tabBarController.view.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    
    if (!suc) {
        NSString *str = [result valueForKey:@"ret_msg"];
        NSString *tip = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:tip duration:1.0 position:@"center"];
    }
    else
    {
        //用户数据处理
        id ret_data = [result valueForKey:@"ret_data"];
        if ([ret_data isKindOfClass:[NSNull class]]) {
            ret_data = [ret_data lastObject];
        }
        //_refreshNotice = YES;
        NSString *value = [ret_data valueForKey:@"key"];
        AdDetailViewController *detail = [[AdDetailViewController alloc] init];
        NSString *url = [NSString stringWithFormat:@"http://wx.goonbaby.com/kq/classKqIndex/key/%@/from/2/isTeacher/1.html",value];
        detail.url = url;
        detail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

#pragma mark - ClickViewDelegate
- (void)touchEndClickView:(ClickView *)click
{
    MyMsgViewController *myMsg = [[MyMsgViewController alloc] init];
    myMsg.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myMsg animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        DJTUser *user = [[DJTGlobalManager shareInstance] userInfo];
        return ([user.adsSource count] > 0) ? 1 : 0;
    }
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = (indexPath.section == 0) ? @"adsCell" : @"dynamicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];;
    if (indexPath.section == 0) {
        DJTUser *user = [[DJTGlobalManager shareInstance] userInfo];
        NSMutableArray *array = [NSMutableArray array];
        for (AdModel *model in user.adsSource) {
            [array addObject:model.picture];
        }
        PublicScrollView *subView = (PublicScrollView *)[cell.contentView viewWithTag:1];
        if (!subView) {
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            CGFloat hei = winSize.width * 8 / 64.0;
            PublicScrollView *scrollView = [[PublicScrollView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, hei)];
            scrollView.delegate = self;
            [scrollView setTag:1];
            [scrollView setImagesArrayFromModel:array];
            [cell.contentView addSubview:scrollView];
        }
        else
        {
            [subView reloadArr:array];
        }
    }
    else
    {
        [(DynamicViewCell *)cell setDelegate:self];
        [(DynamicViewCell *)cell resetClassGroupData:self.dataSource[indexPath.row]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        return;
    }
    
    if (self.httpOperation) {
        [self.view makeToast:@"数据正在加载，请稍候" duration:1.0 position:@"center"];
        return;
    }
    _indexPath = indexPath;
    ClassCircleModel *circleModel = self.dataSource[indexPath.row];
    if([circleModel isNotUpload]){
        return;
    }
    
    ClassReplyDetailController *reply = [[ClassReplyDetailController alloc] init];
    reply.delegate = self;
    reply.circleModel = circleModel;
    reply.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:reply animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        CGFloat hei = winSize.width * 8 / 64.0;
        return hei;
    }
    else
    {
        ClassCircleModel *model = self.dataSource[indexPath.row];
        CGFloat hei = 18 + model.butYori + 24 + 10 + model.replyBackRect.size.height;
        if (model.diggRect.size.height > 0) {
            hei += model.diggRect.size.height + 5;
        }
        if (model.contentRect.size.height > 60) {
            hei -= (model.contentRect.size.height - 60);
        }
        return hei;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    label.text = @"  班级动态";
    label.textColor = CreateColor(163, 163, 163);
    label.backgroundColor = CreateColor(238, 239, 239);
    return label;
}

@end
