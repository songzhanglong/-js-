//
//  MainListModel.m
//  NewTeacher
//
//  Created by mac on 15/7/30.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MainListModel.h"

@implementation MainListStudentItem

- (void)calculeteConSize:(CGFloat)maxWei Font:(UIFont *)font
{
    _nameSize = CGSizeZero,_contentSize = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: font};
    _nameSize = [_name boundingRectWithSize:CGSizeMake(1000, 20) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    //_contentSize = [_content boundingRectWithSize:CGSizeMake(maxWei - _nameSize.width, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
}


@end

@implementation MainListTeacherItem

@end

@implementation MainListModel

@end
