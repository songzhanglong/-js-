//
//  FamilyStuListCell.m
//  NewTeacher
//
//  Created by szl on 16/5/6.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "FamilyStuListCell.h"
#import "DJTGlobalManager.h"
#import "FamilyStudentModel.h"

@implementation FamilyStuListCell
{
    UICollectionView *_collectionView;
    NSArray *_dataSource;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //视图
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(40, 56);
        CGFloat margin = ((SCREEN_WIDTH - 20 - 40 * 6) / 7);
        NSInteger intMar = (NSInteger)margin;
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = intMar;
        layout.sectionInset = UIEdgeInsetsMake(10, margin, 10, margin);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, self.contentView.bounds.size.height) collectionViewLayout:layout];
        [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.layer.masksToBounds = YES;
        _collectionView.layer.cornerRadius = 2;
        _collectionView.scrollEnabled = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"StuListCell"];
        [self.contentView addSubview:_collectionView];
        
    }
    return self;
}

- (void)resetDataSource:(id)object
{
    _dataSource = object;
    [_collectionView reloadData];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        [_collectionView setBackgroundColor:CreateColor(239, 239, 240)];
    }
    else{
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        [_collectionView setBackgroundColor:CreateColor(239, 239, 240)];
    }
    else{
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
    }
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"StuListCell" forIndexPath:indexPath];
    
    CGSize itemSize = ((UICollectionViewFlowLayout *)collectionView.collectionViewLayout).itemSize;
    UIImageView *faceImg = (UIImageView *)[cell.contentView viewWithTag:1];
    if (!faceImg) {
        //face
        faceImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height - 16)];
        faceImg.contentMode = UIViewContentModeScaleAspectFill;
        faceImg.clipsToBounds = YES;
        faceImg.layer.cornerRadius = itemSize.width / 2;
        faceImg.layer.masksToBounds = YES;
        [faceImg setBackgroundColor:collectionView.backgroundColor];
        [faceImg setTag:1];
        [cell.contentView addSubview:faceImg];
        
        UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, itemSize.height - 14, itemSize.width, 14)];
        [nameLab setBackgroundColor:collectionView.backgroundColor];
        [nameLab setTextAlignment:NSTextAlignmentCenter];
        [nameLab setTextColor:[UIColor blackColor]];
        [nameLab setFont:[UIFont boldSystemFontOfSize:10]];
        [nameLab setTag:2];
        [cell.contentView addSubview:nameLab];
    }
    
    UILabel *nameLab = (UILabel *)[cell.contentView viewWithTag:2];
    
    FamilyStudentModel *student = _dataSource[indexPath.item];
    NSString *face = student.face_school;
    if (![face hasPrefix:@"http"]) {
        face = [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
    }
    [faceImg setImageWithURL:[NSURL URLWithString:[face stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"s21.png"]];
    [nameLab setText:student.name];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //查看
    if (_delegate && [_delegate respondsToSelector:@selector(selectStuListCell:At:)]) {
        [_delegate selectStuListCell:self At:indexPath.item];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    cell.alpha = 0.5;
}

- (void)collectionView:(UICollectionView *)collectionView  didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    cell.alpha = 1;
}

@end
