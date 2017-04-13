//
//  StudentBaseViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/25.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "StudentBaseViewController.h"
#import "StudentClockViewController.h"
#import "StudentContactViewController.h"
#import "StudentGrowViewController.h"
#import "StudentPhotoViewController.h"
#import "MyStudentViewController.h"
#import "StudentAlbumsViewController.h"
#import "CTAssetsPickerController.h"
#import "UIImage+FixOrientation.h"
#import "NSString+Common.h"
#import "Toast+UIView.h"
#import "Guardian.h"
#import "ImageCropViewController.h"

@interface StudentBaseViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate,CTAssetsPickerControllerDelegate,ClassSelectedDelegate,UIImagePickerControllerDelegate,GuardianDelegate,ImageCropDelegate>

@end

@implementation StudentBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //back
    UIImage *titleImg = [UIImage imageNamed:@"bg2.png"];
    CGSize imgSize = titleImg.size;
    CGFloat hei = self.view.frame.size.width * imgSize.height / imgSize.width;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:titleImg];
    imageView.userInteractionEnabled = YES;
    [imageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, hei)];
    [self.view addSubview:imageView];
    
    //back button
    CGFloat yOri = 20;
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setBackgroundColor:[UIColor clearColor]];
    [backBtn setFrame:CGRectMake(10, yOri + 7, 30, 30)];
    [backBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_1.png"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backBtnClicke:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    //check
    UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [checkBtn setBackgroundColor:[UIColor clearColor]];
    [checkBtn setFrame:CGRectMake(self.view.bounds.size.width - 10 - 100, yOri + 7, 100, 30)];
    [checkBtn setTitle:@"查看监护人" forState:UIControlStateNormal];
    [checkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [checkBtn addTarget:self action:@selector(checkBtnClicke:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkBtn];
    
    //face back
    UIImageView *faceBack = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 79, 79)];
    [faceBack setImage:[UIImage imageNamed:@"face_bg2.png"]];
    [faceBack setCenter:CGPointMake(self.view.bounds.size.width / 2, 90)];
    [self.view addSubview:faceBack];
    
    UIImageView *face = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 62, 62)];
    [face setCenter:faceBack.center];
    _faceImage = face;
    face.layer.cornerRadius = 31;
    face.layer.masksToBounds = YES;
    [face setBackgroundColor:[UIColor clearColor]];
    [face setUserInteractionEnabled:YES];
    NSString *facetmp = _student.face;
    if (![facetmp hasPrefix:@"http"]) {
        facetmp = [G_IMAGE_ADDRESS stringByAppendingString:facetmp ?: @""];
    }
    [face setImageWithURL:[NSURL URLWithString:facetmp] placeholderImage:[UIImage imageNamed:@"s21.png"]];
    [self.view addSubview:face];
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [singleTapGesture setNumberOfTapsRequired:1];
    [face addGestureRecognizer:singleTapGesture];
    
    //name
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 85, 30)];
    [_nameLabel setCenter:CGPointMake(_faceImage.center.x, _faceImage.frame.size.height + _faceImage.frame.origin.y + 16)];
    NSString *temp = [_student.uname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [_nameLabel setText:temp];
    [_nameLabel setBackgroundColor:[UIColor clearColor]];
    [_nameLabel setTextAlignment:1];
    [self.view addSubview:_nameLabel];
    
    
    //sex
    _sexImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    [_sexImage setCenter:CGPointMake(_faceImage.center.x+40, _faceImage.frame.size.height + _faceImage.frame.origin.y + 15)];
    [_sexImage setBackgroundColor:[UIColor clearColor]];
    [_sexImage setImage:[UIImage imageNamed:[_student.sex isEqualToString:@"男"] ? @"homepage_man.png" : @"homepage_girl.png"]];
    [self.view addSubview:_sexImage];
    
    //tip
    _tipLab = [[UILabel alloc]initWithFrame:CGRectMake(10, hei - 20 - 10, self.view.frame.size.width , 20)];
    [_tipLab setFont:[UIFont systemFontOfSize:13]];
    [_tipLab setBackgroundColor:[UIColor clearColor]];
    [_tipLab setTextAlignment:1];
    [_tipLab setText:[NSString stringWithFormat:@"生日:%@     成长档案:%@/%@",_student.birthday,_student.grows_num,_student.templist_nums]];
    [self.view addSubview:_tipLab];
    
    //select view
    _selectView = [[UIView alloc]initWithFrame:CGRectMake(0, hei + 1, self.view.frame.size.width, 44)];
    [self.view addSubview:_selectView];
    
    //buttons
    NSArray *arr = [NSArray arrayWithObjects:@"宝宝里程",@"成长档案",@"家园联系",@"考勤记录", nil];
    CGFloat butWei = (self.view.frame.size.width - 3) / 4;
    for (int i = 0; i < 4; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake((butWei + 1) * i, 0, butWei, _selectView.frame.size.height)];
        [btn setTitle:[arr objectAtIndex:i] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        btn.tag = i + 1;
        [btn addTarget: self action:@selector(btnClicke:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundColor:(i == 0) ? [UIColor colorWithRed:232/255.0 green:103/255.0 blue:103/255.0 alpha:1] : [UIColor colorWithRed:249 / 255.0 green:149 / 255.0 blue:126 / 255.0 alpha:1]];
        [_selectView addSubview:btn];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)setNCurIndex:(NSInteger)nCurIndex
{
    _nCurIndex = nCurIndex;
    for (int i = 0; i < 4; i++) {
        UIButton *button = (UIButton *)[_selectView viewWithTag:i + 1];
        [button setBackgroundColor:(i == nCurIndex) ? [UIColor colorWithRed:232/255.0 green:103/255.0 blue:103/255.0 alpha:1] : [UIColor colorWithRed:249 / 255.0 green:149 / 255.0 blue:126 / 255.0 alpha:1]];
    }
}

#pragma mark - actions
- (void)handleSingleTap:(UIGestureRecognizer *)gesture {
    //头像选择
    if (self.httpOperation) {
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"本地",@"学生相册",@"拍照", nil];
    [actionSheet showInView:self.view];
}

- (void)handleSingleTapGuardian:(UIGestureRecognizer *)gesture {
    [[gesture view] removeFromSuperview];
}

- (void)backBtnClicke:(id)sender
{
    [[DJTGlobalManager shareInstance] setStudentControls:nil];
    
    for (UIViewController *subCon in self.navigationController.viewControllers) {
        if ([subCon isKindOfClass:[MyStudentViewController class]]) {
            [self.navigationController popToViewController:subCon animated:YES];
            break;
        }
    }
}

- (void)checkBtnClicke:(id)sender
{
    if (self.httpOperation) {
        return;
    }
    
    UIView *backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [backView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGuardian:)];
    [singleTapGesture setNumberOfTapsRequired:1];
    [backView addGestureRecognizer:singleTapGesture];
    
    Guardian *guardian = [[[NSBundle mainBundle]loadNibNamed:@"Guardian" owner:self options:0]lastObject];
    [guardian.parentLabel setText:[NSString stringWithFormat:@"家长:%@",_student.parents_name]];
    [guardian.relationLabel setText:[NSString stringWithFormat:@"关系:%@",_student.relation]];
    [guardian.contactLabel setText:_student.mobile];
    [guardian setCenter:backView.center];
    guardian.delegate = self;
    [backView addSubview:guardian];
    
    [self.view.window addSubview:backView];
    
    
}

- (void)btnClicke:(id)sender
{
    if (self.httpOperation) {
        return;
    }
    
    NSInteger index = [sender tag] - 1;
    if (index == self.nCurIndex) {
        return;
    }
    
    Class class = nil;
    switch (index) {
        case 0:
        {
            class = [StudentPhotoViewController class];
        }
            break;
        case 1:
        {
            class = [StudentGrowViewController class];
        }
            break;
        case 2:
        {
            class = [StudentContactViewController class];
        }
            break;
        case 3:
        {
            class = [StudentClockViewController class];
        }
            break;
        default:
            break;
    }
    
    //导航中查询
    for (UIViewController *nextControl in self.navigationController.viewControllers) {
        if ([nextControl isKindOfClass:class]) {
            [self.navigationController popToViewController:nextControl animated:NO];
            return;
        }
    }
    //内存中查询
    NSArray *controls = [DJTGlobalManager shareInstance].studentControls;
    for (UIViewController *subCon in controls) {
        if ([subCon isKindOfClass:class]) {
            [self.navigationController pushViewController:subCon animated:NO];
            return;
        }
    }
    //新增
    StudentBaseViewController *newCon = [[class alloc] init];
    newCon.student = self.student;
    newCon.myStudentModel = self.myStudentModel;
    [self.navigationController pushViewController:newCon animated:NO];
    [[DJTGlobalManager shareInstance].studentControls addObject:newCon];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            picker.maximumNumberOfSelection = 1;
            
            picker.assetsFilter = [ALAssetsFilter allPhotos];
            picker.delegate = self;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
            break;
        case 1:
        {
            StudentAlbumsViewController *studentAlbum = [[StudentAlbumsViewController alloc] init];
            studentAlbum.student = _student;
            studentAlbum.nMaxCount = 1;
            studentAlbum.delegate = self;
            [self.navigationController pushViewController:studentAlbum animated:YES];
        }
            break;
        case 2:
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
        default:
            break;
    }
}

#pragma mark - ClassSelectedDelegate
- (void)selectClass:(NSArray *)array
{
    UIImage *image = [array firstObject];
    
    ImageCropViewController *controller = [[ImageCropViewController alloc] init];
    controller.originImage = image;
    controller.delegate= self;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - CTAssetsPickerControllerDelegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (assets.count <= 0) {
        return;
    }
    ALAsset *asset = [assets firstObject];
    UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    
    ImageCropViewController *controller = [[ImageCropViewController alloc] init];
    controller.originImage = image;
    controller.delegate= self;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - ImageCropViewController delegate
-(void)ImageCropVC:(ImageCropViewController*)ivc CroppedImage:(UIImage *)image
{
    if (image) {
        NSString *filePath = [APPTmpDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",[NSString stringByDate:@"yyyyMMddHHmmss" Date:[NSDate date]]]];
        NSData *data = UIImageJPEGRepresentation(image, 1);
        [data writeToFile:filePath atomically:NO];
        [self changeHead:filePath];
    }
    
    [self.navigationController popToViewController:self animated:YES];
}
#pragma mark - pravite
- (void)changeHead:(NSString *)filePath
{
    [self.view makeToastActivity];
    NSDictionary *dic = @{@"student_id":_student.student_id};
    __weak typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousRequestWithProgress:[URLFACE stringByAppendingString:@"student:edit_face"] parameters:dic filePath:filePath ssuccessBlcok:^(BOOL success, id data, NSString *msg) {
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
    if (success) {
        NSString *face = [result valueForKey:@"face"];
        if (![face hasPrefix:@"http"]) {
            face = [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
        }
        _student.face = face;
        [_faceImage setImageWithURL:[NSURL URLWithString:face] placeholderImage:[UIImage imageNamed:@"s21.png"]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CHANGE_HEAD_FINISH object:_student.student_id];
        
        NSString *_newImagePath = [face stringByReplacingOccurrencesOfString:G_IMAGE_ADDRESS withString:@""];
        
        DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
        //图像地址提交到后台
        NSMutableDictionary *param = [manager requestinitParamsWith:@"edit_face"];
        [param setObject:_student.student_id forKey:@"userid"];
        [param setObject:_newImagePath forKey:@"face_path"];
        [param setObject:@"0" forKey:@"is_teacher"];  //0-家长,1-老师 2-园长
        NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
        [param setObject:text forKey:@"signature"];
        __weak typeof(self)weakSelf = self;
        [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"class"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
            NSLog(@"%@",data);
            [weakSelf uploadResult:data Suc:success];
        } failedBlock:^(NSString *description) {
            [weakSelf uploadResult:nil Suc:NO];
        }];
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

- (void)uploadResult:(id)result Suc:(BOOL)success
{
    if (success) {
        NSString *str = @"头像修改成功";
        if ([result valueForKey:@"message"]) {
            str = [result valueForKey:@"message"];
        }
        [self.view makeToast:str duration:1.0 position:@"center"];
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
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        image = [image fixOrientation];
        
        ImageCropViewController *controller = [[ImageCropViewController alloc] init];
        controller.originImage = image;
        controller.delegate= self;
        [self.navigationController pushViewController:controller animated:YES];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - GuardianDelegate
-(void)contactGrardian:(Guardian *)guardian Item:(NSInteger)index
{
    [[guardian superview] removeFromSuperview];
    if (index == 1) {
        NSString *phoneNum = [NSString stringWithFormat:@"sms://%@",_student.mobile];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:phoneNum]];
    }
    else if (index == 2)
    {
        NSURLCache * cache = [NSURLCache sharedURLCache];
        [cache removeAllCachedResponses];
        [cache setDiskCapacity:0];
        [cache setMemoryCapacity:0];
        NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",_student.mobile]];
        UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectZero];
        [webView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
        [self.view addSubview:webView];
    }
}

@end
