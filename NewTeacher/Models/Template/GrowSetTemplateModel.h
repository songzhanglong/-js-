//
//  GrowSetTemplateModel.h
//  NewTeacher
//
//  Created by zhangxs on 16/1/26.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol TemplateItem

@end
@interface TemplateItem : JSONModel

@property (nonatomic,strong)NSString *template_path;
@property (nonatomic,strong)NSString *template_path_thumb;
@property (nonatomic,strong)NSString *template_id;
@property (nonatomic,strong)NSString *template_title;
@property (nonatomic,strong)NSString *template_desc;
@property (nonatomic,strong)NSString *template_used_flag;
@property (nonatomic,strong)NSNumber *template_width;
@property (nonatomic,strong)NSNumber *template_height;

@property (nonatomic,assign,readonly)CGSize contSize;

- (void)calculateDescRects;
@end

@interface GrowSetTemplateModel : JSONModel

@property (nonatomic,strong)NSString *album_desc;
@property (nonatomic,strong)NSString *album_id;
@property (nonatomic,strong)NSString *album_title;
@property (nonatomic,strong)NSString *album_type; // 1个人  2教师  3系统
@property (nonatomic,strong)NSMutableArray<TemplateItem>*list;
@property (nonatomic,assign,readonly)CGSize contSize;

- (void)calculateDescRects;
@end
