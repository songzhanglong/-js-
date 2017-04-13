//
//  ClockView.h
//  NewTeacher
//
//  Created by songzhanglong on 15/3/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClockView;
@protocol ClockViewDelegate <NSObject>

@optional
- (void)touchEndClockView:(ClockView *)clock;

@end

@interface ClockView : UIView

@property (nonatomic,assign)id<ClockViewDelegate> delegate;
@property (nonatomic,strong)UILabel *myTipLab;
@property (nonatomic,strong)UIImageView *myImageView;

@end
