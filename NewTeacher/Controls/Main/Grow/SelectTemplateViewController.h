//
//  SelectTemplateViewController.h
//  NewTeacher
//
//  Created by zhangxs on 16/1/26.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "TemplateBaseViewController.h"
#import "GrowSetTemplateModel.h"

@class TermGrowList;

@interface SelectTemplateViewController : TemplateBaseViewController
{
    NSMutableArray *_recordIndexPathArray;
}

@property (nonatomic, strong) GrowSetTemplateModel *templateModel;
@property (nonatomic, strong) TermGrowList *termGrow;
@property (nonatomic, assign) NSInteger nMaxCount;

@end
