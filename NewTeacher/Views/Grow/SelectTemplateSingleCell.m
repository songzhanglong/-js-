//
//  SelectTemplateSingleCell.m
//  NewTeacher
//
//  Created by szl on 16/8/31.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "SelectTemplateSingleCell.h"
#import <Masonry.h>
#import "GrowSetTemplateModel.h"
#import "NSString+Common.h"

@implementation SelectTemplateSingleCell
{
    UIImageView *_contentImg;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkBtn addTarget:self action:@selector(checkBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_checkBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_checkBtn setImage:CREATE_IMG(@"grow_add_check@2x") forState:UIControlStateNormal];
        [_checkBtn setImage:CREATE_IMG(@"grow_add_check1@2x") forState:UIControlStateSelected];
        [_checkBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 15, 5, -5)];
        [self.contentView addSubview:_checkBtn];
        [_checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top);
            make.right.equalTo(self.contentView.mas_right);
            make.width.equalTo(@(40));
            make.height.equalTo(@(40));
        }];
        
        [self customViewInit];
    }
    
    return self;
}

- (void)checkBtnPressed:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(checkSelectTemplateCellBtn:Options:)]) {
        [_delegate checkSelectTemplateCellBtn:self Options:self.options];
    }
}

- (void)customViewInit
{
    //
    UIImageView *imgView = [[UIImageView alloc] init];
    _contentImg = imgView;
    [imgView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    imgView.clipsToBounds = YES;
    [imgView setBackgroundColor:BACKGROUND_COLOR];
    [self.contentView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(@(30));
        make.width.equalTo(self.contentView.mas_width);
        make.height.equalTo(self.contentView.mas_height).with.offset(-30);
    }];
    
}

- (void)resetDataSource:(NSArray *)array Checked:(BOOL)checked
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
    
    _checkBtn.selected = checked;
}

@end
