//
//  CalendarNoticeCell.m
//  NewTeacher
//
//  Created by szl on 15/11/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "CalendarNoticeCell.h"
#import "CalendarModel.h"

@implementation CalendarNoticeCell
{
    UILabel *_contentLab,*_tipLab;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //left
        UIImageView *leftImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 2, 72)];
        [leftImg setBackgroundColor:CreateColor(35.0, 202.0, 255.0)];
        [self.contentView addSubview:leftImg];
        
        //line
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, 2, 72)];
        [line setBackgroundColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:line];
        
        //tip
        UIImageView *tipImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 21, 30, 30)];
        [tipImg setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rl6" ofType:@"png"]]];
        [self.contentView addSubview:tipImg];
        
        CGFloat winWei = [UIScreen mainScreen].bounds.size.width;
        //back
        UIImageView *backImg = [[UIImageView alloc] initWithFrame:CGRectMake(55, 12, winWei - 65, 48)];
        [backImg setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rl8" ofType:@"png"]]];
        [self.contentView addSubview:backImg];
        
        //label
        _contentLab = [[UILabel alloc] initWithFrame:CGRectMake(65, 15, winWei - 105, 24)];
        _contentLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [_contentLab setFont:[UIFont systemFontOfSize:15]];
        [_contentLab setBackgroundColor:[UIColor clearColor]];
        [_contentLab setTextColor:CreateColor(35.0, 202.0, 255.0)];
        [self.contentView addSubview:_contentLab];
        
        //多少人看过园所通知
        _tipLab = [[UILabel alloc] initWithFrame:CGRectMake(65, 35, winWei - 105, 24)];
        _tipLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [_tipLab setFont:[UIFont systemFontOfSize:12]];
        [_tipLab setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_tipLab];
        
        //>箭头
        UIImageView *indictor = [[UIImageView alloc] initWithFrame:CGRectMake(backImg.frame.origin.x + backImg.frame.size.width - 30, backImg.frame.origin.y + (backImg.frame.size.height - 20) / 2, 20, 20)];
        [indictor setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rl9" ofType:@"png"]]];
        [self.contentView addSubview:indictor];
    }
    return self;
}

- (void)resetDataSource:(id)object
{
    MessageModel *message = (MessageModel *)object;
    [_contentLab setText:[NSString stringWithFormat:@"园所通知:%@ ",message.content ?: @"本周未发布园所通知"]];
    [_tipLab setText:[message.read_count isEqualToString:@"0"] ? @"暂时没有人看过此通知" : [NSString stringWithFormat:@"%@人看过",message.read_count]];
}

@end
