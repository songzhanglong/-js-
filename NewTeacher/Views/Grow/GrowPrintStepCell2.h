//
//  GrowPrintStepCell2.h
//  NewTeacher
//
//  Created by zhangxs on 16/7/14.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermGrowDetailModel.h"

@protocol GrowPrintStepCell2Delegate <NSObject>

@optional
- (void)upDataNumsToController:(BOOL)type;

@end

@interface GrowPrintStepCell2 : UITableViewCell
@property (nonatomic,assign)id<GrowPrintStepCell2Delegate> delegate;
@property (nonatomic,assign)NSInteger num;
@property (nonatomic,assign)BOOL isUndoPrint;

- (void)resetDataSource:(TermStudent *)student;

@end
