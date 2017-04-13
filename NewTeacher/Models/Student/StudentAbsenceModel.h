//
//  StudentAbsenceModel.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/6.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StudentAbsenceModel : NSObject

@property (nonatomic,strong) NSString *reson;
@property (nonatomic,strong) NSString *student_id;
@property (nonatomic,strong) NSString *type;    //1-病假,2-事假,0-出勤

@end
