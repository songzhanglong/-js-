//
//  GrowPrintStepCell.h
//  NewTeacher
//
//  Created by szl on 16/5/11.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermGrowDetailModel.h"

@interface GrowPrintStepCell : UITableViewCell

@property (nonatomic,assign)BOOL isChecked;

- (void)resetDataSource:(TermStudent *)student;
- (void)setHasPrintBackView;

@end
