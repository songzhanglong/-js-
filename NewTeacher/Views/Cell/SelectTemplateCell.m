//
//  SelectTemplateCell.m
//  NewTeacher
//
//  Created by zhangxs on 16/1/26.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "SelectTemplateCell.h"

@implementation SelectTemplateCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _checkImgView = [[UIImageView alloc] initWithFrame:CGRectMake( self.contentView.frame.size.width - 30, 4, 30, 30)];
        _checkImgView.backgroundColor = [UIColor clearColor];
        [_checkImgView setImage:CREATE_IMG(@"grow_add_check@2x")];
        [self.contentView addSubview:_checkImgView];
        
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 38, self.contentView.frame.size.width, 127)];
        _imgView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_imgView];
    }
    return self;
}

- (void)resetDataSource:(id)source
{
    
}

@end
