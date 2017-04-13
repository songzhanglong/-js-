//
//  CliassHeaderView.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/4/24.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CliassHeaderView;
@protocol CliassHeaderViewDelegate <NSObject>
@optional
-(void)touchHeadView:(CliassHeaderView *)click;

@end

@interface CliassHeaderView : UIView
@property (nonatomic,assign)id<CliassHeaderViewDelegate> delegate;
@property (nonatomic,strong) UIImageView *headImg;
@property (nonatomic,strong) UILabel *nameLab;
@end
