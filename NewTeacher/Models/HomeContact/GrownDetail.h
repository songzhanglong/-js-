//
//  GrownDetail.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/19.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@interface GrownDetail : JSONModel

@property (nonatomic,strong) NSString *card;
@property (nonatomic,strong) NSString *student_id;
@property (nonatomic,assign) NSInteger nStuIdx;

@end
