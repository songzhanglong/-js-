//
//  PersonalInfoViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/12.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "PersonalInfoViewController.h"
#import "CTAssetsPickerController.h"
#import "Toast+UIView.h"
#import "UIImage+FixOrientation.h"
#import "NSString+Common.h"
#import "SelectItemCell.h"
#import "AppDelegate.h"
#import "ImageCropViewController.h"

@interface PersonalInfoViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,CTAssetsPickerControllerDelegate,ImageCropDelegate,SelectItemCellDelegate>

@end

@implementation PersonalInfoViewController
{
    UIImageView *_headImage;
    NSString *_imagePath;
    BOOL _isChange;
    
    NSString *sexString;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"个人资料";
    [self createRightBarButton];
    
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    _tableView.scrollEnabled = NO;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self createTableHeaderView];
}

- (void)createRightBarButton
{
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
    saveBtn.backgroundColor = [UIColor clearColor];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveUserImage:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

- (void)createTableHeaderView
{
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    CGFloat imgWei = 50,butWei = 85,butMar = 10;
    CGFloat yOri = 20;
    CGFloat margin = (winSize.width - imgWei - butMar - butWei * 2) / 3;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, imgWei + 20 * 2 + 5)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    //tip
    UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(margin * 2 + imgWei, yOri, 100, 20)];
    [tipLab setText:@"修改头像:"];
    [tipLab setFont:[UIFont systemFontOfSize:16]];
    [tipLab setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview:tipLab];
    
    yOri += 20 + 5;
    
    //head
    _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(margin, yOri, imgWei, imgWei)];
    _headImage.layer.masksToBounds = YES;
    _headImage.layer.cornerRadius = imgWei / 2;
    NSString *face = [DJTGlobalManager shareInstance].userInfo.face;
    if (![face hasPrefix:@"http"]) {
        face = [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
    }
    [_headImage setImageWithURL:[NSURL URLWithString:face] placeholderImage:[UIImage imageNamed:@"s21.png"]];
    [headerView addSubview:_headImage];
    
    for (NSInteger i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(imgWei + margin * 2 + (butWei + butMar) * i, yOri + (imgWei - 30) / 2, butWei, 30)];
        [button setTitle:(i == 0) ? @"拍照" : @"本地上传" forState:UIControlStateNormal];
        [button setTag:i + 1];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor colorWithRed:245.0 / 255 green:245.0 / 255 blue:245.0 / 255 alpha:1]];
        [button addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:button];
    }
    
    [_tableView setTableHeaderView:headerView];
    
    
    // 注销按钮
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 73)];
    [footView setBackgroundColor:_tableView.backgroundColor];
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(40, 30, footView.frameWidth - 80, 43);
    [cancelBtn setBackgroundColor:[UIColor redColor]];
    [cancelBtn addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [cancelBtn setTitle:@"退    出" forState:UIControlStateNormal];
    
    [footView addSubview:cancelBtn];
    [_tableView setTableFooterView:footView];
}

//注销登录
- (void)cancelClick
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app popToLoginViewController];
}

- (void)changeItemIndex:(SelectItemCell *)cell By:(SelectItemView *)itemView;
{
    SelectItemCell *itemCell = (SelectItemCell *)cell;
    sexString = (itemCell.itemView.nCurIndex == 0) ? @"男" : @"女";
}
#pragma mark - privite
- (void)changeHead:(NSString *)filePath
{
    [self.view makeToastActivity];
    _tableView.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf = self;
    //图片上传队列
    NSDictionary *dicOne = @{@"id": [NSString stringWithFormat:@"%@",[DJTGlobalManager shareInstance].userInfo.userid],@"type": @"1",@"img": @[@"160,160"]};    //1－图片
    NSData *json = [NSJSONSerialization dataWithJSONObject:dicOne options:NSJSONWritingPrettyPrinted error:nil];
    NSString *lstJson = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    NSString *gbkStr = [lstJson stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlPathImg = [NSString stringWithFormat:@"%@%@",G_UPLOAD_IMAGE,gbkStr];
    self.httpOperation = [DJTHttpClient asynchronousRequestWithProgress:urlPathImg parameters:nil filePath:filePath ssuccessBlcok:^(BOOL success, id data, NSString *msg) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        [weakSelf changeHeadFinish:data Suc:success];
    } failedBlock:^(NSString *description) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        [weakSelf changeHeadFinish:nil Suc:NO];
    } progressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
    }];
}

- (void)changeHeadFinish:(id)result Suc:(BOOL)success
{
    self.httpOperation = nil;
    [self.view hideToastActivity];
    _tableView.userInteractionEnabled = YES;
    if (success) {
        
        //_isChange = NO;
        _imagePath = nil;
        
        NSString *face = nil;
        if ([result isKindOfClass:[NSArray class]]) {
            result = [result firstObject];
        }
        NSString *original = [result valueForKey:@"original"];
        
        if (original && [original length] > 0) {
            NSString *extension = [original pathExtension];
            NSString *thumbnail = [NSString stringWithFormat:@"%@_160_160.%@",[[original stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"original" withString:@"thumbnail"],extension];
            face = thumbnail;
        }
        [self saveUserInfo:face];
//        else
//        {
//            [self.view makeToast:@"头像修改失败" duration:1.0 position:@"center"];
//            return;
//        }
//        
        DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
        manager.userInfo.face = [face hasPrefix:@"http"] ? face : [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
//        
        [[NSNotificationCenter defaultCenter] postNotificationName:CHANGE_USER_HEADER object:nil];
//        //图像地址提交到后台
//        NSMutableDictionary *param = [manager requestinitParamsWith:@"edit_face"];
//        [param setObject:manager.userInfo.userid forKey:@"userid"];
//        [param setObject:face forKey:@"face_path"];
//        [param setObject:@"1" forKey:@"is_teacher"];  //0-家长,1-老师 2-园长
//        NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
//        [param setObject:text forKey:@"signature"];
//        
//        [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"class"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
//            
//        } failedBlock:^(NSString *description) {
//            
//        }];
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        if ([result valueForKey:@"message"]) {
            str = [result valueForKey:@"message"];
        }
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

- (void)saveUserInfo:(NSString *)filePath
{
    if (sexString || filePath) {
        __weak __typeof(self)weakSelf = self;
        self.view.userInteractionEnabled = NO;
        self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"class"] parameters:[self configRequestParam:filePath] successBlcok:^(BOOL success, id data, NSString *msg) {
            [weakSelf userInfoFinish:success Data:data];
        } failedBlock:^(NSString *description) {
            [weakSelf userInfoFinish:NO Data:nil];
        }];
        
    }else{
        [self.view makeToast:@"个人信息没有修改！" duration:1.0 position:@"center"];
    }
}

#pragma mark - 参数配置
- (NSDictionary *)configRequestParam:(NSString *)filePath
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"editTeacher"];
    [param setObject:manager.userInfo.userid forKey:@"teacher_id"];
    if (sexString) {
        [param setObject:sexString forKey:@"sex"];
    }
    if (filePath) {
        [param setObject:filePath forKey:@"face"];
    }
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    return param;
}
- (void)userInfoFinish:(BOOL)success Data:(id)result
{
    self.httpOperation = nil;
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    
    if (!success) {
        NSString *str = [result objectForKey:@"ret_msg"];
        NSString *tip = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:tip duration:1.0 position:@"center"];
    }
    else
    {
        id ret_data = [result valueForKey:@"ret_data"];
        if (ret_data) {
            DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
            
            if (_isChange) {
                NSString *face = [ret_data valueForKey:@"face"];
                manager.userInfo.face = [face hasPrefix:@"http"] ? face : [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
                _isChange = NO;
            }
            
            if (sexString) {
                manager.userInfo.sex = [ret_data valueForKey:@"sex"];
                sexString = nil;
            }
        }
        [self.view makeToast:@"修改成功" duration:1.0 position:@"center"];
    }
}

#pragma mark - actions
- (void)saveUserImage:(id)sender
{
    if (!_isChange) {
        [self saveUserInfo:nil];
    }else{
        if (self.httpOperation) {
            return;
        }
        if (_imagePath) {
            //第一次上传失败，重新上传
            [self changeHead:_imagePath];
        }
        else
        {
            NSString *filePath = [APPTmpDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",[NSString stringByDate:@"yyyyMMddHHmmss" Date:[NSDate date]]]];
            _imagePath = filePath;
            NSData *data = UIImageJPEGRepresentation(_headImage.image, 0.8);
            [data writeToFile:filePath atomically:NO];
            [self changeHead:filePath];
        }
    }
}

- (void)selectPhoto:(id)sender
{
    switch ([sender tag] - 1) {
        case 0:
        {
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                return;
            }
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
//            picker.allowsEditing = YES;
            picker.sourceType = sourceType;
            [self presentViewController:picker animated:YES completion:NULL];
        }
            break;
        case 1:
        {
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            picker.maximumNumberOfSelection = 1;
            
            picker.assetsFilter = [ALAssetsFilter allPhotos];
            picker.delegate = self;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
            break;
        default:
            break;
    }
}
//照片保存回调
- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if(!error){
        [self.view makeToast:@"图片保存成功" duration:1.0 position:@"center"];
    }else{
        [self.view makeToast:@"图片保存失败" duration:1.0 position:@"center"];
    }
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    image = [image fixOrientation];
    //[_headImage setImage:image];
    //_isChange = YES;
    
    ImageCropViewController *controller = [[ImageCropViewController alloc] init];
    controller.originImage = image;
    controller.delegate= self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - CTAssetsPickerControllerDelegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (assets.count <= 0) {
        return;
    }
    ALAsset *asset = [assets firstObject];
    UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    //[_headImage setImage:image];
    //_isChange = YES;
    
    ImageCropViewController *controller = [[ImageCropViewController alloc] init];
    controller.originImage = image;
    controller.delegate= self;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - ImageCropViewController delegate
-(void)ImageCropVC:(ImageCropViewController*)ivc CroppedImage:(UIImage *)image
{
    if (image) {
        [_headImage setImage:image];
    }
    _isChange = YES;
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *personCell = @"PersonInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:personCell];
    if (cell == nil) {
        cell = [[SelectItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SelectCellId"];
        SelectItemCell *itemCell = (SelectItemCell *)cell;
        [itemCell.itemView setItems:@[@"男",@"女"]];
        itemCell.tipLabel.text = @"性别";
    }
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    NSArray *titleArray = @[@"性别",@"学校",@"姓名",@"所在班级"];
    NSArray *nameArray = @[@"",user.schoolname,user.uname,user.classname];
    
    SelectItemCell *itemCell = (SelectItemCell *)cell;
    itemCell.delegate = self;
    itemCell.tipLabel.attributedText = [[NSMutableAttributedString alloc]initWithString:[titleArray objectAtIndex:indexPath.row]];
    itemCell.detaillab.attributedText = [[NSMutableAttributedString alloc]initWithString:[nameArray objectAtIndex:indexPath.row]];
    itemCell.itemView.hidden = (indexPath.row != 0) ? YES : NO;
    itemCell.detaillab.hidden = (indexPath.row == 0) ? YES : NO;
    itemCell.currSex = user.sex;
    return cell;
}

@end
