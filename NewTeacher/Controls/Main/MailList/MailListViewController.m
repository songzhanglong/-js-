//
//  MailListViewController.m
//  NewTeacher
//
//  Created by mac on 15/7/28.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MailListViewController.h"
#import "NSString+Common.h"
#import "MainListModel.h"
#import "NSObject+Reflect.h"
#import "SearchDetailViewController.h"
#import "Toast+UIView.h"
#import "AppDelegate.h"
#import "MailListCell.h"

@interface MailListViewController ()<MailListCellDelegate>

@end

@implementation MailListViewController
{
    MainListStudentItem *currStudentModel;
    NSMutableArray *_studentIndexArray;
    NSMutableArray *_teacherIndexArray;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.showBack = YES;
    indexBootm = 0;
    _dataArray = [NSMutableArray array];
    _resultsData = [NSMutableArray array];
    _studentIndexArray = [NSMutableArray array];
    _teacherIndexArray = [NSMutableArray array];
    lastIndexTag = 937;
    [self customSegmentView];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar.placeholder = @"快速搜索姓名";
    //_searchBar.delegate = self;

    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    
    self.useNewInterface = YES;
    NSDictionary *param = [self configRequestParam];
    [self createTableViewAndRequestAction:@"class" Param:param Header:YES Foot:NO];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self beginRefresh];
    
}
#pragma mark - 参数配置
- (NSDictionary *)configRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getMemberList"];
    [param setObject:manager.userInfo.classid forKey:@"class_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    return param;
}
#pragma mark - 网络请求结束
/**
 *	@brief	数据请求结果
 *
 *	@param 	success 	yes－成功
 *	@param 	result 	服务器返回数据
 */
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    if (success) {
        NSDictionary *ret_data = [result valueForKey:@"ret_data"];
        if (ret_data && [ret_data isKindOfClass:[NSDictionary class]]) {
            if (_studentIndexArray && [_studentIndexArray count] > 0) {
                [_studentIndexArray removeAllObjects];
            }
            if (_teacherIndexArray && [_teacherIndexArray count] > 0) {
                [_teacherIndexArray removeAllObjects];
            }
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            NSArray *student = [ret_data objectForKey:@"student"];
            if (student && [student isKindOfClass:[NSArray class]]) {
                NSMutableArray *tmpArr = [NSMutableArray array];
                NSMutableArray *tmpArr1 = [NSMutableArray array];
                for (id subDic in student) {
                    MainListStudentItem *item = [[MainListStudentItem alloc] init];
                    [item reflectDataFromOtherObject:subDic];
                    [item calculeteConSize:winSize.width - 40 Font:[UIFont systemFontOfSize:14]];
                    if (![item.status isEqualToString:@"1"]) {
                        [tmpArr addObject:item];
                    }else{
                        [tmpArr1 addObject:item];
                    }
                }
                
                if ([tmpArr count] > 0) {
                    MainListModel *model = [[MainListModel alloc] init];
                    model.indexButton = 200;
                    [model setItems:tmpArr];
                    [_studentIndexArray addObject:model];
                }
                if ([tmpArr1 count] > 0) {
                    MainListModel *model1 = [[MainListModel alloc] init];
                    model1.indexButton = 200;
                    [model1 setItems:tmpArr1];
                    [_studentIndexArray addObject:model1];
                }
            }
            
            NSMutableArray *tmpIndexArr = [NSMutableArray array];
            NSMutableArray *tmpIndexArr1 = [NSMutableArray array];
            NSArray *teacher = [ret_data objectForKey:@"teacher"];
            if (teacher && [teacher isKindOfClass:[NSArray class]]) {
                NSMutableArray *tmpArr3 = [NSMutableArray array];
                for (NSDictionary *teacherDic in teacher) {
                    MainListTeacherItem *item = [[MainListTeacherItem alloc] init];
                    [item reflectDataFromOtherObject:teacherDic];
                    [tmpArr3 addObject:item];
                }
                MainListModel *model3 = [[MainListModel alloc] init];
                model3.indexButton = 100;
                [model3 setTeacherItems:tmpArr3];
                [_dataArray addObject:model3];
                [_resultsData addObject:model3];
                
                for (id subDic in teacher) {
                    MainListTeacherItem *item = [[MainListTeacherItem alloc] init];
                    [item reflectDataFromOtherObject:subDic];
                    [tmpIndexArr1 addObject:item];
                }
            }
            NSDictionary *school = [ret_data objectForKey:@"school"];
            if (school && [school isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setObject:school[@"face"] forKey:@"face"];
                [dic setObject:@"" forKey:@"from"];
                [dic setObject:@"" forKey:@"logintime"];
                [dic setObject:school[@"school_name"] forKey:@"teacher_name"];
                [dic setObject:@"" forKey:@"status"];
                [dic setObject:school[@"school_id"] forKey:@"teacher_id"];
                [dic setObject:school[@"userid"] forKey:@"userid"];
                
                NSMutableArray *tmpArr3 = [NSMutableArray array];
                MainListTeacherItem *item = [[MainListTeacherItem alloc] init];
                [item reflectDataFromOtherObject:dic];
                [tmpArr3 addObject:item];
                
                MainListModel *model3 = [[MainListModel alloc] init];
                model3.indexButton = 100;
                [model3 setTeacherItems:tmpArr3];
                [_dataArray addObject:model3];
                [_resultsData addObject:model3];
                
                [tmpIndexArr addObject:item];
            }
            if ([tmpIndexArr count] > 0) {
                MainListModel *model = [[MainListModel alloc] init];
                model.indexButton = 100;
                [model setTeacherItems:tmpIndexArr];
                [_teacherIndexArray addObject:model];
            }
            if ([tmpIndexArr1 count] > 0) {
                MainListModel *model1 = [[MainListModel alloc] init];
                model1.indexButton = 100;
                [model1 setTeacherItems:tmpIndexArr1];
                [_teacherIndexArray addObject:model1];
            }
            if (indexBootm == 0) {
                self.dataSource = _studentIndexArray;
            }else{
                self.dataSource = _teacherIndexArray;
            }
        }
        [_tableView reloadData];
    }
}
- (void)customSegmentView
{
    UIView *mview = [[UIView alloc] initWithFrame:CGRectMake(50, 20, self.view.bounds.size.width-100, 44)];
    mview.backgroundColor = [UIColor clearColor];
    mview.userInteractionEnabled = YES;
    self.navigationItem.titleView = mview;
    
    NSArray *titlerr = @[@"班级",@"幼儿园"];
    for (int i = 0; i < [titlerr count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((mview.bounds.size.width-165)/2-5+87.5*i, 11.5, 82.5, 32.5);
        [button setBackgroundImage:[UIImage imageNamed:(i == 0) ? @"segmentbg.png" : @""] forState:UIControlStateNormal];
        [button setTitle:titlerr[i] forState:UIControlStateNormal];
        [button setTitleColor:(i == 0) ? [UIColor whiteColor] : [UIColor lightGrayColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 937+i;
        [mview addSubview:button];
    }
}
- (void)segmentAction:(UIButton *)button
{
    if (button.tag == lastIndexTag) {
        return;
    }
    [button setBackgroundImage:[UIImage imageNamed:@"segmentbg.png"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIButton *lastButton = (UIButton *)[self.navigationItem.titleView viewWithTag:lastIndexTag];
    if (lastButton) {
        [lastButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [lastButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    lastIndexTag = (int)button.tag;

    [_tableView setContentOffset:CGPointMake(0, 0)];
    
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (button.tag == 938) {
        indexBootm = 1;
        [_searchBar setHidden:NO];
        [headView setFrame:_searchBar.bounds];
        [headView addSubview:_searchBar];

        self.dataSource = _teacherIndexArray;
    }else{
        indexBootm = 0;
        [_searchBar setHidden:YES];
        self.dataSource = _studentIndexArray;
    }
    [_tableView setTableHeaderView:headView];
    [_tableView reloadData];
}
- (void)setCustomAlertView
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIView *bgView = [[UIView alloc] initWithFrame:app.window.bounds];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.userInteractionEnabled = YES;
    bgView.alpha = 0.5;
    bgView.tag = 400;
    [app.window addSubview:bgView];
    
    UIView *mview = [[UIView alloc] initWithFrame:CGRectMake((app.window.bounds.size.width-240)/2, (app.window.bounds.size.height-132)/2, 240, 132)];
    mview.backgroundColor = [UIColor whiteColor];
    mview.userInteractionEnabled = YES;
    mview.tag = 500;
    [app.window addSubview:mview];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, mview.bounds.size.width-25, 20)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor grayColor];
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.text = currStudentModel.name;
    [mview addSubview:nameLabel];
    
    UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, mview.bounds.size.width-20, 20)];
    phoneLabel.backgroundColor = [UIColor clearColor];
    phoneLabel.textColor = [UIColor blackColor];
    phoneLabel.font = [UIFont systemFontOfSize:16];
    phoneLabel.textAlignment = NSTextAlignmentCenter;
    phoneLabel.text = currStudentModel.userid;
    [mview addSubview:phoneLabel];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(15, 80, 100, 30)];
    button1.backgroundColor = CreateColor(70, 174, 58);
    [button1 setTitle:@"拨号" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button1.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    button1.tag = 100;
    [button1 addTarget:self action:@selector(alerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [mview addSubview:button1];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(125, 80, 100, 30)];
    button2.backgroundColor = CreateColor(39, 103, 194);
    [button2 setTitle:@"推荐使用" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button2.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    button2.tag = 200;
    [button2 addTarget:self action:@selector(alerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [mview addSubview:button2];
    
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(mview.bounds.size.width-50, 0, 50, 50)];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deletecook.png"]];
    imgView.frame = CGRectMake(25, 0, 25, 25);
    [deleteButton addSubview:imgView];
    deleteButton.tag = 300;
    [deleteButton addTarget:self action:@selector(alerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [mview addSubview:deleteButton];
}
- (void)alerButtonAction:(UIButton *)btn
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIView *bgview = (UIView *)[app.window viewWithTag:400];
    if (bgview) {
        [bgview removeFromSuperview];
    }
    UIView *alertview = (UIView *)[app.window viewWithTag:500];
    if (alertview) {
        [alertview removeFromSuperview];
    }
    if (btn.tag == 100) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", currStudentModel.userid]]];
    }else if (btn.tag == 200){
        if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
            [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
            return;
        }
        DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
        NSMutableDictionary *param = [manager requestinitParamsWith:@"invite"];
        [param setObject:currStudentModel.mid forKey:@"mid"];
        [param setObject:manager.userInfo.userid forKey:@"teacher_id"];
        [param setObject:currStudentModel.baby_id forKey:@"baby_id"];
        NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
        [param setObject:text forKey:@"signature"];
        
        __weak __typeof(self)weakSelf = self;
        [self.view makeToastActivity];
        self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"class"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
            [weakSelf recommendedFinish:success Data:data];
        } failedBlock:^(NSString *description) {
            [weakSelf recommendedFinish:NO Data:nil];
        }];

    }
}
#pragma mark - DJTImagePickerDelegate delegate
- (void)callPhoneMainListCell:(UITableViewCell *)cell Model:(MainListStudentItem *)model
{
    MainListStudentItem *item = (MainListStudentItem *)model;
    currStudentModel = item;
    
    [self setCustomAlertView];
}
- (void)recommendedFinish:(BOOL)success Data:(id)result
{
    [self.view hideToastActivity];
    self.httpOperation = nil;
    if (success) {
        [self.view makeToast:@"推荐成功" duration:1.0 position:@"center"];
        
        MainListModel *model = _studentIndexArray[0];
        //(student && [student isKindOfClass:[NSArray class]])
        for (int i = 0; i < [model.items count]; i++) {
            MainListStudentItem *item = [model.items objectAtIndex:i];
            if ([item.baby_id isEqualToString:currStudentModel.baby_id]) {
                [model.items removeObjectAtIndex:i];
                
                currStudentModel.status = @"2";
                [model.items insertObject:currStudentModel atIndex:i];
            }
        }
        
        [_tableView reloadData];
    }
    else
    {
        NSString *ret_msg = [result valueForKey:@"ret_msg"];
        ret_msg = ret_msg ?: REQUEST_FAILE_TIP;
        [self.view makeToast:ret_msg duration:1.0 position:@"center"];
    }
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == searchDisplayController.searchResultsTableView)
    {
        return 1;
    }else{
        return [self.dataSource count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == searchDisplayController.searchResultsTableView)
    {
        MainListModel *model = _resultsData[0];
        return model.teacherItems.count;
    }
    else
    {
        MainListModel *model = [self.dataSource objectAtIndex:section];
        return (model.indexButton == 200) ? [model.items count] : [model.teacherItems count];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView == searchDisplayController.searchResultsTableView)
    {
        return 0.0;
    }
    return 20;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView != searchDisplayController.searchResultsTableView)
    {
        MainListModel *model = [self.dataSource objectAtIndex:section];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
        label.backgroundColor = CreateColor(47, 201, 102);
        label.textAlignment = NSTextAlignmentCenter;
        if (model.indexButton == 200) {
            MainListStudentItem *item = model.items[0];
            label.text = ([item.status integerValue] != 1) ? @"未使用童印" : @"已使用童印";
        }else{
            MainListTeacherItem *item = model.teacherItems[0];
            label.text = ([item.status integerValue] == 0) ? @"园长" : @"同事";
        }
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14];
        return label;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == searchDisplayController.searchResultsTableView)
    {
        static NSString *cellId = @"mycell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
        MainListModel *model = _resultsData[0];
        MainListTeacherItem *item = model.teacherItems[indexPath.row];
        cell.textLabel.text = item.teacher_name;
        return cell;
    }else{
        static NSString *cellMore = @"CellMainList";
        
        MailListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellMore];
        if (cell == nil)
        {
            cell = [[MailListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellMore];
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.delegate = self;
        MainListModel *model = self.dataSource[indexPath.section];
        if (model.indexButton == 200) {
            MainListStudentItem *item = model.items[indexPath.row];
            [cell resetClassMainListData:item isHidden:([item.status integerValue] != 1) ? NO : YES isTeacher:NO];
        }else{
            MainListTeacherItem *item = model.teacherItems[indexPath.row];
            [cell resetClassMainListData:item isHidden:([item.status integerValue] == 0) ? NO : YES isTeacher:YES];
        }
        return cell;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == searchDisplayController.searchResultsTableView)
    {
        //[_searchBar resignFirstResponder];
        MainListModel *model = _resultsData[0];
        MainListTeacherItem *item = model.teacherItems[indexPath.row];
        SearchDetailViewController *detail = [[SearchDetailViewController alloc] init];
        detail.teacherItem = item;
        [self.navigationController pushViewController:detail animated:YES];
    }
}
#pragma mark UISearchBar and UISearchDisplayController Delegate Methods

//searchBar开始编辑时改变取消按钮的文字
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    _searchBar.showsCancelButton = YES;
    
    NSArray *subViews;
    
    subViews = [(_searchBar.subviews[0]) subviews];
    
    for (id view in subViews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton* cancelbutton = (UIButton* )view;
            [cancelbutton setTitle:@"取消" forState:UIControlStateNormal];
            break;
        }
    }
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //一旦SearchBar輸入內容有變化，則執行這個方法，詢問要不要重裝searchResultTableView的數據
    
    // Return YES to cause the search result table view to be reloaded.
    
    [self filterContentForSearchText:searchString scope:[_searchBar scopeButtonTitles][_searchBar.selectedScopeButtonIndex]];
    
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption

{
    //如果设置了选项，当Scope Button选项有變化的时候，則執行這個方法，詢問要不要重裝searchResultTableView的數據
    
    // Return YES to cause the search result table view to be reloaded.
    
    [self filterContentForSearchText:_searchBar.text scope:_searchBar.scopeButtonTitles[searchOption]];
    
    return YES;
}
//源字符串内容是否包含或等于要搜索的字符串内容
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSMutableArray *tempResults = [NSMutableArray array];
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    MainListModel *model = [_dataArray objectAtIndex:0];
    for (int i = 0; i < model.teacherItems.count; i++) {
        MainListTeacherItem *item = model.teacherItems[i];
        NSString *storeString = item.teacher_name;
        NSRange storeRange = NSMakeRange(0, storeString.length);
        NSRange foundRange = [storeString rangeOfString:searchText options:searchOptions range:storeRange];
        if (foundRange.length) {
            [tempResults addObject:item];
        }
    }
    MainListModel *nmodel = [[MainListModel alloc] init];
    nmodel.indexButton = 100;
    [nmodel setTeacherItems:tempResults];
    [_resultsData removeAllObjects];
    [_resultsData addObject:nmodel];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
