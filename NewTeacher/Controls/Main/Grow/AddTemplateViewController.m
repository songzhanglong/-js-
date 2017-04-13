//
//  AddTemplateViewController.m
//  NewTeacher
//
//  Created by zhangxs on 16/1/26.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "AddTemplateViewController.h"
#import "NSString+Common.h"
#import "AddTemplateTableViewCell.h"
#import "GrowSetTemplateModel.h"
#import "Toast+UIView.h"
#import "TermGrowList.h"
#import "SetTemplateViewController.h"

@implementation AddTemplateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 30, 30)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.text = @"请选择模板对应的里程主题";
    [self.view addSubview:_titleLabel];
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSDictionary *dic = @{@"class_id":manager.userInfo.classid,@"teacher_id":manager.userInfo.userid,@"term_id":_termGrow.term_id,@"templist_id":_termGrow.templist_id};
    [self createTableViewAndRequestAction:@"grow:set_album_list" Param:dic Header:YES Foot:NO];
    [_tableView setAutoresizingMask:UIViewAutoresizingNone];
    [_tableView setFrame:CGRectMake(0, 55, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 55)];
    _tableView.backgroundColor = [UIColor clearColor];
    
    [self beginRefresh];
}

#pragma mark-
#pragma mark- Right btton action
- (void)setRightNavButton
{
    
}

- (void)rightBtnAction:(UIButton *)btn
{
    if (_recordIndexPath) {
        self.view.userInteractionEnabled = NO;
        [self.view makeToastActivity];
        __weak __typeof(self)weakSelf = self;
        NSString *url = [URLFACE stringByAppendingString:@"grow:set_template_add"];
        DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
        GrowSetTemplateModel *model = [self.dataSource objectAtIndex:_recordIndexPath.section];
        NSDictionary *dic = @{@"class_id": manager.userInfo.classid,@"teacher_id":manager.userInfo.userid,@"album_id":model.album_id,@"template_ids":_template_ids,@"term_id":_termGrow.term_id,@"templist_id":_termGrow.templist_id};
        self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
            [weakSelf sendToRequestFinish:data Suc:success];
        } failedBlock:^(NSString *description) {
            [weakSelf sendToRequestFinish:nil Suc:NO];
        }];
        
    }else{
        [self.view makeToast:@"您还没有选择主题" duration:1.0 position:@"center"];
    }
}

#pragma mark - Request
- (void)sendToRequestFinish:(id)data Suc:(BOOL)suc
{
    self.httpOperation = nil;
    self.view.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    
    if (suc) {
        for (UIViewController *control in self.navigationController.viewControllers) {
            if ([control isKindOfClass:[SetTemplateViewController class]]) {
                [(SetTemplateViewController *)control setIsBeginRefresh:YES];
                [(SetTemplateViewController *)control setIsEditRefresh:YES];
                [self.navigationController popToViewController:control animated:YES];
                return;
            }
        }
        
        [self.navigationController.view makeToast:@"模板添加成功" duration:1.0 position:@"center"];
    }else {
        NSString *str = [data valueForKey:@"message"];
        str = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if (success) {
        NSMutableArray *indexArray = [NSMutableArray array];
        NSArray *data = [result valueForKey:@"data"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        for (id sub in data) {
            NSError *error;
            GrowSetTemplateModel *model = [[GrowSetTemplateModel alloc] initWithDictionary:sub error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [model calculateDescRects];
            [indexArray addObject:model];
        }
        
        self.dataSource = indexArray;
    }
    else {
        NSString *str = [result valueForKey:@"message"];
        str = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
    
    [_tableView reloadData];
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
    static NSString *addTemplateCell = @"addTemplateCellId";
    AddTemplateTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:addTemplateCell];
    if (cell == nil) {
        cell = [[AddTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addTemplateCell];
    }
    [cell resetDataSource:[self.dataSource objectAtIndex:indexPath.section]];
    if (_recordIndexPath && (indexPath.section == _recordIndexPath.section)) {
        cell.checkImgView.image = CREATE_IMG(@"grow_add_check1@2x");
    }else{
        cell.checkImgView.image = CREATE_IMG(@"grow_add_check@2x");
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_recordIndexPath) {
        if (indexPath.section != _recordIndexPath.section) {
            
            AddTemplateTableViewCell *cell = (AddTemplateTableViewCell *)[tableView cellForRowAtIndexPath:_recordIndexPath];
            
            cell.checkImgView.image = CREATE_IMG(@"grow_add_check@2x");
        }
    }
    AddTemplateTableViewCell *cell = (AddTemplateTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    cell.checkImgView.image = CREATE_IMG(@"grow_add_check1@2x");
    
    _recordIndexPath = indexPath;
    
    self.view.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    __weak __typeof(self)weakSelf = self;
    NSString *url = [URLFACE stringByAppendingString:@"grow:set_template_add"];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    GrowSetTemplateModel *model = [self.dataSource objectAtIndex:_recordIndexPath.section];
    NSDictionary *dic = @{@"class_id": manager.userInfo.classid,@"teacher_id":manager.userInfo.userid,@"album_id":model.album_id,@"template_ids":_template_ids,@"term_id":_termGrow.term_id,@"templist_id":_termGrow.templist_id};
    self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf sendToRequestFinish:data Suc:success];
    } failedBlock:^(NSString *description) {
        [weakSelf sendToRequestFinish:nil Suc:NO];
    }];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

@end
