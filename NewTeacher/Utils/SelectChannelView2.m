//
//  SelectChannelView2.m
//  NewTeacher
//
//  Created by szl on 15/12/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SelectChannelView2.h"

@implementation SelectChannelView2

- (id)initWithFrame:(CGRect)frame TitleArray:(NSArray *)array
{
    self = [super initWithFrame:frame];
    if (self) {
        NSInteger numCount = array.count;
        CGFloat butWei = frame.size.width / numCount;
        for (NSInteger i = 0; i < numCount; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(butWei * i, 0, butWei, frame.size.height)];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:array[i]];
            [str addAttribute:NSForegroundColorAttributeName value:CreateColor(227, 167, 116) range:NSMakeRange(0,1)];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(1,[str length] - 1)];
            NSMutableAttributedString *strNor = [[NSMutableAttributedString alloc] initWithString:array[i]];
            [strNor addAttribute:NSForegroundColorAttributeName value:CreateColor(209, 209, 214) range:NSMakeRange(0,1)];
            [strNor addAttribute:NSForegroundColorAttributeName value:CreateColor(153, 153, 153) range:NSMakeRange(1,strNor.length - 1)];
            [button setAttributedTitle:str forState:UIControlStateSelected];
            [button setAttributedTitle:strNor forState:UIControlStateNormal];
            button.selected = (_nCurIdx == i);
            [button setTag:i + 1];
            [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [button addTarget:self action:@selector(tabAt:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
    }
    
    return self;
}

- (void)tabAt:(id)sender
{
    NSUInteger index = [sender tag] - 1;
    BOOL isSame = (index == _nCurIdx);
    if (!isSame) {
        ((UIButton *)sender).selected = YES;
        
        UIButton *preBut = (UIButton *)[self viewWithTag:_nCurIdx + 1];
        preBut.selected = NO;
        _nCurIdx = index;
        
        if (self.selectBlock) {
            self.selectBlock(index);
        }
    }
}

- (void)setNCurIdx:(NSUInteger)nCurIdx
{
    if (nCurIdx == _nCurIdx) {
        return;
    }
    
    UIButton *preBut = (UIButton *)[self viewWithTag:_nCurIdx + 1];
    preBut.selected = NO;
    
    UIButton *curBut = (UIButton *)[self viewWithTag:nCurIdx + 1];
    _nCurIdx = nCurIdx;
    curBut.selected = YES;
}


@end
