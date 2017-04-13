//
//  SelectTemplateViewController.m
//  NewTeacher
//
//  Created by zhangxs on 16/1/26.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "SelectTemplateViewController.h"
#import "SelectTemplateCell.h"
#import "EnsureTemplateViewController.h"
#import "Toast+UIView.h"
#import "SetTemplateViewController.h"
#import "TermGrowList.h"
#import "AddTemplateViewController.h"
#import "SelectTemplateDoubleCell.h"
#import <Masonry.h>

@interface SelectTemplateViewController() <SelectTemplateSingleCellDelegate,EnsureTemplateViewControllerDelegate>

@end

@implementation SelectTemplateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _recordIndexPathArray = [[NSMutableArray alloc] initWithCapacity:15];
    
    //top
    UILabel *_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, SCREEN_WIDTH - 30, 30)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.text = @"请选择需要新增的模板";
    [self.view addSubview:_titleLabel];
    
    //collectionview
    CGFloat margin = 10;
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = margin;
    layout.minimumInteritemSpacing = margin;
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSDictionary *dic = @{@"class_id":manager.userInfo.classid,@"teacher_id":manager.userInfo.userid,@"album_flag":@"0",@"term_id":_termGrow.term_id ?: @"",@"templist_id":_termGrow.templist_id ?: @""};
    [self createCollectionViewLayout:layout Action:@"grow:set_template_list" Param:dic Header:YES Foot:NO];
    [_collectionView setFrame:CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - 40 - 64 - (_templateModel ? 90 : 0))];
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView setAutoresizingMask:UIViewAutoresizingNone];
    NSString *str = ([_termGrow.is_double integerValue] == 1) ? @"SelectTemplateDoubleCell" : @"SelectTemplateSingleCell";
    [_collectionView registerClass:NSClassFromString(str) forCellWithReuseIdentifier:str];
    
    //bottom
    if (_templateModel) {
        [self setFooterView];
    }
    [self beginRefresh];
}

#pragma mark - Right btton action
- (void)rightBtnAction:(UIButton *)btn
{
    if ([_recordIndexPathArray count] > 0) {
        NSMutableArray *tempArray = [NSMutableArray array];
        BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
        for (NSIndexPath *indexPath in _recordIndexPathArray) {
            NSInteger newIdx = indexPath.item;
            if (!isDouble) {
                TemplateItem *item = self.dataSource[newIdx];
                [tempArray addObject:item.template_id];
            }
            else{
                newIdx *= 2;
                TemplateItem *item1 = self.dataSource[newIdx];
                TemplateItem *item2 = self.dataSource[newIdx + 1];
                [tempArray addObject:item1.template_id];
                [tempArray addObject:item2.template_id];
            }
        }
        NSString *template_ids = [tempArray componentsJoinedByString:@","];
        
        if (_templateModel) {
            self.view.userInteractionEnabled = NO;
            UIBarButtonItem *item = [self.navigationItem.rightBarButtonItems lastObject];
            item.enabled = NO;
            [self.view makeToastActivity];
            __weak __typeof(self)weakSelf = self;
            NSString *url = [URLFACE stringByAppendingString:@"grow:set_template_add"];
            DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
            NSDictionary *dic = @{@"class_id": manager.userInfo.classid,@"teacher_id":manager.userInfo.userid,@"album_id":_templateModel.album_id,@"template_ids":template_ids,@"term_id":_termGrow.term_id,@"templist_id":_termGrow.templist_id};
            self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf sendToRequestFinish:data Suc:success];
                });
                
            } failedBlock:^(NSString *description) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf sendToRequestFinish:nil Suc:NO];
                });
                
            }];
        }else{
            AddTemplateViewController *addController = [[AddTemplateViewController alloc] init];
            addController.termGrow = _termGrow;
            addController.template_ids = template_ids;
            [self.navigationController pushViewController:addController animated:YES];
        }
    }else{
        [self.view makeToast:@"您还没有选择模板" duration:1.0 position:@"center"];
    }
}

#pragma mark - Request
- (void)sendToRequestFinish:(id)data Suc:(BOOL)suc
{
    self.httpOperation = nil;
    self.view.userInteractionEnabled = YES;
    UIBarButtonItem *item = [self.navigationItem.rightBarButtonItems lastObject];
    item.enabled = YES;
    [self.view hideToastActivity];
    
    if (suc) {
        for (UIViewController *control in self.navigationController.viewControllers) {
            if ([control isKindOfClass:[SetTemplateViewController class]]) {
                BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
                NSMutableArray *tempArray = [NSMutableArray array];
                for (NSIndexPath *indexPath in _recordIndexPathArray) {
                    NSInteger newIdx = indexPath.item;
                    if (!isDouble) {
                        TemplateItem *item = self.dataSource[newIdx];
                        [tempArray addObject:item];
                    }
                    else{
                        newIdx *= 2;
                        TemplateItem *item1 = self.dataSource[newIdx];
                        TemplateItem *item2 = self.dataSource[newIdx + 1];
                        [tempArray addObject:item1];
                        [tempArray addObject:item2];
                    }
                }
                if ([_templateModel.list count] > 0) {
                    [_templateModel.list addObjectsFromArray:tempArray];
                }else {
                    _templateModel.list = (NSMutableArray<TemplateItem> *)tempArray;
                }
                
                [(SetTemplateViewController *)control addDataToRefresh:_templateModel];
                [self.navigationController popToViewController:control animated:YES];
                return;
            }
        }
        
        [self.view.window makeToast:@"模板添加成功" duration:1.0 position:@"center"];
    }else {
        NSString *str = [data valueForKey:@"message"];
        str = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

- (void)setFooterView
{
    //back
    UIView *mview = [[UIView alloc] init];
    mview.clipsToBounds = YES;
    [mview setTranslatesAutoresizingMaskIntoConstraints:NO];
    mview.backgroundColor = CreateColor(39, 32, 25);
    [self.view addSubview:mview];
    [mview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.height.equalTo(@(90));
        make.left.equalTo(self.view.mas_left);
        make.width.equalTo(self.view.mas_width);
    }];
    
    //img
    UIImageView *_bgImgView = [[UIImageView alloc] init];
    NSInteger type = [_templateModel.album_type integerValue];
    NSString *name = (type == 3) ? @"grow_add_bg_type3@2x" : ((type == 2) ? @"grow_add_bg_type1@2x" : @"grow_add_bg_type2@2x");
    [_bgImgView setImage:CREATE_IMG(name)];
    [_bgImgView setTranslatesAutoresizingMaskIntoConstraints:NO];
    _bgImgView.backgroundColor = [UIColor clearColor];
    [mview addSubview:_bgImgView];
    [_bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(mview.mas_centerX);
        make.centerY.equalTo(mview.mas_centerY);
        make.width.equalTo(@(288));
        make.height.equalTo(@(57));
    }];
    
    UILabel *_nameLabel = [[UILabel alloc] init];
    [_nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.font = [UIFont boldSystemFontOfSize:16];
    [_nameLabel setText:_templateModel.album_title];
    [_bgImgView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(_bgImgView.mas_width).with.offset(-20);
        make.centerY.equalTo(_bgImgView.mas_centerY).with.multipliedBy(2.0 / 3);
        make.left.equalTo(@(10));
        make.height.equalTo(@(20));
    }];
    
    UILabel *_classLabel = [[UILabel alloc] init];
    [_classLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    _classLabel.backgroundColor = [UIColor clearColor];
    _classLabel.textColor = [UIColor whiteColor];
    _classLabel.font = [UIFont boldSystemFontOfSize:12];
    [_classLabel setText:_templateModel.album_desc];
    [_bgImgView addSubview:_classLabel];
    [_classLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(_bgImgView.mas_width).with.offset(-20);
        make.centerY.equalTo(_bgImgView.mas_centerY).with.multipliedBy(4.0 / 3);
        make.left.equalTo(_nameLabel.mas_left);
        make.height.equalTo(@(16));
    }];
}

#pragma mark - Network
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if (success) {
        NSMutableArray *indexArray = [NSMutableArray array];
        NSArray *data = [result valueForKey:@"data"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        for (id sub in data) {
            NSError *error;
            GrowSetTemplateModel *model = [[GrowSetTemplateModel alloc] initWithDictionary:sub error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [model calculateDescRects];
            [indexArray addObject:model];
        }
        if ([indexArray count] > 0) {
            GrowSetTemplateModel *model = [indexArray objectAtIndex:0];
            //跨页时，如果为单页，删除最后一个
            if (([_termGrow.is_double integerValue] == 1) && ([model.list count] % 2 == 1)) {
                [model.list removeObjectAtIndex:[model.list count] - 1];
            }
            self.dataSource = model.list;
        }else {
            [self.view makeToast:@"当前没有可添加模板" duration:1.0 position:@"center"];
            self.dataSource = nil;
        }
    }
    else{
        self.dataSource = nil;
        NSString *str = [result valueForKey:@"message"];
        str = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
    [_collectionView reloadData];
}

#pragma mark - SelectTemplateSingleCellDelegate
- (void)checkSelectTemplateCellBtn:(SelectTemplateSingleCell *)cell Options:(NSArray *)array
{
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    if ([_recordIndexPathArray containsObject:indexPath]) {
        [_recordIndexPathArray removeObject:indexPath];
        cell.checkBtn.selected = NO;
    }
    else{
        if (_recordIndexPathArray.count >= _nMaxCount) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的模板已超过最大数量限制，无法继续添加。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
            [alert show];
            return;
        }
        [_recordIndexPathArray addObject:indexPath];
        cell.checkBtn.selected = YES;
    }
}

#pragma mark - EnsureTemplateViewControllerDelegate
- (void)changeSelectIndexPathItems:(BOOL)checked At:(NSIndexPath *)indexPath
{
    SelectTemplateSingleCell *cell = (SelectTemplateSingleCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    cell.checkBtn.selected = checked;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([_termGrow.is_double integerValue] == 1) {
        return ([self.dataSource count] + 1) / 2;
    }
    return [self.dataSource count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
    CGFloat ratio = 1080.0 / 1512;
    TemplateItem *item = [self.dataSource firstObject];
    if (item.template_width.integerValue != 0 && item.template_height.integerValue != 0) {
        ratio = item.template_width.floatValue / item.template_height.floatValue;
    }
    NSInteger page = isDouble ? 2 : 1,perNums = isDouble ? 2 : 3;
    CGFloat margin = 10;
    CGFloat itemWei = (SCREEN_WIDTH - margin * (perNums + 1)) / perNums,itemHei = (itemWei / page) / ratio + 30;
    return CGSizeMake(itemWei, itemHei);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
    NSString *str = isDouble ? @"SelectTemplateDoubleCell" : @"SelectTemplateSingleCell";
    SelectTemplateSingleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:str forIndexPath:indexPath];
    cell.delegate = self;
    NSArray *arr = nil;
    if (isDouble) {
        NSInteger newIdx = indexPath.item * 2;
        arr = @[self.dataSource[newIdx],self.dataSource[newIdx + 1]];
    }
    else{
        arr = @[self.dataSource[indexPath.item]];
    }
    BOOL isChecked = [_recordIndexPathArray containsObject:indexPath];
    [cell resetDataSource:arr Checked:isChecked];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithCapacity:15];
//    for (NSIndexPath *index in _recordIndexPathArray) {
//        [tempArr addObject:[NSString stringWithFormat:@"%ld",(long)index.item]];
//    }
    EnsureTemplateViewController *templateController = [[EnsureTemplateViewController alloc] init];
    templateController.delegate = self;
    templateController.termGrow = _termGrow;
    templateController.currIndex = indexPath.item;
    templateController.templateModel = _templateModel;
    templateController.dataSource = self.dataSource;
    templateController.recordIndexArray = _recordIndexPathArray;
    templateController.totalCount = _nMaxCount;
    [self.navigationController pushViewController:templateController animated:YES];
}

@end
