//
//  GrowTemplateUITableViewCell.m
//  NewTeacher
//
//  Created by zhangxs on 16/1/25.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "GrowTemplateTableViewCell.h"
#import "GrowTemplateModel.h"
#import "GrowSetTemplateModel.h"
#import "DJTGlobalManager.h"

@implementation GrowTemplateTableViewCell
{
    UICollectionView *_collectionView;
    UIImageView *_homePage;
    UILabel *_titleLabel;
    UIImageView *_typeImgView;
    BOOL _isDouble;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = CreateColor(43, 31, 28);
        
        _typeImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 25, 166)];
        _typeImgView.backgroundColor = [UIColor clearColor];
        [self addSubview:_typeImgView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2.5, 15, 20, _typeImgView.frame.size.height - 30)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.numberOfLines = 0;
        [_typeImgView addSubview:_titleLabel];
        
        //视图
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //layout.itemSize = CGSizeMake(90, 156);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(30, 0, self.frame.size.width - _typeImgView.frame.origin.x - _typeImgView.frame.size.width, 166) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[AddItemCollectionCell class] forCellWithReuseIdentifier:@"AddItemCollectionCell"];
        [_collectionView registerClass:[EditGrowSingleCollectionCell class] forCellWithReuseIdentifier:@"EditGrowSingleCollectionCell"];
        [_collectionView registerClass:[EditGrowDoubleCollectionCell class] forCellWithReuseIdentifier:@"EditGrowDoubleCollectionCell"];
        [self addSubview:_collectionView];
    }
    return self;
}

- (void)resetDataSource:(id)source Double:(BOOL)isDouble
{
    _isDouble = isDouble;
    GrowSetTemplateModel *model = (GrowSetTemplateModel *)source;
    if ([model.album_type integerValue] == 3) {
        _typeImgView.image = CREATE_IMG(@"grow_bg_type3@2x");
    }else if ([model.album_type integerValue] == 2){
        _typeImgView.image = CREATE_IMG(@"grow_bg_type1@2x");
    }else {
        _typeImgView.image = CREATE_IMG(@"grow_bg_type2@2x");
    }
    NSString *title = model.album_title;
    title = (!title || [title isKindOfClass:[NSNull class]]) ? @"" : title;
    _titleLabel.text = title;
    
    self.dataSource = model.list;
    [_collectionView reloadData];
}

#pragma mark - GrowEditCollectionCellDelegate
//type:0-新增，1-删除，2-改名
- (void)editCollectionCell:(UICollectionViewCell *)curCell Type:(NSInteger)type Options:(NSArray *)array
{
    NSIndexPath *index = [_collectionView indexPathForCell:curCell];
    switch (type) {
        case 1:
        {
            if (_delegate && [_delegate respondsToSelector:@selector(delTemplate:At:Options:)]) {
                [_delegate delTemplate:self At:index.item - 1 Options:array];
            }
        }
            break;
        case 2:
        {
            if (_delegate && [_delegate respondsToSelector:@selector(editTemplate:At:Options:)]) {
                [_delegate editTemplate:self At:index.item - 1 Options:array];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_isDouble) {
        return ([_dataSource count] + 1) / 2 + 1;
    }
    return self.dataSource.count + 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat hei = 156.0;
    CGFloat ratio = 1080.0 / 1512;
    TemplateItem *item = [self.dataSource firstObject];
    if (item.template_width.integerValue != 0 && item.template_height.integerValue != 0) {
        ratio = item.template_width.floatValue / item.template_height.floatValue;
    }
    CGFloat imgWei = (hei - 15 - 24) * ratio;
    if (_isDouble && indexPath.item != 0) {
        return CGSizeMake(imgWei * 2 + 24, hei);
    }
    return CGSizeMake(imgWei + 24, hei);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = (indexPath.item == 0) ? @"AddItemCollectionCell" : (_isDouble ? @"EditGrowDoubleCollectionCell" : @"EditGrowSingleCollectionCell");
    AddItemCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    if (indexPath.item > 0) {
        NSInteger index = indexPath.item - 1;
        if (_isDouble) {
            TemplateItem *item = [_dataSource objectAtIndex:index * 2];
            TemplateItem *nextItem = [_dataSource objectAtIndex:index * 2 + 1];
            [cell resetContentData:@[item,nextItem]];
        }
        else{
            TemplateItem *item = [_dataSource objectAtIndex:index];
            [cell resetContentData:@[item]];
        }
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(addTemplate:)]) {
            [_delegate addTemplate:self];
        }
    }else {
        if (_delegate && [_delegate respondsToSelector:@selector(didSelectItem:At:)]) {
            [_delegate didSelectItem:self At:indexPath.item - 1];
        }
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
