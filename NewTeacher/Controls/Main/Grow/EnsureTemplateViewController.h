//
//  EnsureTemplateViewController.h
//  NewTeacher
//
//  Created by zhangxs on 16/1/26.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "TemplateBaseViewController.h"
#import "GrowSetTemplateModel.h"

@class TermGrowList;

@protocol EnsureTemplateViewControllerDelegate <NSObject>

@optional
- (void)changeSelectIndexPathItems:(BOOL)checked At:(NSIndexPath *)indexPath;

@end

@interface EnsureTemplateViewController : TemplateBaseViewController

@property (nonatomic, strong) TermGrowList *termGrow;
@property (nonatomic, strong) GrowSetTemplateModel *templateModel;
@property (nonatomic, strong) NSMutableArray *templateArray;
@property (nonatomic, strong) NSMutableArray *templateScoure;
@property (nonatomic, assign) NSInteger currIndex;
@property (nonatomic, strong) NSMutableArray *recordIndexArray;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) id <EnsureTemplateViewControllerDelegate> delegate;

@end
