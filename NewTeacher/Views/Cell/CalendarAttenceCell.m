//
//  CalendarAttenceCell.m
//  NewTeacher
//
//  Created by szl on 15/11/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "CalendarAttenceCell.h"
#import "CalendarModel.h"
#import "DJTDeviceAttence.h"
#import "DJTGlobalManager.h"

@implementation CalendarAttenceCell
{
    UILabel *_contentLab;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //left
        UIImageView *leftImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 2, 72)];
        [leftImg setBackgroundColor:CreateColor(235.0, 73.0, 65.0)];
        [self.contentView addSubview:leftImg];
        
        //line
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, 2, 72)];
        [line setBackgroundColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:line];
        
        //tip
        UIImageView *tipImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 21, 30, 30)];
        [tipImg setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rl4" ofType:@"png"]]];
        [self.contentView addSubview:tipImg];
        
        CGFloat winWei = [UIScreen mainScreen].bounds.size.width;
        //back
        UIImageView *backImg = [[UIImageView alloc] initWithFrame:CGRectMake(55, 12, winWei - 65, 48)];
        [backImg setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rl8" ofType:@"png"]]];
        [self.contentView addSubview:backImg];
        
        //label 考勤
        _contentLab = [[UILabel alloc] initWithFrame:CGRectMake(65, 24, winWei - 105, 24)];
        _contentLab.lineBreakMode=NSLineBreakByTruncatingTail;
        [_contentLab setFont:[UIFont systemFontOfSize:15]];
        [_contentLab setBackgroundColor:[UIColor clearColor]];
        [_contentLab setTextColor:CreateColor(235.0, 73.0, 65.0)];
        [self.contentView addSubview:_contentLab];
        
        //>箭头
        UIImageView *indictor = [[UIImageView alloc] initWithFrame:CGRectMake(backImg.frame.origin.x + backImg.frame.size.width - 30, backImg.frame.origin.y + (backImg.frame.size.height - 20) / 2, 20, 20)];
        [indictor setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rl9" ofType:@"png"]]];
        [self.contentView addSubview:indictor];
        
    }
    return self;
}

- (void)resetDataSource:(id)object
{
    
    if ([object isKindOfClass:[NSArray class]]) {
        NSInteger healthyCount = 0,thingCount = 0,leaveCount = 0;
        for (id record in (NSArray *)object) {
            NSInteger state = [[record valueForKey:@"state"] integerValue];
            //1:病假；2:事假
            if (state == 7) {
                healthyCount += 1;
            }
            else if (state == 8){
                thingCount += 1;
            }
            else if (state == 6){
                leaveCount += 1;
            }
        }
        NSString *dailyStete = nil;
        if (healthyCount == 0 && thingCount == 0 && leaveCount == 0) {
            dailyStete = ([object count] == 0) ? @"今日未考勤" : @"今日全勤";
        }else{
            NSMutableArray *array = [NSMutableArray array];
            if (thingCount > 0) {
                [array addObject:[NSString stringWithFormat:@"事假%ld人",(long)thingCount]];
            }
            if (healthyCount > 0) {
                [array addObject:[NSString stringWithFormat:@"病假%ld人",(long)healthyCount]];
            }
            if (leaveCount > 0) {
                [array addObject:[NSString stringWithFormat:@"缺勤%ld人",(long)leaveCount]];
            }
            dailyStete = [array componentsJoinedByString:@","];
        }
        [_contentLab setText:dailyStete];
    }
    else{
        [_contentLab setText:@"今日考勤查看"];
    }
}

@end
