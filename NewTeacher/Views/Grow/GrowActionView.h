//
//  GrowActionView.h
//  NewTeacher
//
//  Created by zhangxs on 16/1/25.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GrowActionView;
@protocol GrowActionViewDelegate <NSObject>

- (void)growActionIndex:(GrowActionView *)growView SelectIndexPathToRow:(int)row;

@end
@interface GrowActionView : UIView

@property (nonatomic, assign) id <GrowActionViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame Titles:(NSArray *)titles;
- (void)showInView;
- (void)hiddenInView;

@end
