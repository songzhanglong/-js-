//
//  GrowActionView.m
//  NewTeacher
//
//  Created by zhangxs on 16/1/25.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "GrowActionView.h"

#define BUTTONTAGINDEX 2300
@implementation GrowActionView

- (id)initWithFrame:(CGRect)frame Titles:(NSArray *)titles
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        for (int i = 0; i < [titles count]; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 49 * i, self.frame.size.width, 49)];
            button.backgroundColor = [UIColor whiteColor];
            [button setTitle: [titles objectAtIndex:i] forState:UIControlStateNormal];
            [button setTitleColor:CreateColor(40, 123, 229) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [button setTag:BUTTONTAGINDEX + i];
            [self addSubview:button];
        }
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 2, self.frame.size.width, 2)];
        lineLabel.backgroundColor = CreateColor(40, 123, 229);
        [self addSubview:lineLabel];
    }
    return self;
}

- (void)buttonAction:(UIButton *)sender
{
    [self hiddenInView];
    int currRow = (int)sender.tag - BUTTONTAGINDEX;
    if (_delegate && [_delegate respondsToSelector:@selector(growActionIndex:SelectIndexPathToRow:)]) {
        [_delegate growActionIndex:self SelectIndexPathToRow:currRow];
    }
}

- (void)showInView
{
    CGRect butRec = self.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [self setFrame:CGRectMake(butRec.origin.x, butRec.origin.y + butRec.size.height, butRec.size.width, butRec.size.height)];
    }];
}

- (void)hiddenInView
{
    CGRect butRec = self.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [self setFrame:CGRectMake(butRec.origin.x, butRec.origin.y - butRec.size.height, butRec.size.width, butRec.size.height)];
    }];
}

@end
