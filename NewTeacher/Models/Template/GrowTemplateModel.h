//
//  GrowTemplateModel.h
//  NewTeacher
//
//  Created by zhangxs on 16/1/25.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface GrowTemplateModel : JSONModel

@property (nonatomic,strong)NSString *template_id;
@property (nonatomic,strong)NSString *template_path;
@property (nonatomic,strong)NSString *template_path_thumb;
@property (nonatomic,strong)NSString *template_title;

@end
