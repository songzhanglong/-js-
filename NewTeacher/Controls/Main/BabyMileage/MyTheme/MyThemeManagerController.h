//
//  MyThemeManagerController.h
//  NewTeacher
//
//  Created by szl on 15/12/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MileageBaseViewController.h"
#import "MileageModel.h"

@interface MyThemeManagerController : MileageBaseViewController

@property (nonatomic, strong) MileageModel *indexModel;

- (void)addTheme:(id)sender;

@end
