//
//  StudentAlbumModel.h
//  NewTeacher
//
//  Created by songzhanglong on 14/12/25.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@interface StudentItem : JSONModel

@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *path;
@property (nonatomic,strong)NSString *thumb;
@property (nonatomic,strong)NSString *photo_id;
@property (nonatomic,strong)NSString *type;
@property (nonatomic,strong)NSString *creater;
@property (nonatomic,strong)NSString *creater_name;
@property (nonatomic,strong)NSString *message;
@property (nonatomic,strong)NSString *tags;


@end

@interface StudentAlbumModel : JSONModel

@property (nonatomic,strong)NSString *ctime;
@property (nonatomic,strong)NSMutableArray *photos;

@end
