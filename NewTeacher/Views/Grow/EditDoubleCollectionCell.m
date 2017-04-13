//
//  EditDoubleCollectionCell.m
//  NewTeacher
//
//  Created by szl on 16/8/31.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "EditDoubleCollectionCell.h"
#import <Masonry.h>
#import "GrowSetTemplateModel.h"
#import "NSString+Common.h"

@implementation EditDoubleCollectionCell
{
    UIImageView *_leftImg,*_rightImg;
}

- (void)customViewInit
{
    //
    _leftImg = [[UIImageView alloc] init];
    [_leftImg setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_leftImg setContentMode:UIViewContentModeScaleAspectFill];
    _leftImg.clipsToBounds = YES;
    [_leftImg setBackgroundColor:BACKGROUND_COLOR];
    [self.contentView addSubview:_leftImg];
    [_leftImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.top.equalTo(@(15));
        make.width.equalTo(self.contentView.mas_width).with.multipliedBy(0.5);
        make.height.equalTo(self.contentView.mas_height).with.offset(-75);
    }];
    
    _rightImg = [[UIImageView alloc] init];
    [_rightImg setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_rightImg setContentMode:UIViewContentModeScaleAspectFill];
    _rightImg.clipsToBounds = YES;
    [_rightImg setBackgroundColor:BACKGROUND_COLOR];
    [self.contentView addSubview:_rightImg];
    [_rightImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftImg.mas_right);
        make.top.equalTo(_leftImg.mas_top);
        make.width.equalTo(_leftImg.mas_width);
        make.height.equalTo(_leftImg.mas_height);
    }];
    
}

- (void)resetDataSource:(NSArray *)array
{
    self.options = array;
    TemplateItem *item1 = [array firstObject];
    TemplateItem *item2 = [array lastObject];
    NSString *path1 = item1.template_path ?: @"";
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
    if (![path1 hasPrefix:@"http"]) {
        path1 = [G_IMAGE_GROW_ADDRESS stringByAppendingString:path1];
    }
    path1 = [NSString getPictureAddress:@"2" width:width height:@"0" original:path1];
    [_leftImg setImage:nil];
    [_leftImg setImageWithURL:[NSURL URLWithString:[path1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSString *path2 = item2.template_path ?: @"";
    if (![path2 hasPrefix:@"http"]) {
        path2 = [G_IMAGE_GROW_ADDRESS stringByAppendingString:path2];
    }
    path2 = [NSString getPictureAddress:@"2" width:width height:@"0" original:path2];
    [_rightImg setImage:nil];
    [_rightImg setImageWithURL:[NSURL URLWithString:[path2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    for (id subs in [self.nameBtn subviews]) {
        if ([subs isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)subs removeFromSuperview];
        }
    }
    if ([item1.template_title length] > 0) {
        CGFloat yor = [self calculateDescRects:item1.template_title];
        UIImageView *editImgView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"grow_edit@2x")];
        [self.nameBtn addSubview:editImgView];
        [editImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@((SCREEN_WIDTH - 30 - 20 - yor) / 2 - 20));
            make.centerY.equalTo(self.nameBtn.mas_centerY);
            make.height.equalTo(@(15));
            make.width.equalTo(@(15));
        }];
        [self.nameBtn setTitle:item1.template_title forState:UIControlStateNormal];
    }else {
        [self.nameBtn setTitle:@"编辑模板主题" forState:UIControlStateNormal];
    }
}

@end
