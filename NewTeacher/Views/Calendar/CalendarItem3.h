//
//  CalendarItem3.h
//  NewTeacher
//
//  Created by mac on 15/7/27.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CalendarItem3;
@protocol CalendarItem3Delegate <NSObject>

- (void)clickCalendarItem:(CalendarItem3 *)item;

@end

@interface CalendarItem3 : UIView
@property (nonatomic,readonly)UIImageView *backImage;
@property (nonatomic,readonly)UIImageView *tipImage;
@property (nonatomic,readonly)UILabel     *gregorianLab;//公历
@property (nonatomic,readonly)UIImageView *tipImg;
@property (nonatomic,readonly)UILabel     *tipReason;
@property (nonatomic,strong)NSDate *itemDate;

@property (nonatomic,assign)NSInteger year;
@property (nonatomic,assign)NSInteger month;
@property (nonatomic,assign)NSInteger day;
@property (nonatomic,assign)id<CalendarItem3Delegate> delegate;
@end
