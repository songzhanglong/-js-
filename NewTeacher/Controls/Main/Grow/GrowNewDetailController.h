//
//  GrowNewDetailController.h
//  NewTeacher
//
//  Created by szl on 16/5/4.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"

@class TermGrowList;

@protocol GrowNewDetailControllerDelegate <NSObject>

@optional
- (void)changeFinishCount;

@end

@interface GrowNewDetailController : DJTTableViewController

@property (nonatomic,strong)TermGrowList *termGrow;
@property (nonatomic,assign)BOOL shouldRefresh;
@property (nonatomic,assign)id<GrowNewDetailControllerDelegate> delegate;

@end
