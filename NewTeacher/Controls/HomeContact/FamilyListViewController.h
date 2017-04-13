//
//  FamilyListViewController.h
//  NewTeacher
//
//  Created by szl on 16/5/5.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"

@protocol FamilyListViewControllerDelegate <NSObject>

@optional
- (void)familyListDidSelectIndex:(NSIndexPath *)indexPath;

@end

@interface FamilyListViewController : DJTTableViewController

@property (nonatomic,assign)id<FamilyListViewControllerDelegate> delegate;

@end
