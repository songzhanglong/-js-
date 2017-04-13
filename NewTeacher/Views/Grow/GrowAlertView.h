//
//  GrowAlertView.h
//  NewTeacher
//
//  Created by zhangxs on 16/1/27.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GrowAlertView;
@protocol GrowAlertViewDelegate <NSObject>

- (void)closeGrowAlertView;
- (void)submitThemeToGrowAlertView:(NSString *)theme;

@end
@interface GrowAlertView : UIView <UITextFieldDelegate>
{
    UITextField *_textFiled;
    NSString *defaultTheme;
}

@property (nonatomic, assign) id <GrowAlertViewDelegate> delegate;

- (void)setDefaultTheme:(NSString *)theme;
@end
