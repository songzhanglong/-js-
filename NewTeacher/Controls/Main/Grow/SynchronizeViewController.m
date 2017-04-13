//
//  SynchronizeViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/5/29.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SynchronizeViewController.h"
#import "SynchronsizeStudentCell.h"
#import "GrowAlbumModel.h"
#import "Toast+UIView.h"
#import "TermGrowDetailModel.h"
#import "TermGrowDetailModel.h"

@interface SynchronizeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@end

@implementation SynchronizeViewController
{
    UICollectionView *_collectionView;
    NSMutableArray *_selectedArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    _selectedArr = [NSMutableArray array];
    
    NSEnumerator *enumerator = [self.dataSource reverseObjectEnumerator];
    for (TermStudent *student in enumerator) {
        if ([student.edit_flag integerValue] == 0 && [student.edit_flag length] > 0) {
            [self.dataSource removeObject:student];
        }
    }
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
    CGFloat itemWei = 65,itemHei = 90;
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    CGFloat margin = (winSize.width - 3 * itemWei) / (3 + 1);
    layout.itemSize = CGSizeMake(itemWei, itemHei);
    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(10, margin, 10, margin);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, winSize.height - 64 - 44) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor=  [UIColor whiteColor];
    [_collectionView registerClass:[SynchronsizeStudentCell class] forCellWithReuseIdentifier:@"SynchronsizeStudentCell"];
    [self.view addSubview:_collectionView];
    
    NSArray *rects = @[NSStringFromCGRect(CGRectMake(15, winSize.height - 64 - 44 + 7 + 4.5, 60, 21)),NSStringFromCGRect(CGRectMake(90, winSize.height - 64 - 44 + 7 + 4.5, 60, 21)),NSStringFromCGRect(CGRectMake(winSize.width - 20 - 60, winSize.height - 64 - 44 + 7 + 4.5, 60, 21))];
    
    NSArray *titles = @[@"全选",@"反选",@"确认"];
    for (NSInteger i = 0; i < 3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectFromString(rects[i])];
        [button setTag:i + 1];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 2;
        [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectControl:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundColor:(i != 2) ? CreateColor(130, 130, 130) : CreateColor(43, 210, 67)];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [self.view addSubview:button];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)selectControl:(id)sender
{
    NSInteger idx = [sender tag] - 1;
    switch (idx) {
        case 0:
        case 1:
        {
            NSInteger allCount = _dataSource.count;
            NSMutableArray *paths = [NSMutableArray array];
            for (NSInteger i = 0; i < allCount; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                if ([_selectedArr containsObject:indexPath]) {
                    if (idx == 1) {
                        [_selectedArr removeObject:indexPath];
                        [paths addObject:indexPath];
                    }
                }
                else
                {
                    [_selectedArr addObject:indexPath];
                    [paths addObject:indexPath];
                }
            }
            if (paths.count > 0) {
                [_collectionView reloadItemsAtIndexPaths:paths];
            }
        }
            break;
        case 2:
        {
            NSArray *stus = _dataSource;
            NSMutableArray *array = [NSMutableArray array];
            for (NSIndexPath *indexPath in _selectedArr) {
                DJTStudent *student = stus[indexPath.item];
                [array addObject:student.student_id];
            }
            
            [self beginSynchronize:array];
        }
            break;
        default:
            break;
    }
}

#pragma mark -UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SynchronsizeStudentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SynchronsizeStudentCell" forIndexPath:indexPath];
    TermStudent *student = [_dataSource objectAtIndex:indexPath.item];
    
    NSString *face = student.face;
    if (![face hasPrefix:@"http"]) {
        face = [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
    }
    [cell.photoImg setImageWithURL:[NSURL URLWithString:[face stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"s21.png"]];
    cell.nameLab.text = student.student_name;
    cell.selectBut.selected = [_selectedArr containsObject:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TermStudent *student = [_dataSource objectAtIndex:indexPath.item];
    if ([student.edit_flag integerValue] == 0) {
        [self.view makeToast:@"档案正在打印制作中，不能修改哦" duration:1.0 position:@"center"];
        return;
    }
    SynchronsizeStudentCell *cell = (SynchronsizeStudentCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([_selectedArr containsObject:indexPath]) {
        [_selectedArr removeObject:indexPath];
        cell.selectBut.selected = NO;
    }
    else
    {
        [_selectedArr addObject:indexPath];
        cell.selectBut.selected = YES;
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

#pragma mark - 开始同步
- (void)beginSynchronize:(NSArray *)array
{
    if (array.count == 0) {
        NSArray *controls = self.navigationController.viewControllers;
        [self.navigationController popToViewController:controls[controls.count - 3] animated:YES];
        return;
    }
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    self.view.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    NSDictionary *dic = @{@"grow_id":_student.grow_id,@"template_id":_growAlbum.template_id,@"student_id_list":array,@"teacher_id":manager.userInfo.userid};
    __weak __typeof(self)weakSelf = self;
    NSString *url = [URLFACE stringByAppendingString:@"grow:data_hb_sync_v2"];
    self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf synchronizeFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf synchronizeFinish:NO Data:nil];
    }];
}

- (void)synchronizeFinish:(BOOL)suc Data:(id)data
{
    self.view.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    self.httpOperation = nil;
    NSString *message = [data valueForKey:@"message"];
    NSString *lastTip = message ?: (suc ? @"同步成功" : @"同步失败");
    
    if (suc) {
        [self.navigationController.view makeToast:lastTip duration:1.0 position:@"center"];
        
        NSArray *controls = self.navigationController.viewControllers;
        [self.navigationController popToViewController:controls[controls.count - 3] animated:YES];
    }
    else
    {
        [self.view makeToast:lastTip duration:1.0 position:@"center"];
    }
}

@end
