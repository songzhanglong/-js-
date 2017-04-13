//
//  MyCalendarView.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MyCalendarView2.h"
#import "NSDate+Calendar.h"
#import "CalendarItem2.h"
#import "StudentModel.h"

@interface MyCalendarView2 ()

@end

@implementation MyCalendarView2
{
    NSInteger _nFirstIndex;
    UILabel *_titleLab;
    UIImageView *_topView,*_downView;
}

- (void)dealloc
{
    NSLog(@"MyCalendarView dealloc");
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selectorForSwipeLeftGR:)];
        left.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:left];
        UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selectorForSwipeRightGR:)];
        right.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:right];
        
        CGFloat screenWei = [UIScreen mainScreen].bounds.size.width;
        //title
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWei, 50)];
        [titleView setBackgroundColor:[UIColor colorWithRed:235.0 / 255 green:73.0 / 255 blue:65.0 / 255 alpha:1.0]];
        [self addSubview:titleView];
        
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake((screenWei - 200) / 2, 13, 200, 24)];
        [_titleLab setTextAlignment:1];
        [_titleLab setTextColor:[UIColor whiteColor]];
        [_titleLab setBackgroundColor:[UIColor clearColor]];
        [_titleLab setFont:[UIFont systemFontOfSize:20]];
        [titleView addSubview:_titleLab];
        
        for (NSInteger i = 0; i < 2; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTag:i + 1];
            CGFloat xOri = (i == 0) ? 20 : (screenWei - 20 - 40);
            [button setFrame:CGRectMake(xOri, 10, 40, 30)];
            [button setBackgroundColor:[UIColor clearColor]];
            [button addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
            UIImage *backImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(i == 0) ? @"backL@2x" : @"backR@2x" ofType:@"png"]];
            [button setImage:backImg forState:UIControlStateNormal];
            [titleView addSubview:button];
        }
        
        CGFloat margin = floor((screenWei - 47 * 7) / 8);
        _topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, screenWei, 40)];
        [_topView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_topView];
        
        //back
        UIView *subBac = [[UIView alloc] initWithFrame:CGRectMake(margin + 5, 11, screenWei - margin * 2 - 10, 18)];
        [subBac setBackgroundColor:[UIColor orangeColor]];
        subBac.layer.cornerRadius = 9;
        subBac.layer.masksToBounds = YES;
        [_topView addSubview:subBac];
        
        //label
        NSArray *array = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
        CGFloat wei = 47;
        for (NSInteger i = 0; i < 7; i++) {
            NSInteger col = i % 7;
            UILabel *weekLab = [[UILabel alloc] initWithFrame:CGRectMake(margin + (margin + wei) * col, 11, wei, 18)];
            [weekLab setFont:[UIFont systemFontOfSize:12]];
            [weekLab setTextAlignment:1];
            [weekLab setTextColor:[UIColor whiteColor]];
            [weekLab setBackgroundColor:[UIColor clearColor]];
            [weekLab setText:array[i]];
            [_topView addSubview:weekLab];
        }
    }
    return self;
}

- (void)setDateArr:(NSArray *)dateArr
{
    if (_dateArr == dateArr) {
        return;
    }
    
    _dateArr = dateArr;
    NSUInteger numDays = [_curDate numberOfDaysInMonth]; //当月的天数
    CGFloat numOfRows = ((numDays + _nFirstIndex - 1 - 1) / 7) + 1;
    NSInteger numOfCount = numOfRows * 7;    //向上取整
    for (NSInteger i = 0; i < numOfCount; i++) {
        
        CalendarItem2 *item = (CalendarItem2 *)[_downView viewWithTag:i+ 1];
        if (!item) {
            continue;
        }

        NSString *curYear = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(long)item.year,(long)item.month,(long)item.day];
        NSString *str = @"kq11";
        for (BabyAttence *attence in _dateArr)
        {
            if ([attence.date isEqualToString:curYear]) {
                if ([attence.type isEqualToString:@"1"]) {
                    str = @"kq21";
                    item.tipImg.hidden=NO;
                    item.tipReason.hidden=NO;
                    item.tipReason.text=@"病假";
                }
                else if ([attence.type isEqualToString:@"2"])
                {
                    str = @"kq21";
                    item.tipImg.hidden=NO;
                    item.tipReason.hidden=NO;
                    item.tipReason.text=@"事假";
                }
                break;
            }
        }
        [item.tipImage setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:str ofType:@"png"]]];
    }
}

- (void)changeMonth:(id)sender
{
    switch ([sender tag] - 1) {
        case 0:
        {
            NSDate *preDate = [_curDate associateDayOfThePreviousMonth];
            _curDate = preDate;
            [self scrollToViewByLeft:NO Date:preDate];
        }
            break;
        case 1:
        {
            NSDate *nextDate = [_curDate associateDayOfTheFollowingMonth];
            _curDate = nextDate;
            [self scrollToViewByLeft:YES Date:nextDate];
        }
            break;
        default:
            break;
    }
}

- (UIImageView *)createSubViewByDate:(NSDate *)date
{
    NSDate *todayDate = [NSDate date];
    NSDate *firstDate = [date firstDayOfTheMonth];   //当月的第一天
    NSUInteger weekDay = [firstDate weekday];   //对应的星期,1开始
    NSDate *nextDate = nil;
    if (weekDay == 1) {
        nextDate = firstDate;
    }
    else
    {
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.day = 1 - weekDay;
        nextDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:firstDate options:0];
    }
    
    _nFirstIndex = weekDay;
    NSUInteger numDays = [date numberOfDaysInMonth]; //当月的天数
    CGFloat screenWei = [UIScreen mainScreen].bounds.size.width;
    CGFloat wei = 47,hei = 50;
    CGFloat margin = floor((screenWei - wei * 7) / 8);
    
    CGFloat numOfRows = ((numDays + weekDay - 1 - 1) / 7) + 1;
    CGFloat downHei = numOfRows * (hei + 5) + 5;
    
    UIImageView *tmpView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _topView.frame.origin.y + _topView.frame.size.height, screenWei, downHei)];
    tmpView.userInteractionEnabled = YES;
    [self addSubview:tmpView];
    
    NSInteger numOfCount = numOfRows * 7;    //向上取整
    for (NSInteger i = 0; i < numOfCount; i++) {
        NSInteger row = i / 7;
        NSInteger col = i % 7;
        CGRect tmpRect = CGRectMake(margin + (margin + wei) * col, 5 + (hei + 5) * row, wei, hei);
        CalendarItem2 *item = [[CalendarItem2 alloc] initWithFrame:tmpRect];
        [item setTag:i + 1];
        [item setItemDate:nextDate];
        //今天
        if ([nextDate sameDayWithDate:todayDate]) {
            item.backImage.hidden = NO;
        }
        else
        {
            item.backImage.hidden = YES;
        }
        
        if ((i < weekDay - 1) || (i >= weekDay + numDays - 1)) {
            item.gregorianLab.textColor = [UIColor darkGrayColor];
            item.tipImage.hidden = YES;
        }
        else
        {
            item.gregorianLab.textColor = [UIColor blackColor];
            if ((col == 0 || col == 6) || [nextDate compare:todayDate] == NSOrderedDescending) {
                item.tipImage.hidden = YES;
            }
            else
            {
                item.tipImage.hidden = NO;
                NSString *curYear = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(long)item.year,(long)item.month,(long)item.day];
                NSString *str = @"kq11";
                for (BabyAttence *attence in _dateArr)
                {
                    if ([attence.date isEqualToString:curYear]) {
                        if ([attence.type isEqualToString:@"1"]) {
                            //病假
                            str = @"kq21";
                            item.tipImg.hidden = NO;
                            item.tipImage.hidden = NO;
                            item.tipReason.text = @"病假";
                        }
                        else if ([attence.type isEqualToString:@"2"])
                        {
                            //事假
                            str = @"kq21";
                            item.tipImg.hidden = NO;
                            item.tipReason.hidden = NO;
                            item.tipReason.text = @"事假";
                        }
                        break;
                    }
                }
                [item.tipImage setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:str ofType:@"png"]]];
            }
        }

        [tmpView addSubview:item];
        nextDate = [nextDate followingDay];
    }
    
    return tmpView;
}

- (void)resetYMD
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateFormat:@"yyyy"];
    _year = [[formatter stringFromDate:_curDate] integerValue];
    [formatter setDateFormat:@"MM"];
    _month = [[formatter stringFromDate:_curDate] integerValue];
    [formatter setDateFormat:@"dd"];
    _day = [[formatter stringFromDate:_curDate] integerValue];
    [_titleLab setText:[NSString stringWithFormat:@"%02ld月%04ld",(long)_month,(long)_year]];
}

- (void)setCurDate:(NSDate *)curDate
{
    if ([_curDate isEqual:curDate]) {
        return;
    }
    
    _curDate = curDate;
    [self resetYMD];
    
    [_downView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _downView = [self createSubViewByDate:curDate];
    self.frame = CGRectMake(0, 0, _downView.frame.size.width, _downView.frame.size.height + _downView.frame.origin.y);
}

#pragma mark - privite
- (void)scrollToViewByLeft:(BOOL)left Date:(NSDate *)date
{
    [self resetYMD];
    UIImageView *imageView = [self createSubViewByDate:date];
    CGRect newRect = imageView.frame;
    CGFloat xOri = left ? (newRect.origin.x + newRect.size.width) : (newRect.origin.x - newRect.size.width);
    [imageView setFrame:CGRectMake(xOri, newRect.origin.y, newRect.size.width, newRect.size.height)];
    CGRect downRec = _downView.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [imageView setFrame:newRect];
        CGFloat selfXOri = left ? (downRec.origin.x - downRec.size.width) : (downRec.origin.x + downRec.size.width);
        [_downView setFrame:CGRectMake(selfXOri, downRec.origin.y, downRec.size.width, downRec.size.height)];
        [self setFrame:CGRectMake(0, 0, newRect.size.width, newRect.size.height + newRect.origin.y)];
    } completion:^(BOOL finished) {
        [_downView removeFromSuperview];
        _downView = imageView;
        
        if (_delegate && [_delegate respondsToSelector:@selector(changeMonth:)]) {
            [_delegate changeMonth:self];
        }
    }];
}

- (void)changeToToday
{
    NSDate *today = [NSDate date];
    if ((today.year == _year) && (today.month == _month)) {
        return;
    }
    
    if ([today compare:_curDate] == NSOrderedAscending) {
        _curDate = today;
        [self scrollToViewByLeft:NO Date:today];
    }
    else
    {
        _curDate = today;
        [self scrollToViewByLeft:YES Date:today];
    }
    
}

#pragma mark - Class Extensions
- (void)selectorForSwipeLeftGR:(UISwipeGestureRecognizer *)swipeLeftGR
{
    NSDate *preDate = [_curDate associateDayOfTheFollowingMonth];
    _curDate = preDate;
    [self scrollToViewByLeft:YES Date:preDate];
}

- (void)selectorForSwipeRightGR:(UISwipeGestureRecognizer *)swipeRightGR
{
    NSDate *nextDate = [_curDate associateDayOfThePreviousMonth];
    _curDate = nextDate;
    [self scrollToViewByLeft:NO Date:nextDate];
}

@end
