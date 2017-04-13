//
//  GrowNewExtendCell.m
//  NewTeacher
//
//  Created by szl on 16/5/10.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "GrowNewExtendCell.h"

@implementation GrowNewExtendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [_makeBut removeFromSuperview];
        [_backView setFrame:self.contentView.bounds];
        [_backView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        _backView.layer.cornerRadius = 0;
    }
    return self;
}

@end
