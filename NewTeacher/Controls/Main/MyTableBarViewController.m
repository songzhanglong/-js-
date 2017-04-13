//
//  MyTableViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/23.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "MyTableBarViewController.h"
#import "MainViewController.h"
#import "MessageViewController.h"
#import "MoreViewController.h"
#import "MyTableBar.h"
#import "TumblrLikeMenu.h"
#import "CTAssetsPickerController.h"
#import <AVFoundation/AVFoundation.h>
#import "Toast+UIView.h"
#import "AddActivityViewController.h"
#import "NSString+Common.h"
#import "Toast+UIView.h"
#import <QuartzCore/QuartzCore.h>
#import "SchoolYardViewController.h"
#import "UIImage+FixOrientation.h"
#import "UIImage+Caption.h"
#import "PlayViewController.h"

@interface MyTableBarViewController ()<MyTableBarDelegate,UINavigationControllerDelegate,CTAssetsPickerControllerDelegate,UIImagePickerControllerDelegate>

@end

@implementation MyTableBarViewController
{
    MyTableBar *_tabBarView;
    BOOL        _takePicture; //拍照
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MainViewController *main = [[MainViewController alloc] init];
    SchoolYardViewController *school = [[SchoolYardViewController alloc]init];
    MessageViewController *message = [[MessageViewController alloc] init];
    message.hidesBottomBarWhenPushed = YES;
    MoreViewController *more = [[MoreViewController alloc] init];
    
    UINavigationController *navMain = [[UINavigationController alloc] initWithRootViewController:main];
    navMain.navigationBarHidden = YES;
    //UINavigationController *navStu = [[UINavigationController alloc] initWithRootViewController:student];
    UINavigationController *navSch = [[UINavigationController alloc]initWithRootViewController:school];
    //navSch.navigationBarHidden = YES;
    UINavigationController *navMsg = [[UINavigationController alloc] initWithRootViewController:message];
    navMsg.navigationBarHidden = YES;
    UINavigationController *navMore = [[UINavigationController alloc] initWithRootViewController:more];
    
    NSArray *controls = @[navMain,navSch,navMsg,navMore];
    self.viewControllers = controls;

    _tabBarView = [[MyTableBar alloc] initWithFrame:self.tabBar.bounds];
    _tabBarView.delegate = self;
    [self.tabBar addSubview:_tabBarView];
}

#pragma mark - 弹出菜单
- (void)popMenu
{
    TumblrLikeMenuItem *menuItem0 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s15@2x" ofType:@"png"]] highlightedImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s15_@2x" ofType:@"png"]] text:@"相册"];
    
    TumblrLikeMenuItem *menuItem1 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fb1@2x" ofType:@"png"]] highlightedImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fb1_1@2x" ofType:@"png"]]  text:@"拍照"];
    
    TumblrLikeMenuItem *menuItem2 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s13@2x" ofType:@"png"]] highlightedImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s13_1@2x" ofType:@"png"]] text:@"小视频"];
    
    NSMutableArray *menus = [NSMutableArray arrayWithObjects:menuItem0,menuItem1,menuItem2, nil];
    TumblrLikeMenu *menu = [[TumblrLikeMenu alloc] initWithFrame:self.view.window.bounds subMenus:menus tip:@"取消"];
    __weak typeof(self)weakSelf = self;
    menu.selectBlock = ^(NSUInteger index) {
        if (index == 0) {
            //照片
            [weakSelf callImagePicker];
        }
        else if (index == 1)
        {
            //拍照
            [weakSelf takeOnePhoto];
        }
        else if (index == 2)
        {
            //视频
            [weakSelf takeViedeo];
        }
    };
    [menu show];
}

#pragma mark - 页面切换
- (void)videoCompressedFinish:(NSString *)videoPath
{
    AddActivityViewController *add = [[AddActivityViewController alloc] init];
    add.videoPath = videoPath;
    add.dataSource = [NSMutableArray arrayWithObject:videoPath];
    add.hidesBottomBarWhenPushed = YES;
    [(UINavigationController *)self.selectedViewController pushViewController:add animated:YES];
}

#pragma mark - 选择照片与拍照
- (void)callImagePicker
{
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc]init];
    picker.maximumNumberOfSelection = 20;
    picker.combine = YES;
    picker.assetsFilter = [ALAssetsFilter allAssets];
    
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)takeOnePhoto
{
    _takePicture = YES;
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;//设置类型
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)takeViedeo
{
    _takePicture = NO;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *pickerView = [[UIImagePickerController alloc] init];
        pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSArray * availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        pickerView.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
        pickerView.videoMaximumDuration = 40;
        pickerView.delegate = self;
        pickerView.allowsEditing = YES;
        [self presentViewController:pickerView animated:YES completion:NULL];
    }
}

#pragma mark - CTAssetsPickerControllerDelegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (assets.count > 0) {
        id firstItem = [assets firstObject];
        if ([firstItem isKindOfClass:[NSString class]]) {
            [self videoCompressedFinish:(NSString *)firstItem];
        }
        else{
            AddActivityViewController *add = [[AddActivityViewController alloc] init];
            add.dataSource = [NSMutableArray arrayWithArray:assets];
            add.hidesBottomBarWhenPushed = YES;
            [(UINavigationController *)self.selectedViewController pushViewController:add animated:YES];
        }
    }
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    /*
    if(!error){
        [self.view makeToast:@"图片保存成功" duration:1.0 position:@"center"];
    }else{
        [self.view makeToast:@"图片保存失败" duration:1.0 position:@"center"];
    }
     */
}

//把视频写入相册回调函数
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    /*
    if(!error){
        [self.view makeToast:@"视频文件保存成功" duration:1.0 position:@"center"];
    }else{
        [self.view makeToast:@"视频文件保存失败" duration:1.0 position:@"center"];
    }
     */
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (_takePicture) {
        [picker dismissViewControllerAnimated:YES completion:nil];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        image = [image fixOrientation];//把图片已正确的位置保存
        AddActivityViewController *add = [[AddActivityViewController alloc] init];
        add.dataSource = [NSMutableArray arrayWithObject:image];
        add.hidesBottomBarWhenPushed = YES;
        [(UINavigationController *)self.selectedViewController pushViewController:add animated:YES];
        return;
    }
    
    [picker dismissViewControllerAnimated:NO completion:nil];
    //保存视频
    NSString *videoPath=(NSString *)[[info objectForKey:UIImagePickerControllerMediaURL]path];
    UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    PlayViewController *play = [[PlayViewController alloc] init];
    play.fileUrl = [NSURL fileURLWithPath:videoPath];
    __weak typeof(self)weakSelf = self;
    play.playResult = ^(NSString *path){
        [weakSelf videoCompressedFinish:path];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:play];
    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - MyTableBarDelegate
- (void)selectTableIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            self.selectedIndex = 0;
            _tabBarView.nSelectedIndex = 0;
        }
            break;
        case 1:
        {
            self.selectedIndex = 1;
            _tabBarView.nSelectedIndex = 1;
        }
            break;
        case 2:
        {
            [self popMenu];
        }
            break;
        case 3:
        {
            self.selectedIndex = 2;
            _tabBarView.nSelectedIndex = 3;
        }
            break;
        case 4:
        {
            self.selectedIndex = 3;
            _tabBarView.nSelectedIndex = 4;
        }
            break;
        default:
            break;
    }
}

/**
 *	@brief	状态栏样式，子类复写
 *
 *	@return	样式类型
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.selectedViewController.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return self.selectedViewController.prefersStatusBarHidden;
}

- (BOOL)shouldAutorotate
{
    return self.selectedViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.selectedViewController.supportedInterfaceOrientations;
}

@end
