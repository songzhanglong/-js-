//
//  MoreViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/23.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "MoreViewController.h"
#import "AppDelegate.h"
#import "StickyNoteViewController.h"
#import "PersonalInfoViewController.h"
#import "ChangePassViewController.h"
#import "AboutViewController.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"
#import "AdDetailViewController.h"

@interface MoreViewController ()<UIAlertViewDelegate>

@end

@implementation MoreViewController
{
    BOOL _checkAssistant,_shouldCheck;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ASSISTANT_NOTIFI object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLable.text = @"更多";
    
    [self createRightBarButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkAssistantType:) name:ASSISTANT_NOTIFI object:nil];
    
    _checkAssistant = [DJTGlobalManager shareInstance].userInfo.isOpenAssistant;
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_shouldCheck) {
        _shouldCheck = NO;
        [[DJTGlobalManager shareInstance] checkTeacherAssistant];
    }
}

- (void)createRightBarButton
{
    //返回按钮
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
    sureBtn.backgroundColor = [UIColor clearColor];
    [sureBtn setTitle:@"退出" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(backToLogin:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sureBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [leftView setHidden:YES];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftView];
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,leftItem];
}

- (void)backToLogin:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app popToLoginViewController];
}

#pragma mark - NSNotification
- (void)checkAssistantType:(NSNotification *)notifi
{
    BOOL isOpen = [DJTGlobalManager shareInstance].userInfo.isOpenAssistant;
    if (_checkAssistant != isOpen) {
        _checkAssistant = isOpen;
        [_tableView reloadData];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *docDir = [path objectAtIndex:0];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:docDir error:nil];
        
        [self.view makeToast:@"清除完毕" duration:1.0 position:@"center"];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 1;
    if (section == 1) {
        count = 2;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellMore = @"CellMore";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellMore];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellMore];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSArray *array = @[@[@"便利贴"],@[@"个人资料",@"修改密码"],@[@"教师小助手"],@[@"清除缓存"],@[@"版本记录"],@[@"关于"]];
    NSArray *titles = array[indexPath.section];
    cell.textLabel.text = titles[indexPath.row];
    if (indexPath.section == 2) {
        cell.detailTextLabel.text = _checkAssistant ? @"已开启" : @"未开启";
    }else{
        cell.detailTextLabel.text = @"";
    }
        
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
        {
            StickyNoteViewController *stickyNote = [[StickyNoteViewController alloc] init];
            stickyNote.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:stickyNote animated:YES];
        }
            break;
        case 1:
        {
            if (indexPath.row == 0) {
                PersonalInfoViewController *person = [[PersonalInfoViewController alloc] init];
                person.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:person animated:YES];
            }
            else if (indexPath.row == 1)
            {
                ChangePassViewController *pass = [[ChangePassViewController alloc] init];
                pass.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:pass animated:YES];
            }
        }
            break;
        case 2:
        {
            NSString *url = [DJTGlobalManager shareInstance].userInfo.assistantUrl;
            if (url.length > 0) {
                _shouldCheck = YES;
                AdDetailViewController *controller = [[AdDetailViewController alloc] init];
                controller.url = url;
                controller.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:controller animated:YES];
            }
            else{
                NSString *tip = [DJTGlobalManager shareInstance].userInfo.assistantTip;
                if (!tip || ![tip isKindOfClass:[NSString class]] || (tip.length == 0)) {
                    tip = @"数据正在加载,请稍候再试";
                }
                [self.view makeToast:tip duration:1.0 position:@"center"];
            }
        }
            break;
        case 3:
        {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提示" message:@"确定要清除缓存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            
            [alertView show];
        }
            break;
        case 4:
        {
            //版本记录
            AdDetailViewController *controller = [[AdDetailViewController alloc] init];
            controller.url = @"http://wap.goonbaby.com/version?is_teacher=1&tag=ios";
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 5:
        {
            AboutViewController *about = [[AboutViewController alloc] init];
            about.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:about animated:YES];
        }
        default:
            break;
    }
}

@end
