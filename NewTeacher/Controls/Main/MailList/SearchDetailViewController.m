//
//  SearchDetailViewController.m
//  NewTeacher
//
//  Created by mac on 15/8/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SearchDetailViewController.h"
#import "MailListCell.h"

@interface SearchDetailViewController ()

@end

@implementation SearchDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.showBack = YES;
    
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    self.dataSource = @[_teacherItem];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellMore = @"CellMainList";
    
    MailListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellMore];
    if (cell == nil)
    {
        cell = [[MailListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellMore];
    }
    MainListTeacherItem *item = self.dataSource[indexPath.row];
    [cell resetClassMainListData:item isHidden:(indexPath.section == 0) ? NO : YES isTeacher:YES];
    return cell;
}

@end
