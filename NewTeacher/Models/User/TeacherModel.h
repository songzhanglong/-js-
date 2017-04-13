//
//  TeacherModel.h
//  NewTeacher
//
//  Created by zhangxs on 16/3/1.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface TeacherModel : JSONModel

@property (nonatomic,strong)NSString *face;
@property (nonatomic,strong)NSString *sex;
@property (nonatomic,strong)NSString *status;
@property (nonatomic,strong)NSString *sync_flag;
@property (nonatomic,strong)NSString *userid;
@property (nonatomic,strong)NSString *from;
@property (nonatomic,strong)NSString *class_name;
@property (nonatomic,strong)NSString *ctime;
@property (nonatomic,strong)NSString *yd_id;
@property (nonatomic,strong)NSString *baidu_userid;
@property (nonatomic,strong)NSString *city;
@property (nonatomic,strong)NSString *default_cid;
@property (nonatomic,strong)NSString *class_id;
@property (nonatomic,strong)NSString *pwd;
@property (nonatomic,strong)NSString *update_time;
@property (nonatomic,strong)NSString *logintime;
@property (nonatomic,strong)NSString *teacher_name;
@property (nonatomic,strong)NSString *firstlogin;
@property (nonatomic,strong)NSString *gb_id;
@property (nonatomic,strong)NSString *province;
@property (nonatomic,strong)NSString *teacher_id;
@property (nonatomic,strong)NSString *baidu_tag;
@property (nonatomic,strong)NSString *loginip;

@end
