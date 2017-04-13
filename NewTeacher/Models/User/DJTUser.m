//
//  DJTUser.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/23.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "DJTUser.h"

@implementation DJTButton
+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}
@end

@implementation DJTStudent
+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}
@end

@implementation DJTUser
+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

- (void)caculateClass_nameWei
{
    if ([_classname length] == 0 && [_grade_name length] == 0) {
        _class_nameWei = 0;
    }
    else{
        CGSize lastSize = CGSizeZero;
        UIFont *font = [UIFont systemFontOfSize:12];
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        CGFloat hei = 18;
        NSDictionary *attribute = @{NSFontAttributeName: font};
        lastSize = [[NSString stringWithFormat:@"%@ %@",_classname,_grade_name] boundingRectWithSize:CGSizeMake(winSize.width, hei) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        
        _class_nameWei = MIN(winSize.width - 90, lastSize.width + 10);
    }
}

@end
