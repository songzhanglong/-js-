//
//  EditSigleTemplateViewController.h
//  NewTeacher
//
//  Created by zhangxs on 16/1/27.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "TemplateBaseViewController.h"
#import "GrowSetTemplateModel.h"

@class TermGrowList;

@protocol EditSigleTemplateDelegate <NSObject>
@optional
- (void)reloadPagedFlowView:(NSInteger)index;
- (void)reloadEditTheme:(TemplateItem *)item AtIndex:(NSInteger)index;
@end

@interface EditSigleTemplateViewController : TemplateBaseViewController

@property (nonatomic,strong) TermGrowList *termGrow;
@property (nonatomic, strong) GrowSetTemplateModel *templateModel;
@property (nonatomic, assign) NSInteger currIndex;
@property (nonatomic, assign) id <EditSigleTemplateDelegate> delegate;

@end
