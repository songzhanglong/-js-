//
//  TermPrintRecord.m
//  NewTeacher
//
//  Created by szl on 16/5/11.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "TermPrintRecord.h"

@implementation OrderStatus
+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

- (void)calculateNamesHei
{
    if (_student_names.length <= 0) {
        _namesHei = 0;
        return;
    }
    
    //NSString *names = [_student_names stringByReplacingOccurrencesOfString:@"," withString:@" "];
    NSMutableArray *tempArr = [NSMutableArray array];
    NSArray *names = [_student_names componentsSeparatedByString:@","];
    NSArray *nums = [_grow_nums componentsSeparatedByString:@","];
    for (int i = 0; i < [names count]; i++) {
        NSString *str1 = [names objectAtIndex:i];
        NSString *str2 = [nums objectAtIndex:i];
        if ([str2 integerValue] > 1) {
            str2 = [NSString stringWithFormat:@"[×%@]",str2];
            str1 = [str1 stringByAppendingString:str2];
        }
        [tempArr addObject:str1];
    }
    NSString *tempString = [tempArr componentsJoinedByString:@","];
    
    UIFont *font = [UIFont systemFontOfSize:14];
    CGFloat hei = 18;
    CGSize lastSize = CGSizeZero;
    CGSize lastSize1 = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: font};
    
    lastSize1 = [[NSString stringWithFormat:@"%@：",_status_name] boundingRectWithSize:CGSizeMake(1000, hei) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    lastSize = [tempString boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 20 - 20 - lastSize1.width, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    _namesHei = lastSize.height;
    _statusWei = lastSize1.width;
}

@end

@implementation TermPrintRecord

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (void)calculateNamesHei
{
    if (_student_names.length <= 0) {
        _namesHei = 0;
        return;
    }
    
    NSString *names = [_student_names stringByReplacingOccurrencesOfString:@"," withString:@" "];
    
    UIFont *font = [UIFont systemFontOfSize:14];
    CGFloat wei = SCREEN_WIDTH - 20 - 20 - 45;
    CGSize lastSize = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: font};
    lastSize = [names boundingRectWithSize:CGSizeMake(wei, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    _namesHei = lastSize.height;
}

@end
