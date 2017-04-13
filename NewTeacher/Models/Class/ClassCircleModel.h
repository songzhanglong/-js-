//
//  ClassCircleModel.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@protocol ReplyItem

@end
@interface ReplyItem : JSONModel

@property (nonatomic,strong)NSString *replay_message;
@property (nonatomic,strong)NSString *reply_name;
@property (nonatomic,strong)NSString *send_name;
@property (nonatomic,strong)NSString *tid;
@property (nonatomic,strong)NSString *face;
@property (nonatomic,strong)NSString *is_teacher;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *reply_id;
@property (nonatomic,strong)NSString *reply_is_teacher;
@property (nonatomic,strong)NSString *dateline;
@property (nonatomic,strong)NSString *send_id;
@property (nonatomic,strong)NSString *pid;

@property (nonatomic,assign)CGSize itemSize;

- (void)calculateItemRect:(CGFloat)wei Font:(UIFont *)font;

- (NSAttributedString *)generalHTMLStr;

- (NSString *)generalReplyString;

- (NSString *)generalReplyString2;

@end

@protocol DiggItem

@end
@interface DiggItem : JSONModel

@property (nonatomic,strong)NSString *face;
@property (nonatomic,strong)NSString *is_teacher;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *userid;

@end

@interface ClassCircleModel : JSONModel

@property (nonatomic,strong)NSString *album_name;
@property (nonatomic,strong)NSString *albums_id;
@property (nonatomic,strong)NSArray *attention;     //[{"member_name":"张三"},{"member_name":"李四"}]
@property (nonatomic,strong)NSString *author;
@property (nonatomic,strong)NSString *authorid;
@property (nonatomic,strong)NSString *class_id;
@property (nonatomic,strong)NSString *class_name;
@property (nonatomic,strong)NSString *dateline;
@property (nonatomic,strong)NSMutableArray<DiggItem> *digg;          //点赞,DiggItem
@property (nonatomic,strong)NSString *digest;
@property (nonatomic,strong)NSNumber *digg_count;
@property (nonatomic,strong)NSString *displayorder;
@property (nonatomic,strong)NSString *face;
@property (nonatomic,strong)NSString *grade_id;
@property (nonatomic,strong)NSString *grade_name;
@property (nonatomic,strong)NSNumber *have_digg;    //0-未点赞
@property (nonatomic,strong)NSString *is_teacher;   //1-老师
@property (nonatomic,strong)NSString *lastpost;
@property (nonatomic,strong)NSString *lastposter;
@property (nonatomic,strong)NSString *message;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *picture;      //以｜分隔
@property (nonatomic,strong)NSString *picture_thumb;//以｜分隔
@property (nonatomic,strong)NSNumber *replies;
@property (nonatomic,strong)NSString *school_id;
@property (nonatomic,strong)NSString *subject;
@property (nonatomic,strong)NSString *tag;
@property (nonatomic,strong)NSString *tid;
@property (nonatomic,strong)NSString *type;         //0－图片，1-视频
@property (nonatomic,strong)NSString *views;
@property (nonatomic,strong)NSMutableArray<ReplyItem> *reply;  //ReplyItem
@property (nonatomic,assign) BOOL isNotUpload;

#pragma mark - 计算坐标
@property (nonatomic,assign,readonly)CGRect tipRect;
@property (nonatomic,assign,readonly)CGRect imagesRect;
@property (nonatomic,assign,readonly)CGRect contentRect;
@property (nonatomic,assign,readonly)CGRect attentionRect;
@property (nonatomic,assign,readonly)CGFloat butYori;
@property (nonatomic,assign,readonly)CGRect diggRect;
@property (nonatomic,strong)NSArray *replyRects;
@property (nonatomic,assign,readonly)CGRect replyBackRect;

@property (nonatomic,assign,readonly)CGRect imagesRect2;
@property (nonatomic,assign,readonly)CGRect contentRect2;
@property (nonatomic,assign,readonly)CGFloat butYori2;

- (void)calculateGroupCircleRects;

@end
