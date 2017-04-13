//
//  AddItemCollectionCell.m
//  NewTeacher
//
//  Created by szl on 16/8/31.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "AddItemCollectionCell.h"
#import <Masonry.h>

@implementation AddItemCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self customViewInit];
    }
    
    return self;
}

- (void)customViewInit
{
    //
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
    
    //
    UIImageView *addImg = [[UIImageView alloc] init];
    [addImg setTranslatesAutoresizingMaskIntoConstraints:NO];
    [addImg setImage:CREATE_IMG(@"grow_add_btn_bg@2x")];
    [imgView addSubview:addImg];
    [addImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(imgView.mas_centerX);
        make.centerY.equalTo(imgView.mas_centerY);
        make.width.equalTo(@(30));
        make.height.equalTo(@(30));
    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    [titleLab setBackgroundColor:[UIColor clearColor]];
    [titleLab setTextAlignment:NSTextAlignmentCenter];
    [titleLab setFont:[UIFont systemFontOfSize:12]];
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setTranslatesAutoresizingMaskIntoConstraints:NO];
    [titleLab setText:@"新加模板"];
    [self.contentView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView.mas_bottom);
        make.width.equalTo(imgView.mas_width);
        make.height.equalTo(@(15));
        make.centerX.equalTo(imgView.mas_centerX);
    }];
}

- (void)resetContentData:(NSArray *)array
{
    
}

@end
