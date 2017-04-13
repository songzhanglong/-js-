//
//  CalendarItem2.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/28.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "CalendarItem2.h"

@implementation CalendarItem2

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //back
        _backImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rl2_1" ofType:@"png"]]];
        [_backImage setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [_backImage setContentMode:UIViewContentModeScaleAspectFit];
        [_backImage setHidden:YES];
        [self addSubview:_backImage];
        
        //
        _tipImage = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - 47) / 2, 0, 47, 45)];
        [_tipImage setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_tipImage];
        
        //公历
        _gregorianLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, frame.size.width, 21)];
        [_gregorianLab setTextColor:[UIColor blackColor]];
        [_gregorianLab setTextAlignment:1];
        [_gregorianLab setFont:[UIFont systemFontOfSize:17]];
        [_gregorianLab setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_gregorianLab];
        
        //活动图标
        _tipImg=[[UIImageView alloc]initWithFrame:CGRectMake(10, 45, 7, 7)];
        UIImage *tipImage=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"tu2" ofType:@"png"]];
        _tipImg.image=tipImage;
        [_tipImg.layer setMasksToBounds:YES];
        [_tipImg.layer setCornerRadius:5];
        _tipImg.hidden=YES;//默认隐藏
        _tipImg.backgroundColor=[UIColor redColor];
        [self addSubview:_tipImg];
        
        //活动名称
        _tipReason = [[UILabel alloc] initWithFrame:CGRectMake(_tipImg.frame.origin.x+_tipImg.frame.size.width, 37, frame.size.width-17, 21)];
        [_tipReason setTextColor:[UIColor blackColor]];
        [_tipReason setTextAlignment:1];
        [_tipReason setFont:[UIFont systemFontOfSize:12]];
        [_tipReason setBackgroundColor:[UIColor clearColor]];
        _tipReason.hidden=YES;
        [self addSubview:_tipReason];
    }
    return self;
}

- (void)setItemDate:(NSDate *)itemDate
{
    if ([_itemDate isEqual:itemDate]) {
        return;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateFormat:@"yyyy"];
    _year = [[formatter stringFromDate:itemDate] integerValue];
    [formatter setDateFormat:@"MM"];
    _month = [[formatter stringFromDate:itemDate] integerValue];
    [formatter setDateFormat:@"dd"];
    _day = [[formatter stringFromDate:itemDate] integerValue];
    
    _itemDate = itemDate;
    [_gregorianLab setText:[NSString stringWithFormat:@"%ld",(long)_day]];
}

@end
