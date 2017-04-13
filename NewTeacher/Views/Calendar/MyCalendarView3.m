//
//  MyCalendarView.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MyCalendarView3.h"
#import "NSDate+Calendar.h"
#import "CalendarItem3.h"
#import "Toast+UIView.h"

@interface MyCalendarView3 ()<CalendarItem3Delegate>

@end

@implementation MyCalendarView3
{
    NSInteger _nFirstIndex;
    UIImageView *_topView,*_downView;
    NSMutableArray *indexArray;
    NSMutableArray *selectArray;
    NSMutableArray *allWeekDate;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selectorForSwipeLeftGR:)];
        //left.direction = UISwipeGestureRecognizerDirectionLeft;
        //[self addGestureRecognizer:left];
        //UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selectorForSwipeRightGR:)];
        //right.direction = UISwipeGestureRecognizerDirectionRight;
        //[self addGestureRecognizer:right];
        
        CGFloat screenWei = [UIScreen mainScreen].bounds.size.width;
        CGFloat margin = floor((screenWei - 41 * 7) / 8);
        _topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWei, 40)];
        [_topView setBackgroundColor:[UIColor colorWithRed:235.0 / 255 green:73.0 / 255 blue:65.0 / 255 alpha:1.0]];
        [self addSubview:_topView];
        
        //label
        NSArray *array = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
        CGFloat wei = 41;
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
        
        indexArray = [NSMutableArray array];
        selectArray = [NSMutableArray array];
        allWeekDate = [NSMutableArray array];
    }
    return self;
}
- (UIImageView *)createSubViewByDate:(NSDate *)date
{
    NSDate *todayDate = _curDate;
    /*
     NSTimeZone *zone = [NSTimeZone systemTimeZone];
     NSInteger interval = [zone secondsFromGMTForDate:todayDate];
     todayDate = [todayDate  dateByAddingTimeInterval: interval];
     */
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
    CGFloat wei = 41,hei = 35;
    CGFloat margin = (screenWei - wei * 7) / 8;
    
    CGFloat numOfRows = ((numDays + weekDay - 1 - 1) / 7) + 1;
    CGFloat downHei = numOfRows * hei + 5;
    
    UIImageView *tmpView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _topView.frame.origin.y + _topView.frame.size.height, screenWei, downHei)];
    tmpView.userInteractionEnabled = YES;
    [self addSubview:tmpView];
    
    NSInteger numOfCount = numOfRows * 7;    //向上取整
    for (NSInteger i = 0; i < numOfCount; i++) {
        NSInteger row = i / 7;
        NSInteger col = i % 7;
        CGRect tmpRect = CGRectMake(margin + (margin + wei) * col, 5 + hei * row, wei, hei);
        CalendarItem3 *item = [[CalendarItem3 alloc] initWithFrame:tmpRect];
        [item setTag:i + 1];
        [item setDelegate:self];
        [item setItemDate:nextDate];
        //今天
        if ([nextDate sameDayWithDate:todayDate]) {
            item.backImage.hidden = NO;
        }
        else
        {
            item.backImage.hidden = YES;
        }
        
        if ([nextDate sameDayWithDate:_curDate]) {
            [item.layer setBorderColor:[UIColor redColor].CGColor];
        }
        else
        {
            [item.layer setBorderColor:[UIColor clearColor].CGColor];
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
            }
        }
        
        [tmpView addSubview:item];
        nextDate = [nextDate followingDay];
    }
    
    return tmpView;
}

- (UIImageView *)createSubViewByDate1:(NSDate *)date
{
    NSDate *todayDate  = _curDate;//[NSDate date];
    NSDate *firstDate  = [date firstDayOfTheMonth];   //当月的第一天
    NSUInteger weekDay = [firstDate weekday];   //对应的星期,1开始
    
    _nFirstIndex       = weekDay;
    NSUInteger numDays = [date numberOfDaysInMonth]; //当月的天数
    CGFloat screenWei = [UIScreen mainScreen].bounds.size.width;
    CGFloat margin = floor((screenWei - 41 * 7) / 8);
    CGFloat wei = 41,hei = 31;
    NSDate *nextDate = firstDate;
    CGFloat downHei = (((numDays + weekDay - 1 - 1) / 7) + 1) * (hei + 5) + 5;
    
    UIImageView *tmpView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, screenWei, downHei)];
    tmpView.userInteractionEnabled = YES;
    [self addSubview:tmpView];
    for (NSInteger i = weekDay - 1; i < numDays + weekDay - 1; i++) {
        NSDate *tmpDate = nextDate;
        NSInteger row = i / 7;
        NSInteger col = i % 7;
        CGRect tmpRect = CGRectMake(margin + (margin + wei) * col, 5 + (hei + 5) * row, wei, hei);
        CalendarItem3 *item = [[CalendarItem3 alloc] initWithFrame:tmpRect];
        if (_isCircle) {
            item.frame = CGRectMake(item.frame.origin.x, item.frame.origin.y, item.frame.size.width, item.frame.size.width);
            item.layer.masksToBounds = YES;
            item.backgroundColor  = [UIColor yellowColor];
            item.layer.cornerRadius = item.frame.size.width / 2;
            
            //item.lunarLab.hidden = YES;
            item.gregorianLab.frame = CGRectMake((item.frame.size.width - 21)/2,(item.frame.size.height - 21- 5)/2, 21, 21);
            item.gregorianLab.layer.masksToBounds = YES;
            item.gregorianLab.layer.cornerRadius = item.gregorianLab.frame.size.width/2;
            
            item.backImage.frame = CGRectMake(item.backImage.frame.origin.x, item.backImage.frame.origin.y, tmpRect.size.width, tmpRect.size.width);
            item.backImage.layer.masksToBounds = YES;
            item.backImage.layer.cornerRadius = item.backImage.frame.size.width / 2;
            item.backImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"sp" ofType:@"png"]];
        }
        item.delegate = self;
        [item setTag:i + 1];
        [item setItemDate:tmpDate];
        
        //左右两边，字体灰色
        if (col == 0 || col == 6) {
            item.gregorianLab.textColor = [UIColor lightGrayColor];
        }
        //今天
        if ([tmpDate sameDayWithDate:todayDate]) {
            item.backImage.hidden = NO;
        }
        else
        {
            item.backImage.hidden = YES;
        }
        
        //选中日期
        if ([tmpDate sameDayWithDate:_curDate]) {
            //[item setBackgroundColor:[UIColor colorWithRed:235.0 / 255 green:73.0 / 255 blue:65.0 / 255 alpha:1.0]];
            item.gregorianLab.textColor = [UIColor colorWithRed:235.0 / 255 green:73.0 / 255 blue:65.0 / 255 alpha:1.0];
            //item.lunarLab.textColor = [UIColor whiteColor];
        }
        else
        {
            [item setBackgroundColor:[UIColor whiteColor]];
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
}

- (void)setCurDate:(NSDate *)curDate
{
    if ([_curDate isEqual:curDate]) {
        return;
    }
    _indexDate = curDate;
    _curDate = curDate;
    [self resetYMD];
    
    [_downView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _downView = [self createSubViewByDate:curDate];
    self.frame = CGRectMake(0, 0, _downView.frame.size.width, _downView.frame.size.height + _topView.frame.size.height);
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
        [self setFrame:CGRectMake(0, 0, newRect.size.width, newRect.size.height + 40)];
    } completion:^(BOOL finished) {
        [_downView removeFromSuperview];
        _downView = imageView;
        
        if (_delegate && [_delegate respondsToSelector:@selector(changeMonth:)]) {
            [_delegate changeMonth:self];
        }
    }];
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
    /*
     [self resetYMD];
     UIImageView *imageView = [self createSubViewByDate:nextDate];
     CGRect newRect = imageView.frame;
     [imageView setFrame:CGRectMake(newRect.origin.x - newRect.size.width, newRect.origin.y, newRect.size.width, newRect.size.height)];
     CGRect downRec = _downView.frame;
     [UIView animateWithDuration:0.35 animations:^{
     [imageView setFrame:newRect];
     [_downView setFrame:CGRectMake(downRec.origin.x + downRec.size.width, downRec.origin.y, downRec.size.width, downRec.size.height)];
     [self setFrame:CGRectMake(0, 0, newRect.size.width, newRect.size.height + 40)];
     } completion:^(BOOL finished) {
     [_downView removeFromSuperview];
     _downView = imageView;
     }];
     
     if (_delegate && [_delegate respondsToSelector:@selector(changeMonth:)]) {
     [_delegate changeMonth:self];
     }
     */
}

#pragma mark - CalendarItemDelegate
- (void)clickCalendarItem:(CalendarItem3 *)item
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateFormat:@"dd"];
    //NSUInteger days = [[formatter stringFromDate:[_indexDate firstDayOfTheWeek]] integerValue];
    if ([allWeekDate count] > 0) {
        [allWeekDate removeAllObjects];
    }
    NSDate *tempDate = [_indexDate firstDayOfTheWeek];
    for (int i = 0; i < 7; i++) {
        NSUInteger tempdays = [[formatter stringFromDate:tempDate] integerValue];
        [allWeekDate addObject:[NSString stringWithFormat:@"%lu",(unsigned long)tempdays]];
        NSDate *nextData = [tempDate followingDay];
        tempDate = nextData;
    }
    if ([selectArray count] > 0) {
        NSUInteger currdays = [[formatter stringFromDate:_indexDate] integerValue];
        for (int i = 0; i < [selectArray count]; i++) {
            int tag = (int)[selectArray[i] integerValue];
            if (tag == item.tag) {
                CalendarItem3 *preItem = (CalendarItem3 *)[_downView viewWithTag:item.tag];
                NSInteger col = (item.tag - 1) % 7;
                BOOL side = (col == 0 || col == 6);
                if (currdays != preItem.day && currdays != item.day) {
                    preItem.gregorianLab.textColor = side ? [UIColor lightGrayColor] : [UIColor blackColor];
                    preItem.backImage.image = nil;
                }
                [preItem setBackgroundColor:[UIColor whiteColor]];
                [selectArray removeObjectAtIndex:i];
                [indexArray removeObjectAtIndex:i];
                return;
            }
        }
    }
    //if (item.tag != _day + _nFirstIndex - 1) {
//        CalendarItem3 *preItem = (CalendarItem3 *)[_downView viewWithTag:_day + _nFirstIndex - 1];
//        NSInteger col = (_day + _nFirstIndex - 1 - 1) % 7;
//        BOOL side = (col == 0 || col == 6);
//        if (days != preItem.day && days != item.day) {
//            preItem.gregorianLab.textColor = side ? [UIColor lightGrayColor] : [UIColor blackColor];
//            preItem.backImage.image = nil;
//        }
//        preItem.lunarLab.textColor = [UIColor lightGrayColor];
//        [preItem setBackgroundColor:[UIColor whiteColor]];
    if ([allWeekDate indexOfObject:[NSString stringWithFormat:@"%lu",(unsigned long)item.day]] != NSNotFound) {
        if (item.day != [[formatter stringFromDate:_indexDate] integerValue]) {
            [item setBackgroundColor:[UIColor colorWithRed:235.0 / 255 green:73.0 / 255 blue:65.0 / 255 alpha:1.0]];
            item.gregorianLab.textColor = [UIColor whiteColor];
            
            //if (_isCircle) {
            //preItem.gregorianLab.textColor = side ? [UIColor lightGrayColor] : [UIColor blackColor];
            //preItem.lunarLab.textColor = [UIColor lightGrayColor];
            //[preItem setBackgroundColor:[UIColor whiteColor]];
            //preItem.backImage.hidden = YES;
            [selectArray addObject:[NSString stringWithFormat:@"%ld",(long)item.tag]];
            
            item.gregorianLab.textColor = [UIColor whiteColor];
            item.backgroundColor = [UIColor whiteColor];
            item.backImage.layer.masksToBounds = YES;
            item.backImage.layer.cornerRadius = item.backImage.frame.size.width / 2;
            item.backImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"sp3" ofType:@"png"]];
            item.backImage.hidden = NO;
            //}
            //item.lunarLab.textColor = [UIColor whiteColor];
            _day = item.day;
            _curDate = item.itemDate;
            
            NSString *currStr = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(long)item.year,(long)item.month,(long)item.day];
            [indexArray addObject:currStr];
            
            if (_delegate && [_delegate respondsToSelector:@selector(changeDay:SelectData:)]) {
                [_delegate changeDay:self SelectData:indexArray];
            }
        }
    }else{
        [self makeToast:@"只能复制当前周以后的日期！" duration:1.0 position:@"center"];
    }
}

- (void)changeToToday
{
    NSDate *today = [NSDate date];
    if ((today.year == _year) && (today.month == _month)) {
        if (today.day != _day) {
            CalendarItem3 *preItem = (CalendarItem3 *)[_downView viewWithTag:today.day + _nFirstIndex - 1];
            [self clickCalendarItem:preItem];
        }
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

@end
