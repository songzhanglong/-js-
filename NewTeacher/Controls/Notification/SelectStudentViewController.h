//
//  SelectStudentViewController.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTBaseViewController.h"

@protocol SelectStudentViewDelegate <NSObject>

@optional
- (void)sendToPeople:(NSMutableArray *)people;

@end

@interface SelectStudentViewController : DJTBaseViewController

@property (nonatomic,assign)id<SelectStudentViewDelegate> delegate;
@property (nonatomic,assign)BOOL isSendToTeacher;
@property (nonatomic,strong)NSMutableArray *teacherArray;
@property (nonatomic,strong)NSArray *preArr;

@end
