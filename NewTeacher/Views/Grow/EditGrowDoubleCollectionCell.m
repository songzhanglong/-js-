//
//  EditGrowDoubleCollectionCell.m
//  NewTeacher
//
//  Created by szl on 16/8/31.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "EditGrowDoubleCollectionCell.h"
#import "NSString+Common.h"

@implementation EditGrowDoubleCollectionCell
{
    UIImageView *_leftImg,*_rightImg;
    
}

- (void)contentImgViewInit
{
    //content
    _leftImg = [[UIImageView alloc] init];
    [_leftImg setTranslatesAutoresizingMaskIntoConstraints:NO];
    _leftImg.clipsToBounds = YES;
    [_leftImg setContentMode:UIViewContentModeScaleAspectFill];
    [_leftImg setBackgroundColor:BACKGROUND_COLOR];
    [self.contentView addSubview:_leftImg];
    [_leftImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_editBtn.mas_left);
        make.top.equalTo(self.contentView.mas_top).with.offset(12);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-27);
        make.width.equalTo(_editBtn.mas_width).with.multipliedBy(0.5);
    }];
    
    _rightImg = [[UIImageView alloc] init];
    [_rightImg setTranslatesAutoresizingMaskIntoConstraints:NO];
    _rightImg.clipsToBounds = YES;
    [_rightImg setContentMode:UIViewContentModeScaleAspectFill];
    [_rightImg setBackgroundColor:BACKGROUND_COLOR];
    [self.contentView addSubview:_rightImg];
    [_rightImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftImg.mas_right);
        make.top.equalTo(_leftImg.mas_top);
        make.bottom.equalTo(_leftImg.mas_bottom);
        make.width.equalTo(_leftImg.mas_width);
    }];
    
    
}

- (void)resetContentData:(NSArray *)array
{
    self.options = array;
    TemplateItem *item1 = [array firstObject];
    TemplateItem *item2 = [array lastObject];
    
    NSString *path1 = item1.template_path ?: @"";
    if (![path1 hasPrefix:@"http"]) {
        path1 = [G_IMAGE_GROW_ADDRESS stringByAppendingString:path1];
    }
    path1 = [NSString getPictureAddress:@"2" width:@"320" height:@"0" original:path1];
    [_leftImg setImage:nil];
    [_leftImg setImageWithURL:[NSURL URLWithString:[path1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSString *path2 = item2.template_path ?: @"";
    if (![path2 hasPrefix:@"http"]) {
        path2 = [G_IMAGE_GROW_ADDRESS stringByAppendingString:path2];
    }
    path2 = [NSString getPictureAddress:@"2" width:@"320" height:@"0" original:path2];
    [_rightImg setImage:nil];
    [_rightImg setImageWithURL:[NSURL URLWithString:[path2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSString *title = item1.template_title ?: (item2.template_title ?: @"");
    [_editBtn setTitle:title forState:UIControlStateNormal];
}

@end
