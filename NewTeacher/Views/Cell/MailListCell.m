//
//  MailListCell.m
//  NewTeacher
//
//  Created by mac on 15/7/29.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MailListCell.h"
#import "MainListModel.h"
#import "NSString+Common.h"
#import "DJTGlobalManager.h"

@implementation MailListCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 40, 40)];
        imgView.layer.masksToBounds = YES;
        imgView.layer.cornerRadius = 20;
        [self.contentView addSubview:imgView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, self.contentView.bounds.size.width-74.5-70, 25)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:nameLabel];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 35, self.contentView.bounds.size.width-80, 15)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textColor = [UIColor lightGrayColor];
        contentLabel.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:contentLabel];
        
        tjButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tjButton.frame = CGRectMake(self.contentView.bounds.size.width-74.5, 10, 54.5, 19.5);
        [tjButton setBackgroundImage:[UIImage imageNamed:@"tjtx4.png"] forState:UIControlStateNormal];
        [tjButton setTitle:@"推荐使用" forState:UIControlStateNormal];
        [tjButton.titleLabel setFont:[UIFont boldSystemFontOfSize:11]];
        [tjButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [tjButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.contentView addSubview:tjButton];
        
        phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        phoneButton.frame = CGRectMake(self.contentView.bounds.size.width-80, 10, 60, 25);
        [phoneButton setImage:[UIImage imageNamed:@"bh.png"] forState:UIControlStateNormal];
        phoneButton.tag = 1421;
        [phoneButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [phoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.contentView addSubview:phoneButton];
        
    }
    return self;
}
- (void)buttonAction:(id)sender
{
    MainListStudentItem *item = (MainListStudentItem *)currModel;
    if ([item.status isEqualToString:@"0"]) {
        if (_delegate && [_delegate respondsToSelector:@selector(callPhoneMainListCell:Model:)]) {
            [_delegate callPhoneMainListCell:self Model:item];
        }
    }
}
- (void)buttonPressed:(UIButton *)sender
{
    if (isTeacher) {
        if (sender.tag == 1420) {
            MainListTeacherItem *item = (MainListTeacherItem *)currModel;
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@", item.userid]]];
        }else{
           MainListTeacherItem *item = (MainListTeacherItem *)currModel;
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", item.userid]]];
        }
    }else{
        if (sender.tag == 1420) {
            MainListStudentItem *item = (MainListStudentItem *)currModel;
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@", item.userid]]];
        }else{
            MainListStudentItem *item = (MainListStudentItem *)currModel;
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", item.userid]]];
        }
    }
}
- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}
- (void)resetClassMainListData:(id)object isHidden:(BOOL)hidden isTeacher:(BOOL)teacher
{
    isTeacher = teacher;
    currModel = object;
    if (teacher) {
        MainListTeacherItem *item = (MainListTeacherItem *)object;
        
        NSString *faceUrl = item.face ?: @"";
        if (![faceUrl hasPrefix:@"http"]) {
            faceUrl = [G_IMAGE_ADDRESS stringByAppendingString:faceUrl ?: @""];
        }
        [imgView setImageWithURL:[NSURL URLWithString:faceUrl] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
        nameLabel.text = item.teacher_name;
        contentLabel.text = item.userid;
        
        tjButton.hidden = YES;
        //messagebutton.hidden = NO;
        phoneButton.hidden = NO;
    }else{
        MainListStudentItem *item = (MainListStudentItem *)object;
        
        NSString *faceUrl = item.face ?: @"";
        if (![faceUrl hasPrefix:@"http"]) {
            faceUrl = [G_IMAGE_ADDRESS stringByAppendingString:faceUrl ?: @""];
        }
        [imgView setImageWithURL:[NSURL URLWithString:faceUrl] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
        nameLabel.text = item.name;
        
        NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:[item.logintime doubleValue]];
        contentLabel.text = [item.status isEqualToString:@"1"] ? [NSString stringWithFormat:@"%@  最后登录：%@",item.userid,[NSString stringByDate:@"yyyy-MM-dd" Date:updateDate]] : [NSString stringWithFormat:@"%@  暂未使用童印",item.userid];
        if ([item.status isEqualToString:@"2"]) {
            [tjButton setBackgroundImage:[UIImage imageNamed:@"tjtx5.png"] forState:UIControlStateNormal];
            [tjButton setTitle:@"已推荐" forState:UIControlStateNormal];
        }else{
            [tjButton setBackgroundImage:[UIImage imageNamed:@"tjtx4.png"] forState:UIControlStateNormal];
            [tjButton setTitle:@"推荐使用" forState:UIControlStateNormal];
        }
        tjButton.hidden = hidden;
        //messagebutton.hidden = !hidden;
        phoneButton.hidden = !hidden;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
