//
//  ClockView.m
//  NewTeacher
//
//  Created by songzhanglong on 15/3/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ClockView.h"

@implementation ClockView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIColor *color = [UIColor colorWithRed:104.0 / 255 green:52.0 / 255 blue:83.0 / 255 alpha:1.0];
        self.backgroundColor = color;
        
        UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 120, 24)];
        [tipLab setTextColor:[UIColor colorWithRed:225.0 / 255 green:131.0 / 255 blue:119.0 / 255 alpha:1.0]];
        _myTipLab = tipLab;
        [tipLab setFont:[UIFont systemFontOfSize:20]];
        [tipLab setBackgroundColor:[UIColor clearColor]];
        [self addSubview:tipLab];
        
        //image
        UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(135, 17, 30, 30)];
        _myImageView = imageView1;
        [self addSubview:imageView1];
        
        imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 10 - 54, 14, 54, 37)];
        [imageView1 setImage:[UIImage imageNamed:@"s4.png"]];
        [self addSubview:imageView1];
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_delegate && [_delegate respondsToSelector:@selector(touchEndClockView:)]) {
        [_delegate touchEndClockView:self];
    }
}

@end
