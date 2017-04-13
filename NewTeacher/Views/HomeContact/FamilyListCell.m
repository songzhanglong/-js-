//
//  FamilyListCell.m
//  NewTeacher
//
//  Created by szl on 16/5/5.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "FamilyListCell.h"
#import "FamilyListModel.h"
#import "NSString+Common.h"

@implementation FamilyListCell
{
    UIView *_contentView;
    UILabel *_titleLab,*_timeLab,*_numLab;
    //UIProgressView *_progressView;
    UIImageView *_timeImg;
    UIView *_progressView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH - 20, 60)];
        _contentView = backView;
        [backView setBackgroundColor:[UIColor whiteColor]];
        backView.layer.masksToBounds = YES;
        backView.layer.cornerRadius = 2;
        [self.contentView addSubview:backView];
        
        //title
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, backView.frameWidth - 20, 18)];
        [_titleLab setTextColor:[UIColor blackColor]];
        [_titleLab setFont:[UIFont systemFontOfSize:14]];
        [backView addSubview:_titleLab];
        
        //time
        _timeImg = [[UIImageView alloc] initWithImage:CREATE_IMG(@"contactTime")];
        [_timeImg setFrame:CGRectMake(_titleLab.frameX, backView.frameHeight - 10 - 11, 8, 8)];
        [backView addSubview:_timeImg];
        
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(_timeImg.frameRight + 2, backView.frameHeight - 10 - 14, 100, 14)];
        [_timeLab setText:@"2016/04/03"];
        [_timeLab setFont:[UIFont systemFontOfSize:10]];
        [_timeLab setTextColor:[UIColor lightGrayColor]];
        [backView addSubview:_timeLab];
        
        //progress
        _numLab = [[UILabel alloc] initWithFrame:CGRectMake(backView.frameWidth - 45, _timeLab.frameY, 35, 14)];
        [_numLab setTextAlignment:NSTextAlignmentRight];
        [_numLab setTextColor:CreateColor(53, 175, 81)];
        [_numLab setFont:[UIFont systemFontOfSize:10]];
        [backView addSubview:_numLab];
        
        UIView *proBack = [[UIView alloc] initWithFrame:CGRectMake(_numLab.frameX - 90, _numLab.frameY + 2, 90, _numLab.frameHeight - 4)];
        [proBack setBackgroundColor:CreateColor(231, 231, 238)];
        proBack.layer.cornerRadius = proBack.frameHeight / 2;
        proBack.layer.masksToBounds = YES;
        proBack.clipsToBounds = YES;
        [backView addSubview:proBack];
        
        _progressView = [[UIView alloc] initWithFrame:proBack.bounds];
        [_progressView setBackgroundColor:CreateColor(135, 168, 69)];
        [proBack addSubview:_progressView];
    }
    return self;
}

- (void)resetDataSource:(id)object
{
    FamilyListModel *model = (FamilyListModel *)object;
    [_titleLab setText:model.title ?: @""];
    
    [_timeImg setHidden:!([model.update_time length] > 0)];
    [_timeLab setHidden:!([model.update_time length] > 0)];
    if ([model.update_time length] > 0) {
        NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:model.update_time.doubleValue];
        [_timeLab setText:[NSString stringByDate:@"yyyy/MM/dd" Date:updateDate]];
    }
    [_numLab setText:[NSString stringWithFormat:@"%@/%@",model.count_score,model.cou_stu]];
    CGFloat width = [[_progressView superview] frameWidth] * ([model.count_score floatValue] / [model.cou_stu floatValue]);
    [_progressView setFrameWidth:width];
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
