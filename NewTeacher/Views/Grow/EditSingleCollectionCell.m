//
//  EditSingleCollectionCell.m
//  NewTeacher
//
//  Created by szl on 16/8/31.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "EditSingleCollectionCell.h"
#import "HorizontalButton.h"
#import <Masonry.h>
#import "GrowSetTemplateModel.h"
#import "NSString+Common.h"

@implementation EditSingleCollectionCell

{
    UIImageView *_contentImg;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //buttons
        UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [delBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
        [delBtn setTag:1];
        [delBtn addTarget:self action:@selector(checkBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [delBtn setImage:CREATE_IMG(@"grow_del@2x") forState:UIControlStateNormal];
        [delBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 37, 37, 0)];
        [self.contentView addSubview:delBtn];
        [delBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top);
            make.right.equalTo(self.contentView.mas_right);
            make.width.equalTo(@(52));
            make.height.equalTo(@(52));
        }];
        
        //bottom
        UIView *bottomView = [[UIView alloc] init];
        [bottomView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [bottomView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:bottomView];
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.height.equalTo(@(60));
            make.width.equalTo(self.contentView.mas_width);
            make.centerX.equalTo(self.contentView.mas_centerX);
        }];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];;
        _nameBtn = button;
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        button.backgroundColor = CreateColor(228, 67, 43);
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 1.0;
        [button setTag:2];
        [button setTitle:@"编辑模板主题" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(checkBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(bottomView.mas_centerX);
            make.centerY.equalTo(bottomView.mas_centerY);
            make.height.equalTo(@(30));
            make.width.equalTo(bottomView.mas_width).with.offset(-30);
        }];
        
        [self customViewInit];
    }
    
    return self;
}

- (void)customViewInit
{
    //
    UIImageView *imgView = [[UIImageView alloc] init];
    _contentImg = imgView;
    [imgView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    [imgView setBackgroundColor:BACKGROUND_COLOR];
    imgView.clipsToBounds = YES;
    [self.contentView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(@(15));
        make.width.equalTo(self.contentView.mas_width);
        make.height.equalTo(self.contentView.mas_height).with.offset(-75);
    }];
    
}

- (CGFloat)calculateDescRects:(NSString *)title
{
    CGSize lastSize = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    lastSize = [title boundingRectWithSize:CGSizeMake(1000, 30) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    return  MAX(lastSize.width, 20);
}

- (void)checkBtnPressed:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(beginEditSingleCollectionCell:At:Options:)]) {
        [_delegate beginEditSingleCollectionCell:self At:[sender tag] Options:self.options];
    }
}

- (void)resetDataSource:(NSArray *)array
{
    self.options = array;
    TemplateItem *item = [array firstObject];
    NSString *path = item.template_path ?: @"";
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
    if (![path hasPrefix:@"http"]) {
        path = [G_IMAGE_GROW_ADDRESS stringByAppendingString:path];
    }
    path = [NSString getPictureAddress:@"2" width:width height:@"0" original:path];
    [_contentImg setImageWithURL:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    for (id subs in [_nameBtn subviews]) {
        if ([subs isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)subs removeFromSuperview];
        }
    }
    if ([item.template_title length] > 0) {
        CGFloat yor = [self calculateDescRects:item.template_title];
        UIImageView *editImgView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"grow_edit@2x")];
        [_nameBtn addSubview:editImgView];
        [editImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@((SCREEN_WIDTH - 30 - 20 - yor) / 2 - 20));
            make.centerY.equalTo(self.nameBtn.mas_centerY);
            make.height.equalTo(@(15));
            make.width.equalTo(@(15));
        }];
        [_nameBtn setTitle:item.template_title forState:UIControlStateNormal];
    }else {
        [_nameBtn setTitle:@"编辑模板主题" forState:UIControlStateNormal];
    }
}

@end
