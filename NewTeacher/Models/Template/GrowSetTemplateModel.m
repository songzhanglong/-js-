//
//  GrowSetTemplateModel.m
//  NewTeacher
//
//  Created by zhangxs on 16/1/26.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "GrowSetTemplateModel.h"

@implementation TemplateItem

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

- (void)calculateDescRects
{
    CGSize lastSize = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    lastSize = [_template_desc boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 80, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    _contSize = CGSizeMake(lastSize.width, MAX(lastSize.height, 20));
}

@end

@implementation GrowSetTemplateModel

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

- (void)calculateDescRects
{
    CGSize lastSize = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    lastSize = [_album_desc boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 80, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    _contSize = CGSizeMake(lastSize.width, MAX(lastSize.height, 20));
}

@end
