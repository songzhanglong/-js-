//
//  AddItemCollectionCell.h
//  NewTeacher
//
//  Created by szl on 16/8/31.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>
#import "GrowSetTemplateModel.h"

@protocol GrowEditCollectionCellDelegate <NSObject>

@optional
//type:0-新增，1-删除，2-改名
- (void)editCollectionCell:(UICollectionViewCell *)curCell Type:(NSInteger)type Options:(NSArray *)array;

@end

@interface AddItemCollectionCell : UICollectionViewCell

@property (nonatomic,assign)id<GrowEditCollectionCellDelegate> delegate;
@property (nonatomic,strong)NSArray *options;

- (void)resetContentData:(NSArray *)array;

@end
