//
//  SchoolYardViewController.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/5/25.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SchoolYardViewController.h"
#import "SchoolYardCell.h"
#import "UIButton+WebCache.h"
#import "MyCalendarViewController.h"
#import "GrowNewViewController.h"
#import "FamilyViewController.h"
#import "NotificationListViewController.h"
#import "PersonalInfoViewController.h"
#import "MyStudentViewController.h"
#import "NSDate+Calendar.h"
#import "MailListViewController.h"
#import "CookbookViewController.h"
#import "AppDelegate.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"
#import "BabyMileageViewController.h"
#import "AdDetailViewController.h"
#import "ChannelListViewController.h"

@interface SchoolYardViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIAlertViewDelegate>{
    UICollectionView        *_collectionView;
    UIButton                *_headerView;
    NSMutableArray          *_dataArray;
    NSIndexPath *_indexPath;
}

@end

@implementation SchoolYardViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGE_USER_HEADER object:nil];
}

#pragma mark - 刷新头像
- (void)refreshHeader:(NSNotification *)notifi{
    NSString *face = [DJTGlobalManager shareInstance].userInfo.face;
    if (![face hasPrefix:@"http"]) {
        face = [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
    }
    [_headerView setImageWithURL:[NSURL URLWithString:face] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeader:) name:CHANGE_USER_HEADER object:nil];
    
    [self initData];
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UIImage *headImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"gn1" ofType:@"png"]];
    CGFloat imageViewHei = headImg.size.height / headImg.size.width  * self.view.frame.size.width;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWei = 60,itemHei = 85;
    CGFloat margin = (winSize.width - 4 * itemWei) / (4 + 1);
    layout.itemSize = CGSizeMake(itemWei, itemHei);
    layout.minimumLineSpacing = margin;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, 10, margin);
    layout.headerReferenceSize = CGSizeMake(winSize.width, imageViewHei + 30);
    
    _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[SchoolYardCell class] forCellWithReuseIdentifier:@"SchoolYardCell"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SchoolYardCellHeader"];
    [self.view addSubview:_collectionView];
}

- (void)initData{
    _dataArray = [[NSMutableArray alloc]initWithCapacity:10];
    if ([DJTGlobalManager shareInstance].userInfo.button.count > 0) {
        [_dataArray addObjectsFromArray:[DJTGlobalManager shareInstance].userInfo.button];
    }
    else{
        NSArray *titleArray = @[@"每日考勤",@"我的日历",@"成长档案",@"班级里程",@"家园联系",@"园所通知",@"学生管理",@"每日食谱",@"通讯录"];
        NSArray *imgArray = @[@"gn2.png",@"g1.png",@"gn4.png",@"gn5.png",@"gn6.png",@"gn10.png",@"g2",@"gn8.png",@"gn9.png"];
        NSArray *keyArray = @[@"attence",@"calendar",@"grow",@"mileage",@"card",@"message",@"manage",@"recipes",@"member"];
        for (NSInteger i = 0 ; i < [titleArray count]; i++) {
            DJTButton *model = [[DJTButton alloc]init];
            model.fromDef = YES;
            model.b_key = keyArray[i];
            model.b_name = titleArray[i];
            model.b_picture = imgArray[i];
            [_dataArray addObject:model];
        }
    }
}

- (void)pushPerInfo:(UIButton *)sender{
    PersonalInfoViewController *personInfo = [[PersonalInfoViewController alloc]init];
    personInfo.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personInfo animated:YES];
}

- (void)changeClasses:(id)sender
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.grades.count <= 1) {
        [self.view makeToast:@"您只关联了一个班级!" duration:1.0 position:@"center"];
        return;
    }
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app popSelectedChildrenView];
}

#pragma mark - 开启教师小助手
- (void)beginOpenAssistant
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    self.view.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"openAssistant"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"class"];
    [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf openAssistantFinish:success Data:data];
        });
    } failedBlock:^(NSString *description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf openAssistantFinish:NO Data:nil];
        });
    }];
}

- (void)openAssistantFinish:(BOOL)suc Data:(id)result
{
    self.view.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    if (suc) {
        [DJTGlobalManager shareInstance].userInfo.isOpenAssistant = YES;
        [[DJTGlobalManager shareInstance] checkTeacherAssistant];
        
        DJTButton *model = [_dataArray objectAtIndex:_indexPath.item];
        AdDetailViewController *detail = [[AdDetailViewController alloc] init];
        detail.url = model.b_url;
        detail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detail animated:YES];
    }
    else{
        id ret_msg = [result valueForKey:@"ret_msg"];
        [self.view makeToast:ret_msg ?: REQUEST_FAILE_TIP duration:1.0 position:@"center"];
    }
}

#pragma mark - 根据内容和字体大小计算UILabel宽度
- (CGSize)calculateTextSize:(NSString *)text font:(UIFont *)font
{
    CGSize textSize = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: font};
    textSize = [text  sizeWithAttributes:attribute];
    return textSize;
}

#pragma mark - 视眼
- (void)checkThirdAPI:(NSArray *)powers
{
    [self.view makeToastActivity];
    self.tabBarController.view.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int initLib = API_InitLibInstance();
        if (initLib < 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.tabBarController.view.userInteractionEnabled = YES;
                [weakSelf.view hideToastActivity];
                [weakSelf.view makeToast:@"视眼初始化异常，请联系园所管理员" duration:1.0 position:@"center"];
            });
        }
        else{
            DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
            if (user.device_ip.length <= 0 ||
                user.device_account.length <= 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.tabBarController.view.userInteractionEnabled = YES;
                    [weakSelf.view hideToastActivity];
                    [weakSelf.view makeToast:@"视眼暂时失明，请联系园所管理员" duration:1.0 position:@"center"];
                });
                return ;
            }
            const char *ip = [user.device_ip cStringUsingEncoding:NSUTF8StringEncoding];
            int port = user.device_port.intValue;
            const char *usr = [user.device_account cStringUsingEncoding:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingGB_18030_2000)];
            const char *pwd = [user.device_pwd cStringUsingEncoding:NSUTF8StringEncoding];
            if (API_RequestLogin(ip, port, usr, pwd) < 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.tabBarController.view.userInteractionEnabled = YES;
                    [weakSelf.view hideToastActivity];
                    [weakSelf.view makeToast:@"视眼暂时失明，请联系园所管理员" duration:1.0 position:@"center"];
                });
            }
            else{
                int i;
                int everyArrayNum[3];
                int CamStatusArray[MAX_NODE_NUM];       //存储节点状态:是否摄像头，是否在线
                int SWinStatusArray[MAX_INPUT_IO_NUM];
                int SWoutStatusArray[MAX_OUTPUT_IO_NUM];
                
                char **CamStrArray;
                CamStrArray = (char **)malloc(MAX_NODE_NUM * sizeof(char *));
                for(i = 0; i < MAX_NODE_NUM; i++){
                    CamStrArray[i] = (char *)malloc(64 * sizeof(char));
                }
                
                API_GetDeviceList(everyArrayNum, CamStatusArray, SWinStatusArray, SWoutStatusArray, CamStrArray);
                NSMutableArray *videoArr = [NSMutableArray array];
                for (i = 0; i < everyArrayNum[0]; i++) {
                    NSString *stringName =  [NSString stringWithCString:CamStrArray[i] encoding:NSUTF8StringEncoding];
                    if ([stringName hasPrefix:@"["] && [stringName hasSuffix:@"]"]) {
                        stringName = [[stringName substringToIndex:stringName.length - 1] substringFromIndex:1];
                    }
                    ChannelModel *model = [[ChannelModel alloc] init];
                    model.name = stringName;
                    model.nodeIdx = CamStatusArray[i];
                    [videoArr addObject:model];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.tabBarController.view.userInteractionEnabled = YES;
                    [weakSelf.view hideToastActivity];
                    ChannelListViewController *channelist = [[ChannelListViewController alloc] init];
                    channelist.powerList = powers;
                    channelist.deviceList = videoArr;
                    channelist.hidesBottomBarWhenPushed = YES;
                    [weakSelf.navigationController pushViewController:channelist animated:YES];
                });
                
            }
        }
    });
}

#pragma mark - 园所视眼开放权限接口
- (void)getOpenPower
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    DJTUser *user = [manager userInfo];
    NSMutableDictionary *dic = [manager requestinitParamsWith:@"getMonitorList"];
    [dic setObject:user.schoolid forKey:@"school_id"];
    [dic setObject:@"2" forKey:@"type"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:dic];
    [dic setObject:text forKey:@"signature"];
    self.tabBarController.view.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    __weak typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"monitor"] parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf getOpenPowerFinish:success Data:data];
        });
    } failedBlock:^(NSString *description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf getOpenPowerFinish:NO Data:nil];
        });
    }];
}

- (void)getOpenPowerFinish:(BOOL)success Data:(id)result
{
    self.httpOperation = nil;
    
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        if (ret_data && [ret_data isKindOfClass:[NSArray class]]) {
            NSMutableArray *powerArr = [PowerOpen arrayOfModelsFromDictionaries:ret_data error:nil];
            if (!powerArr || ([powerArr count] == 0)) {
                self.tabBarController.view.userInteractionEnabled = YES;
                [self.view hideToastActivity];
                [self.view makeToast:@"该园所暂未开放园所视眼权限" duration:1.0 position:@"center"];
            }
            else{
                [self checkThirdAPI:powerArr];
            }
        }else{
            self.tabBarController.view.userInteractionEnabled = YES;
            [self.view hideToastActivity];
            [self.view makeToast:@"该园所暂未开放园所视眼权限" duration:1.0 position:@"center"];
        }
    }
    else
    {
        self.tabBarController.view.userInteractionEnabled = YES;
        [self.view hideToastActivity];
        NSString *ret_msg = [result valueForKey:@"ret_msg"];
        ret_msg = ret_msg ?: REQUEST_FAILE_TIP;
        [self.view makeToast:ret_msg duration:1.0 position:@"center"];
    }
}

#pragma mark - 头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view =
    [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SchoolYardCellHeader" forIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150)];
    imageView.image = [UIImage imageNamed:@"g_bg.png"];
    [view addSubview:imageView];
    
    UILabel *schLab = [[UILabel alloc]initWithFrame:CGRectMake(imageView.frame.size.width - 160, imageView.frame.size.height - 25, 150, 20)];
    schLab.text = [DJTGlobalManager shareInstance].userInfo.schoolname;
    schLab.font = [UIFont systemFontOfSize:14];
    CGSize textSize = [self calculateTextSize:schLab.text font:schLab.font];
    schLab.frame = CGRectMake(imageView.frame.size.width - textSize.width - 10, imageView.frame.size.height - 25, textSize.width, 20);
    schLab.textAlignment = 1;
    schLab.backgroundColor = [UIColor clearColor];
    schLab.textColor = [UIColor whiteColor];
    [view addSubview:schLab];
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    _headerView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_headerView setFrame:CGRectMake(20, imageView.frame.size.height - 30, 60, 60)];
    NSString *face = user.face;
    if (![face hasPrefix:@"http"]) {
        face = [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
    }
    [_headerView setImageWithURL:[NSURL URLWithString:face] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
    [_headerView addTarget:self action:@selector(pushPerInfo:) forControlEvents:UIControlEventTouchUpInside];
    _headerView.layer.masksToBounds = YES;
    _headerView.layer.cornerRadius = 30;
    [view addSubview:_headerView];
    
    UILabel *nameLab = [[UILabel alloc]initWithFrame:CGRectMake(_headerView.frame.origin.x + _headerView.frame.size.width +10, imageView.frame.origin.y + imageView.frame.size.height + 5, 80, 20)];
    nameLab.text = user.uname;
    nameLab.font = [UIFont systemFontOfSize:13];
    CGSize bigSize = [self calculateTextSize:nameLab.text font:nameLab.font];
    nameLab.frame = CGRectMake(nameLab.frame.origin.x, nameLab.frame.origin.y, bigSize.width, nameLab.frame.size.height);
    nameLab.textColor = [UIColor blackColor];
    [view addSubview:nameLab];
    
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame = CGRectMake(self.view.bounds.size.width - 30, nameLab.frame.origin.y, 24, 24);
    [but setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"gn11" ofType:@"png"]] forState:UIControlStateNormal];
    but.layer.masksToBounds = YES;
    but.layer.cornerRadius = 12;
    [but addTarget:self action:@selector(changeClasses:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:but];
    
    
    UILabel *classLab = [[UILabel alloc]initWithFrame:CGRectMake( but.frame.origin.x - but.frame.size.width - 80, imageView.frame.origin.y + imageView.frame.size.height + 5, 100, 24)];
    classLab.textAlignment = 1;
    classLab.text = [user.grade_name ?: @"" stringByAppendingString:user.classname];
    classLab.font = [UIFont systemFontOfSize:10];
    classLab.backgroundColor = [UIColor clearColor];
    classLab.textColor = [UIColor darkGrayColor];
    CGSize classLabSize  = [self calculateTextSize:classLab.text font:classLab.font];
    classLab.frame = CGRectMake( but.frame.origin.x - classLabSize.width, classLab.frame.origin.y, classLabSize.width, classLab.frame.size.height);
    [view addSubview:classLab];
    return view;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //开启教师小助手
        [self beginOpenAssistant];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return  [_dataArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SchoolYardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SchoolYardCell" forIndexPath:indexPath];
    
    DJTButton *btnModel = _dataArray[indexPath.item];
    if (btnModel.fromDef) {
        [cell.faceImageView setImage:[UIImage imageNamed:btnModel.b_picture]];
    }
    else{
        [cell.faceImageView setImageWithURL:[NSURL URLWithString:btnModel.b_picture]];
    }
    cell.nameLabel.text = btnModel.b_name;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;
    
    DJTButton *model = [_dataArray objectAtIndex:indexPath.item];
    NSString *b_key = model.b_key;
    if ([b_key isEqualToString:@"attence"]) {
        //考勤请假
        [self getCKey:1];
    }else if ([b_key isEqualToString:@"calendar"]){
        //我的日历
        MyCalendarViewController *myCalendar = [[MyCalendarViewController alloc]init];
        myCalendar.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:myCalendar animated:YES];
    }else if ([b_key isEqualToString:@"grow"]){
        //成长档案
        GrowNewViewController *growNew = [[GrowNewViewController alloc] init];
        growNew.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:growNew animated:YES];
    }else if ([b_key isEqualToString:@"mileage"]){
        //班级里程
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        MileageStudentViewController *student = [[MileageStudentViewController alloc] init];
        student.view.frame = CGRectMake(0, 155, winSize.width, winSize.height - 155 - 64);
        MileageViewController *mileage = [[MileageViewController alloc] init];
        mileage.view.frame = student.view.frame;
        
        BabyMileageViewController *baby = [[BabyMileageViewController alloc] initWithControls:@[mileage,student] Titles:@[@"里程",@"学生"] Frame:CGRectMake(0, 120, winSize.width, 35)];
        baby.initIdx = (indexPath.item == 2) ? 1 : 0;
        baby.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:baby animated:YES];
    }else if ([b_key isEqualToString:@"card"]){
        //家园联系
        FamilyViewController *home = [[FamilyViewController alloc]init];
        home.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:home animated:YES];
    }else if ([b_key isEqualToString:@"message"]){
        //园所通知
        NotificationListViewController *notif = [[NotificationListViewController alloc]init];
        notif.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:notif animated:YES];
    }else if ([b_key isEqualToString:@"manage"]){
        //学生管理
        MyStudentViewController *student = [[MyStudentViewController alloc]init];
        student.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:student animated:YES];
    }else if ([b_key isEqualToString:@"recipes"]){
        //每日食谱
        [self getCKey:2];
//        CookbookViewController *cookbook = [[CookbookViewController alloc] init];
//        cookbook.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:cookbook animated:YES];
    }else if ([b_key isEqualToString:@"member"]){
        //通讯录
        MailListViewController *mailList = [[MailListViewController alloc] init];
        mailList.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:mailList animated:YES];
    }
    else if ([b_key isEqualToString:@"monitor"]){
        //视频监控
        [self getOpenPower];
    }
    else if ([b_key isEqualToString:@"assistant"]){
        //教师小助手
        if ([DJTGlobalManager shareInstance].userInfo.isOpenAssistant) {
            AdDetailViewController *detail = [[AdDetailViewController alloc] init];
            detail.url = model.b_url;
            detail.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detail animated:YES];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"教师小助手功能未开启" message:@"只有开启后家长才能收到小助手推送的消息。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        }
    }
    else{
        if ([model.type isEqualToString:@"2"]) {
            AdDetailViewController *detail = [[AdDetailViewController alloc] init];
            detail.url = model.b_url;
            detail.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detail animated:YES];
        }
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    cell.alpha = 0.5;
}

- (void)collectionView:(UICollectionView *)collectionView  didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    cell.alpha = 1;
}

#pragma mark - 获取密钥
- (void)getCKey:(NSInteger)type
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.view makeToastActivity];
    [self.view setUserInteractionEnabled:NO];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getKey"];
    [param setObject:@"teacher" forKey:@"from"];
    [param setObject:manager.userInfo.classid forKey:@"class_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"token"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf getKeyFinish:success Data:data Type:type];
    } failedBlock:^(NSString *description) {
        [weakSelf getKeyFinish:NO Data:nil Type:type];
    }];
}

- (void)getKeyFinish:(BOOL)suc Data:(id)result Type:(NSInteger)type
{
    self.httpOperation = nil;
    [self.view hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
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
        
        NSString *value = [ret_data valueForKey:@"key"];
        switch (type - 1) {
            case 0:
            {
                AdDetailViewController *detail = [[AdDetailViewController alloc] init];
                NSString *url = [NSString stringWithFormat:@"http://wx.goonbaby.com/kq/classKqIndex/key/%@/from/2/isTeacher/1.html",value];
                detail.url = url;
                detail.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:detail animated:YES];
            }
                break;
            case 1:
            {
                AdDetailViewController *detail = [[AdDetailViewController alloc] init];
                NSString *url = [NSString stringWithFormat:@"http://wx.goonbaby.com/dailydiet/recipesIndex/key/%@/from/teacher.html",value];
                detail.url = url;
                detail.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:detail animated:YES];
            }
                break;
                
            default:
                break;
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
