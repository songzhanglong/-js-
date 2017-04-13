//
//  StickyNoteModel.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/12.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "StickyNoteModel.h"
#import "DJTGlobalDefineKit.h"

@implementation StickyNoteModel

- (void)calculateContentHeight
{
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UIFont *font = [UIFont systemFontOfSize:16];
    CGSize lastSize = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: font};
    lastSize = [_content boundingRectWithSize:CGSizeMake(winSize.width - 60, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    _contHei = MAX(lastSize.height, 20);
}

@end
