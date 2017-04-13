//
//  TermGrowList.h
//  NewTeacher
//
//  Created by szl on 16/5/10.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface TermGrowList : JSONModel

@property (nonatomic,strong)NSString *school_id;
@property (nonatomic,strong)NSString *templist_id;
@property (nonatomic,strong)NSString *templist_name;
@property (nonatomic,strong)NSString *cover_url;
@property (nonatomic,strong)NSString *term_name;
@property (nonatomic,strong)NSString *term_id;
@property (nonatomic,strong)NSNumber *finish_count;
@property (nonatomic,strong)NSNumber *total_count;
@property (nonatomic,strong)NSNumber *tpl_count;
@property (nonatomic,strong)NSNumber *print_flag;   // 1-允许打印， 0-不允许打印
@property (nonatomic,strong)NSNumber *tpl_edit_flag;// 1-允许设置模板， 0-不允许设置模板
@property (nonatomic,strong)NSNumber *is_double;    // 1-跨页模版， 0-普通模版

@end
