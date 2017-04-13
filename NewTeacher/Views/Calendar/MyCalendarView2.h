//
//  MyCalendarView.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyCalendarView2;
@protocol MyCalendarView2Delegate <NSObject>

@optional
- (void)changeMonth:(MyCalendarView2 *)calendar;
- (void)changeDay:(MyCalendarView2 *)calendar;

@end

@interface MyCalendarView2 : UIView

@property (nonatomic,assign)id<MyCalendarView2Delegate> delegate;
@property (nonatomic,strong)NSArray *dateArr;
@property (nonatomic,strong)NSDate *curDate;
@property (nonatomic,assign)NSInteger year;
@property (nonatomic,assign)NSInteger month;
@property (nonatomic,assign)NSInteger day;

- (void)changeToToday;

@end
