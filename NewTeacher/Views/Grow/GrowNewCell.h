//
//  GrowNewCell.h
//  NewTeacher
//
//  Created by szl on 16/5/4.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermGrowList.h"

@protocol GrowNewCellDelegate <NSObject>

@optional
- (void)selectNewCell:(UITableViewCell *)cell At:(NSInteger)index;
- (void)startToMake:(UITableViewCell *)cell;

@end

@interface GrowNewCell : UITableViewCell
{
    UIView *_backView;
    UIButton *_makeBut;
}

@property (nonatomic,assign)id<GrowNewCellDelegate> delegate;

- (void)resetDataSource:(TermGrowList *)termGrow;

@end
