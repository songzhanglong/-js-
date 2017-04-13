//
//  StudentContactViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/25.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "StudentContactViewController.h"
#import "DJTGlobalDefineKit.h"
#import "DJTGlobalManager.h"
#import "NSObject+Reflect.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"
#import "HomeCardTemplateModel.h"
#import "WeekListModel.h"
#import "DJTListView.h"
#import <AVFoundation/AVFoundation.h>

@interface StudentContactViewController ()<UITableViewDelegate,UITableViewDataSource,ListViewDelegate,AVAudioPlayerDelegate>{
    UITableView         *_studentTableView;
    NSMutableArray      *_dataSource;
    DJTListView         *_listView;
    HomeCardCommentModel *_commentModel;
    AVAudioPlayer *_audioPlayer;
}

@end

@implementation StudentContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nCurIndex = 2;
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (!manager.homeCardArr) {
        [self requestHomeCardTemplete];
    }
    else if (!manager.weekList)
    {
        [self requestWeekList];
    }
    else
    {
        [self createTableView];
    }
}

- (void)createTableView
{
    CGFloat yOri = 0;
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    _studentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _selectView.frame.origin.y + _selectView.frame.size.height, winSize.width, winSize.height - (_selectView.frame.origin.y + _selectView.frame.size.height) - yOri) style:UITableViewStylePlain];
    //[_studentTableView setTableFooterView:[[UIView alloc] init]];
    [_studentTableView setTableHeaderView:[self savedHeaderView]];
    HomeCardCommentModel *comment = [[HomeCardCommentModel alloc] init];
    [comment reflectDataFromOtherObject:self.myStudentModel];
    [_studentTableView setTableFooterView:[self createFootView:comment]];
    _studentTableView.delegate = self;
    _studentTableView.dataSource = self;
    [self.view addSubview:_studentTableView];
    
    _dataSource = [NSMutableArray array];
    NSArray *templete = [DJTGlobalManager shareInstance].homeCardArr;
    for (HomeCardTemplateModel *model in templete) {
        HomeCardTemplateModel *curMod = [[HomeCardTemplateModel alloc] init];
        [curMod reflectDataFromOtherObject:model];
        for (BabyCard *card in self.myStudentModel.cards) {
            if ([curMod.card_template_id isEqualToString:card.card_template_id]) {
                [curMod reflectDataFromOtherObject:card];
            }
        }
        [_dataSource addObject:curMod];
    }
}

#pragma mark - 播放录音文件
- (void)playAudio:(UIButton *)button
{
    NSString *str = (button.tag == 1) ? _commentModel.card_school_content : _commentModel.card_home_content;
    NSString *fileName = [str lastPathComponent];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        //播放
        [self videoBeginPlay:filePath];
    }
    else
    {
        [self.view makeToastActivity];
        _studentTableView.userInteractionEnabled = NO;
        __weak typeof(self)weakSelf = self;
        __weak typeof(_studentTableView)weakTab = _studentTableView;
        self.httpOperation = [DJTHttpClient asynchronousRequestWithProgress:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil filePath:nil ssuccessBlcok:^(BOOL success, id data, NSString *msg) {
            [data writeToFile:filePath atomically:NO];
            [weakSelf.view hideToastActivity];
            weakTab.userInteractionEnabled = YES;
            [weakSelf videoBeginPlay:filePath];
            weakSelf.httpOperation = nil;
        } failedBlock:^(NSString *description) {
            [weakSelf.view hideToastActivity];
            weakTab.userInteractionEnabled = YES;
            weakSelf.httpOperation = nil;
        } progressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            
        }];
    }
}

- (void)videoBeginPlay:(NSString *)filePath
{
    if (_audioPlayer && [_audioPlayer isPlaying]) {
        return;
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
    ;
    _audioPlayer = nil;
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:nil];
    [_audioPlayer setDelegate:self];
    //[pAudioPlayer prepareToPlay];
    [_audioPlayer play];
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    _audioPlayer = nil;
}

#pragma mark - 表头与表尾
- (UIView *)savedHeaderView
{
    UIView *back = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44.0)];
    [back setBackgroundColor:[UIColor colorWithRed:239/255.0 green:241/255.0 blue:237/255.0 alpha:1.0]];
    
    //list
    CGFloat winWei = [[UIScreen mainScreen] bounds].size.width;
    CGFloat labWei = (winWei / 2 - 40) / 2;
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    DJTListView *listView = [[DJTListView alloc] initWithFrame:CGRectMake(2, 5, 190, 30)];
    _listView = listView;
    [listView setPSource:manager.weekList];
    listView.curIndex = manager.weekIdx;
    [self.view addSubview:listView];
    listView.delegate = self;
    [back addSubview:listView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(winWei - (labWei + 10) * 2, 0, labWei, 44.0)];
    [label setBackgroundColor:[UIColor clearColor]];
    label.text = @"教师";
    [label setTextAlignment:1];
    label.font = [UIFont systemFontOfSize:15];
    [back addSubview:label];
    
    //家长
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(winWei - (labWei + 10), 0, labWei, 44.0)];
    [label2 setTextAlignment:1];
    [label2 setBackgroundColor:[UIColor clearColor]];
    label2.text = @"家长";
    label2.font = [UIFont systemFontOfSize:15];
    [back addSubview:label2];
    return back;
}

- (UIView *)createFootView:(HomeCardCommentModel *)model
{
    if (!model || ((!model.card_home_comment_type || [model.card_home_comment_type length] <= 0) && (!model.card_school_comment_type || [model.card_school_comment_type length] <= 0))) {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    _commentModel = model;
    
    float yOri = 5;
    UIView *back = [[UIView alloc] init];
    [back setBackgroundColor:[UIColor colorWithRed:239/255.0 green:241/255.0 blue:237/255.0 alpha:1.0]];
    
    if ([model.card_school_comment_type length] > 0)
    {
        //人物
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, yOri, 80, 20)];
        [label setTextAlignment:2];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setText:@"教师:"];
        [back addSubview:label];
        
        if ([model.card_school_comment_type isEqualToString:@"1"]) {
            UIButton *play = [UIButton buttonWithType:UIButtonTypeCustom];
            play.frame = CGRectMake(100, yOri, 200, 20);
            [play setTitle:@"播放录音" forState:UIControlStateNormal];
            [play setTag:1];
            [play addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
            [play setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [play setBackgroundColor:[UIColor whiteColor]];
            [back addSubview:play];
            
            yOri += 20 + 5;
        }
        else
        {
            CGSize lastSize = CGSizeZero;
            NSDictionary *attribute = @{NSFontAttributeName: label.font};
            lastSize = [model.card_school_content boundingRectWithSize:CGSizeMake(200, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
            
            UILabel *labelCon = [[UILabel alloc] initWithFrame:CGRectMake(100, yOri, 200, lastSize.height)];
            [labelCon setNumberOfLines:0];
            [labelCon setBackgroundColor:[UIColor clearColor]];
            [labelCon setText:model.card_school_content];
            [back addSubview:labelCon];
            
            yOri += MAX(lastSize.height, 20) + 5;
        }
    }
    
    if ([model.card_home_comment_type length] > 0)
    {
        //人物
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, yOri, 80, 20)];
        [label setTextAlignment:2];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setText:@"家长:"];
        [back addSubview:label];
        
        if ([model.card_home_comment_type isEqualToString:@"1"]) {
            UIButton *play = [UIButton buttonWithType:UIButtonTypeCustom];
            play.frame = CGRectMake(100, yOri, 200, 20);
            [play setTag:2];
            [play addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
            [play setTitle:@"播放录音" forState:UIControlStateNormal];
            [play setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [play setBackgroundColor:[UIColor whiteColor]];
            [back addSubview:play];
            
            yOri += 20 + 5;
        }
        else
        {
            CGSize lastSize = CGSizeZero;
            NSDictionary *attribute = @{NSFontAttributeName: label.font};
            lastSize = [model.card_home_content boundingRectWithSize:CGSizeMake(200, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
            
            UILabel *labelCon = [[UILabel alloc] initWithFrame:CGRectMake(100, yOri, 200, lastSize.height)];
            [labelCon setNumberOfLines:0];
            [labelCon setBackgroundColor:[UIColor clearColor]];
            [labelCon setText:model.card_home_content];
            [back addSubview:labelCon];
            
            yOri += MAX(lastSize.height, 20) + 5;
        }
    }
    
    [back setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, yOri)];
    return back;
}



#pragma mark - ListViewDelegate
- (void)selectData:(id)object IndexPath:(NSIndexPath *)indexPath
{
    if (_audioPlayer && _audioPlayer.isPlaying) {
        [_audioPlayer stop];
    }
    WeekListModel *model = [_listView.titleArray objectAtIndex:indexPath.row];
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    [manager setWeekIdx:indexPath.row];
    NSDictionary *dic = @{@"student_id":self.student.student_id,@"term_id":manager.userInfo.term_id,@"week_index":model.week_index};
    [self.view makeToastActivity];
    _studentTableView.userInteractionEnabled = NO;
    _listView.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousNormalRequest:[URLFACE stringByAppendingString:@"work:student"] parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf requestListFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf requestListFinish:NO Data:nil];
    }];
}

/**
 *	@brief	加载某个学生的家园联系卡内容
 *
 *	@param 	dic 	家园联系卡内容
 *	@param 	success 	yes-成功
 */
- (void)requestListFinish:(BOOL)success Data:(id)result
{
    NSLog(@"result:%@",result);
    [self.view hideToastActivity];
    _studentTableView.userInteractionEnabled = YES;
    _listView.userInteractionEnabled = YES;
    self.httpOperation = nil;
    HomeCardCommentModel *comment = nil;
    if (success) {
        comment = [[HomeCardCommentModel alloc] init];
        [comment reflectDataFromOtherObject:result];
        
        NSArray *templete = [DJTGlobalManager shareInstance].homeCardArr;
        NSArray *list = [result valueForKey:@"list"];
        list = (!list || [list isKindOfClass:[NSNull class]]) ? [NSArray array] : list;
        NSMutableArray *array = [NSMutableArray array];
        if (list && [list count] > 0) {
            for (HomeCardTemplateModel *model in templete) {
                HomeCardTemplateModel *curMod = [[HomeCardTemplateModel alloc] init];
                [curMod reflectDataFromOtherObject:model];
                for (NSDictionary *subDic in list) {
                    NSString *card_template_id = [subDic valueForKey:@"card_template_id"];
                    if ([curMod.card_template_id isEqualToString:card_template_id]) {
                        [curMod reflectDataFromOtherObject:subDic];
                    }
                }
                [array addObject:curMod];
            }
            
            _dataSource = array;
            //[_preView removeFromSuperview];
        }
        else
        {
            //[self.view addSubview:_preView];
        }
        
    }
    [_studentTableView setTableFooterView:[self createFootView:comment]];
    [_studentTableView reloadData];
}

#pragma mark - 家园联系模版内容
- (void)requestHomeCardTemplete
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self.view makeToastActivity];
    //针对老接口
    NSString *url = [URLFACE stringByAppendingString:@"work:load_card"];
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    NSDictionary *dic = @{@"class_id":user.classid,@"term_id":user.term_id};
    __weak typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf requestHomeCardFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf requestHomeCardFinish:NO Data:nil];
    }];
}

- (void)requestHomeCardFinish:(BOOL)success Data:(id)result
{
    self.httpOperation = nil;
    [self.view hideToastActivity];
    if (success) {
        NSArray *list = [result valueForKey:@"list"];
        list = (!list || [list isKindOfClass:[NSNull class]]) ? [NSArray array] : list;
        NSMutableArray *array = [NSMutableArray array];
        for (id sub in list) {
            HomeCardTemplateModel *model = [[HomeCardTemplateModel alloc] init];
            [model reflectDataFromOtherObject:sub];
            CGFloat wei = [[UIScreen mainScreen] bounds].size.width / 2;
            [model calculateSizeBy:[UIFont systemFontOfSize:16] Wei:wei];
            [array addObject:model];
        }
        DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
        [manager setHomeCardArr:array];
        if (manager.weekList) {
            //
            [self createTableView];
        }
        else
        {
            [self requestWeekList];
        }
    }
    else
    {
        [self.view makeToast:@"家园联系卡模板获取失败" duration:1.0 position:@"center"];
    }
}

#pragma mark - 家园联系周列表
- (void)requestWeekList
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self.view makeToastActivity];
    //针对老接口
    NSString *url = [URLFACE stringByAppendingString:@"work:week_list"];
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    NSDictionary *dic = @{@"school_id":user.schoolid};
    __weak typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf requestWeekListFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf requestWeekListFinish:NO Data:nil];
    }];
}

- (void)requestWeekListFinish:(BOOL)suc Data:(id)result
{
    [self.view hideToastActivity];
    self.httpOperation = nil;
    
    if (suc) {
        NSArray *list = [result valueForKey:@"list"];
        list = (!list || [list isKindOfClass:[NSNull class]]) ? [NSArray array] : list;
        NSMutableArray *array = [NSMutableArray array];
        for (id sub in list) {
            NSError *error = nil;
            WeekListModel *model = [[WeekListModel alloc] initWithDictionary:sub error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            if ([model.week_index integerValue] == 0) {
                continue;
            }
            [array addObject:model];
        }
        [[DJTGlobalManager shareInstance] setWeekList:array];
        [self createTableView];
    }
    else
    {
        NSString *message = [result valueForKey:@"message"];
        message = message ?: @"家园联系周列表获取失败";
        [self.view makeToast:message duration:1.0 position:@"center"];
    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *homeCntCell = @"DJTHomeCntCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:homeCntCell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:homeCntCell];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        CGFloat xOri = 10.0,yOri = 10.0;
        CGFloat wei = [[UIScreen mainScreen] bounds].size.width / 2;
        
        //message
        UILabel *conLab = [[UILabel alloc] initWithFrame:CGRectMake(xOri, yOri, wei, 20.0)];
        [conLab setNumberOfLines:0];
        [conLab setFont:[UIFont systemFontOfSize:16]];
        [conLab setTextColor:[UIColor blackColor]];
        conLab.alpha = 0.7;
        [conLab setTag:1];
        [cell.contentView addSubview:conLab];
        
        //teacher comment
        CGFloat labWei = (wei - xOri * 4) / 2;
        UILabel *teacLab = [[UILabel alloc] initWithFrame:CGRectMake(wei + xOri * 2, yOri, labWei, 20.0)];
        [teacLab setTextAlignment:1];
        [teacLab setTextColor:[UIColor redColor]];
        [teacLab setFont: [UIFont systemFontOfSize:16.0]];
        [teacLab setTag:2];
        [cell.contentView addSubview:teacLab];
        
        //parent comment
        UILabel *parLab = [[UILabel alloc] initWithFrame:CGRectMake(teacLab.frame.origin.x + teacLab.frame.size.width + xOri, yOri, teacLab.frame.size.width, 20.0)];
        [parLab setTextAlignment:1];
        [parLab setTag:3];
        [parLab setTextColor:[UIColor redColor]];
        [parLab setFont: [UIFont systemFontOfSize:16.0]];
        [cell.contentView addSubview:parLab];
    }
    
    HomeCardTemplateModel *model = _dataSource[indexPath.row];
    UILabel *conLab = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *teacLab = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *parLab = (UILabel *)[cell.contentView viewWithTag:3];
    CGRect msgRec = conLab.frame;
    [conLab setFrame:CGRectMake(msgRec.origin.x, msgRec.origin.y, msgRec.size.width, model.carSize.height)];
    [conLab setText:model.card_title];
    if((![model.school isEqualToString:@"1"]) && (![model.school isEqualToString:@"2"]))
    {
        [teacLab setText:@""];
    }
    else
    {
        NSString *school = ([model.school isEqualToString:@"1"] ? @"优秀" : @"良好");
        [teacLab setText:school];
    }
    
    if((![model.home isEqualToString:@"1"]) && (![model.home isEqualToString:@"2"]))
    {
        
        [parLab setText:@""];
    }
    else
    {
        NSString *home = ([model.home isEqualToString:@"1"] ? @"优秀" : @"良好");
        [parLab setText:home];
    }

    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeCardTemplateModel *model = _dataSource[indexPath.row];
    CGFloat hei = model.carSize.height + 20;
    
    return MAX(hei, 40);
}

@end
