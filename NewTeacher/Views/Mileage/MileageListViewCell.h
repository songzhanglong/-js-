//
//  MileageListViewCell.h
//  NewTeacher
//
//  Created by szl on 15/12/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MileageListViewCellDelegate <NSObject>

@optional
- (void)beginEditMileageName:(UITableViewCell *)cell;
- (void)selectMileageImage:(UITableViewCell *)cell At:(NSInteger)index;

@end

@interface MileageListViewCell : UITableViewCell
{
    UILabel *_fromLabel;
    UIButton *_editBtn;
    UIView *_topLeft;
    UIImageView *_tipImgView;
}

@property (nonatomic,assign)id<MileageListViewCellDelegate> delegate;

- (void)resetDataSource:(id)object;

@end
