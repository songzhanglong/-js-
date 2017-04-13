//
//  DelStudent.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/25.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DelStudentDelegate <NSObject>

@optional
- (void)selectDeleteIdx:(NSInteger)idx;
@end
@interface DelStudent : UIView

@property (nonatomic,assign)id<DelStudentDelegate> delegate;
@property (nonatomic,assign)NSInteger delNum;
@property (nonatomic,assign,readonly)UIButton *allSelectedButton;
@property (nonatomic,assign,readonly)UIButton *unSelectedButton;
@property (nonatomic,assign,readonly)UIButton *completedButton;

@end
