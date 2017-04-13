//
//  NotificationSendViewController.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/9.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTBaseViewController.h"

@protocol NotificationSendSuccessDelegate <NSObject>

@optional
- (void)publistMessageFinish;

@end

@interface NotificationSendViewController : DJTBaseViewController
{
    NSString *lastTextValue;
}
@property (nonatomic,assign)id<NotificationSendSuccessDelegate> delegate;
@property (nonatomic,assign)NSInteger sendToIndex;

@end
