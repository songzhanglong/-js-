//
//  GrowPrintStepCell.m
//  NewTeacher
//
//  Created by szl on 16/5/11.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "GrowPrintStepCell.h"
#import "NSString+Common.h"

@implementation GrowPrintStepCell
{
    UIView *_backView,*_shadowView;
    UIImageView *_headImg;
    UILabel *_nameLab,*_timeLab;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _backView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        [_backView setBackgroundColor:[UIColor whiteColor]];
        [_backView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:_backView];
        
        //head
        _headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 36, 36)];
        _headImg.layer.masksToBounds = YES;
        _headImg.layer.cornerRadius = 18;
        _headImg.clipsToBounds = YES;
        [self.contentView addSubview:_headImg];
        
        _shadowView = [[UIView alloc] initWithFrame:_headImg.bounds];
        _shadowView.backgroundColor = rgba(67, 154, 215, 0.5);
        _shadowView.hidden = YES;
        [_headImg addSubview:_shadowView];
        UIImageView *checked = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 20, 20)];
        [checked setImage:CREATE_IMG(@"growChecked")];
        [_shadowView addSubview:checked];
        
        //name
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_headImg.frameRight + 10, _headImg.frameY + 9, 60, 18)];
        [_nameLab setFont:[UIFont systemFontOfSize:14]];
        [_nameLab setBackgroundColor:_backView.backgroundColor];
        [_nameLab setTextColor:[UIColor blackColor]];
        [self.contentView addSubview:_nameLab];
        
        //time
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(_nameLab.frameRight, _nameLab.frameY + 2, SCREEN_WIDTH - _nameLab.frameRight - 5, 14)];
        [_timeLab setFont:[UIFont systemFontOfSize:10]];
        [_timeLab setTextAlignment:NSTextAlignmentRight];
        [_timeLab setTextColor:[UIColor darkGrayColor]];
        [_timeLab setBackgroundColor:_backView.backgroundColor];
        [self.contentView addSubview:_timeLab];
    }
    return self;
}

- (void)setIsChecked:(BOOL)isChecked
{
    _backView.alpha = 1.0;
    _isChecked = isChecked;
    _shadowView.hidden = !isChecked;
    [_backView setBackgroundColor:isChecked ? CreateColor(225, 242, 251) : [UIColor whiteColor]];
    [_nameLab setBackgroundColor:_backView.backgroundColor];
    [_timeLab setBackgroundColor:_backView.backgroundColor];
}

- (void)setHasPrintBackView
{
    _backView.alpha = 0.4;
    [_backView setBackgroundColor:[UIColor redColor]];
    [_nameLab setBackgroundColor:[UIColor clearColor]];
    [_timeLab setBackgroundColor:[UIColor clearColor]];
}

- (void)resetDataSource:(TermStudent *)student
{
    NSString *face = student.face;
    if (![face hasPrefix:@"http"]) {
        face = [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
    }
    [_headImg setImageWithURL:[NSURL URLWithString:[face stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"s21.png"]];
    [_nameLab setText:student.student_name];
    if (student.print_count.integerValue <= 0) {
        [_timeLab setText:@""];
    }
    else{
        NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:student.last_print.doubleValue];
        [_timeLab setText:[NSString stringWithFormat:@"最近提交:%@ 已提交%@次",[NSString stringByDate:@"yyyy-MM-dd HH:mm" Date:updateDate],student.print_count.stringValue]];
    }
    
}

@end
