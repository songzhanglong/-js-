//
//  MyCalendarView.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyCalendarView;
@protocol MyCalendarViewDelegate <NSObject>

@optional
- (void)changeMonth:(MyCalendarView *)calendar;
- (void)changeDay:(MyCalendarView *)calendar;

@end

@interface MyCalendarView : UIView

@property (nonatomic,assign)id<MyCalendarViewDelegate> delegate;
@property (nonatomic,assign)BOOL  isCircle;//圆圈样式,不显示农历
@property (nonatomic,strong)NSDate *curDate;
@property (nonatomic,assign)NSInteger year;
@property (nonatomic,assign)NSInteger month;
@property (nonatomic,assign)NSInteger day;

- (void)changeToToday;

@end
