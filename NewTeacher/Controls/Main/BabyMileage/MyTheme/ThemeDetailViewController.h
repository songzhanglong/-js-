//
//  ThemeDetailViewController.h
//  NewTeacher
//
//  Created by szl on 15/12/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"

@class ThemeBatchModel;

@protocol ThemeDetailViewControllerDelegate <NSObject>

@optional
- (void)changeDiggAndComment;
- (void)deleteThisBatch;

@end

@interface ThemeDetailViewController : DJTTableViewController

@property (nonatomic,strong)ThemeBatchModel *themeBatch;
@property (nonatomic,assign)id<ThemeDetailViewControllerDelegate> delegate;
@property (nonatomic,assign)BOOL disanableDelete;

@end
