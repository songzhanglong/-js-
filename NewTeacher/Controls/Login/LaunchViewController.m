//
//  LaunchViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/8/29.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "LaunchViewController.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "NSString+Common.h"
#import "AdModel.h"

#define LAUNCH_URL      @"launchUrl"

@interface LaunchViewController ()

@end

@implementation LaunchViewController
{
    UIImageView *_imgView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [_imgView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_imgView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:_imgView];
    
    [_imgView setImage:CREATE_IMG(iPhone5 ? @"Default-568h@2x" : @"Default@2x")];
    //[self requestAds];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app launchFinish];
    });
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - 请求广告
- (void)requestAds
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];

    NSMutableDictionary *param = [manager requestinitParamsWith:@"getAdTY"];
    [param setObject:@"5" forKey:@"position_id"];
    [param setObject:@"1" forKey:@"datafrom"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    __weak __typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"ad"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf requestAdsFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf requestAdsFinish:NO Data:nil];
    }];
}

- (void)requestAdsFinish:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    if (suc) {
        NSLog(@"%@",result);
        /*
        NSArray *ret_data = [result valueForKey:@"ret_data"];
        ret_data = (!ret_data || [ret_data isKindOfClass:[NSNull class]]) ? [NSArray array] : ret_data;
        for (NSDictionary *subDic in ret_data) {
            NSError *error;
            AdModel *adModel = [[AdModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [array addObject:adModel];
        }
         */
    }
}

#pragma mark - 下载图片
- (void)beginDownLoadImg:(NSString *)url
{
    @try {
        __weak typeof(_imgView)weakImg = _imgView;
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:[NSURL URLWithString:url] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    [weakImg setImage:image];
                }
            });
            
        }];
    } @catch (NSException *e) {
        
    }
}

@end
