//
//  MainViewController.h
//  NewTeacher
//
//  Created by songzhanglong on 14/12/23.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MainViewController : DJTTableViewController

@property (nonatomic,strong)MPMoviePlayerController *movieController;
@property (nonatomic,assign)BOOL refreshNotice;

- (void)reloadSection:(NSInteger)section;

- (void)refreshTipInfo;
@end
