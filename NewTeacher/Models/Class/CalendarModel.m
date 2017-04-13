//
//  CalendarModel.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/24.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "CalendarModel.h"

@implementation Record

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation MessageModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation PhotoItem

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation CalendarModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
