//
//  TermGrowDetailModel.h
//  NewTeacher
//
//  Created by szl on 16/5/10.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol TermStudent

@end
@interface TermStudent : JSONModel

@property (nonatomic,strong)NSString *grow_id;      // 成长档案id
@property (nonatomic,strong)NSString *student_id;   // 学生id
@property (nonatomic,strong)NSString *student_name; // 学生名称
@property (nonatomic,strong)NSString *face;         // 学生头像
@property (nonatomic,strong)NSNumber *finish_count; // 完成数量
@property (nonatomic,strong)NSNumber *total_count;  // 模板数量
@property (nonatomic,strong)NSNumber *print_count;  // 已提交打印次数
@property (nonatomic,strong)NSString *last_print;   //  上次提交打印时间
@property (nonatomic,strong)NSString *status;       //0 撤销
@property (nonatomic,strong)NSString *status_name;
@property (nonatomic,strong)NSString *edit_flag;
@property (nonatomic,strong)NSString *grow_num;

/*-----自主添加，非服务端返回----*/
@property (nonatomic,strong)NSString *templist_id;  // 模版id
@property (nonatomic,strong)NSString *term_id;      // 学期id

@end

@interface TermGrowDetailModel : JSONModel

@property (nonatomic,strong)NSString *term_id;          // 学期id
@property (nonatomic,strong)NSString *term_name;        // 学期名称
@property (nonatomic,strong)NSString *templist_id;      // 模板id
@property (nonatomic,strong)NSString *templist_name;    // 模板名称
@property (nonatomic,strong)NSString *cover_url;        // 模板封面
@property (nonatomic,strong)NSString *tpl_edit_flag;    // 1-可以修改模板，0-不可以修改模板
@property (nonatomic,strong)NSNumber *finish_stu_count; // 完成学生数量
@property (nonatomic,strong)NSNumber *tpl_height;
@property (nonatomic,strong)NSNumber *tpl_width;
@property (nonatomic,strong)NSArray<TermStudent> *list;

@end
