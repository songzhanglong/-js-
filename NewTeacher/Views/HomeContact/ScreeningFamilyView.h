//
//  ScreeningFamilyView.h
//  NewTeacher
//
//  Created by zhangxs on 16/5/12.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScreeningFamilyViewDelegate <NSObject>

@optional
- (void)screeningActionIndex:(NSInteger)row;

@end
@interface ScreeningFamilyView : UIView

@property (nonatomic, assign) id<ScreeningFamilyViewDelegate> delegate;
@property (nonatomic, strong) NSArray *dataSource;

- (id)initWithFrame:(CGRect)frame TabHei:(CGFloat)hei;

- (void)showInView;
- (void)hiddenInView;

@end