//
//  FamilyStuListCell.h
//  NewTeacher
//
//  Created by szl on 16/5/6.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FamilyStuListCellDelegate <NSObject>

@optional
- (void)selectStuListCell:(UITableViewCell *)cell At:(NSInteger)index;

@end

@interface FamilyStuListCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,assign)id<FamilyStuListCellDelegate> delegate;

- (void)resetDataSource:(id)object;

@end
