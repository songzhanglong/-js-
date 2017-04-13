//
//  GrowSingleTemplate.m
//  NewTeacher
//
//  Created by zhangxs on 16/1/25.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "GrowSingleTemplateView.h"

@implementation GrowSingleTemplateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];

        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, self.frame.size.width, self.frame.size.height - 25 - 5)];
        [_imgView setBackgroundColor:BACKGROUND_COLOR];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        [self addSubview:_imgView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.frame.size.height - 20, self.frame.size.width - 20 - 5, 20)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_titleLabel];
       
//        _editButton.frame = CGRectMake(5, self.frame.size.height - 15 - 2, 15, 15);
//        [_editButton setImage:CREATE_IMG(@"grow_edit@2x") forState:UIControlStateNormal];
        
        UIImageView *editImgView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"grow_edit@2x")];
        editImgView.frame = CGRectMake(0, 5, 15, 15);
        
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _editButton.frame = CGRectMake(5, self.frame.size.height - 15 - 5 - 2, self.frame.size.width - 10, 25);
        [_editButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_editButton addSubview:editImgView];
        [self addSubview:_editButton];
    }
    return self;
}

- (void)buttonAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(editTemplate:)]) {
        [_delegate editTemplate:self];
    }
}

- (void)setContetData:(TemplateItem *)model
{
    NSString *path = model.template_path_thumb ?: @"";
    if (![path hasPrefix:@"http"]) {
        path = [G_IMAGE_GROW_ADDRESS stringByAppendingString:path];
    }
    [_imgView setImageWithURL:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [_titleLabel setText:model.template_title ?: @""];
}
@end
