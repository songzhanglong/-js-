//
//  EnsureTemplateViewController.m
//  NewTeacher
//
//  Created by zhangxs on 16/1/26.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "EnsureTemplateViewController.h"
#import "Toast+UIView.h"
#import "AddTemplateViewController.h"
#import "NSString+Common.h"
#import "TermGrowList.h"
#import "SetTemplateViewController.h"
#import <Masonry.h>
#import "JSCarouselLayout.h"
#import "SelectTemplateDoubleCell.h"

@interface EnsureTemplateViewController ()

@property (nonatomic,assign)CGFloat ratioTemplate;

@end

@implementation EnsureTemplateViewController
{
    NSInteger _nMaxCount;
    BOOL _isLoaded;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _ratioTemplate = 1080.0 / 1512;
    if (self.dataSource && [self.dataSource count] > 0) {
        TemplateItem *item = [self.dataSource firstObject];
        if (item.template_width.integerValue != 0 && item.template_height.integerValue != 0) {
            _ratioTemplate = item.template_width.floatValue / item.template_height.floatValue;
        }
    }
    //label
    UILabel *_label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 30, 30)];
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont systemFontOfSize:14];
    _label.text = @"选择新增成长档案对应的模板";
    [self.view addSubview:_label];
    
    BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
    NSInteger count = [self.dataSource count];
    _nMaxCount = isDouble ? ((count + 1) / 2) : count;
    NSInteger pageCount = isDouble ? 2 : 1;
    CGFloat maxImgHei = SCREEN_HEIGHT - (_templateModel ? 90 : 0) - 64 - 30 - 30,maxImgWei = SCREEN_WIDTH - 20;
    CGFloat wei = maxImgHei * _ratioTemplate * pageCount,hei = maxImgHei;
    if (wei > maxImgHei) {
        wei = maxImgWei;
        hei = (wei / pageCount) / _ratioTemplate + 30;
    }
    
    JSCarouselLayout *layout                = [[JSCarouselLayout alloc] init];
    __weak typeof (self)weakSelf            = self;
    layout.carouselSlideIndexBlock          = ^(NSInteger index){
        weakSelf.currIndex = index;
    };
    layout.visibleCount = 3;
    layout.itemSize = CGSizeMake(wei, hei);
    [self createCollectionViewLayout:layout Action:nil Param:nil Header:NO Foot:NO];
    [_collectionView setAutoresizingMask:UIViewAutoresizingNone];
    [_collectionView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, maxImgHei + 30)];
    NSString *str = isDouble ? @"SelectTemplateDoubleCell" : @"SelectTemplateSingleCell";
    [_collectionView registerClass:NSClassFromString(str) forCellWithReuseIdentifier:str];
    
    if (_templateModel) {
        [self setFooterView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_isLoaded) {
        _isLoaded = YES;
        if (_currIndex != 0) {
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }
    }
}

#pragma mark - UI
- (void)setRightNavButton
{
    //right
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    rightView.backgroundColor = [UIColor clearColor];
    rightView.userInteractionEnabled = YES;
        
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, 0, 50.0, 30.0);
    addBtn.backgroundColor = [UIColor clearColor];
    [addBtn setTag:1];
    [addBtn setTitle:@"确定" forState:UIControlStateNormal];
    [addBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(rightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:addBtn];
        
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightButtonItem];
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

#pragma mark - actions
- (void)rightBtnAction:(UIButton *)btn
{
    if ([_recordIndexArray count] > 0) {
        NSMutableArray *tempArray = [NSMutableArray array];
        BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
        for (NSIndexPath *indexPath in _recordIndexArray) {
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
    [self.view hideToastActivity];
     UIBarButtonItem *item = [self.navigationItem.rightBarButtonItems lastObject];
     item.enabled = YES;
    
    if (suc) {
        
        for (UIViewController *control in self.navigationController.viewControllers) {
            if ([control isKindOfClass:[SetTemplateViewController class]]) {
                BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
                NSMutableArray *tempArray = [NSMutableArray array];
                for (NSIndexPath *indexPath in _recordIndexArray) {
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

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _nMaxCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
    NSString *str = isDouble ? @"SelectTemplateDoubleCell" : @"SelectTemplateSingleCell";
    SelectTemplateSingleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:str forIndexPath:indexPath];
    
    NSArray *arr = nil;
    if (isDouble) {
        NSInteger newIdx = indexPath.item * 2;
        arr = @[self.dataSource[newIdx],self.dataSource[newIdx + 1]];
    }
    else{
        arr = @[self.dataSource[indexPath.item]];
    }
    BOOL isChecked = [_recordIndexArray containsObject:indexPath];
    cell.checkBtn.userInteractionEnabled = NO;
    [cell resetDataSource:arr Checked:isChecked];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SelectTemplateSingleCell *cell = (SelectTemplateSingleCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([_recordIndexArray containsObject:indexPath]) {
        [_recordIndexArray removeObject:indexPath];
        cell.checkBtn.selected = NO;
    }
    else{
        if (_recordIndexArray.count >= _totalCount) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的模板已超过最大数量限制，无法继续添加。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
            [alert show];
            return;
        }
        [_recordIndexArray addObject:indexPath];
        cell.checkBtn.selected = YES;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(changeSelectIndexPathItems:At:)]) {
        [_delegate changeSelectIndexPathItems:cell.checkBtn.selected At:indexPath];
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
