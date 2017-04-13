//
//  StudentClockViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/25.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "StudentClockViewController.h"
#import "MyStudentViewController.h"
#import "MyCalendarView2.h"

@interface StudentClockViewController ()<MyCalendarView2Delegate>

@end

@implementation StudentClockViewController
{
    UIScrollView *_scrollView;
    MyCalendarView2 *_calendarView;
    UIView *_tipView;
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    self.nCurIndex = 3;
    
    CGFloat yOri = 0;
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _selectView.frame.origin.y + _selectView.frame.size.height, winSize.width, winSize.height - (_selectView.frame.origin.y + _selectView.frame.size.height) - yOri)];
    [self.view addSubview:_scrollView];
    
    MyCalendarView2 *vrgView = [[MyCalendarView2 alloc] initWithFrame:CGRectZero];
    [vrgView setCurDate:[NSDate date]];
    [vrgView setDateArr:self.myStudentModel.attence];
    _calendarView = vrgView;
    vrgView.delegate = self;
    [_scrollView addSubview:vrgView];
    
    _tipView = [[[NSBundle mainBundle]loadNibNamed:@"CalendarTipView" owner:self options:0] lastObject];
    [_tipView setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - _tipView.frame.size.width) / 2, _calendarView.frame.size.height + _calendarView.frame.origin.y, _tipView.frame.size.width, _tipView.frame.size.height)];
    [_scrollView addSubview:_tipView];
    
    CGFloat hei = MAX(_scrollView.frame.size.height, _tipView.frame.origin.y + _tipView.frame.size.height);
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, hei)];
}

#pragma mark - MyCalendarView2Delegate
- (void)changeMonth:(MyCalendarView2 *)calendar
{
    CGRect rect = _tipView.frame;
    [_tipView setFrame:CGRectMake(rect.origin.x, calendar.frame.size.height + calendar.frame.origin.y, rect.size.width, rect.size.height)];
    CGFloat hei = MAX(_scrollView.frame.size.height, _tipView.frame.origin.y + _tipView.frame.size.height);
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, hei)];
}

@end
