//
//  DelStudentPhoto.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/13.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DelStudentPhotoDelegate <NSObject>

@optional
- (void)selectDeleteIdx:(NSInteger)idx;

@end

@interface DelStudentPhoto : UIView<UIAlertViewDelegate>

@property (nonatomic,assign)id<DelStudentPhotoDelegate> delegate;
@property (nonatomic,assign)NSInteger delNum;
//1 删除  0 其他
@property (nonatomic,assign)NSInteger lx;
@property (nonatomic,assign,readonly)UIButton *allButton;
@property (nonatomic,assign,readonly)UIButton *otherButton;
@property (nonatomic,assign,readonly)UIButton *delBut;

@end
