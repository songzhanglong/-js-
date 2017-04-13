//
//  MileageStudentModel.h
//  NewTeacher
//
//  Created by szl on 15/12/8.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@interface MileageStudentModel : JSONModel

@property (nonatomic,strong)NSString *birthday;
@property (nonatomic,strong)NSString *sex;
@property (nonatomic,strong)NSNumber *photo_num;
@property (nonatomic,strong)NSString *real_name;
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *student_id;
@property (nonatomic,strong)NSNumber *mp4_num;
@property (nonatomic,strong)NSString *face_school;

@end
