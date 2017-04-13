//
//  ClickView.h
//  NewTeacher
//
//  Created by songzhanglong on 15/3/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClickView;
@protocol ClickViewDelegate <NSObject>

@optional
- (void)touchEndClickView:(ClickView *)click;

@end

@interface ClickView : UIView

@property (nonatomic,assign)id<ClickViewDelegate> delegate;
@property (nonatomic,strong)UILabel *tipLab;
@property (nonatomic,strong)UILabel *numLab;
@property (nonatomic,strong)UIImageView *faceImg;
@property (nonatomic,strong)UIView *backView;

@end
