//
//  SelectCooperateViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/6/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SelectCooperateViewController.h"
#import "SelectCooperateCell.h"
#import "MJRefresh.h"
#import "NSObject+Reflect.h"
#import "Toast+UIView.h"
#import "CooperateModel.h"
#import "UIImageView+WebCache.h"
#import "TermGrowList.h"

@interface SelectCooperateViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@end

@implementation SelectCooperateViewController
{
    UICollectionView *_collectionView;
    NSMutableArray *_dataSource;
    MJRefreshHeaderView *_headerRefresh;
    UILabel *_numLabel;
    NSMutableArray *_selectArr;
    NSInteger _nSelCount;
    
    UIImageView *_tipView;
    UILabel *_tipLabel;
}

- (void)dealloc
{
    [_headerRefresh free];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.showBack = YES;
    self.titleLable.text = @"选择家长需要制作内容";
    _dataSource = [NSMutableArray array];
    _selectArr = [NSMutableArray array];
    
    //right
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
    saveBtn.backgroundColor = [UIColor clearColor];
    [saveBtn setTitle:@"?" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(checkTipInfo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightButtonItem];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
    CGFloat itemWei = 90,itemHei = 130;
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    CGFloat margin = (winSize.width - 3 * itemWei) / (3 + 1);
    layout.itemSize = CGSizeMake(itemWei, itemHei);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 50) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.backgroundColor =  CreateColor(239, 239, 239);
    [_collectionView registerClass:[SelectCooperateCell class] forCellWithReuseIdentifier:@"SelectCooperateCell"];
    [self.view addSubview:_collectionView];
    MJRefreshHeaderView *hView = [MJRefreshHeaderView header];
    hView.scrollView = _collectionView;
    __weak typeof(self)weakSelf = self;
    hView.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView){
        [weakSelf createRequest];
    };
    hView.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
    };
    _headerRefresh = hView;
    
    [_headerRefresh beginRefreshing];
    
    [self createTipView];
}
- (void)setCenterView
{
    if (_dataSource.count == 0) {
        if (!_tipView) {
            _tipView = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 111) / 2, ([UIScreen mainScreen].bounds.size.height - 64 - 94.5 - 50) / 2 - 25, 111, 94.5)];
            [_tipView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"png"]]];
            [self.view addSubview:_tipView];
        }
        else if (![_tipView isDescendantOfView:self.view])
        {
            [self.view addSubview:_tipView];
        }
        if (!_tipLabel) {
            _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, ([UIScreen mainScreen].bounds.size.height - 64 - 94.5 - 50) / 2 + 70, [UIScreen mainScreen].bounds.size.width - 100, 50)];
            _tipLabel.backgroundColor = [UIColor clearColor];
            _tipLabel.text = [NSString stringWithFormat:@"请联系园所管理员\n设置成长档案模板"];
            _tipLabel.numberOfLines = 2;
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            [self.view addSubview:_tipLabel];
        }
        else if (![_tipLabel isDescendantOfView:self.view])
        {
            [self.view addSubview:_tipLabel];
        }
    }
    else
    {
        if (_tipView && [_tipView isDescendantOfView:self.view]) {
            [_tipView removeFromSuperview];
            _tipView = nil;
        }
        if (_tipLabel && [_tipLabel isDescendantOfView:self.view]) {
            [_tipLabel removeFromSuperview];
            _tipLabel = nil;
        }
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)createTipView
{
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, winSize.height - 64 - 50, winSize.width, 50)];
    [backView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:backView];
    
    
    UILabel *sel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 40, 20)];
    [sel setText:@"已选"];
    [sel setBackgroundColor:[UIColor clearColor]];
    [backView addSubview:sel];
    
    _numLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 13, 40, 24)];
    [_numLabel setBackgroundColor:[UIColor clearColor]];
    [_numLabel setTextColor:[UIColor redColor]];
    [_numLabel setTextAlignment:1];
    [_numLabel setText:@"0"];
    [_numLabel setFont:[UIFont systemFontOfSize:24]];
    [backView addSubview:_numLabel];
    
    UILabel *lastLab = [[UILabel alloc] initWithFrame:CGRectMake(90, 15, 20, 20)];
    [lastLab setBackgroundColor:[UIColor clearColor]];
    [lastLab setText:@"张"];
    [backView addSubview:lastLab];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(winSize.width - 120 - 10, 9, 120, 32)];
    [button setBackgroundColor:CreateColor(27, 161, 1)];
    [button setTitle:@"发送给家长" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(sendToParents:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:button];
}

- (void)checkTipInfo:(id)sender
{
    //注册
    CGRect winRect = [[UIScreen mainScreen] bounds];
    UIView *fullView = [[UIView alloc] initWithFrame:winRect];
    [fullView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    fullView.alpha = 0.0;
    [self.view.window addSubview:fullView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:fullView.bounds];
    [button addTarget:self action:@selector(cancelFullView:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:[UIColor clearColor]];
    [fullView addSubview:button];
    
    //中间层
    UIView *midView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winRect.size.width - 30, winRect.size.height - 64 - 30 - 50)];
    [midView setCenter:fullView.center];
    [midView setBackgroundColor:[UIColor whiteColor]];
    midView.layer.masksToBounds = YES;
    midView.layer.cornerRadius = 2;
    [fullView addSubview:midView];
    
    //button
    NSArray *titles = @[@"什么是家庭协助?",@"家长可以编辑哪些内容?",@"家长编辑之后我们可以继续编辑么?",@"模板左下角的数字是什么意思?",@"关于模板选择标识"];
    NSArray *subTitles = @[@"家长也可以协助编辑自己孩子的成长档案。",@"家长可正常编辑您选择的成长档案。",@"可以，最终成品以老师编辑内容为主。",@"已开始编辑模板的家长数量/使用该模板的孩子数量。",@"灰色圈表示待选择；绿色圈(带勾)表示本次已选中；灰色圈(带勾)表示上次选择项。"];
    CGFloat margin = (midView.frame.size.height - 33 - 41 * 3 - 57 * 2) / 7;
    CGFloat yOri = margin;
    for (int i = 0; i < titles.count; i++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, yOri + 3.5, 13, 13)];
        [imgView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"yuan1" ofType:@"png"]]];
        [midView addSubview:imgView];
        
        UILabel *upLab = [[UILabel alloc] initWithFrame:CGRectMake(30, yOri, midView.frame.size.width - 30, 20)];
        [upLab setText:titles[i]];
        [upLab setFont:[UIFont systemFontOfSize:16]];
        [upLab setTextColor:CreateColor(89, 162, 225)];
        [midView addSubview:upLab];
        
        CGFloat hei = (i > 2) ? 32 : 16;
        UILabel *bottomLab = [[UILabel alloc] initWithFrame:CGRectMake(upLab.frame.origin.x, yOri + 25, upLab.frame.size.width - 10, hei)];
        [bottomLab setText:subTitles[i]];
        [bottomLab setFont:[UIFont systemFontOfSize:13]];
        bottomLab.numberOfLines = 2;
        [midView addSubview:bottomLab];
        
        yOri += (i > 2) ? (57 + margin) : (41 + margin);
    }
    
    UIButton *knowBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [knowBut setBackgroundColor:CreateColor(240, 240, 240)];
    [knowBut setFrame:CGRectMake((midView.frame.size.width - 110) / 2, midView.frame.size.height - 33 - margin, 110, 33)];
    knowBut.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [knowBut setTitle:@"我知道了" forState:UIControlStateNormal];
    [knowBut setTitleColor:CreateColor(89, 162, 225) forState:UIControlStateNormal];
    knowBut.layer.masksToBounds = YES;
    knowBut.layer.cornerRadius = 2;
    knowBut.tag = 2;
    [knowBut addTarget:self action:@selector(cancelFullView:) forControlEvents:UIControlEventTouchUpInside];
    [midView addSubview:knowBut];
    
    fullView.userInteractionEnabled = NO;
    [UIView animateWithDuration:.5 animations:^{
        [fullView setAlpha:1.0];
    } completion:^(BOOL finished) {
        fullView.userInteractionEnabled = YES;
    }];
}

- (void)cancelFullView:(UIButton *)button
{
    UIView *fullView = [button superview];
    if (button.tag == 2) {
        fullView = [fullView superview];
    }
    fullView.userInteractionEnabled = NO;
    [UIView animateWithDuration:.5 animations:^{
        [fullView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [fullView removeFromSuperview];
    }];
}

- (void)sendToParents:(id)sender
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        [_headerRefresh performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.1];
        return;
    }
    
    NSMutableArray *set_template_ids = [NSMutableArray array];
    NSMutableArray *cancel_template_ids = [NSMutableArray array];
    for (NSIndexPath *indexPath in _selectArr) {
        CooperateModel *cooperate = _dataSource[indexPath.item];
        BOOL allow_parent = ([cooperate.allow_parent integerValue] == 1);
        if (allow_parent) {
            [cancel_template_ids addObject:cooperate.template_id];
        }
        else
        {
            [set_template_ids addObject:cooperate.template_id];
        }
    }
    
    _collectionView.userInteractionEnabled = NO;
    __weak __typeof(self)weakSelf = self;
    NSString *url = [URLFACE stringByAppendingString:@"grow:hb_allow_parent"];
    NSDictionary *dic = @{@"class_id": manager.userInfo.classid,@"teacher_id":manager.userInfo.userid,@"set_template_ids":set_template_ids,@"cancel_template_ids":cancel_template_ids,@"term_id":_termGrow.term_id,@"templist_id":_termGrow.templist_id};
    self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf sendToParentFinish:data Suc:success];
    } failedBlock:^(NSString *description) {
        [weakSelf sendToParentFinish:nil Suc:NO];
    }];
}

#pragma mark - 发送给家长
- (void)sendToParentFinish:(id)data Suc:(BOOL)suc
{
    _collectionView.userInteractionEnabled = YES;
    self.httpOperation = nil;
    [_headerRefresh endRefreshing];
    NSString *msg = [data valueForKey:@"message"];
    NSString *tip = msg ?: (suc ? @"发送给家长成功" : @"发送给家长失败");
    [self.view makeToast:tip duration:1.0 position:@"center"];
    if (suc) {
        for (NSIndexPath *indexPath in _selectArr) {
            CooperateModel *cooperate = _dataSource[indexPath.item];
            BOOL allow_parent = ([cooperate.allow_parent integerValue] == 1);
            if (allow_parent) {
                cooperate.allow_parent = @"0";
            }
            else
            {
                cooperate.allow_parent = @"1";
            }
        }
        NSArray *array = [NSArray arrayWithArray:_selectArr];;
        [_selectArr removeAllObjects];
        [_collectionView reloadItemsAtIndexPaths:array];
        //[_numLabel setText:@"0"];
    }
}

#pragma mark - 协作数据请求
- (void)createRequest
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        [_headerRefresh performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.1];
        return;
    }
    
    _collectionView.userInteractionEnabled = NO;
    __weak __typeof(self)weakSelf = self;
    NSString *url = [URLFACE stringByAppendingString:@"grow:template_list_v3"];
    NSDictionary *dic = @{@"class_id": manager.userInfo.classid,@"teacher_id":manager.userInfo.userid,@"term_id":_termGrow.term_id,@"templist_id":_termGrow.templist_id};
    self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf requestOperateFinish:data Suc:success];
    } failedBlock:^(NSString *description) {
        [weakSelf requestOperateFinish:nil Suc:NO];
    }];
}

- (void)requestOperateFinish:(id)result Suc:(BOOL)success
{
    _collectionView.userInteractionEnabled = YES;
    self.httpOperation = nil;
    [_headerRefresh endRefreshing];
    if (!success) {
        NSString *tip = @"数据请求失败";
        if (result && [result valueForKey:@"message"]) {
            tip = [result valueForKey:@"message"];
        }
        [self.view makeToast:tip duration:1.0 position:@"center"];
    }
    else
    {
        [_dataSource removeAllObjects];
        NSArray *list = [result valueForKey:@"datalist"];
        _nSelCount = 0;
        list = (!list || [list isKindOfClass:[NSNull class]]) ? [NSArray array] : list;
        
        for (NSDictionary *subDic in list) {
            CooperateModel *cooperate = [[CooperateModel alloc] init];
            [cooperate reflectDataFromOtherObject:subDic];
            if ([cooperate.allow_parent integerValue] == 1) {
                _nSelCount += 1;
            }
            [_dataSource addObject:cooperate];
        }
        [self setCenterView];
        [_collectionView reloadData];
        [_numLabel setText:[NSString stringWithFormat:@"%ld",(long)_nSelCount]];
    }
}

#pragma mark -UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SelectCooperateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectCooperateCell" forIndexPath:indexPath];
    CooperateModel *cooperate = _dataSource[indexPath.item];
    BOOL allow_parent = ([cooperate.allow_parent integerValue] == 1);
    if ([_selectArr containsObject:indexPath]) {
        if (allow_parent) {
            cell.tipBut.enabled = YES;
            cell.tipBut.selected = NO;
        }
        else
        {
            cell.tipBut.enabled = YES;
            cell.tipBut.selected = YES;
        }
    }
    else
    {
        if (allow_parent) {
            cell.tipBut.enabled = NO;
            cell.tipBut.selected = NO;
        }
        else
        {
            cell.tipBut.enabled = YES;
            cell.tipBut.selected = NO;
        }
    }
    
    NSString *path = cooperate.template_path_thumb ?: @"";
    if (![path hasPrefix:@"http"]) {
        path = [G_IMAGE_GROW_ADDRESS stringByAppendingString:path];
    }
    [cell.photoImg setImageWithURL:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    /*
    if (cooperate.total_count.integerValue == 0) {
        [cell.tipLab setText:@""];
    }
    else
    {
        [cell.tipLab setText:[NSString stringWithFormat:@"%@/%@",cooperate.finish_count,cooperate.total_count]];
    }
    */
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SelectCooperateCell *cell = (SelectCooperateCell *)[collectionView cellForItemAtIndexPath:indexPath];
    CooperateModel *cooperate = _dataSource[indexPath.item];
    BOOL allow_parent = ([cooperate.allow_parent integerValue] == 1);
    if ([_selectArr containsObject:indexPath]) {
        if (allow_parent) {
            cell.tipBut.enabled = NO;
            cell.tipBut.selected = NO;
            _nSelCount += 1;
        }
        else
        {
            cell.tipBut.enabled = YES;
            cell.tipBut.selected = NO;
            _nSelCount -= 1;
        }
        [_selectArr removeObject:indexPath];
    }
    else
    {
        if (allow_parent) {
            cell.tipBut.enabled = YES;
            cell.tipBut.selected = NO;
            _nSelCount -= 1;
        }
        else
        {
            cell.tipBut.enabled = YES;
            cell.tipBut.selected = YES;
            _nSelCount += 1;
        }
        [_selectArr addObject:indexPath];
    }
    
    [_numLabel setText:[NSString stringWithFormat:@"%ld",(long)_nSelCount]];
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
