//
//  FamilyNoPiechartDetailViewController.h
//  NewTeacher
//
//  Created by zhangxs on 16/5/6.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"
#import "FamilyStudentModel.h"

@interface FamilyNoPiechartDetailViewController : DJTTableViewController

@property (nonatomic, strong) FamilyStudentModel *listItem;
@property (nonatomic, strong) NSString *score_id;
@property (nonatomic, strong) NSString *indexComent;
@property (nonatomic, strong) NSString *voiceUrl;

- (void)setReviewsData:(NSString *)content;

@end
