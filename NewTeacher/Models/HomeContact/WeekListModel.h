//
//  WeekListModel.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/19.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@interface WeekListModel : JSONModel

@property (nonatomic,strong) NSString *term_name;
@property (nonatomic,strong) NSString *week_index;
@property (nonatomic,strong) NSString *week_name;

@end
