//
//  BabyMileageViewController.h
//  NewTeacher
//
//  Created by szl on 15/11/30.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MileageBaseViewController.h"
#import "MileageStudentViewController.h"
#import "MileageViewController.h"

@class MileageStudentModel;

@interface BabyMileageViewController : MileageBaseViewController

@property (nonatomic,strong)MileageStudentModel *mileageStu;

- (void)resetNumText:(NSString *)str;

@end
