//
//  CalendarItem.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CalendarItem;
@protocol CalendarItemDelegate <NSObject>

- (void)clickCalendarItem:(CalendarItem *)item;

@end

@interface CalendarItem : UIView

@property (nonatomic,assign)id<CalendarItemDelegate> delegate;
@property (nonatomic,readonly)UIImageView *backImage;
@property (nonatomic,readonly)UIImageView *tipImage;
@property (nonatomic,readonly)UILabel *gregorianLab;//公历
@property (nonatomic,readonly)UILabel *lunarLab;    //农历

@property (nonatomic,strong)NSDate *itemDate;

@property (nonatomic,assign)NSInteger year;
@property (nonatomic,assign)NSInteger month;
@property (nonatomic,assign)NSInteger day;

@property (nonatomic,assign)NSInteger lunarYear;    //农历年
@property (nonatomic,assign)NSInteger lunarMonth;   //农历月
@property (nonatomic,assign)NSInteger doubleMonth;  //闰月
@property (nonatomic,assign)NSInteger lunarDay;     //农历日
@property (nonatomic,assign)BOOL isLeap;            //是否闰月标记

@property (nonatomic,strong)NSString *solarTermTitle;
@property (nonatomic,strong)NSString *monthLunar;
@property (nonatomic,strong)NSString *dayLunar;
@property (nonatomic,strong)NSString *zodiacLunar;

@property (nonatomic,strong)NSString *yearHeavenlyStem;
@property (nonatomic,strong)NSString *monthHeavenlyStem;
@property (nonatomic,strong)NSString *dayHeavenlyStem;
@property (nonatomic,strong)NSString *yearEarthlyBranch;
@property (nonatomic,strong)NSString *monthEarthlyBranch;
@property (nonatomic,strong)NSString *dayEarthlyBranch;


@end
