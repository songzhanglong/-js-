//
//  GrowStudentCell.h
//  NewTeacher
//
//  Created by szl on 16/5/10.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermGrowDetailModel.h"

@protocol GrowStudentCellDelegate <NSObject>

@optional
- (void)selectGrowStudentCell:(UITableViewCell *)cell At:(TermStudent *)student;

@end

@interface GrowStudentCell : UITableViewCell

@property (nonatomic,assign)id<GrowStudentCellDelegate> delegate;

- (void)resetDataSource:(NSArray *)array;

@end
