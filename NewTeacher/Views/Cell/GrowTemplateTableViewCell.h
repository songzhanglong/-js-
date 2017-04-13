//
//  GrowTemplateUITableViewCell.h
//  NewTeacher
//
//  Created by zhangxs on 16/1/25.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditGrowDoubleCollectionCell.h"

@class GrowTemplateTableViewCell;
@protocol GrowTemplateTableViewCell <NSObject>

@optional
- (void)editTemplate:(GrowTemplateTableViewCell *)cell At:(NSInteger)idx Options:(NSArray *)array;
- (void)didSelectItem:(GrowTemplateTableViewCell *)cell At:(NSInteger)idx;
- (void)delTemplate:(GrowTemplateTableViewCell *)cell At:(NSInteger)idx Options:(NSArray *)array;
- (void)addTemplate:(GrowTemplateTableViewCell *)cell;
@end

@interface GrowTemplateTableViewCell : UITableViewCell <UICollectionViewDataSource,UICollectionViewDelegate,GrowEditCollectionCellDelegate>
{
    BOOL _isEdit;
}

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) id <GrowTemplateTableViewCell> delegate;

- (void)resetDataSource:(id)source Double:(BOOL)isDouble;

@end
