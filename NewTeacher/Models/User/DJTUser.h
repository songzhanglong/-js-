//
//  DJTUser.h
//  NewTeacher
//
//  Created by songzhanglong on 14/12/23.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@protocol DJTButton

@end

@interface DJTButton : JSONModel

@property (nonatomic,strong)NSString *b_key;        //应用key
@property (nonatomic,strong)NSString *b_name;
@property (nonatomic,strong)NSString *b_picture;
@property (nonatomic,strong)NSString *b_url;        //h5网页地址
@property (nonatomic,strong)NSString *type;         //1客户端功能，2 h5网页
@property (nonatomic,assign)BOOL    fromDef;

@end

@protocol DJTStudent

@end

@interface DJTStudent : JSONModel

@property (nonatomic,strong)NSString *address;
@property (nonatomic,strong)NSString *album_id;
@property (nonatomic,strong)NSString *birthday;
@property (nonatomic,strong)NSString *face;
@property (nonatomic,strong)NSString *grow_id;
@property (nonatomic,strong)NSString *grows_num;
@property (nonatomic,strong)NSString *mobile;
@property (nonatomic,strong)NSString *parents_name;
@property (nonatomic,strong)NSString *photos_num;
@property (nonatomic,strong)NSString *relation;
@property (nonatomic,strong)NSString *sex;
@property (nonatomic,strong)NSString *student_id;
@property (nonatomic,strong)NSString *templist_id;
@property (nonatomic,strong)NSString *templist_nums;
@property (nonatomic,strong)NSString *timeStamp;
@property (nonatomic,strong)NSString *uname;

@end

@interface DJTUser : JSONModel

@property (nonatomic,strong)NSString *areacode;
@property (nonatomic,strong)NSString *term_id;
@property (nonatomic,strong)NSString *uname;
@property (nonatomic,strong)NSString *userid;
@property (nonatomic,strong)NSString *attence_state;    //1-有缺勤，0-全勤，2-未考勤
@property (nonatomic,strong)NSString *classid;
@property (nonatomic,strong)NSString *classname;
@property (nonatomic,strong)NSString *current_day;
@property (nonatomic,strong)NSString *face;
@property (nonatomic,strong)NSString *sex;
@property (nonatomic,strong)NSString *grade_id;
@property (nonatomic,strong)NSString *grade_name;
@property (nonatomic,strong)NSString *schoolid;
@property (nonatomic,strong)NSString *schoolname;
@property (nonatomic,strong)NSString *token;
@property (nonatomic,strong)NSString *level;        //1、小小班  2、小班 3、中班  4、大班 5、学期班  6、非幼儿园
@property (nonatomic,strong)NSString *show_type;    //office-首页就是办公
@property (nonatomic,strong)NSString *h5_url;
@property (nonatomic,strong)NSArray<DJTStudent> *students;
@property (nonatomic,strong)NSArray<DJTButton> *button;

/* ----------视眼-----------*/
@property (nonatomic,strong)NSString *device_pwd;
@property (nonatomic,strong)NSString *device_port;
@property (nonatomic,strong)NSString *device_account;
@property (nonatomic,strong)NSString *device_ip;
/* ----------视眼-----------*/

@property (nonatomic,strong)NSArray<Ignore> *adsSource;
@property (nonatomic,strong)NSArray<Ignore> *decorationArr;
@property (nonatomic,assign)BOOL hasTimeCard;   //园所已绑定考勤卡
@property (nonatomic,assign)BOOL hasPlayCard;
@property (nonatomic,assign)BOOL isOpenAssistant;//是否开启教师小助手
@property (nonatomic,strong)NSString *assistantUrl;//小助手地址
@property (nonatomic,strong)NSString *assistantTip;//小助手提示

@property (nonatomic,assign)CGFloat class_nameWei;
;
- (void)caculateClass_nameWei;

@end
