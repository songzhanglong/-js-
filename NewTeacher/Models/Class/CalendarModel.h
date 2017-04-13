//
//  CalendarModel.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/24.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@protocol Record

@end
@interface Record : JSONModel

@property (nonatomic,strong)NSString *cnt;      //1-病假，2-事假
@property (nonatomic,strong)NSString *state;    //1-正常，2-迟到，3-早退 ，4-迟到+早退 5-缺卡(当天只刷一次卡)，6-缺勤（当天无打卡）, 7-病假，8-事假

@end

@protocol PhotoItem

@end
@interface PhotoItem : JSONModel

@property (nonatomic,strong)NSString *album_id;//相册ID
@property (nonatomic,strong)NSString *desc;//相册文字描述
@property (nonatomic,strong)NSString *path;//原始图
@property (nonatomic,strong)NSString *thumb;//缩略图

@end

@interface MessageModel : JSONModel

@property (nonatomic,strong)NSString *sender;
@property (nonatomic,strong)NSString *content;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *is_del;
@property (nonatomic,strong)NSString *message_id;
@property (nonatomic,strong)NSString *sender_type;
@property (nonatomic,strong)NSString *type;
@property (nonatomic,strong)NSString *ctime;
@property (nonatomic,strong)NSString *need_reply;
@property (nonatomic,strong)NSString *ip;
@property (nonatomic,strong)NSString *read_count;//看过的人
@property (nonatomic,strong)NSString *class_id;

@end

@interface CalendarModel : JSONModel

@property (nonatomic,strong)NSArray<Record> *attence;  //考勤,全勤无record
@property (nonatomic,strong)NSArray<PhotoItem> *photo;     //相册
@property (nonatomic,strong)MessageModel *message;  //园所消息
@property (nonatomic,strong)NSArray *card;     //家园联系卡

@end
