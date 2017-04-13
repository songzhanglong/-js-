//
//  DJTGlobalManager.h
//  TY
//
//  Created by songzhanglong on 14-5-21.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJTUser.h"
#import "AFNetworking.h"

@interface DJTGlobalManager : NSObject

@property (nonatomic,retain)NSMutableArray *grades;
@property (nonatomic,retain)DJTUser *userInfo;
@property (nonatomic,strong)NSString *qqInfo;
@property (nonatomic,assign)AFNetworkReachabilityStatus networkReachabilityStatus;    //网络状态

@property (nonatomic,retain)NSMutableArray *studentControls;    //学生管理控制器
@property (nonatomic,assign)BOOL isHomeUpDate;  //家园档案是否更新
@property (nonatomic,strong)NSMutableDictionary *albumDic;  //每日食谱，与每日作业id保存 b-每日食谱,c-每日作业
@property (nonatomic,strong)NSArray *homeCardArr;//家园联系卡
@property (nonatomic,strong)NSArray *weekList;  //家园联系周列表
@property (nonatomic,assign)NSInteger weekIdx;  //家园联系周索引
@property (nonatomic,strong)NSString *deviceToken;
@property (nonatomic,strong)NSArray *deviceAttences;  //考勤机的考勤数据
@property (nonatomic,strong)NSMutableArray *mileageList;

+ (DJTGlobalManager *)shareInstance;

/**
 *	@brief	弹出消息
 *
 *	@param 	title 	标题
 *	@param 	msg 	内容
 */
- (void)showAlert:(NSString *)title Msg:(NSString *)msg;

/**
 *	@brief	查找视图的某个父类
 *
 *	@param 	view 	视图
 *	@param 	father 	类别
 *
 *	@return	查找结果
 */
+ (id)viewController:(UIView *)view Class:(Class)father;

#pragma mark - 教师小助手
- (void)checkTeacherAssistant;

#define mark - SRWebSocket
/**
 *	@brief	链接WebSocket
 */
- (void)startConnectWebSocket;

/**
 *	@brief	关闭WebSocket
 */
- (void)closeWebSocket;


#pragma mark - 初始化请求参数通用部分
/**
 *	@brief	初始化请求参数通用部分
 *
 *	@param 	ckey 	标记请求
 *
 *	@return	NSMutableDictionary
 */
- (NSMutableDictionary *)requestinitParamsWith:(NSString *)ckey;


@end
