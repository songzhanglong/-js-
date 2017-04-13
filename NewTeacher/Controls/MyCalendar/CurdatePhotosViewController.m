//
//  CurdatePhotosViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/3/9.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "CurdatePhotosViewController.h"
#import "UIImage+Caption.h"
#import "MWPhotoBrowser.h"
#import "NSObject+Reflect.h"
#import "MJRefresh.h"
#import "Toast+UIView.h"
#import "WaterfallLayout.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NSString+Common.h"

@interface TodayItem : NSObject

@property (nonatomic,strong)NSString *album_id;
@property (nonatomic,strong)NSString *path;
@property (nonatomic,strong)NSString *thumb;

@end

@implementation TodayItem

@end

@interface CurdatePhotosViewController ()<MWPhotoBrowserDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,strong)MPMoviePlayerController *movieController;

@end

@implementation CurdatePhotosViewController
{
    NSMutableArray *_photoArray,*_dataSource;
    MJRefreshFooterView *_footerRefresh;
    UICollectionView *_collectionView;
}

- (void)dealloc
{
    [_footerRefresh free];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = _curDate;
    _photoArray = [NSMutableArray array];
    _dataSource = [NSMutableArray array];
    
    //collectionview
    WaterfallLayout *layout = [[WaterfallLayout alloc] init];
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"todayLayoCell"];
    _collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:_collectionView];
    
    __weak typeof(self)weakSelf = self;
    MJRefreshFooterView *fView = [MJRefreshFooterView footer];
    fView.scrollView = _collectionView;
    fView.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView){
        [weakSelf createRequest];
    };
    fView.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
        NSLog(@"刷新完毕");
    };
    _footerRefresh = fView;
    [_footerRefresh beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

#pragma mark - 视频检测
/**
 *	@brief	判断是否为视频
 *
 *	@param 	index 	索引
 *
 *	@return	yes－视频
 */
- (BOOL)checkIsVideo:(NSIndexPath *)indexPath
{
    TodayItem *curItem = _dataSource[indexPath.item];
    NSString *fileName = [curItem.path lastPathComponent];
    if ([[[fileName pathExtension] lowercaseString] isEqualToString:@"mp4"]) {
        [self playVideo:curItem.path];
        return YES;
    }
    return NO;
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

-(void)movieFinishedCallback:(NSNotification*)notify {
    
    MPMoviePlayerController* theMovie = [notify object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    
    [theMovie.view removeFromSuperview];
    
    self.movieController = nil;
}

#pragma mark - network
- (void)createRequest
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        [_footerRefresh performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.1];
        return;
    }
    __weak __typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"photo"];
    NSMutableDictionary *dic = [[DJTGlobalManager shareInstance] requestinitParamsWith:@"getAllPhotos"];
    [dic setObject:[DJTGlobalManager shareInstance].userInfo.classid forKey:@"class_id"];
    [dic setObject:_curDate forKey:@"date"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:dic];
    [dic setObject:text forKey:@"signature"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf requestPhotosFinish:data Suc:success];
    } failedBlock:^(NSString *description) {
        [weakSelf requestPhotosFinish:nil Suc:NO];
    }];
}

- (void)requestPhotosFinish:(id)result Suc:(BOOL)success
{
    self.httpOperation = nil;
    [_footerRefresh endRefreshing];
    if (!success) {
        NSString *tip = REQUEST_FAILE_TIP;
        if (result && [result valueForKey:@"message"]) {
            tip = [result valueForKey:@"message"];
        }
        [self.view makeToast:tip duration:1.0 position:@"center"];
    }
    else
    {
        [_dataSource removeAllObjects];
        id ret_data = [result valueForKey:@"ret_data"];
        ret_data = (!ret_data || [ret_data isKindOfClass:[NSNull class]]) ? [NSArray array] : ret_data;
        for (id subDic in ret_data) {
            TodayItem *item = [[TodayItem alloc] init];
            [item reflectDataFromOtherObject:subDic];
            [_dataSource addObject:item];
        }
        [((WaterfallLayout *)_collectionView.collectionViewLayout) clearLayoutArrributes];
        [_collectionView reloadData];
        
        if (_dataSource.count == 0) {
            [self.view makeToast:@"该天未发布任何图片和视频" duration:1.0 position:@"center"];
        }
    }
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"todayLayoCell" forIndexPath:indexPath];
    UIImageView *faceImg = (UIImageView *)[cell.contentView viewWithTag:1];
    if (!faceImg) {
        //face
        faceImg = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        [faceImg setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [faceImg setContentMode:UIViewContentModeScaleAspectFill];
        faceImg.clipsToBounds = YES;
        [faceImg setTag:1];
        [faceImg setBackgroundColor:BACKGROUND_COLOR];
        [cell.contentView addSubview:faceImg];
        
        //video
        UIImageView *videoImg = [[UIImageView alloc] initWithFrame:CGRectMake((faceImg.frame.size.width - 30) / 2, (faceImg.frame.size.height - 30) / 2, 30, 30)];
        [videoImg setImage:CREATE_IMG(@"mileageVideo")];
        [videoImg setTag:3];
        [videoImg setBackgroundColor:[UIColor clearColor]];
        videoImg.translatesAutoresizingMaskIntoConstraints = NO;
        [faceImg addSubview:videoImg];
        
        NSDictionary* views = NSDictionaryOfVariableBindings(videoImg);
        //设置高度
        [faceImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[videoImg(30)]" options:0 metrics:nil views:views]];
        //设置宽度
        [faceImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[videoImg(30)]" options:0 metrics:nil views:views]];
        [faceImg addConstraints:[NSArray arrayWithObjects:[NSLayoutConstraint constraintWithItem:videoImg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:faceImg attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],[NSLayoutConstraint constraintWithItem:videoImg attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:faceImg attribute:NSLayoutAttributeCenterY multiplier:1 constant:0], nil]];
        }
    
    TodayItem *item = _dataSource[indexPath.item];

    NSString *fileName = [item.path lastPathComponent];
    BOOL mp4 = [[[fileName pathExtension] lowercaseString] isEqualToString:@"mp4"];
    NSString *lastpath = mp4 ? item.path : item.thumb;
    NSString *url = [lastpath hasPrefix:@"http"] ? lastpath : [G_IMAGE_ADDRESS stringByAppendingString:lastpath ?: @""];
    if (mp4) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] atTime:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [faceImg setImage:image];
            });
        });
    }
    else
    {
        [faceImg setImageWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    
    //video
    UIImageView *videoImg = (UIImageView *)[faceImg viewWithTag:3];
    videoImg.hidden = !mp4;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    [_photoArray removeAllObjects];
    
    //if ([self checkIsVideo:indexPath]) {
    //    return;
    //}
    
    for (TodayItem *item in _dataSource) {
        MWPhoto *photo = nil;
        NSString *path = item.path;
        path = [item.path hasPrefix:@"http"] ? item.path : [G_IMAGE_ADDRESS stringByAppendingString:item.path ?: @""];
        NSString *fileName = [path lastPathComponent];
        if ([[[fileName pathExtension] lowercaseString] hasSuffix:@"mp4"]) {
            photo = [MWPhoto photoWithImage:[UIImage thumbnailPlaceHolderImageForVideo:[NSURL URLWithString:path]]];
            photo.videoUrl = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            photo.isVideo = YES;
        }
        else
        {
            CGFloat scale_screen = [UIScreen mainScreen].scale;
            NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
            path = [NSString getPictureAddress:@"2" width:width height:@"0" original:path];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:path]];
        }
        
        [_photoArray addObject:photo];
    }
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [browser setCurrentPhotoIndex:indexPath.item];
    browser.displayActionButton = NO;
    browser.displayNavArrows = YES;
    
    [self.navigationController pushViewController:browser animated:YES];
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

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return _photoArray.count;
}
 
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < _photoArray.count)
        return [_photoArray objectAtIndex:index];
    return nil;
}

@end
