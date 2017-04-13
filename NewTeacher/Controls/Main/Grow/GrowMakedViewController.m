//
//  GrowMakedViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/31.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "GrowMakedViewController.h"
#import "NSString+Common.h"
#import "Toast+UIView.h"
#import "UIImageView+WebCache.h"
#import "GrowAlbumModel.h"
#import "NSObject+Reflect.h"
#import "MakeGrowController.h"
#import "GrowNewViewController.h"
#import "GrowMakeCell.h"
#import "TermGrowDetailModel.h"
#import "GrowNewDetailController.h"
#import "ProgressCircleView.h"

@interface GrowMakedViewController ()<GrowMakeCellDelegate,MakeGrowControllerDelegate>

@end

@implementation GrowMakedViewController
{
    NSIndexPath *_indexPath;
    NSInteger nEditIdx;
    //视频录制进度控制
    ProgressCircleView *_progressView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.showBack = YES;
    self.titleLable.text = _student.student_name;
    self.titleLable.textColor = [UIColor whiteColor];
    
    UIButton *leftBut = (UIButton *)((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView;
    [leftBut setFrame:CGRectMake(0, 0, 40, 30)];
    [leftBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backL@2x" ofType:@"png"]] forState:UIControlStateNormal];
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSDictionary *dic = @{@"student_id": _student.student_id,@"grow_id":_student.grow_id,@"teacher_id":manager.userInfo.userid,@"templist_id":_student.templist_id,@"term_id":_student.term_id};
    [self createTableViewAndRequestAction:@"grow:data_hb_stu_v3" Param:dic Header:YES Foot:NO];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    
    [self beginRefresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = CreateColor(33.0, 27.0, 25.0);
    }
    else
    {
        navBar.tintColor = CreateColor(33.0, 27.0, 25.0);
    }
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
        navBar.tintColor = CreateColor(233.0, 233.0, 233.0);
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - 制作
- (void)makeNextTemplate
{
    if (_indexPath) {
        GrowExtendModel *extend = self.dataSource[_indexPath.section];
        if ([extend.list count] - 1 == nEditIdx) {
            //下一组
            nEditIdx = 0;
            if ([self.dataSource count] - 1 == _indexPath.section) {
                [self beginReMakeAt:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
            else{
                [self beginReMakeAt:[NSIndexPath indexPathForRow:0 inSection:_indexPath.section + 1]];
            }
        }
        else{
            nEditIdx++;
            [self beginReMakeAt:_indexPath];
        }
    }
}

- (void)beginReMakeAt:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    GrowExtendModel *extend = self.dataSource[indexPath.section];
    GrowAlbumModel *growAlbum = extend.list[nEditIdx];
    NSString *url = growAlbum.template_path_edit;
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_GROW_ADDRESS stringByAppendingString:url ?: @""];
    }
    NSURL *downUrl = [NSURL URLWithString:url];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *key = nil;
    if (manager.cacheKeyFilter) {
        key = manager.cacheKeyFilter(downUrl);
    }
    else {
        key = [downUrl absoluteString];
    }
    
    if (!key) {
        [self.view makeToast:@"图片地址异常" duration:1.0 position:@"center"];
        return;
    }
    
    UIImage *image = [manager.imageCache imageFromMemoryCacheForKey:key];
    if (image) {
        //无需下载
        [self downloadTemplate:YES Data:image];
        return;
    }
    else
    {
        UIImage *diskImage = [manager.imageCache imageFromDiskCacheForKey:key];
        if (diskImage) {
            //无需下载
            [self downloadTemplate:YES Data:diskImage];
            return;
        }
    }
    
    //下载
    self.navigationController.view.userInteractionEnabled = NO;
    [self uploadProgress:0 tip:@"图片正在下载..."];
    @try {
        __weak typeof(self)weakSelf = self;
        [manager downloadWithURL:downUrl options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            CGFloat progress = 0;
            if (expectedSize > 0) {
                progress = receivedSize / (CGFloat)expectedSize;
            }
            [weakSelf uploadProgress:progress tip:@"图片正在下载..."];
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [weakSelf downloadTemplate:NO Data:nil];
                }
                else
                {
                    [weakSelf downloadTemplate:YES Data:image];
                }
            });
            
        }];
    } @catch (NSException *e) {
        [self downloadTemplate:NO Data:nil];
    }
}

- (void)uploadProgress:(CGFloat)progress tip:(NSString *)tipStr
{
    if (!_progressView) {
        _progressView = [[ProgressCircleView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 120) / 2, (SCREEN_HEIGHT - 64 - 120) / 2, 120, 120)];
    }
    if (![_progressView isDescendantOfView:self.view]) {
        [self.navigationController.view addSubview:_progressView];
    }
    [_progressView.loadingIndicator setProgress:progress animated:YES];
    [_progressView.progressLab setText:tipStr];
}

- (void)downloadTemplate:(BOOL)suc Data:(UIImage *)img
{
    self.navigationController.view.userInteractionEnabled = YES;
    [_progressView removeFromSuperview];
    if (!suc) {
        [self.navigationController.view makeToast:@"模板下载失败" duration:1.0 position:@"center"];
        return;
    }
    
    GrowExtendModel *extend = self.dataSource[_indexPath.section];
    GrowAlbumModel *growAlbum = extend.list[nEditIdx];
    
    MakeGrowController *makeGrow = [[MakeGrowController alloc] init];
    makeGrow.isSmallPicLimit = ([growAlbum.allow_nonhd integerValue] == 1);
    makeGrow.student = _student;
    makeGrow.growAlbum = growAlbum;
    makeGrow.targerImg = img;
    makeGrow.album_id = extend.album_id;
    makeGrow.album_title = extend.album_title;
    makeGrow.tpl_width = _detailModel.tpl_width;
    makeGrow.tpl_height = _detailModel.tpl_height;
    makeGrow.dataSource = (NSMutableArray<TermStudent> *)_detailModel.list;
    makeGrow.delegate = self;
    [self.navigationController pushViewController:makeGrow animated:YES];
    
}

#pragma mark - 网络
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    if (!success) {
        NSString *tip = @"数据请求失败";
        if (result && [result valueForKey:@"message"]) {
            tip = [result valueForKey:@"message"];
        }
        [self.view makeToast:tip duration:1.0 position:@"center"];
    }
    else
    {
        NSArray *dataList = [result valueForKey:@"data"];
        if (dataList && [dataList isKindOfClass:[NSArray class]]) {
            self.dataSource = [GrowExtendModel arrayOfModelsFromDictionaries:dataList error:nil];
        }
        else{
            self.dataSource = nil;
        }
        [_tableView reloadData];
    }
}

#pragma mark - videoArr + isVideo
- (NSArray *)getGalleryArrayBy:(GrowAlbumModel *)growAlbum
{
    NSMutableArray *galleryArray = [NSMutableArray array];
    NSString *url = growAlbum.play_url ?: @"";
    
    for (NSInteger i = 0; i < growAlbum.src_gallery_list.count; i++) {
        NSArray *subArr = growAlbum.src_gallery_list[i];
        if ([subArr count] > 1) {
            NSString *curUrl = [url stringByAppendingString:[NSString stringWithFormat:@"?i=%ld",(long)i]];
            [galleryArray addObject:curUrl];
        }
        else{
            [galleryArray addObject:@""];
        }
    }
    
    return galleryArray;
}

- (NSArray *)getVideoArrayBy:(GrowAlbumModel *)growAlbum
{
    NSMutableArray *videoArr = [NSMutableArray array];
    NSInteger maxCount = MAX(growAlbum.src_h5_list.count, growAlbum.src_video_list.count);
    for (NSInteger nm = 0; nm < maxCount; nm++) {
        if (growAlbum.src_h5_list && [growAlbum.src_h5_list count] > nm) {
            NSString *h5Str = growAlbum.src_h5_list[nm];
            if (h5Str.length > 0) {
                if (![h5Str hasPrefix:@"http"]) {
                    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
                    h5Str = [user.h5_url stringByAppendingString:h5Str];
                }
                [videoArr addObject:h5Str];
            }
            else if (growAlbum.src_video_list && [growAlbum.src_video_list count] > nm){
                NSString *videoStr = growAlbum.src_video_list[nm];
                [videoArr addObject:videoStr];
            }
            else{
                [videoArr addObject:@""];
            }
        }
        else if (growAlbum.src_video_list && [growAlbum.src_video_list count] > nm){
            NSString *videoStr = growAlbum.src_video_list[nm];
            [videoArr addObject:videoStr];
        }
        else{
            [videoArr addObject:@""];
        }
    }
    return videoArr;
}

- (BOOL)checkIsGallery:(GrowAlbumModel *)growAlbum
{
    BOOL isGallery = NO;
    for (NSArray *array in growAlbum.src_gallery_list) {
        if ([array count] > 1) {
            isGallery = YES;
            break;
        }
    }
    return isGallery;
}

- (BOOL)checkIsVideo:(GrowAlbumModel *)growAlbum
{
    BOOL isVideo = NO;
    for (NSString *subStr in growAlbum.src_video_list) {
        if ([subStr length] > 0) {
            isVideo = YES;
            break;
        }
    }
    if (!isVideo) {
        for (NSString *subStr in growAlbum.src_h5_list) {
            if ([subStr length] > 0) {
                isVideo = YES;
                break;
            }
        }
    }
    
    return isVideo;
}

- (NSArray *)getVoiceArrayBy:(GrowAlbumModel *)growAlbum
{
    NSMutableArray *voiceArr = [NSMutableArray array];
    NSInteger count = growAlbum.src_txt_list.count;
    for (NSInteger i = 0; i < count; i++) {
        NSString *str = growAlbum.src_txt_list[i];
        if (str.length > 0) {
            if ([str hasPrefix:@"["] && [str rangeOfString:@"]"].location != NSNotFound) {
                NSRange range = [str rangeOfString:@"]"];
                NSString * url = [str substringWithRange:NSMakeRange(1,range.location - 1)];
                if (![url hasPrefix:@"http"]) {
                    url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
                }
                [voiceArr addObject:url];
            }
            else{
                [voiceArr addObject:@""];
            }
        }
        else{
            [voiceArr addObject:@""];
        }
    }
    
    return voiceArr;
}

- (BOOL)checkIsAudio:(GrowAlbumModel *)growAlbum
{
    BOOL isAudio = NO;
    for (NSString *subStr in growAlbum.src_txt_list) {
        if ([subStr hasPrefix:@"["] && [subStr rangeOfString:@"]"].location != NSNotFound) {
            isAudio = YES;
            break;
        }
    }
    
    return isAudio;
}

#pragma mark - GrowMakeCellDelegate
- (void)selectGrowCell:(UITableViewCell *)cell At:(NSInteger)index
{
    _indexPath = [_tableView indexPathForCell:cell];
    nEditIdx = index;
    _browserPhotos = [NSMutableArray array];
    NSMutableArray *tmpSource = [NSMutableArray array];
    NSString *preStr = G_IMAGE_GROW_ADDRESS;
    GrowExtendModel *extend = self.dataSource[_indexPath.section];
    for (NSInteger i = 0; i < [extend.list count]; i++) {
        GrowAlbumModel *growAlbum = extend.list[i];
        BOOL isGallery = [self checkIsGallery:growAlbum];
        BOOL isVoice = [self checkIsAudio:growAlbum];
        NSString *str = growAlbum.image_path;
        if ((str && ![str isKindOfClass:[NSNull class]]) && ([str length] > 2)) {
            NSString *bigStr = [str hasPrefix:@"http"] ? str : [preStr stringByAppendingString:str];
            MWPhoto *bigPhoto = [MWPhoto photoWithURL:[NSURL URLWithString:bigStr]];
            if (isGallery) {
                bigPhoto.isVideo = YES;
                NSArray *galleryArray = [self getGalleryArrayBy:growAlbum];
                bigPhoto.videoPaths = galleryArray;
            }
            else if ([self checkIsVideo:growAlbum]) {
                bigPhoto.isVideo = YES;
                NSArray *videoArr = [self getVideoArrayBy:growAlbum];
                bigPhoto.videoPaths = videoArr;
            }
            if (isVoice) {
                bigPhoto.isVoice = YES;
                bigPhoto.voicePaths = [self getVoiceArrayBy:growAlbum];
            }
            [_browserPhotos addObject:bigPhoto];
        }
        else
        {
            
            NSString *temStr = [growAlbum.template_path hasPrefix:@"http"] ? growAlbum.template_path : [preStr stringByAppendingString:growAlbum.template_path];
            MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:temStr]];
            if (isGallery) {
                photo.isVideo = YES;
                NSArray *galleryArray = [self getGalleryArrayBy:growAlbum];
                photo.videoPaths = galleryArray;
            }
            else if ([self checkIsVideo:growAlbum]){
                photo.isVideo = YES;
                NSArray *videoArr = [self getVideoArrayBy:growAlbum];
                photo.videoPaths = videoArr;
            }
            if (isVoice) {
                photo.isVoice = YES;
                photo.voicePaths = [self getVoiceArrayBy:growAlbum];
            }
            [_browserPhotos addObject:photo];
        }
        
        NSString *smallStr = (growAlbum.image_thumb && ![growAlbum.image_thumb isKindOfClass:[NSNull class]]) ? growAlbum.image_thumb : growAlbum.template_path_thumb;
        smallStr = [smallStr hasPrefix:@"http"] ? smallStr : [preStr stringByAppendingString:smallStr];
        [tmpSource addObject:smallStr];
    }
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [browser setCurrentPhotoIndex:nEditIdx];
    browser.displayActionButton = NO;
    browser.canEditItem = ([_student.edit_flag length] > 0 && [_student.edit_flag integerValue] == 0) ? 2 : 1;
    browser.displayNavArrows = NO;
    browser.imgSource = tmpSource;
    [self.navigationController pushViewController:browser animated:YES];
    
}

- (void)editGrowCell:(UITableViewCell *)cell At:(NSInteger)index
{
    if ([_student.edit_flag length] > 0 && [_student.edit_flag integerValue] == 0) {
        [self.view makeToast:@"档案正在打印制作中，不能修改哦" duration:1.0 position:@"center"];
        return;
    }
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    nEditIdx = index;
    [self beginReMakeAt:indexPath];
}

#pragma mark - MakeGrowControllerDelegate
- (void)makeFinishImg:(NSString *)imgPath Data:(id)data url:(NSString *)url
{
    MWPhotoBrowser *browser = nil;
    NSArray *viewControls = self.navigationController.viewControllers;
    for (UIViewController *control in viewControls) {
        if ([control isKindOfClass:[MWPhotoBrowser class]]) {
            browser = (MWPhotoBrowser *)control;
        }
        else if ([control isKindOfClass:[GrowNewDetailController class]]) {
            [(GrowNewDetailController *)control setShouldRefresh:YES];
        }
    }
    
    //数据处理
    GrowExtendModel *extend = self.dataSource[_indexPath.section];
    GrowAlbumModel *album = extend.list[nEditIdx];
    album.image_thumb = imgPath;
    album.image_path = url;
    album.src_image_list = [data valueForKey:@"src_image_list"];
    album.src_gallery_list = [data valueForKey:@"src_gallery_list"];
    album.src_txt_list = [data valueForKey:@"src_txt_list"];
    album.image_detail_list = [data valueForKey:@"image_detail_list"];
    album.deco_detail_list = [data valueForKey:@"deco_detail_list"];
    album.src_deco_list = [data valueForKey:@"src_deco_list"];
    album.src_deco_txt_list = [data valueForKey:@"src_deco_txt_list"];
    
    if (browser) {
        BOOL isGallery = [self checkIsGallery:album];
        BOOL isVoice = [self checkIsAudio:album];
        NSString *str = album.image_path;
        NSString *preStr = G_IMAGE_GROW_ADDRESS;
        if ((str && ![str isKindOfClass:[NSNull class]]) && ([str length] > 2)) {
            NSString *bigStr = [str hasPrefix:@"http"] ? str : [preStr stringByAppendingString:str];
            MWPhoto *bigPhoto = [MWPhoto photoWithURL:[NSURL URLWithString:bigStr]];
            if (isGallery) {
                bigPhoto.isVideo = YES;
                NSArray *galleryArray = [self getGalleryArrayBy:album];
                bigPhoto.videoPaths = galleryArray;
            }
            else if ([self checkIsVideo:album]) {
                bigPhoto.isVideo = YES;
                NSArray *videoArr = [self getVideoArrayBy:album];
                bigPhoto.videoPaths = videoArr;
            }
            if (isVoice) {
                bigPhoto.isVoice = YES;
                bigPhoto.voicePaths = [self getVoiceArrayBy:album];
            }
            [_browserPhotos replaceObjectAtIndex:nEditIdx withObject:bigPhoto];
        }
        else
        {
            
            NSString *temStr = [album.template_path hasPrefix:@"http"] ? album.template_path : [preStr stringByAppendingString:album.template_path];
            MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:temStr]];
            if (isGallery) {
                photo.isVideo = YES;
                NSArray *galleryArray = [self getGalleryArrayBy:album];
                photo.videoPaths = galleryArray;
            }
            else if ([self checkIsVideo:album]){
                photo.isVideo = YES;
                NSArray *videoArr = [self getVideoArrayBy:album];
                photo.videoPaths = videoArr;
            }
            if (isVoice) {
                photo.isVoice = YES;
                photo.voicePaths = [self getVoiceArrayBy:album];
            }
            [_browserPhotos replaceObjectAtIndex:nEditIdx withObject:photo];
        }
        
        NSString *smallStr = (album.image_thumb && ![album.image_thumb isKindOfClass:[NSNull class]]) ? album.image_thumb : album.template_path_thumb;
        smallStr = [smallStr hasPrefix:@"http"] ? smallStr : [preStr stringByAppendingString:smallStr];
        [browser.imgSource replaceObjectAtIndex:nEditIdx withObject:smallStr];
        [browser reloadData];
    }
    
    GrowMakeCell *cell = [_tableView cellForRowAtIndexPath:_indexPath];
    [cell reloadCellAtIndex:nEditIdx];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *growCellId = @"growCellId";
    GrowMakeCell *cell = [tableView dequeueReusableCellWithIdentifier:growCellId];
    if (cell == nil) {
        cell = [[GrowMakeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:growCellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    [cell resetDataSource:self.dataSource[indexPath.section]];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 166;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:_tableView.backgroundColor];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - MWPhotoBrowserDelegate
- (void)changeToMakeGrowed:(NSInteger)index
{
    nEditIdx = index;
    [self beginReMakeAt:_indexPath];
}

- (CGRect)calculateFrameAt:(NSInteger)index Source:(NSInteger)sIdx
{
    GrowExtendModel *extend = self.dataSource[_indexPath.section];
    GrowAlbumModel *album = extend.list[index];
    
    id image_coor = [album.template_detail valueForKey:@"image_coor"];
    if (image_coor && [image_coor count] > 0 && [image_coor count] > sIdx) {
        NSDictionary *dic = [image_coor objectAtIndex:sIdx];
        NSString *xValue = [dic valueForKey:@"x"];
        NSString *yValue = [dic valueForKey:@"y"];
        if ((!xValue || [xValue isKindOfClass:[NSNull class]] || [xValue isEqualToString:@""]) || (!yValue || [yValue isKindOfClass:[NSNull class]] || [yValue isEqualToString:@""])) {
            return CGRectZero;
        }
        NSArray *x = [xValue componentsSeparatedByString:@","];
        NSArray *y = [yValue componentsSeparatedByString:@","];
        return CGRectMake([x[0] floatValue], [x[1] floatValue], ([y[0] floatValue] - [x[0] floatValue]), ([y[1] floatValue] - [x[1] floatValue]));
    }
    return CGRectZero;
}

- (CGRect)calculateFrameAt:(NSInteger)index SourceVoice:(NSInteger)sIdx
{
    GrowExtendModel *extend = self.dataSource[_indexPath.section];
    GrowAlbumModel *album = extend.list[index];
    
    id word_coor = [album.template_detail valueForKey:@"word_coor"];
    if (word_coor && [word_coor count] > 0 && [word_coor count] > sIdx) {
        NSDictionary *dic = [word_coor objectAtIndex:sIdx];
        NSString *xValue = [dic valueForKey:@"x"];
        NSString *yValue = [dic valueForKey:@"y"];
        if ((!xValue || [xValue isKindOfClass:[NSNull class]] || [xValue isEqualToString:@""]) || (!yValue || [yValue isKindOfClass:[NSNull class]] || [yValue isEqualToString:@""])) {
            return CGRectZero;
        }
        NSArray *x = [xValue componentsSeparatedByString:@","];
        NSArray *y = [yValue componentsSeparatedByString:@","];
        return CGRectMake([x[0] floatValue], [x[1] floatValue], ([y[0] floatValue] - [x[0] floatValue]), ([y[1] floatValue] - [x[1] floatValue]));
    }
    return CGRectZero;
}

@end
