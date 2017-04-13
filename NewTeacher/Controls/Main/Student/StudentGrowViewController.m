//
//  StudentGrowViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/25.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "StudentGrowViewController.h"
#import "BabyPhotoAlbumCell.h"
#import "NSString+Common.h"

@interface StudentGrowViewController ()<BabyPhotoAlbumCellDelegate>

@end

@implementation StudentGrowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.nCurIndex = 1;
    
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    CGFloat yOri = 0;
    [_tableView setAutoresizingMask:UIViewAutoresizingNone];
    [_tableView setFrame:CGRectMake(0, _selectView.frame.origin.y + _selectView.frame.size.height, winSize.width, winSize.height - _selectView.frame.size.height - _selectView.frame.origin.y - yOri)];
    self.dataSource = self.myStudentModel ? self.myStudentModel.grows : nil;
}

#pragma mark - BabyPhotoAlbumCellDelegate
- (void)didSelectCell:(UITableViewCell *)cell At:(NSInteger)index
{
    _browserPhotos = [NSMutableArray array];
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    NSInteger curIdx = indexPath.row * 2 + index;
    for (int i = 0; i < [self.dataSource count]; i++) {
        BabyGrow *model = self.dataSource[i];
        CGFloat scale_screen = [UIScreen mainScreen].scale;
        NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
        NSString *path = [NSString getPictureAddress:@"2" width:width height:@"0" original:model.image_path];
        NSURL *url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        MWPhoto *photo = [MWPhoto photoWithURL:url];
        
        [_browserPhotos addObject:photo];
    }

    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [browser setCurrentPhotoIndex:curIdx];
    browser.displayActionButton = NO;
    browser.displayNavArrows = YES;

    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataSource && [self.dataSource count] > 0)
    {
        return (([self.dataSource count] - 1) / 2 + 1);
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *growAlbumCell = @"GrowAlbumCell";
    
    BabyPhotoAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:growAlbumCell];
    float margin = 5.0;
    CGSize winSize = [[UIScreen mainScreen] bounds].size;
    
    float imgWei = (winSize.width - margin * 3) / 2;
    float imgHei = imgWei * 1280.0 / 800.0;
    if (cell == nil)
    {
        cell = [[BabyPhotoAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:growAlbumCell imageSize:CGSizeMake(imgWei, imgHei) numberOfAssets:2 margin:margin];
        cell.delegate = self;
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    NSMutableArray *imgs = [NSMutableArray array];
    NSInteger index = indexPath.row * 2;
    [imgs addObject:self.dataSource[index]];
    if ([self.dataSource count] > index + 1) {
        [imgs addObject:self.dataSource[index + 1]];
    }
    
    [cell setAsserts:imgs];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float margin = 5.0;
    CGSize winSize = [[UIScreen mainScreen] bounds].size;
    
    float imgWei = (winSize.width - margin * 3) / 2;
    float imgHei = imgWei * 1280.0 / 800.0;
    return 4 + imgHei;
}

@end
