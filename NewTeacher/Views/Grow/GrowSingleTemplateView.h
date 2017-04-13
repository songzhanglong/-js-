//
//  GrowSingleTemplate.h
//  NewTeacher
//
//  Created by zhangxs on 16/1/25.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrowSetTemplateModel.h"

@class GrowSingleTemplateView;
@protocol GrowSingleTemplateViewDelegate <NSObject>

- (void)editTemplate:(GrowSingleTemplateView *)growView;

@end

@interface GrowSingleTemplateView : UIView
{
    UIImageView *_imgView;
    UIButton *_editButton;
    UILabel *_titleLabel;
}
@property (nonatomic, assign) id <GrowSingleTemplateViewDelegate> delegate;
- (void)setContetData:(TemplateItem *)model;
@end
