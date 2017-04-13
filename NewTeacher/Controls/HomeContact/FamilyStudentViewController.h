//
//  FamilyStudentViewController.h
//  NewTeacher
//
//  Created by szl on 16/5/5.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"

@protocol FamilyStudentViewControllerDelegate<NSObject>

@optional
- (void)getTableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface FamilyStudentViewController : DJTTableViewController

@property (nonatomic,assign)id<FamilyStudentViewControllerDelegate> delegate;

@end
