//
//  ProgressLayer.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/7.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface ProgressLayer : CALayer

@property (nonatomic, assign) CGFloat theProgress;
@property (nonatomic, strong) UIColor *drawColor;

@end
