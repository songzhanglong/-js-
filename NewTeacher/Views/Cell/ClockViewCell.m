//
//  ClockViewCell.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/24.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "ClockViewCell.h"

@implementation ClockViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIColor *color = [UIColor colorWithRed:104.0 / 255 green:52.0 / 255 blue:83.0 / 255 alpha:1.0];
        self.backgroundColor = color;
        self.contentView.backgroundColor = color;
        
        UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 120, 24)];
        [tipLab setTextColor:[UIColor colorWithRed:225.0 / 255 green:131.0 / 255 blue:119.0 / 255 alpha:1.0]];
        _myTipLab = tipLab;
        [tipLab setFont:[UIFont systemFontOfSize:20]];
        [tipLab setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:tipLab];
        
        //image
        UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(135, 17, 30, 30)];
        _myImageView = imageView1;
        [self.contentView addSubview:imageView1];
        
        imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 10 - 54, 14, 54, 37)];
        [imageView1 setImage:[UIImage imageNamed:@"s4.png"]];
        [self.contentView addSubview:imageView1];
    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
