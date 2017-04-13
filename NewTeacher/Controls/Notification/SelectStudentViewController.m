//
//  SelectStudentViewController.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SelectStudentViewController.h"
#import "DJTGlobalManager.h"
#import "DJTGlobalDefineKit.h"
#import "DelStudent.h"
#import "TeacherModel.h"

@interface SelectStudentViewController ()<UITableViewDataSource,DelStudentDelegate,UITableViewDelegate>{
    UITableView     *_myTableView;
    NSMutableArray  *_selectedArr;
    DelStudent *_delPhoto;
}

@end

@implementation SelectStudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showBack = YES;
    self.titleLable.text = @"发送给";
    _selectedArr = [NSMutableArray arrayWithArray:_preArr];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SCREEN_HEIGHT - 64.0 - 44) style:UITableViewStylePlain];
    _myTableView = tableView;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tableView.dataSource = self;
    tableView.delegate = self;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectZero];
    [tableView setTableFooterView:footView];
    [self.view addSubview:tableView];
    
    _delPhoto = [[DelStudent alloc] initWithFrame:CGRectMake(0, tableView.frame.size.height, self.view.frame.size.width, 44)];
    [_delPhoto setDelegate:self];
    [_delPhoto.allSelectedButton setBackgroundColor:[UIColor greenColor]];
    [_delPhoto.unSelectedButton setBackgroundColor:[UIColor lightGrayColor]];
    [_delPhoto.completedButton setBackgroundColor:[UIColor darkGrayColor]];
    //_delPhoto.completedButtxon.userInteractionEnabled = NO;
    [_delPhoto.completedButton setTitle:[NSString stringWithFormat:@"完成(%ld/%ld)",(long)_selectedArr.count, _isSendToTeacher ? (long)_teacherArray.count : (long)[DJTGlobalManager shareInstance].userInfo.students.count] forState:UIControlStateNormal];
    [self.view addSubview:_delPhoto];
}

- (void)backToPreControl:(id)sender
{
    if (_selectedArr.count > 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(sendToPeople:)]) {
            NSMutableArray *array = [NSMutableArray array];
            for (NSIndexPath *indexPath in _selectedArr) {
                if (_isSendToTeacher) {
                    TeacherModel *teacher = _teacherArray[indexPath.row];
                    [array addObject:teacher];
                }else{
                    DJTStudent *sutdent = [DJTGlobalManager shareInstance].userInfo.students[indexPath.row];
                    [array addObject:sutdent];
                }
            }
            [_delegate sendToPeople:array];
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
    NSInteger allCount = _isSendToTeacher ? [_teacherArray count] : [DJTGlobalManager shareInstance].userInfo.students.count;
    NSInteger count = (idx == 0) ? allCount : (allCount - curCount);
    [_delPhoto.completedButton setTitle:[NSString stringWithFormat:@"完成(%ld/%ld)",(long)count,(long)allCount] forState:UIControlStateNormal];
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _isSendToTeacher ? _teacherArray.count :[[DJTGlobalManager shareInstance].userInfo.students count];
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
        UIImageView *tipImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 18, 30, 30)];
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
    
    UIImageView *tipImg = (UIImageView *)[cell.contentView viewWithTag:1];
    UIImageView *headImg = (UIImageView *)[cell.contentView viewWithTag:2];
    UILabel *nameLab = (UILabel *)[cell.contentView viewWithTag:3];
    [tipImg setImage:[_selectedArr containsObject:indexPath] ? [UIImage imageNamed:@"bb2_1.png"] : [UIImage imageNamed:@"bb2_2.png"]];
    if (_isSendToTeacher) {
        TeacherModel *teacher = [_teacherArray objectAtIndex:indexPath.row];
        NSString *str = teacher.face;
        if (![str hasPrefix:@"http"]) {
            str = [G_IMAGE_ADDRESS stringByAppendingString:str ?: @""];
        }
        [headImg setImageWithURL:[NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"s21.png"]];
        [nameLab setText:teacher.teacher_name];
    }else{
        DJTStudent *sutdent = [DJTGlobalManager shareInstance].userInfo.students[indexPath.row];
        [headImg setImageWithURL:[NSURL URLWithString:[sutdent.face stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"s21.png"]];
        [nameLab setText:sutdent.uname];
    }
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
    NSInteger allCount = _isSendToTeacher ? [_teacherArray count] : [DJTGlobalManager shareInstance].userInfo.students.count;
    [_delPhoto.completedButton setTitle:[NSString stringWithFormat:@"完成(%ld/%ld)",(long)curCount,(long)allCount] forState:UIControlStateNormal];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}



@end
