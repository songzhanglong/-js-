//
//  StudentBaseViewController.h
//  NewTeacher
//
//  Created by songzhanglong on 14/12/25.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"
#import "StudentModel.h"
#import <MediaPlayer/MediaPlayer.h>

@class CTAssetsPickerController;

@interface StudentBaseViewController : DJTTableViewController
{
    UIImageView *_faceImage;
    UILabel     *_nameLabel;
    UILabel     *_tipLab;
    UIImageView *_sexImage;
    UIView      *_selectView;
}

@property (nonatomic,strong)DJTStudent *student;
@property (nonatomic,assign)NSInteger nCurIndex;
@property (nonatomic,strong)StudentModel *myStudentModel;
@property (nonatomic,strong)MPMoviePlayerController *movieController;

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets;

@end
