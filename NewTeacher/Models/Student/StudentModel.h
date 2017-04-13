//
//  StudentModel.h
//  NewTeacher
//
//  Created by songzhanglong on 14/12/25.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeCardCommentModel : NSObject

@property (nonatomic,strong)NSString *card_school_comment_type;   //评论类型(0代表文字，1代表录音)
@property (nonatomic,strong)NSString *card_school_content;        //评论内容(文字或者录音URL)
@property (nonatomic,strong)NSString *card_home_comment_type;     //评论类型(0代表文字，1代表录音)
@property (nonatomic,strong)NSString *card_home_content;          //评论内容(文字或者录音URL)

@end

@interface BabyPhoto : NSObject

@property (nonatomic,strong)NSString *photo_id;     //图片唯一ID号
@property (nonatomic,strong)NSString *photo_thumb;  //图片的缩略图
@property (nonatomic,strong)NSString *photo_path;   //图片的高清图
@property (nonatomic,strong)NSString *photo_desc;   //
@property (nonatomic,strong)NSString *type;         //

@end

@interface BabyGrow : NSObject

@property (nonatomic,strong)NSString *id;          //每张成长档案唯一ID号
@property (nonatomic,strong)NSString *grow_index;   //
@property (nonatomic,strong)NSString *image_thumb;  //图片的缩略图
@property (nonatomic,strong)NSString *image_path;   //图片的高清图

@end

@interface BabyCard : NSObject

@property (nonatomic,strong)NSString *card_template_id;     //每张成长档案唯一ID号
@property (nonatomic,strong)NSString *school;       //完成状态（1：代表优秀；0代表良好）
@property (nonatomic,strong)NSString *home;         //完成状态（1：代表优秀；0代表良好）

@end

@interface BabyAttence : NSObject

@property (nonatomic,strong)NSString *date;         //日期
@property (nonatomic,strong)NSString *type;         //异常类型(1:病假；2:事假)
@property (nonatomic,strong)NSString *reason;       //异常原因

@end


@interface StudentModel : NSObject

@property (nonatomic,strong)NSMutableArray *photos;    //宝贝相册,DJTBabyPhoto
@property (nonatomic,strong)NSArray *grows;     //已制作成长档案列表,DJTBabyGrow
@property (nonatomic,strong)NSArray *cards;     //家园联系卡内容,DJTBabyCard
@property (nonatomic,strong)NSArray *attence;   //考勤异常数据,DJTBabyAttence
@property (nonatomic,strong)NSString *card_school_comment_type;     //教师评论类型（0:代表文字；1:代表录音）;
@property (nonatomic,strong)NSString *card_school_content;          //评论类容
@property (nonatomic,strong)NSString *card_home_comment_type;       //家长评论类型（0:代表文字；1:代表录音）
@property (nonatomic,strong)NSString *card_home_content;                            //评论类容

@end
