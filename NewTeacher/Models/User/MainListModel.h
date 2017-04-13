//
//  MainListModel.h
//  NewTeacher
//
//  Created by mac on 15/7/30.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainListStudentItem : NSObject

@property (nonatomic,strong)NSString *baby_id;
@property (nonatomic,strong)NSString *face;
@property (nonatomic,strong)NSString *from;
@property (nonatomic,strong)NSString *logintime;
@property (nonatomic,strong)NSString *mid;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *status;
@property (nonatomic,strong)NSString *student_id;
@property (nonatomic,strong)NSString *userid;
@property (nonatomic,assign)CGSize nameSize;
@property (nonatomic,assign)CGSize contentSize;

- (void)calculeteConSize:(CGFloat)maxWei Font:(UIFont *)font;


@end

@interface MainListTeacherItem : NSObject

@property (nonatomic,strong)NSString *face;
@property (nonatomic,strong)NSString *from;
@property (nonatomic,strong)NSString *logintime;
@property (nonatomic,strong)NSString *teacher_name;
@property (nonatomic,strong)NSString *status;
@property (nonatomic,strong)NSString *teacher_id;
@property (nonatomic,strong)NSString *userid;
@property (nonatomic,assign)CGSize nameSize;
@property (nonatomic,assign)CGSize contentSize;


@end


@interface MainListModel : NSObject

@property (nonatomic,strong)NSMutableArray *items;
@property (nonatomic,assign)int indexButton;
@property (nonatomic,strong)NSMutableArray *teacherItems;

@end
