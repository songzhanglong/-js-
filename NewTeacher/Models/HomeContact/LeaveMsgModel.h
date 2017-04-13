//
//  LeaveMsgModel.h
//  NewTeacher
//
//  Created by zhangxs on 16/5/4.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface LeaveMsgModel : JSONModel

@property (nonatomic,strong)NSString *content;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *create_user;
@property (nonatomic,strong)NSString *face_school;
@property (nonatomic,strong)NSString *form_date;
@property (nonatomic,strong)NSString *form_id;
@property (nonatomic,strong)NSString *relation;
@property (nonatomic,strong)NSString *score_id;
@property (nonatomic,strong)NSString *student_id;
@property (nonatomic,strong)NSString *student_name;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,assign)CGFloat content_hei;

- (void)caculateContentHei;
@end
