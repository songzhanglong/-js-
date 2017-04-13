//
//  GrowUndoPrintViewController.h
//  NewTeacher
//
//  Created by zhangxs on 16/6/22.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"
#import "TermPrintRecord.h"
#import "TermGrowList.h"

@interface GrowUndoPrintViewController : DJTTableViewController

@property (nonatomic,strong)TermPrintRecord *record;
@property (nonatomic,strong)TermGrowList *termGrow;

@end
