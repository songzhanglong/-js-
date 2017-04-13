//
//  CalendarItem.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "CalendarItem.h"

struct SolarTerm
{
    __unsafe_unretained NSString *solarName;
    NSInteger solarDate;
};

NSInteger LunarCalendarInfo[] = { 0x04bd8,0x04ae0,0x0a570,0x054d5,0x0d260,0x0d950,0x16554,0x056a0,0x09ad0,0x055d2,
    0x04ae0,0x0a5b6,0x0a4d0,0x0d250,0x1d255,0x0b540,0x0d6a0,0x0ada2,0x095b0,0x14977,
    0x04970,0x0a4b0,0x0b4b5,0x06a50,0x06d40,0x1ab54,0x02b60,0x09570,0x052f2,0x04970,
    0x06566,0x0d4a0,0x0ea50,0x06e95,0x05ad0,0x02b60,0x186e3,0x092e0,0x1c8d7,0x0c950,
    0x0d4a0,0x1d8a6,0x0b550,0x056a0,0x1a5b4,0x025d0,0x092d0,0x0d2b2,0x0a950,0x0b557,
    0x06ca0,0x0b550,0x15355,0x04da0,0x0a5b0,0x14573,0x052b0,0x0a9a8,0x0e950,0x06aa0,
    0x0aea6,0x0ab50,0x04b60,0x0aae4,0x0a570,0x05260,0x0f263,0x0d950,0x05b57,0x056a0,
    0x096d0,0x04dd5,0x04ad0,0x0a4d0,0x0d4d4,0x0d250,0x0d558,0x0b540,0x0b6a0,0x195a6,
    0x095b0,0x049b0,0x0a974,0x0a4b0,0x0b27a,0x06a50,0x06d40,0x0af46,0x0ab60,0x09570,
    0x04af5,0x04970,0x064b0,0x074a3,0x0ea50,0x06b58,0x055c0,0x0ab60,0x096d5,0x092e0,
    0x0c960,0x0d954,0x0d4a0,0x0da50,0x07552,0x056a0,0x0abb7,0x025d0,0x092d0,0x0cab5,
    0x0a950,0x0b4a0,0x0baa4,0x0ad50,0x055d9,0x04ba0,0x0a5b0,0x15176,0x052b0,0x0a930,
    0x07954,0x06aa0,0x0ad50,0x05b52,0x04b60,0x0a6e6,0x0a4e0,0x0d260,0x0ea65,0x0d530,
    0x05aa0,0x076a3,0x096d0,0x04bd7,0x04ad0,0x0a4d0,0x1d0b6,0x0d250,0x0d520,0x0dd45,
    0x0b5a0,0x056d0,0x055b2,0x049b0,0x0a577,0x0a4b0,0x0aa50,0x1b255,0x06d20,0x0ada0,
    0x14b63};

@implementation CalendarItem
{
    UIImageView *_backImage,*_redCircle;
    struct SolarTerm solarTerm[2];
    NSArray *SolarTerms;
    NSArray *arrayMonth;
    NSArray *arrayDay;
    NSArray *HeavenlyStems;
    NSArray *EarthlyBranches;
    NSArray *LunarZodiac;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //back
        _backImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rl2_1" ofType:@"png"]]];
        [_backImage setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [_backImage setHidden:YES];
        [self addSubview:_backImage];
        
        //公历
        _gregorianLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, frame.size.width, 21)];
        [_gregorianLab setTextColor:[UIColor blackColor]];
        [_gregorianLab setBackgroundColor:[UIColor clearColor]];
        [_gregorianLab setTextAlignment:1];
        [_gregorianLab setFont:[UIFont systemFontOfSize:17]];
        [self addSubview:_gregorianLab];
        
        //农历
        _lunarLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 26, frame.size.width, 18)];
        [_lunarLab setFont:[UIFont systemFontOfSize:12]];
        [_lunarLab setTextAlignment:1];
        [_lunarLab setTextColor:[UIColor lightGrayColor]];
        [_lunarLab setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_lunarLab];
        
        //
        _tipImage = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - 5) / 2, 42, 5, 5)];
        _tipImage.layer.masksToBounds = YES;
        _tipImage.layer.cornerRadius = 2.5;
        _tipImage.hidden = YES;
        [_tipImage setBackgroundColor:[UIColor colorWithRed:235.0 / 255 green:73.0 / 255 blue:65.0 / 255 alpha:1.0]];
        [self addSubview:_tipImage];
        
        HeavenlyStems = [NSArray arrayWithObjects:@"甲",@"乙",@"丙",@"丁",@"戊",@"己",@"庚",@"辛",@"壬",@"癸",nil];
        EarthlyBranches = [NSArray arrayWithObjects:@"子",@"丑",@"寅",@"卯",@"辰",@"巳",@"午",@"未",@"申",@"酉",@"戌",@"亥",nil];
        LunarZodiac = [NSArray arrayWithObjects:@"鼠",@"牛",@"虎",@"兔",@"龙",@"蛇",@"马",@"羊",@"猴",@"鸡",@"狗",@"猪",nil];
        SolarTerms = [NSArray arrayWithObjects:@"立春", @"雨水", @"惊蛰", @"春分", @"清明", @"谷雨", @"立夏", @"小满", @"芒种", @"夏至", @"小暑", @"大暑", @"立秋", @"处暑", @"白露", @"秋分", @"寒露", @"霜降", @"立冬", @"小雪", @"大雪", @"冬至", @"小寒", @"大寒", nil];
        arrayMonth = [NSArray arrayWithObjects:@"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月", @"九月",  @"十月", @"冬月", @"腊月", nil];
        
        arrayDay = [NSArray arrayWithObjects:@"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十", @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十", @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十", @"三一", nil];
    }
    return self;
}


/**
 * 返回农历年的总天数
 * @param y 指定农历年份(数字)
 * @return 该农历年的总天数(数字)
 */
- (NSInteger)LunarYearDays:(NSInteger)y
{
    NSInteger i, sum = 348;
    for (i = 0x8000; i > 0x8; i >>= 1)
    {
        if ((LunarCalendarInfo[y - 1900] & i) != 0)
            sum += 1;
    }
    return (sum + [self DoubleMonthDays:y]);
}

- (NSInteger)DoubleMonth:(NSInteger)y
{
    return (LunarCalendarInfo[y - 1900] & 0xf);
}

///返回农历年闰月的天数
- (NSInteger)DoubleMonthDays:(NSInteger)y
{
    if ([self DoubleMonth:y] != 0)
        return (((LunarCalendarInfo[y - 1900] & 0x10000) != 0) ? 30 : 29);
    else
        return (0);
}

///返回农历年月份的总天数
- (NSInteger)MonthDays:(NSInteger)y :(NSInteger)m
{
    return (((LunarCalendarInfo[y - 1900] & (0x10000 >> m)) != 0) ? 30 : 29);
}

- (NSInteger)IfGregorian:(NSInteger)y :(NSInteger)m :(NSInteger)d :(NSInteger)opt
{
    if (opt == 1)
    {
        if (y > 1582 || (y == 1582 && m > 10) || (y == 1582 && m == 10 && d > 14))
            return (1);	 //Gregorian
        else
            if (y == 1582 && m == 10 && d >= 5 && d <= 14)
                return (-1);  //空
            else
                return (0);  //Julian
    }
    
    if (opt == 2)
        return (1);	 //Gregorian
    if (opt == 3)
        return (0);	 //Julian
    return (-1);
}

- (NSInteger)DayDifference:(NSInteger)y :(NSInteger)m :(NSInteger)d
{
    NSInteger ifG = [self IfGregorian:y:m:d:1];
    NSInteger monL[] = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    if (ifG == 1)
    {
        if ((y % 100 != 0 && y % 4 == 0) || (y % 400 == 0))
            monL[2] += 1;
        else
        {
            if (y % 4 == 0)
                monL[2] += 1;
        }
    }
    
    int v = 0;
    
    for (int i = 0; i <= m - 1; i++)
        v += monL[i];
    
    v += d;
    if (y == 1582)
    {
        if (ifG == 1)
            v -= 10;
        if (ifG == -1)
            v = 0;  //infinity 
    }
    return v;
}

- (double)EquivalentStandardDay:(NSInteger)y :(NSInteger)m :(NSInteger)d
{
    //Julian的等效标准天数
    double v = (y - 1) * 365 + floor((double)((y - 1) / 4)) + [self DayDifference:y:m:d] - 2;
    
    if (y > 1582)
    {//Gregorian的等效标准天数
        v += -floor((double)((y - 1) / 100)) + floor((double)((y - 1) / 400)) + 2;
    } 
    return v;
}

- (double)Term:(NSInteger)y :(NSInteger)n :(BOOL)pd
{
    //儒略日
    double juD = y * (365.2423112 - 6.4e-14 * (y - 100) * (y - 100) - 3.047e-8 * (y - 100)) + 15.218427 * n + 1721050.71301;
    
    //角度
    double tht = 3e-4 * y - 0.372781384 - 0.2617913325 * n;
    
    //年差实均数
    double yrD = (1.945 * sin(tht) - 0.01206 * sin(2 * tht)) * (1.048994 - 2.583e-5 * y);
    
    //朔差实均数
    double shuoD = -18e-4 * sin(2.313908653 * y - 0.439822951 - 3.0443 * n);
    
    double vs = (pd) ? (juD + yrD + shuoD - [self EquivalentStandardDay:y:1:0] - 1721425) : (juD - [self EquivalentStandardDay:y:1:0] - 1721425);
    return vs;
}

- (double)AntiDayDifference:(NSInteger)y :(double)x
{
    NSInteger m = 1;
    for (NSInteger j = 1; j <= 12; j++)
    {
        NSInteger mL = [self DayDifference:y:(j + 1):1] - [self DayDifference:y:j:1];
        if (x <= mL || j == 12)
        {
            m = j;
            break;
        }
        else
            x -= mL;
    }
    return 100 * m + x;
}

- (double)Tail:(double)x
{
    return x - floor(x);
}

- (void)ComputeSolarTerm
{
    for (NSInteger n = _month * 2 - 1; n <= _month * 2; n++)
    {
        double Termdays = [self Term:_year:n:YES];
        double mdays = [self AntiDayDifference:_year:floor(Termdays)];
        NSInteger hour = (NSInteger)floor((double)[self Tail:Termdays] * 24);
        NSInteger minute = (int)floor((double)([self Tail:Termdays] * 24 - hour) * 60);
        NSInteger tMonth = (int)ceil((double)n / 2);
        NSInteger tday = (NSInteger)mdays % 100;
        
        if (n >= 3)
            solarTerm[n - _month * 2 + 1].solarName = [SolarTerms objectAtIndex:(n - 3)];
        else
            solarTerm[n - _month * 2 + 1].solarName = [SolarTerms objectAtIndex:(n + 21)];
        
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setYear:_year];
        [components setMonth:tMonth];
        [components setDay:tday];
        [components setHour:hour];
        [components setMinute:minute];
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *ldate = [gregorian dateFromComponents:components];
        
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        
        solarTerm[n - _month * 2 + 1].solarDate = [[dateFormatter stringFromDate:ldate] integerValue];
    }
}

- (void)setItemDate:(NSDate *)itemDate
{
    if ([_itemDate isEqual:itemDate]) {
        return;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateFormat:@"yyyy"];
    _year = [[formatter stringFromDate:itemDate] integerValue];
    [formatter setDateFormat:@"MM"];
    _month = [[formatter stringFromDate:itemDate] integerValue];
    [formatter setDateFormat:@"dd"];
    _day = [[formatter stringFromDate:itemDate] integerValue];
    [_gregorianLab setText:[NSString stringWithFormat:@"%ld",(long)_day]];
    _itemDate = itemDate;
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *start = @"1900-01-31";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *end = [dateFormatter stringFromDate:itemDate];
        
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"yyyy-MM-dd"];
        NSDate *startDate = [f dateFromString:start];
        NSDate *endDate = [f dateFromString:end];
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:startDate toDate:endDate options:0];
        NSInteger dayCyclical = (([components day] + 30) / (86400 / (3600 * 24)))+10;
        
        NSInteger sumdays = [components day];
        
        NSInteger tempdays = 0;
        
        //计算农历年
        for (weakSelf.lunarYear = 1900; weakSelf.lunarYear < 2050 && sumdays > 0; weakSelf.lunarYear++)
        {
            tempdays = [weakSelf LunarYearDays:weakSelf.lunarYear];
            sumdays -= tempdays;
        }
        
        if (sumdays < 0)
        {
            sumdays += tempdays;
            weakSelf.lunarYear--;
        }
        
        //计算闰月
        weakSelf.doubleMonth = [weakSelf DoubleMonth:weakSelf.lunarYear];
        weakSelf.isLeap = false;
        
        //计算农历月
        for (weakSelf.lunarMonth = 1; weakSelf.lunarMonth < 13 && sumdays > 0; weakSelf.lunarMonth++)
        {
            //闰月
            if (weakSelf.doubleMonth > 0 && weakSelf.lunarMonth == (weakSelf.doubleMonth + 1) && weakSelf.isLeap == false)
            {
                --weakSelf.lunarMonth;
                weakSelf.isLeap = true;
                tempdays = [weakSelf DoubleMonthDays:weakSelf.lunarYear];
            }
            else
            {
                tempdays = [weakSelf MonthDays:weakSelf.lunarYear:weakSelf.lunarMonth];
            }
            
            //解除闰月
            if (weakSelf.isLeap == true && weakSelf.lunarMonth == (weakSelf.doubleMonth + 1))
            {
                weakSelf.isLeap = false;
            }
            sumdays -= tempdays;
        }
        
        //计算农历日
        if (sumdays == 0 && weakSelf.doubleMonth > 0 && weakSelf.lunarMonth == weakSelf.doubleMonth + 1)
        {
            if (weakSelf.isLeap)
            {
                weakSelf.isLeap = false;
            }
            else
            {
                weakSelf.isLeap = true;
                --weakSelf.lunarMonth;
            }
        }
        
        if (sumdays < 0)
        {
            sumdays += tempdays;
            --weakSelf.lunarMonth;
        }
        
        weakSelf.lunarDay = sumdays + 1;
        //计算节气
        [weakSelf ComputeSolarTerm];
        
        weakSelf.solarTermTitle = @"";
        for (int i = 0; i < 2; i++)
        {
            NSDateFormatter *currentFormatter = [[NSDateFormatter alloc] init];
            
            [currentFormatter setDateFormat:@"yyyyMMdd"];
            
            if (solarTerm[i].solarDate == [[currentFormatter stringFromDate:itemDate] intValue])
                weakSelf.solarTermTitle = solarTerm[i].solarName;
        }
        
        weakSelf.monthLunar = (NSString *)[arrayMonth objectAtIndex:(weakSelf.lunarMonth - 1)];
        weakSelf.dayLunar = (NSString *)[arrayDay objectAtIndex:(weakSelf.lunarDay - 1)];
        weakSelf.zodiacLunar = (NSString *)[LunarZodiac objectAtIndex:((weakSelf.lunarYear - 4) % 60 % 12)];
        
        weakSelf.yearHeavenlyStem = (NSString *)[HeavenlyStems objectAtIndex:((weakSelf.lunarYear - 4) % 60 % 10)];
        if ((((weakSelf.year - 1900) * 12 + weakSelf.month + 13) % 10) == 0)
            weakSelf.monthHeavenlyStem = (NSString *)[HeavenlyStems objectAtIndex:9];
        else
            weakSelf.monthHeavenlyStem = (NSString *)[HeavenlyStems objectAtIndex:(((weakSelf.year-1900) * 12 + weakSelf.month + 13) % 10 - 1)];
        
        weakSelf.dayHeavenlyStem = (NSString *)[HeavenlyStems objectAtIndex:(dayCyclical%10)];
        
        weakSelf.yearEarthlyBranch = (NSString *)[EarthlyBranches objectAtIndex:((weakSelf.lunarYear - 4) % 60 % 12)];
        if ((((weakSelf.year - 1900) * 12 + weakSelf.month + 13) % 12) == 0)
            weakSelf.monthEarthlyBranch = (NSString *)[EarthlyBranches objectAtIndex:11];
        else
            weakSelf.monthEarthlyBranch = (NSString *)[EarthlyBranches objectAtIndex:(((weakSelf.year - 1900) * 12 + weakSelf.month + 13) % 12 - 1)];
        weakSelf.dayEarthlyBranch = (NSString *)[EarthlyBranches objectAtIndex:(dayCyclical % 12)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf.lunarLab setText:weakSelf.dayLunar];
        });
    });
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickCalendarItem:)]) {
        [_delegate clickCalendarItem:self];
    }
}

@end
