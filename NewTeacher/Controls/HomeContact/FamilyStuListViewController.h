//
//  FamilyStuListViewController.h
//  NewTeacher
//
//  Created by szl on 16/5/6.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"
#import "FamilyListModel.h"

@interface FamilyStuListViewController : DJTTableViewController

@property (nonatomic, strong) FamilyListModel *listItem;
@property (nonatomic, assign) BOOL isRefreshData;

@end
