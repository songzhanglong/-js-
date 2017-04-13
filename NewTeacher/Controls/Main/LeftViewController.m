//
//  LeftViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/24.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "LeftViewController.h"
#import "YQSlideMenuController.h"
#import "DJTGlobalManager.h"
#import "MyTableBarViewController.h"
#import "GrowNewViewController.h"
#import "NotificationListViewController.h"
#import "NotificationSendViewController.h"
#import "MyCalendarViewController.h"
#import "UIButton+WebCache.h"
#import "MainViewController1.h"
#import "AppDelegate.h"
#import "Toast+UIView.h"
#import "PersonalInfoViewController.h"
#import "BabyMileageViewController.h"
#import "FamilyViewController.h"

@interface LeftViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation LeftViewController
{
    UITableView *_tableView;
    UIButton *_headImg;
    UILabel *_nameLab;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGE_USER_HEADER object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeader:) name:CHANGE_USER_HEADER object:nil];
    
    //back
    UIImageView *backView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backView.clipsToBounds = YES;
    backView.contentMode = UIViewContentModeScaleAspectFill;
    [backView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s28@2x" ofType:@"png"]]];
    [self.view addSubview:backView];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:footView];
    _tableView.scrollEnabled = NO;
    [self.view addSubview:_tableView];
    
    //header
    CGFloat yOri = 20;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80 + yOri)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    
    _headImg = [UIButton buttonWithType:UIButtonTypeCustom];
    _headImg .frame =CGRectMake(10, 15 + yOri, 50, 50);
    _headImg.layer.masksToBounds = YES;
    _headImg.layer.cornerRadius = 25;
    NSString *face = user.face;
    if (![face hasPrefix:@"http"]) {
        face = [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
    }
    [_headImg setImageWithURL:[NSURL URLWithString:face] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
    [_headImg addTarget:self action:@selector(sendNoti:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:_headImg];
    
    _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(70, 15 + yOri, 200, 20)];
    [_nameLab setTextColor:[UIColor whiteColor]];
    [_nameLab setFont:[UIFont systemFontOfSize:16]];
    [_nameLab setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview:_nameLab];
    [_nameLab setText:user.uname];
    
    if ([user.schoolname length] != 0) {
        CGSize lastSize = CGSizeZero;
        CGFloat wei = [UIScreen mainScreen].bounds.size.width - 70 - 70;
        UIFont *font = [UIFont systemFontOfSize:18];
        NSDictionary *attribute = @{NSFontAttributeName: font};
        lastSize = [user.schoolname boundingRectWithSize:CGSizeMake(wei, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        
        UILabel *schoolLab = [[UILabel alloc] initWithFrame:CGRectMake(70, 15 + 24 + yOri, wei, MIN(lastSize.height, 43))];
        [schoolLab setTextColor:[UIColor yellowColor]];
        [schoolLab setFont:font];
        [schoolLab setNumberOfLines:2];
        [schoolLab setBackgroundColor:[UIColor clearColor]];
        [headerView addSubview:schoolLab];
        [schoolLab setText:user.schoolname];
    }
    
    [_tableView setTableHeaderView:headerView];
}
- (void)sendNoti:(id)sender
{
    YQSlideMenuController *deckController = (YQSlideMenuController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [deckController hideMenu];
    
    double delayInSeconds = 0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        dispatch_async(dispatch_get_main_queue(), ^{
            Class toClass = [PersonalInfoViewController class];
            MyTableBarViewController *tabBarCon = (MyTableBarViewController *)deckController.contentViewController;
            UINavigationController *nav = (UINavigationController *)tabBarCon.selectedViewController;
            BOOL hasFound = NO;
            UIViewController *toCon = nil;
            //判断是否在当前堆栈中
            for (UIViewController *subCon in nav.viewControllers) {
                if ([subCon isKindOfClass:toClass]){
                    hasFound = YES;
                    toCon = subCon;
                    break;
                }
            }
            if (!hasFound) {
                //未在当前堆栈中找到该类
                toCon = [[toClass alloc] init];
                toCon.hidesBottomBarWhenPushed = YES;
                [nav pushViewController:toCon animated:YES];
            }
            else
            {
                //在当前堆栈中，且不是栈顶
                if (![nav.topViewController isKindOfClass:toClass]) {
                    [nav popToViewController:toCon animated:YES];
                }
                
            }
        });
        
    });
}

- (void)refreshHeader:(NSNotification *)notifi
{
    NSString *face = [DJTGlobalManager shareInstance].userInfo.face;
    if (![face hasPrefix:@"http"]) {
        face = [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
    }
    [_headImg setImageWithURL:[NSURL URLWithString:face] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *leftIdentifierBase = @"leftCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:leftIdentifierBase];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:leftIdentifierBase];
        
        //imageView
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 9, 32, 32)];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setTag:1];
        [cell.contentView addSubview:imageView];
        
        //title sup
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 9, imageView.frame.origin.y, 250, 20)];
        [label setFont:[UIFont systemFontOfSize:18]];
        [label setTextColor:[UIColor blackColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        label.highlightedTextColor = [UIColor whiteColor];
        [label setTag:2];
        [cell.contentView addSubview:label];
        
        //title sub
        label = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y + label.frame.size.height, 250, 14)];
        [label setFont:[UIFont systemFontOfSize:12]];
        [label setTextColor:[UIColor darkGrayColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTag:3];
        [cell.contentView addSubview:label];
    }
    
    NSArray *topTitles = @[@"我的日历",@"成长档案",@"班级里程",@"家园联系",@"通知"];
    NSArray *tipsArray = @[@"记录您每天的辛勤劳动成果",@"为班级学生制作成长档案吧～",@"点击分享班级里程的精彩瞬间",@"家园共育",@"点击发布园所通知"];
    NSArray *imgs = @[@"s22@2x.png",@"s24@2x.png",@"s25@2x.png",@"s26@2x.png",@"s27@2x.png"];
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
    [imageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgs[indexPath.row] ofType:nil]]];
    
    UILabel *supTitle = (UILabel *)[cell.contentView viewWithTag:2];
    [supTitle setText:topTitles[indexPath.row]];
    
    UILabel *subTitle = (UILabel *)[cell.contentView viewWithTag:3];
    [subTitle setText:tipsArray[indexPath.row]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YQSlideMenuController *deckController = (YQSlideMenuController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [deckController hideMenu];
    
    double delayInSeconds = 0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        dispatch_async(dispatch_get_main_queue(), ^{
            Class toClass = nil;
            switch (indexPath.row) {
                case 0:
                {
                    toClass = [MyCalendarViewController class];
                }
                    break;
                case 1:
                {
                    toClass = [GrowNewViewController class];
                }
                    break;
                case 2:
                {
                    toClass = [BabyMileageViewController class];
                }
                    break;
                case 3:
                {
                    toClass = [FamilyViewController class];
                }
                    break;
                case 4:
                {
                    toClass = [NotificationListViewController class];
                }
                    break;
                default:
                    break;
            }
            
            if (!toClass) {
                return;
            }
            MyTableBarViewController *tabBarCon = (MyTableBarViewController *)deckController.contentViewController;
            UINavigationController *nav = (UINavigationController *)tabBarCon.selectedViewController;
            BOOL hasFound = NO;
            UIViewController *toCon = nil;
            //判断是否在当前堆栈中
            for (UIViewController *subCon in nav.viewControllers) {
                if ([subCon isKindOfClass:toClass]){
                    hasFound = YES;
                    toCon = subCon;
                    break;
                }
            }
            if (!hasFound) {
                //未在当前堆栈中找到该类
                if (toClass == [BabyMileageViewController class]) {
                    CGSize winSize = [UIScreen mainScreen].bounds.size;
                    MileageStudentViewController *student = [[MileageStudentViewController alloc] init];
                    student.view.frame = CGRectMake(0, 155, winSize.width, winSize.height - 155 - 64);
                    MileageViewController *mileage = [[MileageViewController alloc] init];
                    mileage.view.frame = student.view.frame;
                    
                    toCon = [[BabyMileageViewController alloc] initWithControls:@[mileage,student] Titles:@[@"里程",@"学生"] Frame:CGRectMake(0, 120, winSize.width, 35)];
                    [(BabyMileageViewController *)toCon setInitIdx:0];
                }
                else{
                    toCon = [[toClass alloc] init];
                }
                toCon.hidesBottomBarWhenPushed = YES;
                [nav pushViewController:toCon animated:YES];
            }
            else
            {
                //在当前堆栈中，且不是栈顶
                if (![nav.topViewController isKindOfClass:toClass]) {
                    [nav popToViewController:toCon animated:YES];
                }
                
            }
        });
        
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
}

@end
