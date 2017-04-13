//
//  ClassActivityModel.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ClassActivityModel.h"

@implementation ClassActivityItem
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation ClassActivityModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
- (void)calculateType
{
    if (_nCurType <= kZeroStyle) {
        NSInteger count = _photo.count;
        if (count >= 5) {
            _nCurType = kFiveStyle;
        }
        else
        {
            _nCurType = (kShowStyle)count;
        }
    }
}

@end
