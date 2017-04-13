//
//  EditGrowSingleCollectionCell.m
//  NewTeacher
//
//  Created by szl on 16/8/31.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "EditGrowSingleCollectionCell.h"
#import "NSString+Common.h"

@implementation EditGrowSingleCollectionCell
{
    UIImageView *_contentImg;
}

- (void)customViewInit
{
    //content
    UIImageView *imgView = [[UIImageView alloc] init];
    [imgView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [imgView setImage:CREATE_IMG(@"grow_collection_bg@2x")];
    [self.contentView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(self.contentView.mas_top);
        make.width.equalTo(self.contentView.mas_width);
        make.height.equalTo(self.contentView.mas_height).with.offset(-15);
    }];
    
    //buttons
    UIButton *_delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_delBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_delBtn setTag:1];
    [_delBtn addTarget:self action:@selector(editTemplateTheme:) forControlEvents:UIControlEventTouchUpInside];
    [_delBtn setImage:CREATE_IMG(@"grow_del@2x") forState:UIControlStateNormal];
    [_delBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 37, 37, 0)];
    [self.contentView addSubview:_delBtn];
    [_delBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView.mas_top);
        make.right.equalTo(imgView.mas_right);
        make.width.equalTo(@(52));
        make.height.equalTo(@(52));
    }];
    
    _editBtn = [HorizontalButton buttonWithType:UIButtonTypeCustom];
    _editBtn.imgSize = CGSizeMake(15, 15);
    [_editBtn setTag:2];
    [_editBtn addTarget:self action:@selector(editTemplateTheme:) forControlEvents:UIControlEventTouchUpInside];
    [_editBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_editBtn setImage:CREATE_IMG(@"grow_edit@2x") forState:UIControlStateNormal];
    [_editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_editBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [_editBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.contentView addSubview:_editBtn];
    [_editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView.mas_bottom);
        make.left.equalTo(imgView.mas_left).with.offset(12);
        make.width.equalTo(imgView.mas_width).with.offset(-24);
        make.height.equalTo(@(15));
    }];
    
    [self contentImgViewInit];
}

- (void)contentImgViewInit
{
    //content
    _contentImg = [[UIImageView alloc] init];
    [_contentImg setTranslatesAutoresizingMaskIntoConstraints:NO];
    _contentImg.clipsToBounds = YES;
    [_contentImg setContentMode:UIViewContentModeScaleAspectFill];
    [_contentImg setBackgroundColor:BACKGROUND_COLOR];
    [self.contentView addSubview:_contentImg];
    [_contentImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsMake(12, 12, 12 + 15, 12));
    }];
}

- (void)editTemplateTheme:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(editCollectionCell:Type:Options:)]) {
        [self.delegate editCollectionCell:self Type:[sender tag] Options:self.options];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _editBtn.textSize = CGSizeMake(_editBtn.frame.size.width - 15, 15);
}

- (void)resetContentData:(NSArray *)array
{
    self.options = array;
    TemplateItem *item = [array firstObject];
    
    NSString *path = item.template_path ?: @"";
    if (![path hasPrefix:@"http"]) {
        path = [G_IMAGE_GROW_ADDRESS stringByAppendingString:path];
    }
    path = [NSString getPictureAddress:@"2" width:@"320" height:@"0" original:path];
    [_contentImg setImage:nil];
    [_contentImg setImageWithURL:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [_editBtn setTitle:item.template_title ?: @"" forState:UIControlStateNormal];
}

@end
