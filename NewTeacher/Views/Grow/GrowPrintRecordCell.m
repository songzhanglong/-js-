//
//  GrowPrintRecordCell.m
//  NewTeacher
//
//  Created by szl on 16/5/11.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "GrowPrintRecordCell.h"
#import "NSString+Common.h"

@implementation GrowPrintRecordCell
{
    UIButton *_rightBut,*_undoBtn;
    UIView *_backView;
    UILabel *_timeLab,*_preTimeLab,*_numLab,*_usrLab,*_tipLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(10, 8, SCREEN_WIDTH - 20, self.contentView.frameHeight - 8)];
        [backView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [backView setBackgroundColor:CreateColor(226, 226, 231)];
        backView.clipsToBounds = YES;
        backView.layer.masksToBounds = YES;
        _backView = backView;
        backView.layer.cornerRadius = 2;
        [self.contentView addSubview:backView];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 0, backView.frameWidth, 32)];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button addTarget:self action:@selector(expandCell:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:button];
        
        //
        CGFloat lwei = (backView.frameWidth - 30) / 3;
        for (NSInteger i = 0; i < 3; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * lwei, 7, lwei, 18)];
            [label setBackgroundColor:[UIColor whiteColor]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFont:[UIFont systemFontOfSize:14]];
            [label setTextColor:[UIColor darkGrayColor]];
            [backView addSubview:label];
            
            if (i == 0) {
                _preTimeLab = label;
            }
            else if (i == 1){
                _numLab = label;
            }
            else{
                _usrLab = label;
            }
        }
        
        _rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBut setFrame:CGRectMake(lwei * 3, 8, 20, 20)];
        [_rightBut setImage:CREATE_IMG(@"growUnExpand") forState:UIControlStateNormal];
        [_rightBut setImage:CREATE_IMG(@"growExpand") forState:UIControlStateSelected];
        [backView addSubview:_rightBut];
        
        //
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(10, button.frameBottom + 8, backView.frameWidth - 20, 18)];
        [_timeLab setFont:[UIFont systemFontOfSize:14]];
        [_timeLab setTextColor:[UIColor darkGrayColor]];
        [_timeLab setBackgroundColor:backView.backgroundColor];
        [backView addSubview:_timeLab];
        
        for (int i = 0; i < 10; i++) {
            UILabel *statusLab = [[UILabel alloc] initWithFrame:CGRectMake(_timeLab.frameX, _timeLab.frameBottom + 12, 45, 18)];
            [statusLab setFont:_timeLab.font];
            [statusLab setTag:10 + i];
            [statusLab setTextColor:_timeLab.textColor];
            [statusLab setBackgroundColor:_timeLab.backgroundColor];
            [backView addSubview:statusLab];
            
            UILabel *namesLab = [[UILabel alloc] initWithFrame:CGRectMake(statusLab.frameRight, statusLab.frameY, backView.frameWidth - statusLab.frameRight - 10, 0)];
            [namesLab setNumberOfLines:0];
            [namesLab setTag:20 + i];
            [namesLab setFont:statusLab.font];
            [namesLab setTextColor:statusLab.textColor];
            [namesLab setBackgroundColor:statusLab.backgroundColor];
            [backView addSubview:namesLab];
        }
        
        _undoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_undoBtn setFrame:CGRectMake(backView.frameWidth - 50, backView.frameHeight - 25, 40, 20)];
        [_undoBtn setTitle:@"撤销" forState:UIControlStateNormal];
        [_undoBtn setTintColor:[UIColor whiteColor]];
        [_undoBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_undoBtn.layer setMasksToBounds:YES];
        [_undoBtn.layer setCornerRadius:3];
        [_undoBtn addTarget:self action:@selector(undoAction:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:_undoBtn];
        
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(_undoBtn.frameRight - 8, _undoBtn.frameY - 2, 10, 10)];
        [_tipLabel setBackgroundColor:CreateColor(236, 184, 7)];
        [_tipLabel setTextColor:[UIColor whiteColor]];
        [_tipLabel setFont:[UIFont boldSystemFontOfSize:8]];
        [_tipLabel setText:@"!"];
        [_tipLabel setTextAlignment:NSTextAlignmentCenter];
        [_tipLabel.layer setMasksToBounds:YES];
        [_tipLabel.layer setCornerRadius:5];
        [_tipLabel.layer setBorderWidth:1];
        [_tipLabel.layer setBorderColor:[UIColor whiteColor].CGColor];
        [backView addSubview:_tipLabel];
    }
    return self;
}

- (void)undoAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(undoPrintRecordCell:)]) {
        [_delegate undoPrintRecordCell:self];
    }
}

- (void)expandCell:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(expandPrintRecordCell:)]) {
        [_delegate expandPrintRecordCell:self];
    }
}

- (void)resetDataSource:(TermPrintRecord *)printRecord
{
    CGFloat idx = 0;
    for (NSInteger i = 0; i < 10; i++) {
        UILabel *statuesLab = (UILabel *)[_backView viewWithTag:10 + i];
        if (i < [printRecord.student_names_group count]) {
            OrderStatus *item = [printRecord.student_names_group objectAtIndex:i];
            [statuesLab setHidden:NO];
            [statuesLab setFrame:CGRectMake(_timeLab.frameX, _timeLab.frameBottom + 12 + idx, item.statusWei, 18)];
            [statuesLab setText:[NSString stringWithFormat:@"%@：",item.status_name]];
            idx += item.namesHei + 5;
        }else{
            [statuesLab setHidden:YES];
        }
        
        UILabel *namesLab = (UILabel *)[_backView viewWithTag:20 + i];
        if (i < [printRecord.student_names_group count]) {
            OrderStatus *item = [printRecord.student_names_group objectAtIndex:i];
            [namesLab setHidden:NO];
            [namesLab setFrame:CGRectMake(statuesLab.frameRight, statuesLab.frameY, _backView.frameWidth - statuesLab.frameRight - 10, item.namesHei)];
            
            NSMutableArray *tempArr = [NSMutableArray array];
            NSArray *names = [item.student_names componentsSeparatedByString:@","];
            NSArray *nums = [item.grow_nums componentsSeparatedByString:@","];
            for (int i = 0; i < [names count]; i++) {
                NSString *str1 = [names objectAtIndex:i];
                NSString *str2 = [nums objectAtIndex:i];
                if ([str2 integerValue] > 1) {
                    str2 = [NSString stringWithFormat:@"[×%@]",str2];
                    str1 = [str1 stringByAppendingString:str2];
                }
                [tempArr addObject:str1];
            }
            
            NSString *tempString = [tempArr componentsJoinedByString:@","];
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:tempString];
            [attStr addAttribute:NSForegroundColorAttributeName value:namesLab.textColor range:NSMakeRange(0, [attStr length])];
            NSInteger loction = 0;
            for (int i = 0; i < [nums count]; i++) {
                NSString *str1 = [NSString stringWithFormat:@"[×%@]",nums[i]];
                NSRange range = [tempString rangeOfString:str1];
                if(range.location == NSNotFound){
                    continue;
                }
                tempString = [tempString substringFromIndex:range.location+range.length];
                [attStr addAttribute:NSForegroundColorAttributeName value:CreateColor(82, 150, 255) range:NSMakeRange(range.location + loction, range.length)];
                
                loction += range.location + range.length;
            }
            [namesLab setAttributedText:attStr];
        }else {
            [namesLab setHidden:YES];
        }
    }
    
    if ([printRecord.cancel_flag integerValue] == 1) {
        [_tipLabel setHidden:YES];
        [_undoBtn setBackgroundColor:[UIColor redColor]];
    }else {
        [_tipLabel setHidden:NO];
        [_undoBtn setBackgroundColor:[UIColor darkGrayColor]];
    }
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:printRecord.create_time.doubleValue];
    NSString *timer = [NSString stringByDate:@"yyyy-MM-dd HH:mm" Date:updateDate];
    [_preTimeLab setText:[[timer componentsSeparatedByString:@" "] firstObject]];
    [_numLab setText:printRecord.print_num.stringValue];
    [_usrLab setText:printRecord.create_teacher_name];
    _rightBut.selected = printRecord.isExpand;
    [_timeLab setText:[NSString stringWithFormat:@"提交时间：%@",timer]];
    
   
    [_undoBtn setFrameY:_timeLab.frameBottom + 12 + idx];
    [_tipLabel setFrameY:_undoBtn.frameY - 2];
}

@end
