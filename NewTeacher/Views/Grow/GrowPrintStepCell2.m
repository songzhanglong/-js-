//
//  GrowPrintStepCell2.m
//  NewTeacher
//
//  Created by zhangxs on 16/7/14.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "GrowPrintStepCell2.h"
#import "NSString+Common.h"

@implementation GrowPrintStepCell2
{
    UIView *_backView,*_shadowView,*_numsView;
    UIImageView *_headImg;
    UILabel *_nameLab,*_timeLab,*_numsLab;
    TermStudent *_currModel;
    UILabel *_undoNumsLabel;
    NSInteger _indexNum;
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
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_headImg.frameRight + 10, _headImg.frameY + 5, 60, 18)];
        [_nameLab setFont:[UIFont systemFontOfSize:14]];
        [_nameLab setBackgroundColor:_backView.backgroundColor];
        [_nameLab setTextColor:[UIColor blackColor]];
        [self.contentView addSubview:_nameLab];
        
        //time
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(_nameLab.frameX, _nameLab.frameBottom, SCREEN_WIDTH - _nameLab.frameX - 15, 14)];
        [_timeLab setFont:[UIFont systemFontOfSize:10]];
        [_timeLab setTextColor:[UIColor darkGrayColor]];
        [_timeLab setBackgroundColor:_backView.backgroundColor];
        [self.contentView addSubview:_timeLab];
        
        _undoNumsLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 10, 90, 20)];
        [_undoNumsLabel setBackgroundColor:[UIColor clearColor]];
        [_undoNumsLabel setText:@"×1"];
        _undoNumsLabel.hidden = YES;
        [_undoNumsLabel setTextColor:[UIColor blackColor]];
        [_undoNumsLabel setFont:[UIFont systemFontOfSize:14]];
        [_undoNumsLabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_undoNumsLabel];
        
        _numsView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 10, 90, 20)];
        [_numsView setBackgroundColor:[UIColor whiteColor]];
        [_numsView.layer setCornerRadius:3];
        [_numsView.layer setMasksToBounds:YES];
        [_numsView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [_numsView.layer setBorderWidth:1];
        [_numsView setUserInteractionEnabled:YES];
        [self.contentView addSubview:_numsView];
        
        for (int i = 0; i < 3; i++) {
            if (i != 1) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setFrame:CGRectMake(30 * i, 0, 30, 20)];
                [btn setTitle:(i == 0) ? @"-" : @"+" forState:UIControlStateNormal];
                [btn setTitleColor:(i == 0) ? [UIColor lightGrayColor] : [UIColor blackColor] forState:UIControlStateNormal];
                btn.tag = i + 1;
                [btn addTarget:self action:@selector(addOrSubtractAction:) forControlEvents:UIControlEventTouchUpInside];
                [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
                [_numsView addSubview:btn];
            }else {
                UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 30, 20)];
                _numsLab = tipLab;
                [tipLab setBackgroundColor:[UIColor clearColor]];
                [tipLab setTextColor:[UIColor blackColor]];
                [tipLab setFont:[UIFont systemFontOfSize:14]];
                [tipLab setTextAlignment:NSTextAlignmentCenter];
                [_numsView addSubview:tipLab];
            }
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30 + 30 * i, 0, 1, _numsView.frameHeight)];
            [label setBackgroundColor:[UIColor lightGrayColor]];
            [_numsView addSubview:label];
        }
    }
    return self;
}

- (void)addOrSubtractAction:(id)sender
{
    BOOL isAdd;
    UIButton *btn = (UIButton *)sender;
    if ([btn tag] == 1) {
        //subtract
        if (_num == 1) {
            return;
        }
        _num--;
        isAdd = NO;
    }else {
        //add
        if (_num >= _indexNum && _isUndoPrint) {
            return;
        }
        _num++;
        isAdd = YES;
    }
    [_numsLab setText:[NSString stringWithFormat:@"%ld",(long)_num]];
    UIButton *tempBtn = (UIButton *)[_numsView viewWithTag:1];
    if (tempBtn) {
        [tempBtn setTitleColor:(_num == 1) ? [UIColor lightGrayColor] : [UIColor blackColor] forState:UIControlStateNormal];
    }
    if (_isUndoPrint) {
        UIButton *addBtn = (UIButton *)[_numsView viewWithTag:3];
        if (addBtn) {
            [addBtn setTitleColor:(_num >= _indexNum) ? [UIColor lightGrayColor] : [UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    _currModel.grow_num = [NSString stringWithFormat:@"%ld",(long)_num];
    if (_delegate && [_delegate respondsToSelector:@selector(upDataNumsToController:)]) {
        [_delegate upDataNumsToController:isAdd];
    }
}

- (void)resetDataSource:(TermStudent *)student
{
    _currModel = student;
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
    
    _num = [student.grow_num integerValue];
    [_numsLab setText:student.grow_num];
    
    UIButton *tempBtn = (UIButton *)[_numsView viewWithTag:1];
    if (tempBtn) {
        [tempBtn setTitleColor:(_num == 1) ? [UIColor lightGrayColor] : [UIColor blackColor] forState:UIControlStateNormal];
    }
    
    if (_isUndoPrint) {
        _num = [student.grow_num integerValue];
        _indexNum = _num;
        if (_num > 0) {
            [_numsLab setText:[NSString stringWithFormat:@"%ld",(long)_num]];
        }
        
        _undoNumsLabel.hidden = (_num > 1);
        _numsView.hidden = (_num == 1);
        
        UIButton *btn = (UIButton *)[_numsView viewWithTag:1];
        if (btn) {
            [btn setTitleColor:(_num > 1) ? [UIColor blackColor] : [UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        UIButton *tempBtn = (UIButton *)[_numsView viewWithTag:3];
        if (tempBtn) {
            [tempBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
    }
}

@end
