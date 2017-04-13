//
//  SelectCooperateCell.m
//  NewTeacher
//
//  Created by songzhanglong on 15/6/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SelectCooperateCell.h"

@implementation SelectCooperateCell

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _photoImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 90, 130)];
        _photoImg.contentMode = UIViewContentModeScaleAspectFill;
        _photoImg.clipsToBounds = YES;
        [_photoImg setBackgroundColor:BACKGROUND_COLOR];
        [self.contentView addSubview:_photoImg];
        
        UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, 108, 90, 22)];
        [downView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5]];
        [self.contentView addSubview:downView];
        /*
        _tipLab = [[UILabel alloc] initWithFrame:CGRectMake(5, 1, 58, 20)];
        [_tipLab setBackgroundColor:[UIColor clearColor]];
        [_tipLab setTextColor:[UIColor whiteColor]];
        [downView addSubview:_tipLab];
         */
        
        _tipBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tipBut setFrame:CGRectMake(68, 2.5, 17, 17)];
        [_tipBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bb2_small_1" ofType:@"png"]] forState:UIControlStateNormal];
        [_tipBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bb2_small" ofType:@"png"]] forState:UIControlStateSelected];
        [_tipBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bb2_small_2" ofType:@"png"]] forState:UIControlStateDisabled];
        [downView addSubview:_tipBut];
    }
    return self;
}

@end
