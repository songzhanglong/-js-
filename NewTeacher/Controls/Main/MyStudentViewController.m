//
//  MyStudentViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/23.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "MyStudentViewController.h"
#import "StudentPhotoViewController.h"
#import "SortStudentView.h"

@interface MyStudentViewController ()<SortStudentViewDelegate>

@end

@implementation MyStudentViewController
{
    UILabel *_headerLab;
    NSInteger _nCurIdx;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGE_HEAD_FINISH object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showBack = YES;
    self.titleLable.text = @"学生列表";
    [self createRightBarButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeHead:) name:CHANGE_HEAD_FINISH object:nil];
    
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    _headerLab = label;
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [label setText:@"成长档案完成度从高到低    "];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    [label setTextAlignment:2];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor colorWithRed:81.0 / 255 green:90.0 / 255 blue:116.0 / 255 alpha:1.0]];
    [_tableView setTableHeaderView:_headerLab];
    _nCurIdx = 0;
}

- (void)createRightBarButton
{
    UIButton *sortBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sortBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
    sortBtn.backgroundColor = [UIColor clearColor];
    [sortBtn setTitle:@"排序" forState:UIControlStateNormal];
    [sortBtn setTitleColor:[UIColor colorWithRed:253.0 / 255 green:215.0 / 255 blue:187.0 / 255 alpha:1.0] forState:UIControlStateNormal];
    [sortBtn addTarget:self action:@selector(sortStudents:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sortBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    [self selectSortType:nil];
}

#pragma mark - actions
- (void)sortStudents:(id)sender
{
    UIView *backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [backView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
    [backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backItemClicked:)]];
    
    CGRect sortRec = CGRectMake(0, backView.frame.size.height, backView.frame.size.width, 90);
    SortStudentView *sortStudent = [[SortStudentView alloc] initWithFrame:sortRec];
    sortStudent.nSortIndex = _nCurIdx;
    sortStudent.delegate = self;
    [sortStudent setBackgroundColor:[UIColor whiteColor]];
    [backView addSubview:sortStudent];
    [UIView animateWithDuration:0.35 animations:^{
        [sortStudent setFrame:CGRectMake(sortRec.origin.x, sortRec.origin.y - sortRec.size.height, sortRec.size.width, sortRec.size.height)];
    }];
    
    [self.view.window addSubview:backView];
}

- (void)backItemClicked:(UITapGestureRecognizer *)tap
{
    UIView *tapView = [tap view];
    CGPoint point = [tap locationInView:tapView];
    SortStudentView *sortView = [tapView subviews][0];
    
    if (CGRectContainsPoint(sortView.frame, point)) {
        return;
    }
    
    [self dismissSortStudentView:sortView];
}

- (void)dismissSortStudentView:(SortStudentView *)sortView
{
    [[sortView superview] setUserInteractionEnabled:NO];
    CGRect rect = sortView.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [sortView setFrame:CGRectMake(rect.origin.x, rect.origin.y + rect.size.height, rect.size.width, rect.size.height)];
    } completion:^(BOOL finished) {
        [[sortView superview] removeFromSuperview];
        [_tableView reloadData];
    }];
}

#pragma mark - 头像修改通知
- (void)changeHead:(NSNotification *)notifi
{
    NSString *stuId = [notifi object];
    for (NSInteger i = 0; i < [self.dataSource count]; i++) {
        DJTStudent *stu = self.dataSource[i];
        if ([stu.student_id isEqualToString:stuId]) {
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
    }
}

#pragma mark - SortStudentViewDelegate
- (void)selectSortType:(SortStudentView *)sortView
{
    if (sortView) {
        if (_nCurIdx == sortView.nSortIndex) {
            return;
        }
        _nCurIdx = sortView.nSortIndex;
    }
    
    NSArray *array = [[DJTGlobalManager shareInstance].userInfo.students sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        DJTStudent *stu1 = (DJTStudent *)obj1;
        DJTStudent *stu2 = (DJTStudent *)obj2;
        switch (_nCurIdx) {
            case 0:
            {
                return ([stu1.grows_num integerValue] < [stu2.grows_num integerValue]);
            }
                break;
            case 1:
            {
                return ([stu1.grows_num integerValue] > [stu2.grows_num integerValue]);
            }
                break;
            default:
                break;
        }
        
        return 0;
    }];
    self.dataSource = [NSMutableArray arrayWithArray:array];
    [_headerLab setText:(_nCurIdx == 0) ? @"成长档案完成度从高到低    " : @"成长档案完成度从低到高    "];
    if (sortView) {
        [self dismissSortStudentView:sortView];
    }
    else
    {
        [_tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *myStudentIdentifierBase = @"myStudentCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myStudentIdentifierBase];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myStudentIdentifierBase];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //imageView
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 7, 56, 56)];
        [imageView setBackgroundColor:[UIColor clearColor]];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 28;
        [imageView setTag:1];
        [cell.contentView addSubview:imageView];
        
        //title sup
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 5, imageView.frame.origin.y + 5, 250, 21)];
        [label setFont:[UIFont systemFontOfSize:17]];
        [label setTextColor:[UIColor blackColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTag:2];
        [cell.contentView addSubview:label];
        
        //title sub
        label = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.origin.x, imageView.frame.size.height + imageView.frame.origin.y - 18 - 5, label.frame.size.width, label.frame.size.height)];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:[UIColor colorWithRed:253.0 / 255 green:215.0 / 255 blue:187.0 / 255 alpha:1.0]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTag:4];
        [cell.contentView addSubview:label];
    }
    
    DJTStudent *student = [self.dataSource objectAtIndex:indexPath.row];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
    [imageView setImageWithURL:[NSURL URLWithString:student.face] placeholderImage:[UIImage imageNamed:@"s21.png"]];
    
    UILabel *supTitle = (UILabel *)[cell.contentView viewWithTag:2];
    [supTitle setText:student.uname];
    
    UILabel *subTitle2 = (UILabel *)[cell.contentView viewWithTag:4];
    [subTitle2 setText:[NSString stringWithFormat:@"成长档案:%lld/%lld",[student.grows_num longLongValue],[student.templist_nums longLongValue]]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DJTStudent *student = self.dataSource[indexPath.row];
    StudentPhotoViewController *photo = [[StudentPhotoViewController alloc] init];
    photo.hidesBottomBarWhenPushed = YES;
    photo.student = student;
    [self.navigationController pushViewController:photo animated:YES];
}

@end
