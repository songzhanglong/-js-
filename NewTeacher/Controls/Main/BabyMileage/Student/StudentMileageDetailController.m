//
//  StudentMileageDetailController.m
//  NewTeacher
//
//  Created by szl on 15/12/9.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "StudentMileageDetailController.h"
#import "MileageModel.h"
#import "MileageStudentModel.h"
#import "NSString+Common.h"
#import "AddThemeViewController.h"
#import "NSString+Common.h"
#import "MileageStudentModel.h"
#import "BabyMileageViewController.h"

@interface StudentMileageDetailController ()

@end

@implementation StudentMileageDetailController
{
    UIImageView *navBarHairlineImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showNewBack = YES;
    UIBarButtonItem *item = [self.navigationItem.leftBarButtonItems lastObject];
    UIButton *leftBut = (UIButton *)[[item.customView subviews] firstObject];
    [leftBut setFrame:CGRectMake(0, 0, 30, 30)];
    [leftBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mileageBackN" ofType:@"png"]] forState:UIControlStateNormal];
    [leftBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mileageBackH" ofType:@"png"]] forState:UIControlStateHighlighted];
    self.titleLable.text = self.mileage.name;
    self.titleLable.textColor = [UIColor whiteColor];
    //[self createRightButton];
    
    //top
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UIImageView *topImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, winSize.width, 180)];
    [topImg setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mileageTopBg" ofType:@"png"]]];
    [self.view addSubview:topImg];
    
    //head
    UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 54) / 2, 10, 54, 54)];
    NSString *str = _mileageStu.face_school;
    if (![str hasPrefix:@"http"]) {
        str = [G_IMAGE_ADDRESS stringByAppendingString:str ?: @""];
    }
    [headImg setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
    headImg.layer.masksToBounds = YES;
    headImg.layer.cornerRadius = 27;
    [self.view addSubview:headImg];
    
    //name + birthday
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(50, headImg.frame.origin.y + headImg.frame.size.height + 10, winSize.width - 100, 22)];
    [nameLab setFont:[UIFont boldSystemFontOfSize:18]];
    [nameLab setTextAlignment:1];
    [nameLab setTextColor:[UIColor whiteColor]];
    [nameLab setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:nameLab];
    
    UILabel *birthday = [[UILabel alloc] initWithFrame:CGRectMake(nameLab.frame.origin.x, nameLab.frame.origin.y + nameLab.frame.size.height, nameLab.frame.size.width, 16)];
    [birthday setFont:[UIFont systemFontOfSize:12]];
    [birthday setBackgroundColor:[UIColor clearColor]];
    [birthday setTextColor:[UIColor whiteColor]];
    [birthday setTextAlignment:1];
    [self.view addSubview:birthday];
    
    [nameLab setText:self.mileageStu.real_name];
    NSDate *dateBir = [NSString convertStringToDate:self.mileageStu.birthday];
    NSString *birStr = [NSString stringByDate:@"yyyy年MM月dd日" Date:dateBir];
    [birthday setText:birStr];
    
    [_tableView setAutoresizingMask:UIViewAutoresizingNone];
    [_tableView setFrame:CGRectMake(0, 120, winSize.width, winSize.height - 180)];
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getAlbumPhotos"];
    [param setObject:self.mileage.album_id ?: @"" forKey:@"album_id"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page"];
    [param setObject:_mileageStu.student_id forKey:@"student_id"];
    [param setObject:@"2" forKey:@"visual_type"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
    self.action = @"photo";
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = CreateColor(82, 78, 128);
    }
    else
    {
        navBar.tintColor = CreateColor(82, 78, 128);
    }
    
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    navBarHairlineImageView.hidden = YES;
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
        navBar.tintColor = CreateColor(233, 233, 233);
    }
    
    navBarHairlineImageView.hidden = NO;
}

- (void)createRightButton{
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
    [moreBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mileageMenuN" ofType:@"png"]] forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mileageMenuH" ofType:@"png"]] forState:UIControlStateHighlighted];
    [moreBtn addTarget:self action:@selector(addTheme:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

- (void)addTheme:(id)sender
{
    AddThemeViewController *addTheme = [[AddThemeViewController alloc] init];
    addTheme.themeType = MileageThemeAdd;
    BabyMileageViewController *baby = nil;
    for (UIViewController *con in self.navigationController.viewControllers) {
        if ([con isKindOfClass:[BabyMileageViewController class]]) {
            baby = (BabyMileageViewController *)con;
            addTheme.delegate =  (MileageViewController *)[baby.subControls objectAtIndex:0];
            break;
        }
    }
    
    [self.navigationController pushViewController:addTheme animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - 重载
- (void)createTableHeaderView{
     if ([self.mileage.digst length] > 0) {
         if (!_tableView.tableHeaderView) {
             CGSize winSize = [UIScreen mainScreen].bounds.size;
     
             UIFont *font = [UIFont systemFontOfSize:12];
             CGSize textSize = [NSString calculeteSizeBy:self.mileage.digst Font:font MaxWei:winSize.width - 50];
             CGFloat textHei = MAX(14, textSize.height);
             UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 20 + textHei + 8 + 8)];
             [headView setBackgroundColor:_tableView.backgroundColor];
     
             UIView *midView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, winSize.width, 20 + textHei)];
             [midView setBackgroundColor:[UIColor whiteColor]];
             [headView addSubview:midView];
     
             UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25, 10, winSize.width - 50, textHei)];
             [label setText:self.mileage.digst];
             [label setFont:font];
             [label setNumberOfLines:0];
             [midView addSubview:label];
     
             [_tableView setTableHeaderView:headView];
         }
     }
     else{
         [_tableView setTableHeaderView:nil];
     }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 18)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    UILabel *firstLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 18)];
    [firstLab setTextAlignment:1];
    [firstLab setBackgroundColor:CreateColor(82, 78, 128)];
    [firstLab setTextColor:[UIColor whiteColor]];
    [firstLab setFont:[UIFont systemFontOfSize:12]];
    [headerView addSubview:firstLab];
    
    ThemeBatchModel *theme = self.dataSource[section];
    UILabel *secondLab = [[UILabel alloc] initWithFrame:CGRectMake(firstLab.frameRight, 0, 95, 18)];
    [secondLab setTextColor:firstLab.backgroundColor];
    [secondLab setFont:[UIFont systemFontOfSize:12]];
    [secondLab setTextAlignment:1];
    [secondLab setBackgroundColor:CreateColor(212, 213, 215)];
    [secondLab setText:[theme.is_teacher isEqualToString:@"1"] ? (theme.name ?: @"") : [NSString stringWithFormat:@"%@小朋友", theme.name ?: @""]];
    [headerView addSubview:secondLab];
    
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:theme.create_time.doubleValue];
    [firstLab setText:[NSString stringByDate:@"yyyy年MM月dd日" Date:updateDate]];
    
    return headerView;
}
@end
