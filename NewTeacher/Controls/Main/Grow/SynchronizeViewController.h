//
//  SynchronizeViewController.h
//  NewTeacher
//
//  Created by songzhanglong on 15/5/29.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTBaseViewController.h"

@class TermStudent;
@class GrowAlbumModel;

@interface SynchronizeViewController : DJTBaseViewController

@property (nonatomic,strong)TermStudent *student;
@property (nonatomic,strong)GrowAlbumModel *growAlbum;
@property (nonatomic,strong)NSMutableArray *dataSource;

@end
