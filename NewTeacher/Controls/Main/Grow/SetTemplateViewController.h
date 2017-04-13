//
//  SetTemplateViewController.h
//  NewTeacher
//
//  Created by zhangxs on 16/1/25.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "DJTBaseViewController.h"

@class TermGrowList;

@interface SetTemplateViewController : DJTBaseViewController

@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,strong)TermGrowList *termGrow;
@property (nonatomic,assign)BOOL isBeginRefresh;
@property (nonatomic,assign)BOOL isEditRefresh;

- (void)addDataToRefresh:(id)source;

@end
