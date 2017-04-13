//
//  AddTemplateViewController.h
//  NewTeacher
//
//  Created by zhangxs on 16/1/26.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "TemplateBaseViewController.h"

@class TermGrowList;

@interface AddTemplateViewController : TemplateBaseViewController
{
    NSIndexPath *_recordIndexPath;
}

@property (nonatomic,strong)TermGrowList *termGrow;
@property (nonatomic,strong)NSString *template_ids;

@end
