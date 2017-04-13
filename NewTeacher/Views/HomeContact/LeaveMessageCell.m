//
//  LeaveMessageCell.m
//  NewTeacher
//
//  Created by zhangxs on 16/5/4.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "LeaveMessageCell.h"
#import "LeaveMsgModel.h"
#import "NSString+Common.h"

@interface LeaveMessageCell ()
{
    UIImageView *_faceImgView,*_child_faceImgView;
    UILabel *_nameLabel,*_timeLabel,*_contLabel,*_child_nameLabel,*_titleLabel;

    UIView *_bgView;
}

@end

@implementation LeaveMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        CGFloat width = 301.5,xOri = (SCREEN_WIDTH - width) / 2;
        
        //middle
        UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(xOri, 10, width, self.contentView.frameHeight - 16)];
        [middleView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [middleView setBackgroundColor:[UIColor whiteColor]];
        _bgView = middleView;
        [self.contentView addSubview:middleView];
        
        //left + right
        UIImageView *leftImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0.5, middleView.frameHeight)];
        [leftImg setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [leftImg setImage:CREATE_IMG(@"contact_cell_bg3")];
        [middleView addSubview:leftImg];
        
        UIImageView *rightImg = [[UIImageView alloc] initWithFrame:CGRectMake(middleView.frameWidth - 0.5, 0, 0.5, middleView.frameHeight)];
        [rightImg setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [rightImg setImage:CREATE_IMG(@"contact_cell_bg3")];
        [middleView addSubview:rightImg];
        
        //top
        CGRect topRect = CGRectMake(xOri, 0, middleView.frameWidth, 60);
        UIImageView *topImg = [[UIImageView alloc] initWithFrame:topRect];
        [topImg setImage:CREATE_IMG(@"contact_cell_bg1")];
        [self.contentView addSubview:topImg];
        
        //bottom
        UIImageView *bottomImg = [[UIImageView alloc] initWithFrame:CGRectMake(topImg.frameX, self.contentView.frameHeight - 6, topImg.frameWidth, 6)];
        [bottomImg setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [bottomImg setImage:CREATE_IMG(@"contact_cell_bg2")];
        [self.contentView addSubview:bottomImg];
        
        _faceImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, topImg.frameBottom - middleView.frameY, 40, 40)];
        [_faceImgView.layer setMasksToBounds:YES];
        [_faceImgView.layer setCornerRadius:20];
        [middleView addSubview:_faceImgView];
        
        CGFloat timeWidth = 120;
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(_faceImgView.frameRight + 10, _faceImgView.frameY + 11, middleView.frameWidth - 10 - timeWidth - 10 - 8 - 10 - 10 - _faceImgView.frameRight, 18)];
        _nameLabel.backgroundColor=[UIColor whiteColor];
        [_nameLabel setFont:[UIFont systemFontOfSize:14]];
        [_nameLabel setTextColor:CreateColor(62, 139, 184)];
        [middleView addSubview:_nameLabel];
        
        //time
        UIImageView *timeImg = [[UIImageView alloc] initWithImage:CREATE_IMG(@"contactTime")];
        [timeImg setFrame:CGRectMake(_nameLabel.frameRight + 10, _nameLabel.frameY + 5, 8, 8)];
        [middleView addSubview:timeImg];
        
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(timeImg.frameRight, _nameLabel.frameY + 1, timeWidth + 5, 16)];
        _timeLabel.backgroundColor = [UIColor whiteColor];
        [_timeLabel setFont:[UIFont systemFontOfSize:12]];
        [_timeLabel setTextColor:[UIColor lightGrayColor]];
        [_timeLabel setTextAlignment:NSTextAlignmentRight];
        [middleView addSubview:_timeLabel];
        
        _contLabel = [[UILabel alloc] initWithFrame:CGRectMake(_faceImgView.frameX, _faceImgView.frameBottom + 5, middleView.frameWidth - 20, 0)];
        _contLabel.backgroundColor = [UIColor clearColor];
        [_contLabel setFont:[UIFont systemFontOfSize:12]];
        [_contLabel setTextColor:[UIColor blackColor]];
        _contLabel.numberOfLines = 0;
        [middleView addSubview:_contLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, middleView.frameHeight - 50.5, middleView.frameWidth - 20, 0.5)];
        [lineView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [lineView setBackgroundColor:[UIColor lightGrayColor]];
        [middleView addSubview:lineView];
        
        _child_faceImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, middleView.frameHeight - 40, 30, 30)];
        [_child_faceImgView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [_child_faceImgView.layer setMasksToBounds:YES];
        [_child_faceImgView.layer setCornerRadius:15];
        [middleView addSubview:_child_faceImgView];
        
        _child_nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(_child_faceImgView.frameRight + 10, _child_faceImgView.frameY + 6, 60, 18)];
        [_child_nameLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        _child_nameLabel.backgroundColor = [UIColor whiteColor];
        [_child_nameLabel setFont:[UIFont systemFontOfSize:14]];
        [_child_nameLabel setTextColor:[UIColor blackColor]];
        [middleView addSubview:_child_nameLabel];
        
        //record
        UIImageView *recordImg = [[UIImageView alloc] initWithFrame:CGRectMake(_child_nameLabel.frameRight, _child_faceImgView.frameY + 10, 10, 10)];
        [recordImg setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [recordImg setImage:CREATE_IMG(@"contactRecord")];
        [middleView addSubview:recordImg];
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(recordImg.frameRight + 5, _child_faceImgView.frameY + 7, middleView.frameWidth - recordImg.frameRight - 15, 16)];
        [_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        [_titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [middleView addSubview:_titleLabel];
    }
    return self;
}

- (void)resetLeaveMessageData:(id)object
{
    LeaveMsgModel *model = (LeaveMsgModel *)object;
    NSString *face = model.face_school;
    if (![face hasPrefix:@"http"]) {
        face = [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
    }
    [_faceImgView setImageWithURL:[NSURL URLWithString:face] placeholderImage:CREATE_IMG(@"s21@2x")];
    [_nameLabel setText:[NSString stringWithFormat:@"%@%@",model.student_name,model.relation]];
    
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:model.create_time.doubleValue];
    [_timeLabel setText:[NSString stringByDate:@"yyyy/MM/dd HH:mm:ss" Date:updateDate]];

    [_contLabel setFrameHeight:model.content_hei];
    [_contLabel setText:model.content ?: @""];
    
    [_child_faceImgView setImageWithURL:[NSURL URLWithString:face] placeholderImage:CREATE_IMG(@"s21@2x")];
    [_child_nameLabel setText:model.student_name];
    [_titleLabel setText:model.title];
}

@end
