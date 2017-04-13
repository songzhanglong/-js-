//
//  CooperateModel.h
//  NewTeacher
//
//  Created by songzhanglong on 15/6/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CooperateModel : NSObject

@property (nonatomic,strong)NSString *template_path;    //模板图片地址
@property (nonatomic,strong)NSString *template_path_thumb;  //模板缩略图地址
@property (nonatomic,strong)NSString *template_id;  // 模板页id
@property (nonatomic,strong)NSString *allow_parent; // 是否设置协作 1-协作，0-未设置协作
@property (nonatomic,strong)NSString *total_count;  // 协作的家长数
@property (nonatomic,strong)NSString *finish_count; // 协作完成数
@property (nonatomic,strong)NSString *allow_time;   // 设置协作最近时间 10为数字

@end
