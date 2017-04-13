//
//  SendToMotherViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/21.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SendToMotherViewController.h"
#import "DelStudentPhoto.h"

@interface SendToMotherViewController ()<UITableViewDataSource,UITableViewDelegate,DelStudentPhotoDelegate>

@end

@implementation SendToMotherViewController
{
    UITableView *_myTableView;
    DelStudentPhoto *_delPhoto;
    NSMutableArray *_selectedArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showBack = YES;
    self.titleLable.text = @"发送给";
    _selectedArr = [NSMutableArray array];
    if (_selectIndexArray && [_selectIndexArray count] > 0) {
        [_selectedArr addObjectsFromArray:_selectIndexArray];
    }
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64.0 - 44) style:UITableViewStylePlain];
    _myTableView = tableView;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tableView.dataSource = self;
    tableView.delegate = self;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectZero];
    [tableView setTableFooterView:footView];
    [self.view addSubview:tableView];
    
    _delPhoto = [[DelStudentPhoto alloc] initWithFrame:CGRectMake(0, tableView.frame.size.height, self.view.frame.size.width, 44)];
    [_delPhoto setDelegate:self];
    [_delPhoto.allButton setBackgroundColor:[UIColor greenColor]];
    [_delPhoto.otherButton setBackgroundColor:[UIColor lightGrayColor]];
    [_delPhoto.delBut setBackgroundColor:[UIColor darkGrayColor]];
    //_delPhoto.delBut.userInteractionEnabled = NO;
    [_delPhoto.delBut setTitle:[NSString stringWithFormat:@"完成(%ld/%ld)",(long)[_selectedArr count],(long)[DJTGlobalManager shareInstance].userInfo.students.count] forState:UIControlStateNormal];
    [self.view addSubview:_delPhoto];
}
#pragma mark - 重载
- (void)backToPreControl:(id)sender
{
    if (_selectedArr.count > 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(sendToPeople:IndexArray:)]) {
            NSMutableArray *array = [NSMutableArray array];
            for (NSIndexPath *indexPath in _selectedArr) {
                DJTStudent *sutdent = [DJTGlobalManager shareInstance].userInfo.students[indexPath.row];
                [array addObject:sutdent];
            }
            [_delegate sendToPeople:array IndexArray:_selectedArr];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - DelStudentPhotoDelegate
- (void)selectDeleteIdx:(NSInteger)idx
{
    if (idx == 2) {
        [self backToPreControl:nil];
        return;
    }
    NSInteger curCount = _selectedArr.count;
    NSInteger allCount = [DJTGlobalManager shareInstance].userInfo.students.count;
    NSInteger count = (idx == 0) ? allCount : (allCount - curCount);
    [_delPhoto.delBut setTitle:[NSString stringWithFormat:@"完成(%ld/%ld)",(long)count,(long)allCount] forState:UIControlStateNormal];
    for (NSInteger i = 0; i < allCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        if ([_selectedArr containsObject:indexPath]) {
            if (idx == 1) {
                [_selectedArr removeObject:indexPath];
            }
        }
        else
        {
            [_selectedArr addObject:indexPath];
        }
    }
    [_myTableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[DJTGlobalManager shareInstance].userInfo.students count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *selectParentIdentify = @"selectParentCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:selectParentIdentify];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:selectParentIdentify];
        
        //image
        UIImageView *tipImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 18, 24, 24)];
        [tipImg setTag:1];
        [cell.contentView addSubview:tipImg];
        
        //head
        UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(64, 10, 40, 40)];
        headImg.clipsToBounds = YES;
        [headImg setContentMode:UIViewContentModeScaleAspectFill];
        headImg.layer.masksToBounds = YES;
        headImg.layer.cornerRadius = 20;
        [headImg setTag:2];
        [cell.contentView addSubview:headImg];
        
        //name
        UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(124, 20, [UIScreen mainScreen].bounds.size.width - 124 - 20, 20)];
        [nameLab setBackgroundColor:[UIColor clearColor]];
        [nameLab setTag:3];
        [cell.contentView addSubview:nameLab];
    }
    
    DJTStudent *sutdent = [DJTGlobalManager shareInstance].userInfo.students[indexPath.row];
    
    UIImageView *tipImg = (UIImageView *)[cell.contentView viewWithTag:1];
    UIImageView *headImg = (UIImageView *)[cell.contentView viewWithTag:2];
    UILabel *nameLab = (UILabel *)[cell.contentView viewWithTag:3];
    [tipImg setImage:[_selectedArr containsObject:indexPath] ? [UIImage imageNamed:@"bb2_1.png"] : [UIImage imageNamed:@"bb2_2.png"]];
    NSString *face = sutdent.face;
    if (![face hasPrefix:@"http"]) {
        face = [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
    }
    [headImg setImageWithURL:[NSURL URLWithString:[face stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"s21.png"]];
    [nameLab setText:sutdent.uname];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *tipImg = (UIImageView *)[cell.contentView viewWithTag:1];
    if ([_selectedArr containsObject:indexPath]) {
        [_selectedArr removeObject:indexPath];
        [tipImg setImage:[UIImage imageNamed:@"bb2_2.png"]];
    }
    else{
        [_selectedArr addObject:indexPath];
        [tipImg setImage:[UIImage imageNamed:@"bb2_1.png"]];
    }
    NSInteger curCount = _selectedArr.count;
    NSInteger allCount = [DJTGlobalManager shareInstance].userInfo.students.count;
    [_delPhoto.delBut setTitle:[NSString stringWithFormat:@"完成(%ld/%ld)",(long)curCount,(long)allCount] forState:UIControlStateNormal];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(tableView.frame.origin.x, 0, tableView.frame.size.width, 25)];
    titleLabel.backgroundColor=CreateColor(247, 247, 247);
    titleLabel.text= @"  家长";
    return titleLabel;
}

@end
