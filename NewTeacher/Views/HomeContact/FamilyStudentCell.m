//
//  FamilyStudentCell.m
//  NewTeacher
//
//  Created by szl on 16/5/5.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "FamilyStudentCell.h"
#import "FamilyStudentModel.h"

@implementation FamilyStudentCell
{
    UIView *_contentView;
    UIImageView *_headImg;
    UILabel *_nameLab,*_numLab,*_recordLab;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 20, 60)];
        _contentView = backView;
        [backView setBackgroundColor:[UIColor whiteColor]];
        backView.layer.masksToBounds = YES;
        backView.layer.cornerRadius = 2;
        [self.contentView addSubview:backView];
        
        //head
        _headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        _headImg.layer.masksToBounds = YES;
        _headImg.layer.cornerRadius = 20;
        _headImg.contentMode = UIViewContentModeScaleAspectFill;
        _headImg.clipsToBounds = YES;
        [backView addSubview:_headImg];
        
        //name
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_headImg.frameRight + 10, _headImg.frameY, 80, 18)];
        [_nameLab setTextColor:[UIColor blackColor]];
        [_nameLab setFont:[UIFont systemFontOfSize:14]];
        [backView addSubview:_nameLab];
        
        _numLab = [[UILabel alloc] initWithFrame:CGRectMake(_nameLab.frameRight + 10, _nameLab.frameY, backView.frameWidth - _nameLab.frameRight - 20, 18)];
        [_numLab setTextAlignment:NSTextAlignmentRight];
        [backView addSubview:_numLab];
        
        //record
        UIImageView *recordImg = [[UIImageView alloc] initWithFrame:CGRectMake(_nameLab.frameX, _headImg.frameBottom - 10, 10, 10)];
        [recordImg setImage:CREATE_IMG(@"contactRecord")];
        [backView addSubview:recordImg];
        
        _recordLab = [[UILabel alloc] initWithFrame:CGRectMake(recordImg.frameRight + 2, recordImg.frameY - 2, backView.frameWidth - recordImg.frameRight - 10 - 2, 14)];
        [_recordLab setTextColor:[UIColor lightGrayColor]];
        [_recordLab setFont:[UIFont systemFontOfSize:10]];
        [backView addSubview:_recordLab];
    }
    return self;
}

- (void)resetDataSource:(id)object
{
    FamilyStudentModel *model = (FamilyStudentModel *)object;
    NSString *str = model.face_school;
    NSString *url = [str hasPrefix:@"http"] ? str : [G_IMAGE_ADDRESS stringByAppendingString:str ?: @""];
    [_headImg setImageWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:CREATE_IMG(@"s21@2x")];
    if ([model.totals integerValue] >0) {
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:@"共"];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, 1)];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, 1)];
        NSMutableAttributedString *attributeStr2 = [[NSMutableAttributedString alloc] initWithString:model.totals];
        [attributeStr2 addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, [model.totals length])];
        [attributeStr2 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, [model.totals length])];
        NSMutableAttributedString *attributeStr3 = [[NSMutableAttributedString alloc] initWithString:@"份联系表"];
        [attributeStr3 addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, 4)];
        [attributeStr3 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, 4)];
        [attributeStr appendAttributedString:attributeStr2];
        [attributeStr appendAttributedString:attributeStr3];
        [_numLab setAttributedText:attributeStr];
    }else {
        [_numLab setFont:[UIFont systemFontOfSize:10]];
        [_numLab setTextColor:[UIColor darkGrayColor]];
        [_numLab setText:@"还未填写过哦"];
    }
    
    [_nameLab setText:model.name ?: @""];
    [_recordLab setText:model.title];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        [_contentView setBackgroundColor:CreateColor(239, 239, 240)];
    }
    else{
        [_contentView setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        [_contentView setBackgroundColor:CreateColor(239, 239, 240)];
    }
    else{
        [_contentView setBackgroundColor:[UIColor whiteColor]];
    }
}

@end
