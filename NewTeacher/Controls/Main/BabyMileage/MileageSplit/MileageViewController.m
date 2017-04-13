//
//  MileageViewController.m
//  NewTeacher
//
//  Created by szl on 15/11/30.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MileageViewController.h"
#import "NSString+Common.h"
#import "Toast+UIView.h"
#import "MileageListViewCell.h"
#import "MileageAllEditView.h"
#import "BabyMileageViewController.h"
#import "AddThemeViewController.h"
#import "UIImage+Caption.h"
#import "SystemClassViewController.h"
#import "SystemStudentViewController.h"
#import "TeacherClassViewController.h"
#import "TeacherStudentViewController.h"
#import "MyThemeManagerController.h"
#import "ThemeDetailViewController.h"
#import "DataBaseOperation.h"

@interface MileageViewController ()<MileageListViewCellDelegate,MileageAllEditViewDelegate,UIAlertViewDelegate,ThemeDetailViewControllerDelegate>

@end

@implementation MileageViewController
{
    BOOL _lastPage,_refresh;
    NSIndexPath *_indexPath;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:REFRESH_LICHENT object:nil];
    [[DJTGlobalManager shareInstance] setMileageList:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _pageCount = 10;
    _pageIdx = 1;
    
    self.useNewInterface = YES;
    [self createTableViewAndRequestAction:@"photo" Param:nil Header:YES Foot:YES];
    [_tableView setBackgroundColor:CreateColor(238, 238, 235)];
    
    DJTGlobalManager *gloManager = [DJTGlobalManager shareInstance];
    [gloManager setMileageList:[[DataBaseOperation shareInstance] selectMileageListBy:gloManager.userInfo.userid]];
    
    [self beginRefresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshThisList:) name:REFRESH_LICHENT object:nil];
}

- (void)resetTitleContent:(id)ret_data
{
    NSNumber *album_num = [ret_data valueForKey:@"album_num"];
    NSNumber *photo_num = [ret_data valueForKey:@"photo_num"];
    NSNumber *video_num = [ret_data valueForKey:@"video_num"];
    NSString *str = [NSString stringWithFormat:@"里程 %ld / 照片 %ld / 视频%ld",(long)[album_num integerValue],(long)[photo_num integerValue],(long)[video_num integerValue]];
    [(BabyMileageViewController *)self.parentViewController resetNumText:str];
}
- (void)createTableFooterView{
    if ([self.dataSource count] > 0) {
        [_tableView setTableFooterView:[[UIView alloc] init]];
    }else {
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 170)];
        [headView setBackgroundColor:_tableView.backgroundColor];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 100) / 2, 30, 100, 100)];
        imgView.image = CREATE_IMG(@"contact_a");
        [headView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, imgView.frame.origin.y + imgView.frame.size.height + 10, winSize.width - 10, 30)];
        [label setText:@"暂时还没有创建里程主题哦!"];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:CreateColor(84, 128, 215)];
        [label setBackgroundColor:_tableView.backgroundColor];
        [label setTextAlignment:1];
        [headView addSubview:label];
        
        [_tableView setTableFooterView:headView];
    }
}

- (void)refreshThisList:(NSNotification *)notifi
{
    _refresh = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    ((BabyMileageViewController *)self.parentViewController).titleLable.text = @"班级里程";
    if (_refresh) {
        _refresh = NO;
        [self beginRefresh];
    }
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getMileageList"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page"];
    [param setObject:@"2" forKey:@"visual_type"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
}

- (void)startPullRefresh
{
    _pageIdx = 1;
    _lastPage = NO;
    [super startPullRefresh];
}

- (void)startPullRefresh2
{
    if (_lastPage) {
        [self.view makeToast:@"已到最后一页" duration:1.0 position:@"center"];
        
        //isStopRefresh
        [self performSelector:@selector(finishRefresh) withObject:nil afterDelay:0.1];
    }
    else
    {
        if ([self.dataSource count] > 0) {
            _pageIdx++;
        }
        [super startPullRefresh2];
    }
    
}

- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        if (!ret_data || [ret_data isKindOfClass:[NSNull class]]) {
            [self.view makeToast:@"暂无数据" duration:1.0 position:@"center"];
            return;
        }
        
        id pageSize = [ret_data valueForKey:@"pageCount"];
        _lastPage = _pageIdx >= [pageSize integerValue];
        
        NSMutableArray *array = [NSMutableArray array];
        NSArray *data = [ret_data valueForKey:@"list"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        for (id subDic in data) {
            NSError *error;
            MileageModel *mileage = [[MileageModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [mileage caculateNameHei];
            [array addObject:mileage];
        }
        
        self.dataSource = array;
        
        [self resetTitleContent:ret_data];
    }
    else{
        self.dataSource = nil;
    }
    [self createTableFooterView];
    [_tableView reloadData];
}

- (void)requestFinish2:(BOOL)success Data:(id)result
{
    [super requestFinish2:success Data:result];
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        
        if (!ret_data || [ret_data isKindOfClass:[NSNull class]]) {
            [self.view makeToast:@"暂无数据" duration:1.0 position:@"center"];
            return;
        }
        
        id pageSize = [ret_data valueForKey:@"pageCount"];
        _lastPage = _pageIdx >= [pageSize integerValue];
        
        NSArray *data = [ret_data valueForKey:@"list"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        NSMutableArray *array = [NSMutableArray array];
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        NSInteger count = [self.dataSource count];
        for (id subDic in data) {
            NSError *error;
            MileageModel *mileage = [[MileageModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [mileage caculateNameHei];
            [array addObject:mileage];
            [set addIndex:count++];
        }
        
        if (!self.dataSource) {
            self.dataSource = [NSMutableArray array];
        }
        [self.dataSource addObjectsFromArray:array];
        [_tableView insertSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    else
    {
        if (_pageIdx > 1) {
            _pageIdx -= 1;
        }
    }
}

#pragma mark - ThemeDetailViewControllerDelegate
- (void)deleteThisBatch
{
    if ([self.parentViewController isKindOfClass:[MileageBaseViewController class]]) {
        [self.parentViewController.navigationController popToViewController:self.parentViewController animated:YES];
    }
    else if ([self.parentViewController.parentViewController isKindOfClass:[MileageBaseViewController class]])
    {
        [self.parentViewController.parentViewController.navigationController popToViewController:self.parentViewController.parentViewController animated:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_LICHENT object:nil];
}

#pragma mark - MileageListViewCellDelegate
- (void)beginEditMileageName:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    _indexPath = indexPath;
    
    MileageModel *mileage = self.dataSource[indexPath.section];
    NSInteger type = mileage.mileage_type.integerValue; //1（我的）  2（教师） 3（推荐）
    if (type == 3) {
        //edit
        AddThemeViewController *addTheme = [[AddThemeViewController alloc] init];
        addTheme.themeType = MileageThemeEdit;
        addTheme.mileage = mileage;
        addTheme.delegate = self;
        [self.parentViewController.navigationController pushViewController:addTheme animated:YES];
    }
    else{
        MileageAllEditView *editView = [[MileageAllEditView alloc] initWithFrame:[UIScreen mainScreen].bounds Titles:@[@"删除",@"修改"] NImageNames:@[@"mileage_delete@2x",@"themeChangeN"] HImageNames:@[@"mileage_delete_1@2x",@"themeChangeH"]];
        editView.delegate = self;
        [editView showInView:self.view.window];
    }
}

- (void)selectMileageImage:(UITableViewCell *)cell At:(NSInteger)index
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    MileageModel *model = self.dataSource[indexPath.section];
    MileagePhotoItem *item = [model.photo objectAtIndex:index];
    ThemeBatchModel *batchModel = [[ThemeBatchModel alloc] init];
    batchModel.batch_id = item.batch_id;
    batchModel.album_id = model.album_id;
    batchModel.photos = (NSArray<ThemeBatchItem> *)@[item];
    batchModel.userid = item.userid;
    
    ThemeDetailViewController *detail = [[ThemeDetailViewController alloc] init];
    detail.themeBatch = batchModel;
    detail.titleLable.text = model.name;
    detail.delegate = self;
    [self.parentViewController.navigationController pushViewController:detail animated:YES];
    
    UIView *subView = [cell.contentView viewWithTag:101];
    if (!subView.hidden) {
        DJTGlobalManager *gloManager = [DJTGlobalManager shareInstance];
        NSDictionary *curDic = nil;
        for (id subDic in gloManager.mileageList) {
            if ([subDic[@"albumid"] isEqualToString:model.album_id]) {
                curDic = subDic;
                break;
            }
        }
        NSString *userid = gloManager.userInfo.userid;
        NSMutableArray *tmpArr = [NSMutableArray array];
        for (MileagePhotoItem *item in model.photo) {
            [tmpArr addObject:item.batch_id];
        }
        NSString *photoIds = [tmpArr componentsJoinedByString:@"|"];
        if (!curDic) {
            [gloManager.mileageList addObject:@{@"userid":userid,@"albumid":model.album_id,@"photoids":photoIds}];
            [[DataBaseOperation shareInstance] insertMileage:userid Batch:model.album_id Photo:photoIds];
        }
        else{
            NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:curDic];
            [newDic setObject:photoIds forKey:@"photoids"];
            NSInteger index = [gloManager.mileageList indexOfObject:curDic];
            [gloManager.mileageList replaceObjectAtIndex:index withObject:newDic];
            [[DataBaseOperation shareInstance] updateMileagePhotoIds:photoIds By:curDic[@"albumid"]];
        }
        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - MileageAllEditViewDelegate
- (void)selectEditIndex:(NSInteger)index
{
    MileageModel *model = self.dataSource[_indexPath.section];
    if (index == 0) {
        //delete
        if ([model.photo count] <= 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要删除当前主题吗？" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
            [alertView show];
        }else {
            [self.parentViewController.navigationController.view makeToast:@"主题有内容不能删除" duration:1.0 position:@"center"];
        }
        
    }else if (index == 1){
        //edit
        AddThemeViewController *addTheme = [[AddThemeViewController alloc] init];
        addTheme.themeType = MileageThemeEdit;
        addTheme.mileage = model;
        addTheme.delegate = self;
        [self.parentViewController.navigationController pushViewController:addTheme animated:YES];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self deleteTheme:self.dataSource[_indexPath.section]];
    }
}

#pragma mark - 删除主题
- (void)deleteTheme:(MileageModel *)model {
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view.window makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    __weak __typeof(self)weakSelf = self;
    
    NSMutableDictionary *param = [manager requestinitParamsWith:@"deleteAlbum"];
    [param setObject:model.album_id forKey:@"album_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self.parentViewController.view makeToastActivity];
    [self.parentViewController.view setUserInteractionEnabled:NO];
    //针对新接口
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"photo"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf deleteFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf deleteFinish:NO Data:nil];
    }];
}

- (void)deleteFinish:(BOOL)success Data:(id)result
{
    [self.parentViewController.view hideToastActivity];
    [self.parentViewController.view setUserInteractionEnabled:YES];
    self.httpOperation = nil;
    
    if (success) {
        [self.dataSource removeObjectAtIndex:[_indexPath section]];
        [_tableView deleteSections:[NSIndexSet indexSetWithIndex:_indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else{
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.parentViewController.navigationController.view makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - AddThemeViewControllerDelegate
- (void)editThemeFinish
{
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:_indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)addNewTheme:(MileageModel *)model
{
    if (!self.dataSource) {
        self.dataSource = [NSMutableArray array];
    }
    [self.dataSource insertObject:model atIndex:0];
    [_tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *mileageCell = @"mileageCellId";
    MileageListViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:mileageCell];
    if (cell == nil) {
        cell = [[MileageListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mileageCell];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    MileageModel *mileage = self.dataSource[indexPath.section];
    [cell resetDataSource:mileage];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MileageModel *model = self.dataSource[indexPath.section];
    switch ([model.mileage_type integerValue]) {
        case 2:
        {
            //班级
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            TeacherClassViewController *teaCla = [[TeacherClassViewController alloc] init];
            teaCla.view.frame = CGRectMake(0, 30, winSize.width, winSize.height - 30 - 64);
            teaCla.mileage = model;
            TeacherStudentViewController *teaStu = [[TeacherStudentViewController alloc] init];
            teaStu.mileage = model;
            teaStu.view.frame = teaCla.view.frame;
            MyThemeManagerController *manager = [[MyThemeManagerController alloc] initWithControls:@[teaCla,teaStu] Titles:@[@"班级",@"学生"] Frame:CGRectMake(0, 0, winSize.width, 30)];
            manager.indexModel = model;
            manager.titleLable.text = model.name;
            [self.parentViewController.navigationController pushViewController:manager animated:YES];
        }
            break;
        case 3:
        {
            //系统
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            SystemClassViewController *sysCla = [[SystemClassViewController alloc] init];
            sysCla.view.frame = CGRectMake(0, 30, winSize.width, winSize.height - 30 - 64);
            sysCla.mileage = model;
            SystemStudentViewController *sysStu = [[SystemStudentViewController alloc] init];
            sysStu.mileage = model;
            sysStu.view.frame = sysCla.view.frame;
            MyThemeManagerController *manager = [[MyThemeManagerController alloc] initWithControls:@[sysCla,sysStu] Titles:@[@"班级",@"学生"] Frame:CGRectMake(0, 0, winSize.width, 30)];
            manager.indexModel = model;
            manager.titleLable.text = model.name;
            [self.parentViewController.navigationController pushViewController:manager animated:YES];
        }
            break;
        default:
            break;
    }
    
    MileageListViewCell *cell = (MileageListViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    UIView *subView = [cell.contentView viewWithTag:101];
    if (!subView.hidden) {
        DJTGlobalManager *gloManager = [DJTGlobalManager shareInstance];
        NSDictionary *curDic = nil;
        for (id subDic in gloManager.mileageList) {
            if ([subDic[@"albumid"] isEqualToString:model.album_id]) {
                curDic = subDic;
                break;
            }
        }
        NSString *userid = gloManager.userInfo.userid;
        NSMutableArray *tmpArr = [NSMutableArray array];
        for (MileagePhotoItem *item in model.photo) {
            [tmpArr addObject:item.batch_id];
        }
        NSString *photoIds = [tmpArr componentsJoinedByString:@"|"];
        if (!curDic) {
            [gloManager.mileageList addObject:@{@"userid":userid,@"albumid":model.album_id,@"photoids":photoIds}];
            [[DataBaseOperation shareInstance] insertMileage:userid Batch:model.album_id Photo:photoIds];
        }
        else{
            NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:curDic];
            [newDic setObject:photoIds forKey:@"photoids"];
            NSInteger index = [gloManager.mileageList indexOfObject:curDic];
            [gloManager.mileageList replaceObjectAtIndex:index withObject:newDic];
            [[DataBaseOperation shareInstance] updateMileagePhotoIds:photoIds By:curDic[@"albumid"]];
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MileageModel *mileage = self.dataSource[indexPath.section];
    if ([mileage.photo count] > 0) {
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        CGFloat wei = (winSize.width - 30) / 3;
        return wei;
    }
    
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return (section == 0) ? 5 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

@end
