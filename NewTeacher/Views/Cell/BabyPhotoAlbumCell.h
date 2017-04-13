//
//  BabyPhotoAlbumCell.h
//  NewTeacher
//
//  Created by songzhanglong on 14/12/25.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BabyPhotoAlbumCellDelegate <NSObject>

@optional
- (void)didSelectCell:(UITableViewCell *)cell At:(NSInteger)index;

@end

@interface BabyPhotoAlbumCell : UITableViewCell

@property (nonatomic,readonly)CGSize      gImageSize;         //图片大小
@property (nonatomic,readonly)NSUInteger  nNumberOfAssets;    //数量
@property (nonatomic,readonly)CGFloat     fMargin;            //间距
@property (nonatomic,assign)id<BabyPhotoAlbumCellDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier imageSize:(CGSize)imageSize numberOfAssets:(NSUInteger)numberOfAssets margin:(CGFloat)margin;

/**
 *	刷新数据
 *
 *	@param 	asserts 	对象
 */
- (void)setAsserts:(id)asserts;

/**
 *	添加子视图
 */
- (void)addSelectedImages;

@end
