//
//  GrowMakedViewController.h
//  NewTeacher
//
//  Created by songzhanglong on 14/12/31.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"

@class TermStudent;
@class TermGrowDetailModel;

@interface GrowMakedViewController : DJTTableViewController

@property (nonatomic,strong)TermStudent *student;
@property (nonatomic,strong)TermGrowDetailModel *detailModel;

- (void)makeNextTemplate;

@end
