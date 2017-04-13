//
//  SynchronsizeStudentCell.m
//  NewTeacher
//
//  Created by songzhanglong on 15/5/29.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SynchronsizeStudentCell.h"

@implementation SynchronsizeStudentCell

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _photoImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 65, 65)];
        _photoImg.contentMode = UIViewContentModeScaleAspectFill;
        _photoImg.clipsToBounds = YES;
        [_photoImg.layer setMasksToBounds:YES];
        [_photoImg.layer setCornerRadius:32.5];
        [self.contentView addSubview:_photoImg];
        
        _selectBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectBut setBackgroundColor:[UIColor clearColor]];
        [_selectBut setFrame:CGRectMake(self.contentView.frameWidth - 17, self.contentView.frameHeight - 17 - 25, 17, 17)];
        [_selectBut setUserInteractionEnabled:NO];
        [_selectBut setImage:nil forState:UIControlStateNormal];
        [_selectBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"grow_photo_check" ofType:@"png"]] forState:UIControlStateSelected];
        [self.contentView addSubview:_selectBut];
        
        _nameLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 70, 70, 20)];
        _nameLab.textColor = [UIColor blackColor];
        [_nameLab setTextAlignment:NSTextAlignmentCenter];
        [_nameLab setFont:[UIFont systemFontOfSize:14]];
        _nameLab.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_nameLab];
    }
    return self;
}

@end
