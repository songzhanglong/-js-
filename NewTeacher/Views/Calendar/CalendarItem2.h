//
//  CalendarItem2.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/28.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarItem2 : UIView

@property (nonatomic,readonly)UIImageView *backImage;
@property (nonatomic,readonly)UIImageView *tipImage;
@property (nonatomic,readonly)UILabel     *gregorianLab;//公历
@property (nonatomic,readonly)UIImageView *tipImg;
@property (nonatomic,readonly)UILabel     *tipReason;
@property (nonatomic,strong)NSDate *itemDate;

@property (nonatomic,assign)NSInteger year;
@property (nonatomic,assign)NSInteger month;
@property (nonatomic,assign)NSInteger day;

@end
