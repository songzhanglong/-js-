//
//  LeaveMsgModel.m
//  NewTeacher
//
//  Created by zhangxs on 16/5/4.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "LeaveMsgModel.h"

@implementation LeaveMsgModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (void)caculateContentHei
{
    if (_content.length <= 0) {
        _content_hei = 0;
        return;
    }
    CGSize lastSize = CGSizeZero;
    UIFont *font = [UIFont systemFontOfSize:12];
    NSDictionary *attribute = @{NSFontAttributeName: font};
    lastSize = [_content boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 20 - 20, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    _content_hei = lastSize.height;
}

@end
