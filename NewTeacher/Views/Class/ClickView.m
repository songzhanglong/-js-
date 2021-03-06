//
//  ClickView.m
//  NewTeacher
//
//  Created by songzhanglong on 15/3/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ClickView.h"

@implementation ClickView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:246.0 / 255 green:246.0 / 255 blue:246.0 / 255 alpha:1.0];
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - 196) / 2, 15, 196, 46)];
        _backView = backView;
        [backView setBackgroundColor:[UIColor colorWithRed:88.0 / 255 green:73.0 / 255 blue:68.0 / 255 alpha:1.0]];
        [self addSubview:backView];
        
        //image
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 39, 39)];
        _faceImg = imageView;
        imageView.layer.cornerRadius = 19.5;
        imageView.layer.masksToBounds = YES;
        [imageView setImage:[UIImage imageNamed:@"s5_big.png"]];
        [backView addSubview:imageView];
        
        UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.size.width + 16, 16, 120, 14)];
        _tipLab = tipLab;
        [tipLab setTextColor:[UIColor whiteColor]];
        [tipLab setFont:[UIFont systemFontOfSize:12]];
        [tipLab setBackgroundColor:[UIColor clearColor]];
        [backView addSubview:tipLab];
        
        _numLab = [[UILabel alloc] initWithFrame:CGRectMake(backView.frame.size.width - 35, 8, 30, 30)];
        _numLab.layer.cornerRadius = 15;
        _numLab.layer.masksToBounds = YES;
        _numLab.textAlignment = 1;
        [_numLab setTextColor:[UIColor whiteColor]];
        [_numLab setFont:[UIFont systemFontOfSize:12]];
        [_numLab setBackgroundColor:[UIColor redColor]];
        [backView addSubview:_numLab];
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_delegate && [_delegate respondsToSelector:@selector(touchEndClickView:)]) {
        [_delegate touchEndClickView:self];
    }
}

@end
