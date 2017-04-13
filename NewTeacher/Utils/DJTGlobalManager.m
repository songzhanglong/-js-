//
//  DJTGlobalManager.m
//  TY
//
//  Created by songzhanglong on 14-5-21.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "DJTGlobalManager.h"
#import "SRWebSocket.h"
#import "DJTGlobalDefineKit.h"
#import "NSString+Common.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MyMsgModel.h"
#import "NSObject+Reflect.h"
#import "DataBaseOperation.h"
#import "MainViewController.h"
#import "YQSlideMenuController.h"
#import "MyTableBarViewController.h"

@interface DJTGlobalManager ()<SRWebSocketDelegate>
{
    NSTimer *_timer;
    BOOL _refreshMainAfter;
}
@end

@implementation DJTGlobalManager
{
    SRWebSocket *_webSocket;
    BOOL isConnected;
    NSTimeInterval _alertTimeInterval;
}

- (void)dealloc
{
    [_userInfo release];
    [_albumDic release];
    [_homeCardArr release];
    [_studentControls release];
    [_weekList release];
    [_deviceAttences release];
    [self closeWebSocket];
    [self clearTimer];
    
    [super dealloc];
}

+ (DJTGlobalManager *)shareInstance
{
    static DJTGlobalManager *globalManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        globalManager = [[DJTGlobalManager alloc] init];
    });
    
    return globalManager;
}

- (id)init
{
    if (self = [super init]) {
        _albumDic = [[NSMutableDictionary alloc] init];
        self.qqInfo = @"3492435469";
    }
    return self;
}

/**
 *	@brief	弹出消息
 *
 *	@param 	title 	标题
 *	@param 	msg 	内容
 */
- (void)showAlert:(NSString *)title Msg:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    [alert release];
}

/**
 *	@brief	查找视图的某个父类
 *
 *	@param 	view 	视图
 *	@param 	father 	类别
 *
 *	@return	查找结果
 */
+ (id)viewController:(UIView *)view Class:(Class)father
{
    if (!view) {
        return nil;
    }
    
    if ([view.nextResponder isKindOfClass:father])
    {
        return view.nextResponder;
    }
    return [DJTGlobalManager viewController:(UIView *)view.nextResponder Class:father];
}

#define mark - SRWebSocket
/**
 *	@brief	链接WebSocket
 */
- (void)startConnectWebSocket
{
    if (isConnected) {
        return;
    }
    
    [self closeWebSocket];
    
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://%@/websocket",WEBSOCKET_URL]]]];
    _webSocket.delegate = self;
    [_webSocket open];
}

/**
 *	@brief	关闭WebSocket
 */
- (void)closeWebSocket
{
    if (_webSocket) {
        _webSocket.delegate = nil;
        [_webSocket close];
        [_webSocket release];
        _webSocket = nil;
    }
    isConnected = NO;
}

#pragma mark - 心跳
- (void)resetheartbeat
{
    [self clearTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(timerFire) userInfo:nil repeats:YES];
}

- (void)clearTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

/**
 *	@brief	心跳报文
 */
- (void)timerFire
{
    if (!_webSocket) {
        return;
    }
    NSArray *dic = @[@{@"flag": @"0",@"eachData": @"ping",@"userCode": [NSString stringWithFormat:@"%@1",_userInfo.userid],@"mobileFlag":@"1"}];
    
    NSData *data1 = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *str = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];

    if (_webSocket.readyState != SR_CONNECTING) {
        [_webSocket send:str];
    }
}

#pragma mark - 教师小助手
- (void)checkTeacherAssistant
{
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"class"];
    NSMutableDictionary *param = [self requestinitParamsWith:@"checkAssistant"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [self checkAssistant:success Data:data];
    } failedBlock:^(NSString *description) {
        [self checkAssistant:NO Data:nil];
    }];
}

- (void)checkAssistant:(BOOL)success Data:(id)result
{
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        if (ret_data) {
            NSString *have_device = [ret_data valueForKey:@"check"];
            if (have_device) {
                _userInfo.assistantUrl = [ret_data valueForKey:@"url"];
                _userInfo.isOpenAssistant = ([have_device integerValue] == 1);
                [[NSNotificationCenter defaultCenter] postNotificationName:ASSISTANT_NOTIFI object:nil];
            }
        }
    }
    else{
        _userInfo.assistantTip = [result valueForKey:@"ret_msg"];
    }
}

#pragma mark - SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    isConnected = YES;
    NSArray *array = @[@{@"flag": @"2",@"userCode": [NSString stringWithFormat:@"%@1",_userInfo.userid],@"mobileFlag":@"1"}];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (_webSocket.readyState != SR_CONNECTING) {
        [_webSocket send:str];
    }
    [str release];
    
    [self resetheartbeat];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    [self closeWebSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSString *decodeMsg = [message stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    decodeMsg = [decodeMsg stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    NSData *data = [decodeMsg dataUsingEncoding:NSUTF8StringEncoding];
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@",result);
    if ([result isKindOfClass:[NSArray class]]) {
        result = [result firstObject];
    }
    NSString *eachData = [result valueForKey:@"eachData"];
    if (eachData)
    {
        if ([eachData isEqualToString:@"ok"] || [eachData isEqualToString:@"pong"] || [eachData isEqualToString:@"refuse"])
        {
            
        }
        else
        {
            if ([[result valueForKey:@"status"] integerValue] != 2) {
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.alertAction = @"Ok";
                localNotification.alertBody = eachData;
                
                [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                [localNotification release];
                
                //播放震动
                NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
                if (fabs(nowTimeInterval - _alertTimeInterval) > 2)//消息间隔短，不响不震动
                {
                    _alertTimeInterval = nowTimeInterval;
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    AudioServicesPlaySystemSound(1012);
                }
            }
            
            //[self resetheartbeat];
            
            //数据库插入
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                MyMsgModel *msgModel = [[MyMsgModel alloc] init];
                [msgModel reflectDataFromOtherObject:result];
                if ([msgModel.eachData rangeOfString:@"'"].location != NSNotFound) {
                    msgModel.eachData = [msgModel.eachData stringByReplacingOccurrencesOfString:@"'" withString:@""];
                }
                if (msgModel.eachData && [msgModel.eachData length] > 0) {
                    [[DataBaseOperation shareInstance] insertMyMsg:msgModel];
                }
                
            });
            
            YQSlideMenuController *sideCon = (YQSlideMenuController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
            if ([sideCon isKindOfClass:[YQSlideMenuController class]]) {
                MyTableBarViewController *tabBarCon = (MyTableBarViewController *)sideCon.contentViewController;
                UINavigationController *nav = (UINavigationController *)tabBarCon.selectedViewController;
                UIViewController *rootCon = [nav.viewControllers firstObject];
                if ([rootCon isKindOfClass:[MainViewController class]]) {
                    if (!_refreshMainAfter) {
                        _refreshMainAfter = YES;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self refreshNoticeInfo];
                        });
                    }
                }
                else
                {
                    UINavigationController *mainNav = [tabBarCon.viewControllers firstObject];
                    MainViewController *main = [[mainNav viewControllers] firstObject];
                    main.refreshNotice = YES;
                }
                
            }
        }
    }
}

- (void)refreshNoticeInfo
{
    _refreshMainAfter = NO;
    YQSlideMenuController *sideCon = (YQSlideMenuController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
    if ([sideCon isKindOfClass:[YQSlideMenuController class]]) {
        MyTableBarViewController *tabBarCon = (MyTableBarViewController *)sideCon.contentViewController;
        UINavigationController *mainNav = [tabBarCon.viewControllers firstObject];
        MainViewController *main = [[mainNav viewControllers] firstObject];
        main.refreshNotice = NO;
        [main reloadSection:1];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{

    [self closeWebSocket];
    [self clearTimer];
    
    if (_userInfo != nil && _networkReachabilityStatus >= AFNetworkReachabilityStatusReachableViaWWAN) {
        [self startConnectWebSocket];
    }
}


#pragma mark - 初始化请求参数通用部分
/**
 *	@brief	初始化请求参数通用部分
 *
 *	@param 	ckey 	标记请求
 *
 *	@return	NSMutableDictionary
 */
- (NSMutableDictionary *)requestinitParamsWith:(NSString *)ckey
{
    NSString *nonce = [NSString getRandomNumber:100000 to:1000000];
    NSString *timestamp = [NSString getRandomNumber:1000000000 to:10000000000];    //系统时间
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:ckey,@"ckey",nonce,@"nonce",timestamp,@"timestamp",@"1.0",@"version", @"1",@"is_teacher",app_Version,@"v",nil];
    if (_userInfo) {
        [dic setObject:_userInfo.token ?: @"" forKey:@"token"];
        [dic setObject:_userInfo.userid ?: @"" forKey:@"userid"];
        [dic setObject:_userInfo.classid ?: @"" forKey:@"class_id"];
    }
    return dic;
}

@end
