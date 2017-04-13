//
//  EditSigleTemplateViewController.m
//  NewTeacher
//
//  Created by zhangxs on 16/1/27.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "EditSigleTemplateViewController.h"
#import "Toast+UIView.h"
#import "SetTemplateViewController.h"
#import "TermGrowList.h"
#import "GrowAlertView.h"
#import "NSString+Common.h"
#import <Masonry.h>
#import "JSCarouselLayout.h"
#import "EditDoubleCollectionCell.h"

@interface EditSigleTemplateViewController ()<GrowAlertViewDelegate,UIAlertViewDelegate,EditSingleCollectionCellDelegate>
{
    UIButton *_leftBtn,*_rightBtn;
    NSInteger _nMaxCount;
}

@property (nonatomic,assign)CGFloat ratioTemplate;

@end

@implementation EditSigleTemplateViewController

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
    
    BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
    NSInteger count = [self.dataSource count];
    _nMaxCount = isDouble ? ((count + 1) / 2) : count;
    NSInteger pageCount = isDouble ? 2 : 1;
    CGFloat maxImgHei = SCREEN_HEIGHT - 90 - 64 - 15 - 60,maxImgWei = SCREEN_WIDTH - 20;
    CGFloat wei = maxImgHei * _ratioTemplate * pageCount,hei = maxImgHei;
    if (wei > maxImgHei) {
        wei = maxImgWei;
        hei = (wei / pageCount) / _ratioTemplate + 60 + 15;
    }
    
    JSCarouselLayout *layout                = [[JSCarouselLayout alloc] init];
    __weak typeof (self)weakSelf            = self;
    layout.carouselSlideIndexBlock          = ^(NSInteger index){
        weakSelf.currIndex = index;
        [weakSelf resetButtonsEnable];
    };
    layout.visibleCount = 3;
    layout.itemSize = CGSizeMake(wei, hei);
    [self createCollectionViewLayout:layout Action:nil Param:nil Header:NO Foot:NO];
    [_collectionView setAutoresizingMask:UIViewAutoresizingNone];
    [_collectionView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 90 - 64)];
    NSString *str = isDouble ? @"EditDoubleCollectionCell" : @"EditSingleCollectionCell";
    [_collectionView registerClass:NSClassFromString(str) forCellWithReuseIdentifier:str];
    
    //初始化
    [self setFooterView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_currIndex != 0) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

- (TemplateItem *)getCuttentEditItem
{
    BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
    TemplateItem *item = nil;
    if (isDouble) {
        item = [self.dataSource objectAtIndex:_currIndex * 2];
    }
    else{
        item = self.dataSource[_currIndex];
    }
    return item;
}

#pragma mark - UI
- (void)setRightNavButton
{

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
    
    //ii
    UIView *lineView = [[UIView alloc] init];
    [lineView setTranslatesAutoresizingMaskIntoConstraints:NO];
    lineView.backgroundColor = CreateColor(235, 166, 44);
    [mview addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(20));
        make.height.equalTo(@(13));
        make.left.equalTo(@(45));
        make.width.equalTo(@(4));
    }];
    
    //title
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = CreateColor(235, 166, 44);
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [titleLabel setText:_templateModel.album_title];
    [mview addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lineView.mas_right).with.offset(5);
        make.centerY.equalTo(lineView.mas_centerY);
        make.width.equalTo(mview.mas_width).with.offset(50);
        make.height.equalTo(@(26));
    }];
    
    UILabel *contLabel = [[UILabel alloc] init];
    [contLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    contLabel.backgroundColor = [UIColor clearColor];
    contLabel.textColor = [UIColor whiteColor];
    contLabel.font = [UIFont systemFontOfSize:14];
    contLabel.numberOfLines = 0;
    contLabel.text = _templateModel.album_desc;
    [mview addSubview:contLabel];
    [contLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lineView.mas_left);
        make.top.equalTo(titleLabel.mas_bottom).with.offset(5);
        make.width.equalTo(@(_templateModel.contSize.width));
        make.height.equalTo(@(_templateModel.contSize.height));
    }];
    
    //button
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    _leftBtn = leftBtn;
    [leftBtn setImage:CREATE_IMG(@"grow_set_left_1@2x") forState:UIControlStateNormal];
    [leftBtn setImage:CREATE_IMG(@"grow_set_left@2x") forState:UIControlStateDisabled];
    [leftBtn addTarget:self action:@selector(leftOrRightAction:) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setTag:1];
    [mview addSubview:leftBtn];
    [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(5));
        make.centerY.equalTo(mview.mas_centerY);
        make.width.equalTo(@(30));
        make.height.equalTo(@(30));
    }];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    _rightBtn = rightBtn;
    [rightBtn setImage:CREATE_IMG(@"grow_set_right_1@2x") forState:UIControlStateNormal];
    [rightBtn setImage:CREATE_IMG(@"grow_set_right@2x") forState:UIControlStateDisabled];
    [rightBtn addTarget:self action:@selector(leftOrRightAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTag:2];
    [mview addSubview:rightBtn];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-5));
        make.centerY.equalTo(mview.mas_centerY);
        make.width.equalTo(@(30));
        make.height.equalTo(@(30));
    }];
    
    [self resetButtonsEnable];
}

- (void)resetButtonsEnable
{
    _leftBtn.enabled = (_currIndex != 0);
    _rightBtn.enabled = ((_nMaxCount - 1) > _currIndex);
}

- (void)leftOrRightAction:(UIButton *)btn
{
    NSInteger index = btn.tag - 1;
    switch (index) {
        case 0:
        {
            _currIndex--;
        }
            break;
        case 1:
        {
            _currIndex++;
        }
            break;
        default:
            break;
    }
    [self resetButtonsEnable];
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark - EditSingleCollectionCellDelegate
//index:1-删除，2-编辑
- (void)beginEditSingleCollectionCell:(UICollectionViewCell *)cell At:(NSInteger)index Options:(NSArray *)array
{
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    _currIndex = indexPath.item;
    switch (index) {
        case 1:
        {
            NSInteger limit = (_termGrow.is_double.integerValue == 1) ? 2 : 1;
            TemplateItem *item = [self.dataSource objectAtIndex:_currIndex];
            if ([item.template_used_flag integerValue] == 1 && [self.dataSource count] == limit) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"该模板已经设置过，并且为最后一张，您确定删除吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alertView setTag:171];
                [alertView show];
            }else if ([item.template_used_flag integerValue] == 1 && [self.dataSource count] > limit){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"该模板已经设置过，您确定删除吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alertView setTag:171];
                [alertView show];
            }else if ([item.template_used_flag integerValue] != 1 && [self.dataSource count] == limit){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"该模板为最后一张，您确定删除吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alertView setTag:171];
                [alertView show];
            }
            else{
                [self sendDeleteRequest];
            }
        }
            break;
        case 2:
        {
            
            TemplateItem *item = [self getCuttentEditItem];
            GrowAlertView *alertView = [[GrowAlertView alloc] initWithFrame:self.view.window.bounds];
            [alertView setTag:100];
            alertView.delegate = self;
            [self.view.window addSubview:alertView];
            [alertView setDefaultTheme:item.template_title];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _nMaxCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
    NSString *str = isDouble ? @"EditDoubleCollectionCell" : @"EditSingleCollectionCell";
    EditSingleCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:str forIndexPath:indexPath];
    cell.delegate = self;
    
    NSArray *arr = nil;
    if (isDouble) {
        NSInteger newIdx = indexPath.item * 2;
        arr = @[self.dataSource[newIdx],self.dataSource[newIdx + 1]];
    }
    else{
        arr = @[self.dataSource[indexPath.item]];
    }
    [cell resetDataSource:arr];
    
    return cell;
}

#pragma mark - Request
- (void)sendDeleteRequest
{
    self.view.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    __weak __typeof(self)weakSelf = self;
    NSMutableArray *tempArray = [NSMutableArray array];
    BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
    if (isDouble) {
        TemplateItem *item = [self.dataSource objectAtIndex:_currIndex * 2];
        [tempArray addObject:item.template_id];
        item = [self.dataSource objectAtIndex:_currIndex * 2 + 1];
        [tempArray addObject:item.template_id];
    }
    else{
        TemplateItem *item = self.dataSource[_currIndex];
        [tempArray addObject:item.template_id];
    }
    NSString *url = [URLFACE stringByAppendingString:@"grow:set_template_del"];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSDictionary *dic = @{@"class_id": manager.userInfo.classid,@"teacher_id":manager.userInfo.userid,@"template_ids":[tempArray componentsJoinedByString:@","],@"term_id":_termGrow.term_id,@"templist_id":_termGrow.templist_id};
    self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf delTelmateFinish:data Suc:success];
        });
        
    } failedBlock:^(NSString *description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf delTelmateFinish:nil Suc:NO];
        });
        
    }];
}

- (void)delTelmateFinish:(id)data Suc:(BOOL)suc
{
    self.httpOperation = nil;
    self.view.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    if (suc) {
        _nMaxCount--;

        BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
        if (isDouble) {
            NSInteger newIdx = _currIndex * 2;
            [self.dataSource removeObjectAtIndex:newIdx + 1];
            [self.dataSource removeObjectAtIndex:newIdx];
        }
        else{
            [self.dataSource removeObjectAtIndex:_currIndex];
        }
        [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_currIndex inSection:0]]];
        if ([_delegate respondsToSelector:@selector(reloadPagedFlowView:)]) {
            [_delegate reloadPagedFlowView:_currIndex];
        }
        if (_currIndex > _nMaxCount - 1) {
            _currIndex--;
        }
        [self resetButtonsEnable];
        
        [self.navigationController.view makeToast:@"模板删除成功" duration:1.0 position:@"center"];
        for (UIViewController *control in self.navigationController.viewControllers) {
            if ([control isKindOfClass:[SetTemplateViewController class]]) {
                if (_nMaxCount == 0) {
                    [self.navigationController popToViewController:control animated:YES];
                }
                break;
            }
        }
        
    }else {
        NSString *str = [data valueForKey:@"message"];
        str = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark GrowAlertView delegate
- (void)closeGrowAlertView
{
    GrowAlertView *alertView = (GrowAlertView *)[self.view.window viewWithTag:100];
    if (alertView) {
        [alertView removeFromSuperview];
    }
}
- (void)submitThemeToGrowAlertView:(NSString *)theme
{
    TemplateItem *item = [self getCuttentEditItem];
    
    self.view.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    __weak __typeof(self)weakSelf = self;
    NSString *url = [URLFACE stringByAppendingString:@"grow:set_template_title"];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSDictionary *dic = @{@"class_id": manager.userInfo.classid,@"teacher_id":manager.userInfo.userid,@"template_id":item.template_id,@"template_title":theme,@"term_id":_termGrow.term_id,@"templist_id":_termGrow.templist_id};
    self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf editTelmateFinish:YES Data:data Theme:theme];
        });
    } failedBlock:^(NSString *description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf editTelmateFinish:NO Data:nil Theme:theme];
        });
    }];
}

#pragma mark - network
- (void)editTelmateFinish:(BOOL)suc Data:(id)result Theme:(NSString *)theme{
    
    [self.view hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
    self.httpOperation = nil;
    if (suc) {
        id data = [result valueForKey:@"data"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSDictionary dictionary] : data;
        NSString *image_thumb_url = [data valueForKey:@"image_thumb_url"];
        image_thumb_url = (!image_thumb_url || [image_thumb_url isKindOfClass:[NSNull class]]) ? @"" : image_thumb_url;
        
        NSString *image_url = [data valueForKey:@"image_url"];
        image_url = (!image_url || [image_url isKindOfClass:[NSNull class]]) ? @"" : image_url;
        
        TemplateItem *edit_item = [self getCuttentEditItem];
        for (TemplateItem *item in self.dataSource) {
            if ([item.template_id isEqualToString:edit_item.template_id]) {
                item.template_title = theme;
                item.template_path_thumb = [image_thumb_url length] > 0 ? image_thumb_url : edit_item.template_path_thumb;
                item.template_path = [image_url length] > 0 ? image_url : edit_item.template_path;
                break;
            }
        }
        
        if ([_delegate respondsToSelector:@selector(reloadEditTheme:AtIndex:)]) {
            [_delegate reloadEditTheme:nil AtIndex:_currIndex];
        }
        
        [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_currIndex inSection:0]]];
        [self.view makeToast: @"模板主题修改成功" duration:1.0 position:@"center"];
    }
    else{
        id ret_msg = [result valueForKey:@"ret_msg"];
        [self.view makeToast:ret_msg ?: REQUEST_FAILE_TIP duration:1.0 position:@"center"];
    }
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 171 && buttonIndex == 1) {
        [self sendDeleteRequest];
    }
}

#pragma mark - lazy load

@end
