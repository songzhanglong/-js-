//
//  SelectTemplateSingleCell.h
//  NewTeacher
//
//  Created by szl on 16/8/31.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectTemplateSingleCell;
@protocol SelectTemplateSingleCellDelegate <NSObject>

@optional
- (void)checkSelectTemplateCellBtn:(SelectTemplateSingleCell *)cell Options:(NSArray *)array;

@end

@interface SelectTemplateSingleCell : UICollectionViewCell

@property (nonatomic,strong)UIButton *checkBtn;
@property (nonatomic,assign)id<SelectTemplateSingleCellDelegate> delegate;
@property (nonatomic,strong)NSArray *options;

- (void)resetDataSource:(NSArray *)array Checked:(BOOL)checked;

@end
