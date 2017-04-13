//
//  GrowPrintRecordViewController.h
//  NewTeacher
//
//  Created by szl on 16/5/11.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"

@class TermGrowList;

@interface GrowPrintRecordViewController : DJTTableViewController

@property (nonatomic,strong)TermGrowList *termGrow;
@property (nonatomic,assign)BOOL shouldRefresh;
@property (nonatomic,assign)BOOL sucPrint;

@end
