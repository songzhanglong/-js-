//
//  SetTemplateViewController.m
//  NewTeacher
//
//  Created by zhangxs on 16/1/25.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "SetTemplateViewController.h"
#import "Toast+UIView.h"
#import "GrowTemplateModel.h"
#import "GrowSetTemplateModel.h"
#import "EditSigleTemplateViewController.h"
#import "GrowAlertView.h"
#import "SelectTemplateViewController.h"
#import "GrowNewViewController.h"
#import "TermGrowList.h"
#import "GrowNewDetailController.h"
#import "XWDragCellCollectionView.h"
#import "MJRefresh.h"
#import "EditGrowDoubleCollectionCell.h"

@interface SetTemplateViewController ()<GrowEditCollectionCellDelegate,GrowAlertViewDelegate,EditSigleTemplateDelegate,UIAlertViewDelegate,XWDragCellCollectionViewDataSource, XWDragCellCollectionViewDelegate>

@end

@implementation SetTemplateViewController 
{
    NSIndexPath *_indexPath,*_editIndexPath,*_deleteIndexPath;
    MJRefreshHeaderView *_headerRefresh;
    UICollectionView *_collectionView;
    NSMutableArray *_sort_list;
    UIImageView *navBarHairlineImageView;
}

- (void)dealloc
{
    [_headerRefresh free];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showBack = YES;
    UIImageView *bgImgView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"grow_bg@2x")];
    bgImgView.frame = self.view.bounds;
    [self.view addSubview:bgImgView];
    
    UIButton *leftBut = (UIButton *)((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView;
    [leftBut setFrame:CGRectMake(0, 0, 40, 30)];
    [leftBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backL@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [self setRightNavButton];
    
    //视图
    CGFloat margin = 5;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = margin;
    layout.minimumInteritemSpacing = margin;
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    _collectionView = [[XWDragCellCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    _collectionView.backgroundView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"grow_bg@2x")];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    ((XWDragCellCollectionView *)_collectionView).shakeLevel = 3.0f;
    ((XWDragCellCollectionView *)_collectionView).isDouble = ([_termGrow.is_double integerValue] == 1);
    [_collectionView registerClass:[EditGrowSingleCollectionCell class] forCellWithReuseIdentifier:@"EditGrowSingleCollectionCell"];
    [_collectionView registerClass:[EditGrowDoubleCollectionCell class] forCellWithReuseIdentifier:@"EditGrowDoubleCollectionCell"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GrowMakeCellHeader"];
    [self.view addSubview:_collectionView];
    
    __weak typeof(self)weakSelf = self;
    MJRefreshHeaderView *hView = [MJRefreshHeaderView header];
    hView.scrollView = _collectionView;
    hView.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView){
        [weakSelf refreshTemplateList];
    };
    hView.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
        //NSLog(@"刷新完毕");
    };
    _headerRefresh = hView;
    
    [_headerRefresh beginRefreshing];
}

#pragma mark - appear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = CreateColor(70, 57, 53);
    }
    else
    {
        navBar.tintColor = CreateColor(70, 57, 53);
    }
    
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    navBarHairlineImageView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_isBeginRefresh) {
        _isBeginRefresh = NO;
        [_headerRefresh beginRefreshing];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = [UIColor whiteColor];
    }
    else
    {
        navBar.tintColor = CreateColor(233.0, 233.0, 233.0);
    }
    
    navBarHairlineImageView.hidden = NO;
}

#pragma mark - StatusBarStyle
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Private Methods
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (TemplateItem *)fintEditItemAt:(NSIndexPath *)indexPath
{
    GrowSetTemplateModel *model = self.dataSource[indexPath.section];
    BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
    if (isDouble) {
        return model.list[indexPath.item * 2];
    }
    else{
        return model.list[indexPath.item];
    }
}

- (NSMutableArray *)checkSortListArray
{
    NSMutableArray *list = [NSMutableArray array];
    
    for (NSInteger i = 0; i < [self.dataSource count]; i++) {
        GrowSetTemplateModel *templateModel = self.dataSource[i];
        NSMutableArray *tmpArr = [NSMutableArray array];
        for (NSInteger j = 0; j < [templateModel.list count]; j++) {
            TemplateItem *item = templateModel.list[j];
            [tmpArr addObject:item.template_id];
        }
        NSString *template_ids = [tmpArr componentsJoinedByString:@","];
        NSDictionary *dic = @{@"template_ids":template_ids,@"album_id":templateModel.album_id};
        [list addObject:dic];
    }
    
    return list;
}

- (void)setRightNavButton
{
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    rightView.backgroundColor = [UIColor clearColor];
    rightView.userInteractionEnabled = YES;
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, 0, 50.0, 30.0);
    addBtn.backgroundColor = [UIColor clearColor];
    [addBtn setTitle:@"+新增" forState:UIControlStateNormal];
    [addBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(rightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:addBtn];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightButtonItem];
}

#pragma mark- Actions
- (void)backToPreControl:(id)sender
{
    for (UIViewController *control in self.navigationController.viewControllers) {
        if ([control isKindOfClass:[GrowNewViewController class]]) {
            GrowNewViewController *controller = (GrowNewViewController *)control;
            controller.shouldRefresh = _isEditRefresh;
        }else if ([control isKindOfClass:[GrowNewDetailController class]]) {
            GrowNewDetailController *controller = (GrowNewDetailController *)control;
            controller.shouldRefresh = _isEditRefresh;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBtnAction:(UIButton *)btn
{
    NSInteger count = 0;
    for (GrowSetTemplateModel *tempModel in self.dataSource) {
        count += [tempModel.list count];
    }
    if (count >= 30) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的模板已超过最大数量限制，无法继续添加。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
        [alert show];
        return;
    }
    
    BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
    NSInteger page = isDouble ? 2 : 1;
    SelectTemplateViewController *selectController = [[SelectTemplateViewController alloc] init];
    selectController.termGrow = _termGrow;
    selectController.nMaxCount = (30 - count) / page;
    [self.navigationController pushViewController:selectController animated:YES];
}

- (void)editSectionOrAddTemplate:(id)sender
{
    NSInteger section = [sender tag] % 10000;
    NSInteger idx = [sender tag] / 10000 - 1;
    switch (idx) {
        case 0:
        {
            //向下
            if (section == [self.dataSource count] - 1) {
                [self.view makeToast:@"该主题无法下移哦" duration:1.0 position:@"center"];
                return;
            }
            [self.dataSource exchangeObjectAtIndex:section withObjectAtIndex:section + 1];
            [_collectionView reloadData];
            
            //提交顺序修改
            [self commitSortListOfNew];
        }
            break;
        case 1:
        {
            //向上
            if (section == 0) {
                [self.view makeToast:@"该主题无法上移哦" duration:1.0 position:@"center"];
                return;
            }
            [self.dataSource exchangeObjectAtIndex:section withObjectAtIndex:section - 1];
            [_collectionView reloadData];

            //提交顺序修改
            [self commitSortListOfNew];
        }
            break;
        case 2:
        {
            //添加
            NSInteger count = 0;
            for (GrowSetTemplateModel *tempModel in self.dataSource) {
                count += [tempModel.list count];
            }
            if (count >= 30) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的模板已超过最大数量限制，无法继续添加。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
                [alert show];
                return;
            }
            
            //add
            GrowSetTemplateModel *model = [self.dataSource objectAtIndex:section];
            SelectTemplateViewController *selectController = [[SelectTemplateViewController alloc] init];
            selectController.templateModel = model;
            selectController.termGrow = _termGrow;
            BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
            NSInteger page = isDouble ? 2 : 1;
            selectController.nMaxCount = (30 - count) / page;
            [self.navigationController pushViewController:selectController animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 刷新数据
- (void)refreshTemplateList
{
    __weak typeof(self)weakSelf = self;
    NSString *url = [URLFACE stringByAppendingString:@"grow:set_template_list"];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSDictionary *dic = @{@"class_id":manager.userInfo.classid ?: @"",@"teacher_id":manager.userInfo.userid ?: @"",@"album_flag":@"1",@"term_id":_termGrow.term_id ?: @"",@"templist_id":_termGrow.templist_id ?: @""};
    
    self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf refreshTemplateListFinish:success Data:data];
        });
    } failedBlock:^(NSString *description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf refreshTemplateListFinish:NO Data:nil];
        });
    }];
}

- (void)refreshTemplateListFinish:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    [_headerRefresh endRefreshing];
    if (!suc) {
        NSString *str = [result valueForKey:@"message"];
        str = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
    else
    {
        NSArray *dataList = [result valueForKey:@"data"];
        if (dataList && [dataList isKindOfClass:[NSArray class]]) {
            self.dataSource = [GrowSetTemplateModel arrayOfModelsFromDictionaries:dataList error:nil];
            BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
            //跨页时，如果为单页，删除最后一个
            if (isDouble) {
                for (GrowSetTemplateModel *model in self.dataSource) {
                    if ([model.list count] % 2 == 1) {
                        [model.list removeObjectAtIndex:[model.list count] - 1];
                    }
                }
            }
            
            _sort_list = [self checkSortListArray];
        }
        else{
            self.dataSource = nil;
        }
        [_collectionView reloadData];
    }
}

#pragma mark - 模板页排序
- (void)commitSortListOfNew
{
    NSMutableArray *listArr = [self checkSortListArray];
    if ([_sort_list isEqualToArray:listArr]) {
        return;
    }
    _sort_list = listArr;
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSDictionary *dic = @{@"term_id":_termGrow.term_id,@"class_id":manager.userInfo.classid,@"teacher_id":manager.userInfo.userid,@"sort_list":_sort_list};
    
    [DJTHttpClient asynchronousNormalRequest:[URLFACE stringByAppendingString:@"grow:set_template_sort"] parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        NSLog(@"%@",data);
    } failedBlock:^(NSString *description) {
        NSLog(@"%@",description);
    }];
}

#pragma mark - GrowEditCollectionCellDelegate
//type:0-新增，1-删除，2-改名
- (void)editCollectionCell:(UICollectionViewCell *)curCell Type:(NSInteger)type Options:(NSArray *)array
{
    switch (type) {
        case 1:
        {
            NSIndexPath *indexPath = [_collectionView indexPathForCell:curCell];
            _deleteIndexPath = indexPath;
            TemplateItem *item = [self fintEditItemAt:indexPath];
            
            GrowSetTemplateModel *model = [self.dataSource objectAtIndex:indexPath.section];
            
            NSInteger limit = (_termGrow.is_double.integerValue == 1) ? 2 : 1;
            if ([item.template_used_flag integerValue] == 1 && [model.list count] == limit) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"该模板已经设置过，并且为最后一张，您确定删除吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alertView show];
            }else if ([item.template_used_flag integerValue] == 1 && [model.list count] > limit){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"该模板已经设置过，您确定删除吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alertView show];
            }else if ([item.template_used_flag integerValue] != 1 && [model.list count] == limit){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"该模板为最后一张，您确定删除吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alertView show];
            }
            else{
                [self sendDeleteRequest];
            }
        }
            break;
        case 2:
        {
            NSIndexPath *indexPath = [_collectionView indexPathForCell:curCell];
            TemplateItem *item = [self fintEditItemAt:indexPath];
            _editIndexPath = indexPath;
            
            GrowAlertView *alertView = [[GrowAlertView alloc] initWithFrame:self.view.window.bounds];
            [alertView setTag:101];
            alertView.delegate = self;
            [self.view.window addSubview:alertView];
            [alertView setDefaultTheme:item.template_title];
        }
            break;
        default:
            break;
    }
}

#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.dataSource count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    GrowSetTemplateModel *model = [self.dataSource objectAtIndex:section];
    BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
    if (isDouble) {
        return ([model.list count] + 1) / 2;
    }
    return [model.list count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
    CGFloat imgWei = !isDouble ? ((SCREEN_WIDTH - 5 * 4) / 3) : ((SCREEN_WIDTH - 5 * 3) / 2);
    
    //CGFloat hei = 156.0;
    CGFloat ratio = 1080.0 / 1512;
    GrowSetTemplateModel *model = [self.dataSource objectAtIndex:indexPath.section];
    TemplateItem *item = [model.list firstObject];
    if (item.template_width.integerValue != 0 && item.template_height.integerValue != 0) {
        ratio = item.template_width.floatValue / item.template_height.floatValue;
    }
    //CGFloat imgWei = (hei - 15 - 24) * ratio;
    CGFloat imgHei = (imgWei - 24) / (ratio * (isDouble ? 2 : 1));
    
//    if (isDouble) {
//        return CGSizeMake(imgWei * 2 + 24, hei);
//    }
    return CGSizeMake(imgWei, imgHei + 15 + 24);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
    NSString *identifier = isDouble ? @"EditGrowDoubleCollectionCell" : @"EditGrowSingleCollectionCell";
    AddItemCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    
    GrowSetTemplateModel *model = [self.dataSource objectAtIndex:indexPath.section];
    if (isDouble) {
        TemplateItem *item = [model.list objectAtIndex:indexPath.item * 2];
        TemplateItem *nextItem = [model.list objectAtIndex:indexPath.item * 2 + 1];
        [cell resetContentData:@[item,nextItem]];
    }
    else{
        TemplateItem *item = [model.list objectAtIndex:indexPath.item];
        [cell resetContentData:@[item]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    GrowSetTemplateModel *model = [self.dataSource objectAtIndex:indexPath.section];
    EditSigleTemplateViewController *templateController = [[EditSigleTemplateViewController alloc] init];
    templateController.termGrow = _termGrow;
    templateController.currIndex = indexPath.item;
    templateController.templateModel = model;
    templateController.dataSource = model.list;
    templateController.delegate = self;
    [self.navigationController pushViewController:templateController animated:YES];
}

- (NSArray *)dataSourceArrayOfCollectionView:(XWDragCellCollectionView *)collectionView{
    return self.dataSource;
}

- (void)dragCellCollectionView:(XWDragCellCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray{
    //self.dataSource = (NSMutableArray *)newDataArray;
}

- (void)dragCellCollectionViewCellEndMoving:(XWDragCellCollectionView *)collectionView{
    BOOL shouleReload = NO;
    NSMutableArray *tempArr = [NSMutableArray array];
    [tempArr addObjectsFromArray:self.dataSource];
    for (int i = 0; i < [self.dataSource count]; i++) {
        GrowSetTemplateModel *model = self.dataSource[i];
        if ([model.list count] == 0) {
            [tempArr removeObject:model];
            shouleReload = YES;
        }
    }
    if (shouleReload) {
        self.dataSource = tempArr;
        [_collectionView reloadData];
    }

    //提交顺序修改
    [self commitSortListOfNew];
}

#pragma mark - 头视图
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(SCREEN_WIDTH, 30);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *view =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GrowMakeCellHeader" forIndexPath:indexPath];
        
        //先清除历史数据
        for (UIView *sub in view.subviews) {
            if (sub.tag > 0 && [sub isKindOfClass:[UIButton class]]) {
                [sub removeFromSuperview];
            }
        }
        
        //标签
        UILabel *label = (UILabel *)[view viewWithTag:200];
        if (!label) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, view.frameWidth - 20, 20)];
            //[label setBackgroundColor:view.backgroundColor];
            [label setFont:[UIFont systemFontOfSize:16]];
            [label setTextColor:[UIColor whiteColor]];
            [label setTag:200];
            [view addSubview:label];
        }
        
        GrowSetTemplateModel *model = [self.dataSource objectAtIndex:indexPath.section];
        [label setText:model.album_title ?: @""];
        
        NSArray *imgsN = @[@"template_nor_down",@"template_nor_up",@"tempalte_nor_add_temp"];
        NSArray *imgsH = @[@"template_sel_down",@"template_sel_up",@"tempalte_sel_add_temp"];
        for (int i = 0; i < 3; i++) {
            UIButton *btn = (UIButton *)[view viewWithTag:(i + 1) * 10000 + indexPath.section];
            if (!btn) {
                btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setFrame:CGRectMake(SCREEN_WIDTH - 100 + 35 * i, 2.5, 25, 25)];
                [btn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
                [btn setImage:CREATE_IMG(imgsN[i]) forState:UIControlStateNormal];
                [btn setImage:CREATE_IMG(imgsH[i]) forState:UIControlStateHighlighted];
                [btn setTag:(i + 1) * 10000 + indexPath.section];
                [btn addTarget:self action:@selector(editSectionOrAddTemplate:) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:btn];
            }
        }
        
        return view;
    }
    
    return nil;
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

- (void)sendDeleteRequest
{
    self.view.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    __weak __typeof(self)weakSelf = self;
    NSMutableArray *tempArray = [NSMutableArray array];
    GrowSetTemplateModel *model = self.dataSource[_deleteIndexPath.section];
    BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
    if (isDouble) {
        TemplateItem *item = [model.list objectAtIndex:_deleteIndexPath.item * 2];
        [tempArray addObject:item.template_id];
        item = [model.list objectAtIndex:_deleteIndexPath.item * 2 + 1];
        [tempArray addObject:item.template_id];
    }
    else{
        TemplateItem *item = [model.list objectAtIndex:_deleteIndexPath.item];
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

#pragma mark - delete Request
- (void)delTelmateFinish:(id)data Suc:(BOOL)suc
{
    self.httpOperation = nil;
    self.view.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    
    if (suc) {
        _isEditRefresh = YES;
        GrowSetTemplateModel *model = [self.dataSource objectAtIndex:_deleteIndexPath.section];
        BOOL isDouble = ([_termGrow.is_double integerValue] == 1);
        if (isDouble) {
            NSInteger newIdx = _deleteIndexPath.item * 2;
            [model.list removeObjectAtIndex:newIdx + 1];
            [model.list removeObjectAtIndex:newIdx];
        }
        else{
            [model.list removeObjectAtIndex:_deleteIndexPath.item];
        }
        //类型判断
        if ([model.list count] == 0) {
            [self.dataSource removeObjectAtIndex:_deleteIndexPath.section];
            [_collectionView deleteSections:[NSIndexSet indexSetWithIndex:_deleteIndexPath.section]];
        }else{
            [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:_deleteIndexPath.section]];
        }
        _deleteIndexPath = nil;
        [self.view makeToast:@"模板删除成功" duration:1.0 position:@"center"];
    }else {
        NSString *str = [data valueForKey:@"message"];
        str = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - EditSigleTemplateViewControllerDelegate
- (void)reloadEditTheme:(TemplateItem *)item AtIndex:(NSInteger)index
{
    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:_indexPath.section]];
}

- (void)reloadPagedFlowView:(NSInteger)index
{
    GrowSetTemplateModel *model = [self.dataSource objectAtIndex:_indexPath.section];
    //类型判断
    if ([model.list count] == 0) {
        [self.dataSource removeObjectAtIndex:_indexPath.section];
        [_collectionView deleteSections:[NSIndexSet indexSetWithIndex:_indexPath.section]];
    }else{
        [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:_indexPath.section]];
    }
}

#pragma mark add template refresh table view
- (void)addDataToRefresh:(id)source
{
    _isEditRefresh = YES;
    GrowSetTemplateModel *addModel = (GrowSetTemplateModel *)source;
    NSInteger index = [self.dataSource indexOfObject:addModel];
    
    if (index != NSNotFound) {
        [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:index]];
    }else{
        _isBeginRefresh = YES;
    }
}

#pragma mark - GrowAlertViewDelegate
- (void)closeGrowAlertView
{
    GrowAlertView *alertView = (GrowAlertView *)[self.view.window viewWithTag:101];
    if (alertView) {
        [alertView removeFromSuperview];
    }
}

- (void)submitThemeToGrowAlertView:(NSString *)theme
{
    //submit
    TemplateItem *item = [self fintEditItemAt:_editIndexPath];
    self.view.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    __weak __typeof(self)weakSelf = self;
    NSString *url = [URLFACE stringByAppendingString:@"grow:set_template_title"];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSDictionary *dic = @{@"class_id": manager.userInfo.classid,@"teacher_id":manager.userInfo.userid,@"template_id":item.template_id,@"template_title":theme,@"templist_id":_termGrow.templist_id,@"term_id":_termGrow.term_id};
    self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf editTelmateFinish:data Suc:success Title:theme];
        });
    } failedBlock:^(NSString *description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf editTelmateFinish:nil Suc:NO Title:theme];
        });
    }];
}

#pragma mark - edit title Request
- (void)editTelmateFinish:(id)data Suc:(BOOL)suc Title:(NSString *)theme
{
    self.httpOperation = nil;
    self.view.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    
    if (suc) {
        id result = [data valueForKey:@"data"];
        result = (!result || [result isKindOfClass:[NSNull class]]) ? [NSDictionary dictionary] : result;
        NSString *image_thumb_url = [result valueForKey:@"image_thumb_url"];
        image_thumb_url = (!image_thumb_url || [image_thumb_url isKindOfClass:[NSNull class]]) ? @"" : image_thumb_url;
        
        NSString *image_url = [result valueForKey:@"image_url"];
        image_url = (!image_url || [image_url isKindOfClass:[NSNull class]]) ? @"" : image_url;
        
        GrowSetTemplateModel *model = [self.dataSource objectAtIndex:_editIndexPath.section];
        TemplateItem *edit_item = [self fintEditItemAt:_editIndexPath];
        for (TemplateItem *item in model.list) {
            if ([item.template_id isEqualToString:edit_item.template_id]) {
                item.template_title = theme;
                item.template_path_thumb = [image_thumb_url length] > 0 ? image_thumb_url : edit_item.template_path_thumb;
                item.template_path = [image_url length] > 0 ? image_url : edit_item.template_path;
                break;
            }
        }
        [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:_editIndexPath.section]];
        _editIndexPath = nil;
        [self.view makeToast:@"模板主题修改成功" duration:1.0 position:@"center"];
    }else {
        NSString *str = [data valueForKey:@"message"];
        str = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self sendDeleteRequest];
    }
}

@end
