//
//  ClassActivityModel.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

typedef enum{
    kZeroStyle = 0,     //无图片
    kOneStyle,          //一张图片
    kTwoStyle,          //两张图片
    kThirdStyle,        //三张图片，左边一张，右边两张
    kFourStyle,         //四张图片，左1，中2，右1
    kFiveStyle          //五张图片，左1，中2，右2
}kShowStyle;

@interface ClassActivityItem : JSONModel

@property (nonatomic,strong)NSString *photo_desc;
@property (nonatomic,strong)NSString *photo_id;
@property (nonatomic,strong)NSString *photo_path;
@property (nonatomic,strong)NSString *photo_thumb;
@property (nonatomic,strong)NSString *type;
@property (nonatomic,strong)NSString *creater;
@property (nonatomic,strong)NSString *creater_name;
@property (nonatomic,strong)NSString *tags;

@end

@interface ClassActivityModel : JSONModel
@property (nonatomic,strong)NSString *id;
@property (nonatomic,strong)NSString *album_id;
@property (nonatomic,strong)NSString *album_name;
@property (nonatomic,strong)NSString *photos_num;
@property (nonatomic,strong)NSString *thumb;
@property (nonatomic,strong)NSString *up_time;
@property (nonatomic,strong)NSMutableArray *photo;

@property (nonatomic,assign)kShowStyle nCurType;

- (void)calculateType;

@end
