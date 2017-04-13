//
//  DJTDeviceAttence.h
//  NewTeacher
//
//  Created by 张雪松 on 15/11/4.
//  Copyright © 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@interface DJTDeviceAttence : JSONModel

@property (nonatomic,strong)NSString *class_id;
@property (nonatomic,strong)NSString *cnt;
@property (nonatomic,strong)NSString *state;    //0-未排班/未排课, 1-正常，2-迟到，3-早退 ，4-迟到+早退 5-缺卡(当天只刷一次卡)，6-缺勤（当天无打卡）, 7-病假，8-事假

@end
