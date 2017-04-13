//
//  DJTMakeGrowController.h
//  TYWorld
//
//  Created by songzhanglong on 14-10-14.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "DJTBaseViewController.h"

@class TermStudent;
@class GrowAlbumModel;

@protocol MakeGrowControllerDelegate <NSObject>

@optional
- (void)makeFinishImg:(NSString *)imgPath Data:(id)data url:(NSString *)url;

@end

@interface MakeGrowController : DJTBaseViewController

@property (nonatomic,strong)GrowAlbumModel *growAlbum;
@property (nonatomic,strong)TermStudent *student;
@property (nonatomic,strong)UIImage *targerImg;
@property (nonatomic,strong)NSString *album_id;
@property (nonatomic,strong)NSString *album_title;
@property (nonatomic,strong)NSNumber *tpl_height;
@property (nonatomic,strong)NSNumber *tpl_width;
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,assign)BOOL isSmallPicLimit;
@property (nonatomic,assign)id<MakeGrowControllerDelegate> delegate;

@end
