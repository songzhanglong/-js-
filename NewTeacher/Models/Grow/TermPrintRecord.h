//
//  TermPrintRecord.h
//  NewTeacher
//
//  Created by szl on 16/5/11.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol OrderStatus

@end

@interface OrderStatus : JSONModel

@property (nonatomic,strong)NSString *status_name;
@property (nonatomic,strong)NSString *student_names;
@property (nonatomic,strong)NSString *grow_nums;
@property (nonatomic,assign)CGFloat namesHei;               // 高度
@property (nonatomic,assign)CGFloat statusWei;
- (void)calculateNamesHei;
@end

@interface TermPrintRecord : JSONModel

@property (nonatomic,strong)NSString *student_names;        // 提交学生名单，多个以逗号隔开
@property (nonatomic,strong)NSString *create_teacher;       // 老师id
@property (nonatomic,strong)NSString *create_teacher_name;  // 提交者名称
@property (nonatomic,strong)NSNumber *print_num;            // 数量
@property (nonatomic,strong)NSString *create_time;          // 提交时间
@property (nonatomic,strong)NSString *cancel_flag;          // 1 撤销
@property (nonatomic,strong)NSArray<OrderStatus>*student_names_group;
@property (nonatomic,assign)BOOL isExpand;                  // 是否展开
@property (nonatomic,assign)CGFloat namesHei;               // 高度

- (void)calculateNamesHei;

@end
