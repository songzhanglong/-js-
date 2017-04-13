//
//  DelStudent.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/25.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DelStudent.h"

@implementation DelStudent

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        for (int i = 0; i < 2; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(6 + (66 + 6) * i, (frame.size.height - 33) / 2, 66, 33)];
            [button setTag:i + 1];
            [button setTitle:(i == 0) ? @"全选" : @"反选" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(pressButton:) forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundColor:[UIColor darkGrayColor]];
            [self addSubview:button];
            if (i == 0) {
                _allSelectedButton = button;
            }
            else
            {
                _unSelectedButton = button;
            }
        }
        //completedButton
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(frame.size.width -120, (frame.size.height - 33) / 2, 100, 33)];
        [button setTag:3];
        [button setTitle:[NSString stringWithFormat:@"删除(0)"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(pressButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundColor:[UIColor redColor]];
        _completedButton = button;
        [self addSubview:_completedButton];
    }
    return self;
}

- (void)setDelNum:(NSInteger)delNum
{
    [_completedButton setTitle:[NSString stringWithFormat:@"删除(%ld)",(long)delNum] forState:UIControlStateNormal];
}

- (void)pressButton:(id)button
{
    NSInteger index = [button tag] - 1;
    if (_delegate && [_delegate respondsToSelector:@selector(selectDeleteIdx:)]) {
        [_delegate selectDeleteIdx:index];
    }
}

@end
