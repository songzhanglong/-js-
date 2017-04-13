//
//  MyTableBar.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/23.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "MyTableBar.h"
#import "DJTGlobalDefineKit.h"
#import "DJTGlobalManager.h"

@implementation MyTableBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor colorWithRed:88/255.0 green:73/255.0 blue:67/255.0 alpha:1];
        
        CGFloat butWei1 = 40,butWei2 = 53;
        CGFloat margin = (frame.size.width - butWei2 - butWei1 * 4 - 20) / 4;
        
        NSArray *titles = @[@"首页",@"办公",@"",@"学堂",@"更多"];
        NSArray *titleImgArray = @[@"down1.png",@"s35.png",@"down5.png",@"sy5.png",@"down4.png"];
        NSArray *titleHeilightImgArray = @[@"down1_1.png",@"s35_1.png",@"down5_1.png",@"sy5_1.png",@"down4_1.png"];
        
        for (int i = 0 ; i < 5; i++) {
            CGFloat xOri = 10 + (butWei1 + margin) * i + ((i > 2) ? (butWei2 - butWei1) : 0);
            CGFloat yOri = (frame.size.height - 44) / 2;
            UIImage *image = [UIImage imageNamed:titleImgArray[i]];
            
            UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
            CGFloat wei = (i == 2) ? butWei2 : butWei1;
            if(i!=2)
                [but setFrame:CGRectMake(xOri, yOri, wei, 44)];
            else
                [but setFrame:CGRectMake(xOri-(118-wei)/2.0, yOri-(118-44)/2.0-4, 118, 118)];
            [but setBackgroundColor:[UIColor clearColor]];
            [but setImage:[UIImage imageNamed:[titleHeilightImgArray objectAtIndex:i] ] forState:UIControlStateSelected];
            [but setImage:image forState:UIControlStateNormal];
            [but addTarget:self action:@selector(buttonPre:) forControlEvents:UIControlEventTouchUpInside];
            but.tag = i + 1;
            but.selected = (i == 0);
            
            if (i != 2) {
                NSString *title = titles[i];
                UIFont *font = [UIFont systemFontOfSize:11];
                CGSize bigSize = CGSizeZero;
                NSDictionary *attribute = @{NSFontAttributeName: font};
                bigSize = [title sizeWithAttributes:attribute];
                [but setTitle:titles[i] forState:UIControlStateNormal];
                [but.titleLabel setFont:font];
                [but setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                [but setTitleColor:[UIColor colorWithRed:255/255.0 green:177/255.0 blue:85/255.0 alpha:1] forState:UIControlStateSelected];
                //top, left, bottom, right
                [but setImageEdgeInsets:UIEdgeInsetsMake(-13, 0, 0, -bigSize.width)];
                [but setTitleEdgeInsets:UIEdgeInsetsMake(30, -image.size.width, 0, 0)];
            }
            
            [self addSubview:but];
        }
    }
    
    return self;
}

- (void)buttonPre:(id)sender
{
    NSInteger index = [sender tag] - 1;
    if ((_nSelectedIndex != index) && (index != 2)) {
        UIButton *button = (UIButton *)[self viewWithTag:_nSelectedIndex + 1];
        button.selected = NO;
        
        [(UIButton *)sender setSelected:YES];
        _nSelectedIndex = index;
        
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(selectTableIndex:)]) {
        [_delegate selectTableIndex:index];
    }
    
}

- (void)setNSelectedIndex:(NSInteger)nSelectedIndex
{
    _nSelectedIndex = nSelectedIndex;
    for (UIView *subView in [self subviews]) {
        if ([subView isKindOfClass:[UIButton class]]) {
            [(UIButton *)subView setSelected:(subView.tag - 1 == nSelectedIndex)];
        }
    }
}

@end
