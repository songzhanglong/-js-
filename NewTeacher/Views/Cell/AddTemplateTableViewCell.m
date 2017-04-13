//
//  AddTemplateTableViewCell.m
//  NewTeacher
//
//  Created by zhangxs on 16/1/26.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "AddTemplateTableViewCell.h"
#import "GrowSetTemplateModel.h"

@implementation AddTemplateTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 288) / 2, 0, 288, 57)];
        _bgImgView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_bgImgView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_bgImgView.frame.origin.x + 15, 10, _bgImgView.frame.size.width - 10 - 30, 22)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.contentView addSubview:_nameLabel];
        
        _classLabel = [[UILabel alloc] initWithFrame:CGRectMake(_bgImgView.frame.origin.x + 15, _nameLabel.frame.size.height + _nameLabel.frame.origin.y, _bgImgView.frame.size.width - 10 - 30, 15)];
        _classLabel.backgroundColor = [UIColor clearColor];
        _classLabel.textColor = [UIColor whiteColor];
        _classLabel.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:_classLabel];
        
        _checkImgView = [[UIImageView alloc] initWithFrame:CGRectMake( _bgImgView.frame.size.width - 10 - 10, (_bgImgView.frame.size.height - 30) / 2, 30, 30)];
        _checkImgView.backgroundColor = [UIColor clearColor];
        [_checkImgView setImage:CREATE_IMG(@"grow_add_check@2x")];
        [self.contentView addSubview:_checkImgView];
    }
    return self;
}

- (void)resetDataSource:(id)source
{
    GrowSetTemplateModel *model = (GrowSetTemplateModel *)source;
    if ([model.album_type integerValue] == 3) {
        _bgImgView.image = CREATE_IMG(@"grow_add_bg_type3@2x");
    }else if ([model.album_type integerValue] == 2){
        _bgImgView.image = CREATE_IMG(@"grow_add_bg_type1@2x");
    }else {
        _bgImgView.image = CREATE_IMG(@"grow_add_bg_type2@2x");
    }
    [_nameLabel setText:model.album_title];
    [_classLabel setText:model.album_desc];
}

@end
