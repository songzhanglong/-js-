//
//  StudentPhotoViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/25.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "StudentPhotoViewController.h"
#import "NSObject+Reflect.h"
#import "CTAssetsPickerController.h"
#import "Toast+UIView.h"
#import "UIImage+Caption.h"
#import "UploadManager.h"
#import "NSString+Common.h"
#import "ThemeBatchModel.h"
#import "NSString+Common.h"
#import "BabyMileageViewController.h"
#import "StudentMileageViewController.h"
#import "MileagePhotoViewController.h"
#import "MileageStudentModel.h"
#import "UIImage+FixOrientation.h"

@interface StudentPhotoViewController ()<UINavigationControllerDelegate,CTAssetsPickerControllerDelegate>

@end

@implementation StudentPhotoViewController
{
    BOOL _stopSuper,_requestHistory;
    NSInteger _pageIdx,_pageCount;
    BOOL _lastPage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nCurIndex = 0;
    self.useNewInterface = YES;
    [[DJTGlobalManager shareInstance] setStudentControls:[NSMutableArray arrayWithObject:self]];
    _pageCount = 10;
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat margin = 5;
    CGFloat itemWei = (winSize.width - 4 * margin) / 3,itemHei = itemWei;
    layout.itemSize = CGSizeMake(itemWei, itemHei);
    layout.minimumLineSpacing = margin;
    layout.minimumInteritemSpacing = margin;
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    [self createCollectionViewLayout:layout Action:nil Param:nil Header:YES Foot:YES];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"mileagePhotoCell"];
    [_collectionView setAutoresizingMask:UIViewAutoresizingNone];
    CGFloat yOri = 0;
    [_collectionView setFrame:CGRectMake(0, _selectView.frame.origin.y + _selectView.frame.size.height, winSize.width, winSize.height - 44 - (_selectView.frame.origin.y + _selectView.frame.size.height) - yOri)];
    _collectionView.alwaysBounceVertical = YES;
    [self beginRefresh];
    
    [self.view addSubview:[self createBabyPhotoFootView]];
}

/**
 *	@brief	宝贝相册下边视图
 *
 *	@return	view
 */
- (UIView *)createBabyPhotoFootView
{
    CGFloat yOri = 0;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 44 - yOri, [[UIScreen mainScreen] bounds].size.width, 44.0)];
    [footView setBackgroundColor:[UIColor whiteColor]];
    
    //add
    UIButton *addBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBut setFrame:CGRectMake(20, 7, 130, 30)];
    [addBut setTag:1];
    [addBut setTitle:@"添加图片" forState:UIControlStateNormal];
    [addBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addBut addTarget:self action:@selector(addOrSelectAllPicture:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:addBut];
    
    //select
    UIButton *selBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [selBut setTag:2];
    [selBut setFrame:CGRectMake(self.view.frame.size.width - 150, 7, 130, 30)];
    [selBut setTitle:@"查看所有" forState:UIControlStateNormal];
    [selBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [selBut addTarget:self action:@selector(addOrSelectAllPicture:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:selBut];
    
    return footView;
}

/**
 *	@brief	添加或查看图片
 *
 *	@param 	sender 	按钮项
 */
- (void)addOrSelectAllPicture:(UIButton *)sender
{
    NSInteger tag = [sender tag] - 1;
    switch (tag) {
        case 0:
        {
            _stopSuper = YES;
            //添加图片
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            picker.maximumNumberOfSelection = 20;
            
            picker.assetsFilter = [ALAssetsFilter allPhotos];
            picker.delegate = self;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
            break;
        case 1:
        {
            MileageStudentModel *model = [[MileageStudentModel alloc] init];
            model.birthday = self.student.birthday;
            model.real_name = self.student.uname;
            model.student_id = self.student.student_id;
            model.face_school = self.student.face;
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            StudentMileageViewController *student = [[StudentMileageViewController alloc] init];
            student.view.frame = CGRectMake(0, 155, winSize.width, winSize.height - 155 - 64);
            MileagePhotoViewController *mileage = [[MileagePhotoViewController alloc] init];
            mileage.disanableDelete = YES;
            mileage.view.frame = student.view.frame;
            
            BabyMileageViewController *baby = [[BabyMileageViewController alloc] initWithControls:@[student,mileage] Titles:@[@"里程",@"相册"] Frame:CGRectMake(0, 120, winSize.width, 35)];
            baby.mileageStu = model;
            baby.initIdx = 1;
            [self.navigationController pushViewController:baby animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _stopSuper = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.myStudentModel && !_requestHistory) {
        _requestHistory = YES;
        [self requestHistoryInfo];
    }
}

#pragma mark - 宝宝里程之前的接口
- (void)requestHistoryInfo
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSDictionary *dic = @{@"album_id": self.student.album_id,@"userid":manager.userInfo.userid,@"student_id":self.student.student_id,@"grow_id":self.student.grow_id,@"grade_id":manager.userInfo.grade_id,@"school_id":manager.userInfo.schoolid,@"term_id":manager.userInfo.term_id,@"week_index":[NSString stringWithFormat:@"%ld",(long)manager.weekIdx + 1]};
    
    //针对老接口
    NSString *url = [URLFACE stringByAppendingString:@"student:index"];
    
    __weak typeof(self)weakSelf = self;
    [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf historyFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf historyFinish:NO Data:nil];
    }];
}
     
- (void)historyFinish:(BOOL)suc Data:(id)result
{
    _requestHistory = NO;
    if (suc) {
        StudentModel *student = [[StudentModel alloc] init];
        [student reflectDataFromOtherObject:result];
        
        //考勤异常数据,BabyAttence
        NSMutableArray *array = [NSMutableArray array];
        if ([student.attence isKindOfClass:[NSArray class]] && student.attence.count > 0) {
            for (NSObject *object in student.attence) {
                BabyAttence *attence = [[BabyAttence alloc] init];
                [attence reflectDataFromOtherObject:object];
                [array addObject:attence];
            }
        }
        [student setAttence:array];
        
        //宝贝相册,DJTBabyPhoto
        array = [NSMutableArray array];
        if ([student.photos isKindOfClass:[NSArray class]] && student.photos.count > 0) {
            for (NSObject *object in student.photos) {
                BabyPhoto *photo = [[BabyPhoto alloc] init];
                [photo reflectDataFromOtherObject:object];
                [array addObject:photo];
            }
        }
        
        [student setPhotos:array];
        
        //已制作成长档案列表,DJTBabyGrow
        array = [NSMutableArray array];
        if ([student.grows isKindOfClass:[NSArray class]] && student.grows.count > 0) {
            for (id object in student.grows) {
                BabyGrow *grow = [[BabyGrow alloc] init];
                [grow reflectDataFromOtherObject:object];
                [array addObject:grow];
            }
        }
        [student setGrows:array];
        
        //家园联系卡内容,DJTBabyCard
        array = [NSMutableArray array];
        if ([student.cards isKindOfClass:[NSArray class]] && student.cards.count > 0) {
            for (NSObject *object in student.cards) {
                BabyCard *card = [[BabyCard alloc] init];
                [card reflectDataFromOtherObject:object];
                [array addObject:card];
            }
        }
        
        [student setCards:array];
        
        self.myStudentModel = student;
    }
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getPhotoList2"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page"];
    [param setObject:@"2" forKey:@"visual_type"];
    
    [param setObject:self.student.student_id forKey:@"student_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
    self.action = @"photo";
}

- (void)startPullRefresh
{
    _pageIdx = 1;
    _lastPage = NO;
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
        if ([self.dataSource count] > 0) {
            _pageIdx++;
        }
        [super startPullRefresh2];
    }
    
}

- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        
        id pageSize = [ret_data valueForKey:@"pageCount"];
        _lastPage = _pageIdx >= [pageSize integerValue];
        
        NSMutableArray *array = [NSMutableArray array];
        NSArray *data = [ret_data valueForKey:@"list"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        for (id subDic in data) {
            NSError *error;
            ThemeBatchModel *themeBatch = [[ThemeBatchModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [array addObjectsFromArray:themeBatch.photos];
        }
        
        self.dataSource = array;
    }
    else{
        self.dataSource = nil;
        id ret_msg = [result valueForKey:@"ret_msg"];
        [self.view makeToast:ret_msg ?: REQUEST_FAILE_TIP duration:1.0 position:@"center"];
        
    }
    [_collectionView reloadData];
}

- (void)requestFinish2:(BOOL)success Data:(id)result
{
    [super requestFinish2:success Data:result];
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        id pageSize = [ret_data valueForKey:@"pageCount"];
        _lastPage = _pageIdx >= [pageSize integerValue];
        
        NSArray *data = [ret_data valueForKey:@"list"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        NSMutableArray *array = [NSMutableArray array];
        NSMutableArray *set = [NSMutableArray array];
        NSInteger count = [self.dataSource count];
        for (id subDic in data) {
            NSError *error;
            ThemeBatchModel *themeBatch = [[ThemeBatchModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            for (ThemeBatchItem *item in themeBatch.photos) {
                [array addObject:item];
                [set addObject:[NSIndexPath indexPathForItem:count++ inSection:0]];
            }
        }
        
        if (!self.dataSource) {
            self.dataSource = [NSMutableArray array];
        }
        [self.dataSource addObjectsFromArray:array];
        [_collectionView insertItemsAtIndexPaths:set];
    }
    else
    {
        if (_pageIdx > 1) {
            _pageIdx -= 1;
        }
    }
}

#pragma mark - 上传图片
- (void)uploadImgs:(NSArray *)array
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        
        [self.view.window makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    NSString *timeStr = [NSString stringByDate:@"yyyyMMddHHmmss" Date:[NSDate date]];
    NSMutableArray *paths = [NSMutableArray array];
    for (int i = 0; i < array.count; i++) {
        NSString *fileName = [NSString stringWithFormat:@"%@%d.jpg",timeStr,i];
        NSString *filePath = [APPTmpDirectory stringByAppendingPathComponent:fileName];;
        UIImage *image = [array objectAtIndex:i];
        
        NSData *data = UIImageJPEGRepresentation(image, 1);
        [data writeToFile:filePath atomically:NO];
        
        [paths addObject:filePath];
    }
    
    //图片上传队列
    NSDictionary *dicOne = @{@"id": [NSString stringWithFormat:@"%@",[DJTGlobalManager shareInstance].userInfo.userid],@"type": @"1",@"img": @[@"160,160"]};    //1－图片
    NSData *json = [NSJSONSerialization dataWithJSONObject:dicOne options:NSJSONWritingPrettyPrinted error:nil];
    NSString *lstJson = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    NSString *gbkStr = [lstJson stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlPathImg = [NSString stringWithFormat:@"%@%@",G_UPLOAD_IMAGE,gbkStr];
    
    UploadModel *model = [[UploadModel alloc] init];
    model.uploadUrl = urlPathImg;
    model.imgs = paths;
    model.endUrl = [G_INTERFACE_ADDRESS stringByAppendingString:@"dynamic"];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *endDic = [manager requestinitParamsWith:@"addDynamic"];
    [endDic setObject:@"1" forKey:@"is_teacher"];   //0家长 1老师  2园长
    [endDic setObject:@"" forKey:@"tag"];
    [endDic setObject:@"" forKey:@"subject"];
    [endDic setObject:manager.userInfo.userid forKey:@"authorid"];
    [endDic setObject:manager.userInfo.uname forKey:@"author"];
    [endDic setObject:manager.userInfo.classid forKey:@"class_id"];
    [endDic setObject:@"" forKey:@"message"];
    [endDic setObject:self.student.album_id forKey:@"album_id"];
    [endDic setObject:@"" forKey:@"ip"];
    [endDic setObject:@"[]" forKey:@"member_ids"];
    model.endParam = endDic;
    UploadManager *upManger = [UploadManager shareInstance];
    [upManger.upModels addObject:model];
    [upManger startNextRequest];
    
    [self performSelector:@selector(tipInfo) withObject:nil afterDelay:0.3];
    
}

- (void)tipInfo
{
    [self.view makeToast:@"已提交到后台上传队列" duration:1.0 position:@"center"];
}

#pragma mark - CTAssetsPickerControllerDelegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (_stopSuper) {
        if (assets.count > 0) {
            NSMutableArray *array = [NSMutableArray array];
            for (int i = 0; i < [assets count]; i++) {
                ALAsset *asset = [assets objectAtIndex:i];
                UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
                image = [image fixOrientation];
                [array addObject:image];
            }
            [self uploadImgs:array];
        }
    }
    else
    {
        [super assetsPickerController:picker didFinishPickingAssets:assets];
    }
    
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"mileagePhotoCell" forIndexPath:indexPath];
    UIImageView *contentImg = (UIImageView *)[cell.contentView viewWithTag:1];
    if (!contentImg) {
        CGSize itemSize = ((UICollectionViewFlowLayout *)collectionView.collectionViewLayout).itemSize;
        //face
        contentImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height)];
        [contentImg setContentMode:UIViewContentModeScaleAspectFill];
        contentImg.clipsToBounds = YES;
        [contentImg setTag:1];
        [contentImg setBackgroundColor:BACKGROUND_COLOR];
        [cell.contentView addSubview:contentImg];
        
        //video
        UIImageView *videoImg = [[UIImageView alloc] initWithFrame:CGRectMake((contentImg.frameWidth - 30) / 2, (contentImg.frameHeight - 30) / 2, 30, 30)];
        [videoImg setImage:CREATE_IMG(@"mileageVideo")];
        [videoImg setTag:2];
        [videoImg setBackgroundColor:[UIColor clearColor]];
        [contentImg addSubview:videoImg];
    }
    
    ThemeBatchItem *item = self.dataSource[indexPath.item];
    [contentImg setImage:nil];
    NSString *path = item.thumb ?: item.path;
    if (![path hasPrefix:@"http"]) {
        path = [G_IMAGE_ADDRESS stringByAppendingString:path ?: @""];
    }
    
    if (item.type.integerValue != 0) {
        BOOL mp4 = [[[[item.thumb lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"mp4"];
        if (mp4) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] atTime:1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [contentImg setImage:image];
                });
            });
        }
        else{

            [contentImg setImageWithURL:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        }
    }
    else
    {
        [contentImg setImageWithURL:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    
    //video
    UIImageView *videoImg = (UIImageView *)[contentImg viewWithTag:2];
    videoImg.hidden = (item.type.integerValue == 0);
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    _browserPhotos = [NSMutableArray array];
    
    //宝贝相册
    for (int i = 0; i < [self.dataSource count]; i++) {
        ThemeBatchItem *model = self.dataSource[i];
        
        NSString *path = model.path;
        if (![path hasPrefix:@"http"]) {
            path = [G_IMAGE_ADDRESS stringByAppendingString:path ?: @""];
        }
        
        MWPhoto *photo = nil;
        if (model.type.integerValue != 0) {
            BOOL mp4 = [[[[model.thumb lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"mp4"];
            if (mp4) {
                photo = [MWPhoto photoWithImage:[UIImage thumbnailPlaceHolderImageForVideo:[NSURL URLWithString:path]]];
            }
            else{
                NSString *tmpStr = model.thumb;
                if (![tmpStr hasPrefix:@"http"]) {
                    tmpStr = [G_IMAGE_ADDRESS stringByAppendingString:tmpStr ?: @""];
                }
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:tmpStr]];
            }
            photo.videoUrl = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            photo.isVideo = YES;
        }
        else
        {
            CGFloat scale_screen = [UIScreen mainScreen].scale;
            NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
            path = [NSString getPictureAddress:@"2" width:width height:@"0" original:path];
            NSURL *url = [NSURL URLWithString:path];
            photo = [MWPhoto photoWithURL:url];
        }
        [_browserPhotos addObject:photo];
    }
    
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [browser setCurrentPhotoIndex:indexPath.item];
    browser.displayActionButton = NO;
    browser.displayNavArrows = YES;
    
    [self.navigationController pushViewController:browser animated:YES];
}

@end
