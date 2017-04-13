//
//  EditSingleCollectionCell.h
//  NewTeacher
//
//  Created by szl on 16/8/31.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditSingleCollectionCellDelegate <NSObject>

@optional
//index:1-删除，2-编辑
- (void)beginEditSingleCollectionCell:(UICollectionViewCell *)cell At:(NSInteger)index Options:(NSArray *)array;

@end

@interface EditSingleCollectionCell : UICollectionViewCell

@property (nonatomic,assign)id<EditSingleCollectionCellDelegate> delegate;
@property (nonatomic,strong)UIButton *nameBtn;
@property (nonatomic,strong)NSArray *options;

- (void)resetDataSource:(NSArray *)array;
- (CGFloat)calculateDescRects:(NSString *)title;

@end
