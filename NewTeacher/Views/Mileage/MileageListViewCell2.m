//
//  MileageListViewCell2.m
//  NewTeacher
//
//  Created by szl on 15/12/9.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MileageListViewCell2.h"
#import "NSString+Common.h"
#import "MileageModel.h"

@implementation MileageListViewCell2
{
    UILabel *_beginLab,*_endLab;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        CGFloat wei = (winSize.width - 30) / 3;
        
        _fromLabel.hidden = YES;
        _topLeft.hidden = YES;
        [_tipImgView removeFromSuperview];
        _tipImgView = nil;
        
        UIView * boundView = [[UIView alloc] initWithFrame:CGRectMake(12, 6, 2, 24)];
        [boundView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:boundView];
        
        _beginLab = [[UILabel alloc] initWithFrame:CGRectMake(16, 4, wei - 4, 14)];
        [_beginLab setTextColor:[UIColor whiteColor]];
        [_beginLab setFont:[UIFont systemFontOfSize:10]];
        [_beginLab setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_beginLab];
        
        _endLab = [[UILabel alloc] initWithFrame:CGRectMake(_beginLab.frameX, _beginLab.frameBottom, _beginLab.frameWidth, _beginLab.frameHeight)];
        [_endLab setTextColor:_beginLab.textColor];
        [_endLab setFont:_beginLab.font];
        [_endLab setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_endLab];
    }
    
    return self;
}

- (void)resetDataSource:(id)object
{
    [super resetDataSource:object];
    
    _editBtn.hidden = YES;
    
    MileageModel *mileMod = (MileageModel *)object;
    NSDate *beginDate = [NSDate dateWithTimeIntervalSince1970:mileMod.ctime.doubleValue];
    NSString *beginStr = [NSString stringByDate:@"yyyy-MM-dd" Date:beginDate];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:mileMod.etime.doubleValue];
    NSString *endStr = [NSString stringByDate:@"yyyy-MM-dd" Date:endDate];
    [_beginLab setText:[beginStr stringByAppendingString:@" 创建"]];
    [_endLab setText:[endStr stringByAppendingString:@" 更新"]];
}

@end
