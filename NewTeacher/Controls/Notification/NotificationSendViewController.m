//
//  NotificationSendViewController.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/9.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "NotificationSendViewController.h"
#import "SelectStudentViewController.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"
#import "TeacherModel.h"

#pragma mark - 可删除视图
@class DeleteNotiImageView;
@protocol DeleteNotiImageViewDelegate <NSObject>

@optional
- (void)deleteImageView:(DeleteNotiImageView *)imageView;

@end

@interface DeleteNotiImageView : UIView

@property (nonatomic,assign)id<DeleteNotiImageViewDelegate> delegate;

@property (nonatomic,strong)UIImageView *contentImg;

@end

@implementation DeleteNotiImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        _contentImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _contentImg.layer.masksToBounds = YES;
        _contentImg.layer.cornerRadius = MIN(frame.size.width, frame.size.height) / 2;
        [self addSubview:_contentImg];
        
        UIButton *_deleteBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBut setImage:[UIImage imageNamed:@"closed1.png"] forState:UIControlStateNormal];
        [_deleteBut setFrame:CGRectMake(frame.size.width - 20, -5, 25, 25)];
        [_deleteBut setBackgroundColor:[UIColor clearColor]];
        [_deleteBut addTarget:self action:@selector(deleteSelf:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteBut];
    }
    return self;
}

- (void)deleteSelf:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(deleteImageView:)]) {
        [_delegate deleteImageView:self];
    }
    
    [self removeFromSuperview];
}

@end

@interface NotificationSendViewController ()<SelectStudentViewDelegate,UIScrollViewDelegate,DeleteNotiImageViewDelegate,UITextViewDelegate>{
    UIScrollView *_scrollView;
    NSMutableArray  *_dataSource;
    UIView          *_sendHeaderView;
    UIView          *_sendTextView;
    UITextView      *_contentTextView;
    UIButton        *_sendButton,*_allStuBut,*_addBut;
    NSMutableArray  *_teacherData;
}

@end

@implementation NotificationSendViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showBack=YES;
    self.titleLable.text = @"创建新消息";
    _dataSource = [NSMutableArray  array];
    _teacherData = [NSMutableArray  array];
    lastTextValue=@"";
    if (_sendToIndex != 1) {
        [_dataSource addObjectsFromArray:[DJTGlobalManager shareInstance].userInfo.students];
    }
    
    //监视键盘高度变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidBeginChange:) name:UITextViewTextDidChangeNotification object:nil];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    _scrollView.delegate = self;
    [_scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    [self.view addSubview:_scrollView];
    
    //up
    _sendHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    _sendHeaderView.backgroundColor = CreateColor(62.0, 70.0, 98.0);
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, 60, 20)];
    tipLabel.text = @"发送给:";
    tipLabel.textColor = [UIColor whiteColor];
    [tipLabel setBackgroundColor:[UIColor clearColor]];
    [tipLabel setTextAlignment:2];
    [_sendHeaderView addSubview:tipLabel];
    
    UIButton *allBut = [UIButton buttonWithType:UIButtonTypeCustom];
    allBut.layer.masksToBounds = YES;
    allBut.layer.cornerRadius = 10.0;
    [allBut setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    _allStuBut = allBut;
    [allBut setTitle:(_sendToIndex == 1) ? @"全园教师" : @"全班同学" forState:UIControlStateNormal];
    [allBut setFrame:CGRectMake(70, 30, 190, 40)];
    [allBut addTarget:self action:@selector(selectStudents:) forControlEvents:UIControlEventTouchUpInside];
    [_sendHeaderView addSubview:allBut];
    [_scrollView addSubview:_sendHeaderView];
    
    //down
    _sendTextView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, 180)];
    [_scrollView addSubview:_sendTextView];
    
    UILabel *downTip = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 20, 20)];
    [downTip setText:@"内容(300字以内)"];
    [_sendTextView addSubview:downTip];
    
    _contentTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, 40, SCREEN_WIDTH - 20, 120)];
    _contentTextView.backgroundColor = CreateColor(247.0, 247.0, 247.0);
    _contentTextView.returnKeyType = UIReturnKeyDone;
    _contentTextView.delegate = self;
    _contentTextView.layer.cornerRadius = 10.0;
    _contentTextView.layer.masksToBounds = YES;
    [_sendTextView addSubview:_contentTextView];
    
    //send button
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sendButton setFrame:CGRectMake(10, _sendTextView.frame.origin.y + _sendTextView.frame.size.height  + 30, SCREEN_WIDTH - 20, 45)];
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    _sendButton.backgroundColor = CreateColor(70.0, 57.0, 53.0);
    _sendButton.layer.masksToBounds = YES;
    _sendButton.layer.cornerRadius = 10.0;
    [_sendButton addTarget:self action:@selector(sendNotification:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_sendButton];
    
    if (_sendToIndex == 1) {
        [self sendToRequest];
    }
}

#pragma mark - 获取教师信息
- (void)sendToRequest
{
    _scrollView.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    __weak typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"member"];
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    NSMutableDictionary *dic = [[DJTGlobalManager shareInstance] requestinitParamsWith:@"getTeacherBySchool"];
    [dic setObject:user.schoolid forKey:@"school_id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:dic];
    [dic setObject:text forKey:@"signature"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf getTeacherInfoFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf getTeacherInfoFinish:NO Data:nil];
    }];
}

- (void)getTeacherInfoFinish:(BOOL)suc Data:(id)result
{
    _scrollView.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    self.httpOperation = nil;
    if (suc) {
        NSArray *data = [result valueForKey:@"ret_data"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        for (id subDic in data) {
            NSError *error = nil;
            TeacherModel *model = [[TeacherModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [_teacherData addObject:model];
        }
        [_dataSource addObjectsFromArray:_teacherData];
    }
    else
    {
        NSString *str = [result valueForKey:@"ret_msg"];
        str = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

- (void)sendNotification:(id)sender{
    if (_contentTextView.isFirstResponder) {
        [_contentTextView resignFirstResponder];
    }
    
    if (!_contentTextView.text || [_contentTextView.text length] == 0) {
            [self.view makeToast:@"请先编辑内容" duration:1.0 position:@"other"];
        return;
    }
    else
    {
        NSString *newStr = [_contentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([newStr length] <= 0) {
                [self.view makeToast:@"不能全部输入空字符" duration:1.0 position:@"other"];
            return;
        }
        else if (_contentTextView.text.length > 300)
        {
                [self.view makeToast:@"内容(300字以内)" duration:1.0 position:@"other"];
            return;
        }
    }
    
    if (_dataSource.count == 0) {
        [self.view makeToast:(_sendToIndex == 1) ? @"请选择教师" : @"请选择学生" duration:1.0 position:@"other"];
        return;
    }
    
    //网络判断
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view.window makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self publicSchoolNotifi];
}

- (void)selectStudents:(id)sender{
    if (_contentTextView.isFirstResponder) {
        [_contentTextView resignFirstResponder];
    }
    SelectStudentViewController *selectStudent = [[SelectStudentViewController alloc]init];
    selectStudent.delegate = self;
    NSMutableArray *pre = [NSMutableArray array];
    if (_sendToIndex == 1) {
        selectStudent.teacherArray = _teacherData;
        for (id sub in _dataSource) {
            NSInteger index = [_teacherData indexOfObject:sub];
            [pre addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }else{
        for (id sub in _dataSource) {
            NSInteger index = [[DJTGlobalManager shareInstance].userInfo.students indexOfObject:sub];
            [pre addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }
    selectStudent.isSendToTeacher = (_sendToIndex == 1);
    selectStudent.preArr = pre;
    [self.navigationController pushViewController:selectStudent animated:YES];
}

#pragma mark - 发送园所通知
- (void)publicSchoolNotifi
{
    _scrollView.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    __weak typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"message"];
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    NSMutableDictionary *dic = [[DJTGlobalManager shareInstance] requestinitParamsWith:@"sendMessage"];
    [dic setObject:user.userid forKey:@"sender"];
    [dic setObject:_contentTextView.text forKey:@"content"];
    [dic setObject:@"teacher" forKey:@"sender_type"];
    [dic setObject:@"127.0.0.1" forKey:@"ip"];
    [dic setObject:@"school" forKey:@"type"];
    [dic setObject:(_sendToIndex == 1) ? @"teacher" : @"member" forKey:@"receiver_type"];
    NSMutableArray *array = [NSMutableArray array];
    if (_sendToIndex == 1) {
        for (TeacherModel *teacher in _dataSource) {
            [array addObject:teacher.teacher_id];
        }
        [dic removeObjectForKey:@"class_id"];
    }else{
        for (DJTStudent *student in _dataSource) {
            [array addObject:student.student_id];
        }
    }
    
    NSString *receiver = (array.count == 0) ? @"" : [array componentsJoinedByString:@"|"];
    [dic setObject:receiver forKey:@"receiver"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:dic];
    [dic setObject:text forKey:@"signature"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf publishNotifiFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf publishNotifiFinish:NO Data:nil];
    }];
}

- (void)publishNotifiFinish:(BOOL)suc Data:(id)result
{
    _scrollView.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    self.httpOperation = nil;
    if (suc) {
        if (_delegate && [_delegate respondsToSelector:@selector(publistMessageFinish)]) {
            [_delegate publistMessageFinish];
        }
        else
        {
            [self.view makeToast:@"评论发布成功" duration:1.0 position:@"center"];
        }
    }
    else
    {
        NSString *str = [result valueForKey:@"ret_msg"];
        str = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - SelectStudentViewDelegate
- (void)sendToPeople:(NSMutableArray *)people{
    [_dataSource removeAllObjects];
    [_dataSource addObjectsFromArray:people];
    for (UIView *subView in _sendHeaderView.subviews) {
        if ([subView isKindOfClass:[DeleteNotiImageView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    CGRect headRec = _sendHeaderView.frame;
    CGRect downRec = _sendTextView.frame;
    CGRect butRec = _sendButton.frame;
    
    if (_sendToIndex == 1) {
        if (_dataSource.count == _teacherData.count) {
            if (![_allStuBut isDescendantOfView:_sendHeaderView]) {
                [_sendHeaderView addSubview:_allStuBut];
            }
            
            if (_addBut) {
                [_addBut removeFromSuperview];
                _addBut = nil;
            }
            
            [_sendHeaderView setFrame:CGRectMake(headRec.origin.x, headRec.origin.y, headRec.size.width, 100)];
        }
        else
        {
            if ([_allStuBut isDescendantOfView:_sendHeaderView]) {
                [_allStuBut removeFromSuperview];
            }
            
            NSInteger firstCount = 0;
            NSInteger curCount = _dataSource.count;
            
            if (!_addBut) {
                _addBut = [UIButton buttonWithType:UIButtonTypeCustom];
                [_addBut setFrame:CGRectMake(70, 30, 40, 40)];
                [_addBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"++" ofType:@"png"]] forState:UIControlStateNormal];
                [_addBut addTarget:self action:@selector(selectStudents:) forControlEvents:UIControlEventTouchUpInside];
                [_sendHeaderView addSubview:_addBut];
            }
            
            CGFloat margin = 10;
            NSInteger cols = (SCREEN_WIDTH - 70) / (40 + margin);
            NSInteger rows = _dataSource.count / cols + 1;
            for (NSInteger i = firstCount; i < curCount; i++) {
                NSInteger col = (i + 1) % cols;
                NSInteger row = (i + 1) / cols;
                TeacherModel *student = _dataSource[i];
                NSString *str = student.face;
                NSString *url = [str hasPrefix:@"http"] ? str : [G_IMAGE_ADDRESS stringByAppendingString:str ?: @""];
                DeleteNotiImageView *subImg = [[DeleteNotiImageView alloc] initWithFrame:CGRectMake((40 + margin) * col + 70, 30 + (40 + 5) * row, 40, 40)];
                subImg.delegate = self;
                [subImg setTag:i + 1];
                [subImg.contentImg setImageWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"s21.png"]];
                [_sendHeaderView addSubview:subImg];
            }
            
            
            [_sendHeaderView setFrame:CGRectMake(headRec.origin.x, headRec.origin.y, headRec.size.width, 30 + rows * (40 + 5) + 25)];
        }
    }else{
        if (_dataSource.count == [DJTGlobalManager shareInstance].userInfo.students.count) {
            if (![_allStuBut isDescendantOfView:_sendHeaderView]) {
                [_sendHeaderView addSubview:_allStuBut];
            }
            
            if (_addBut) {
                [_addBut removeFromSuperview];
                _addBut = nil;
            }
            
            [_sendHeaderView setFrame:CGRectMake(headRec.origin.x, headRec.origin.y, headRec.size.width, 100)];
        }
        else
        {
            if ([_allStuBut isDescendantOfView:_sendHeaderView]) {
                [_allStuBut removeFromSuperview];
            }
            
            NSInteger firstCount = 0;
            NSInteger curCount = _dataSource.count;
            
            if (!_addBut) {
                _addBut = [UIButton buttonWithType:UIButtonTypeCustom];
                [_addBut setFrame:CGRectMake(70, 30, 40, 40)];
                [_addBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"++" ofType:@"png"]] forState:UIControlStateNormal];
                [_addBut addTarget:self action:@selector(selectStudents:) forControlEvents:UIControlEventTouchUpInside];
                [_sendHeaderView addSubview:_addBut];
            }
            
            CGFloat margin = 10;
            NSInteger cols = (SCREEN_WIDTH - 70) / (40 + margin);
            NSInteger rows = _dataSource.count / cols + 1;
            for (NSInteger i = firstCount; i < curCount; i++) {
                NSInteger col = (i + 1) % cols;
                NSInteger row = (i + 1) / cols;
                DJTStudent *student = _dataSource[i];
                NSString *str = student.face;
                NSString *url = [str hasPrefix:@"http"] ? str : [G_IMAGE_ADDRESS stringByAppendingString:str ?: @""];
                DeleteNotiImageView *subImg = [[DeleteNotiImageView alloc] initWithFrame:CGRectMake((40 + margin) * col + 70, 30 + (40 + 5) * row, 40, 40)];
                subImg.delegate = self;
                [subImg setTag:i + 1];
                [subImg.contentImg setImageWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"s21.png"]];
                [_sendHeaderView addSubview:subImg];
            }
            
            
            [_sendHeaderView setFrame:CGRectMake(headRec.origin.x, headRec.origin.y, headRec.size.width, 30 + rows * (40 + 5) + 25)];
        }
    }
    
    [_sendTextView setFrame:CGRectMake(downRec.origin.x, headRec.origin.y + _sendHeaderView.frame.size.height, downRec.size.width, downRec.size.height)];
    [_sendButton setFrame:CGRectMake(butRec.origin.x, _sendTextView.frame.origin.y + _sendTextView.frame.size.height, butRec.size.width, butRec.size.height)];
    
    CGFloat conHei = MAX(_sendButton.frame.origin.y + _sendButton.frame.size.height, _scrollView.frame.size.height);
    [_scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, conHei)];
}

#pragma mark - 监视键盘高度变换
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    //键盘显示后的原点坐标
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat yMax = _scrollView.contentSize.height - _scrollView.frame.size.height;
    CGRect scrRec = _scrollView.frame;
    [_scrollView setContentOffset:CGPointMake(0, yMax)];
    CGFloat hei = _sendTextView.frame.origin.y + _sendTextView.frame.size.height - yMax;
    CGFloat margin = hei + keyboardRect.size.height - (SCREEN_HEIGHT - 64);
    if (margin > 0) {
        [_scrollView setFrame:CGRectMake(0, 0 - margin, scrRec.size.width, scrRec.size.height)];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect scrRec = _scrollView.frame;
    [_scrollView setFrame:CGRectMake(0, 0, scrRec.size.width, scrRec.size.height)];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_contentTextView.isFirstResponder) {
        [_contentTextView resignFirstResponder];
    }
}

#pragma mark - DeleteNotiImageViewDelegate
- (void)deleteImageView:(DeleteNotiImageView *)imageView
{
    if (_contentTextView.isFirstResponder) {
        [_contentTextView resignFirstResponder];
    }
    
    CGRect preRec = imageView.frame;
    NSInteger count = _dataSource.count;
    [_dataSource removeObjectAtIndex:imageView.tag - 1];
    for (NSInteger i = imageView.tag + 1; i <= count ; i++) {
        UIView *tempView = [_sendHeaderView viewWithTag:i];
        CGRect nextRec = tempView.frame;
        tempView.frame = preRec;
        tempView.tag -= 1;
        
        preRec = nextRec;
    }
    
    CGFloat margin = 10;
    NSInteger cols = (SCREEN_WIDTH - 70) / (40 + margin);
    NSInteger rows = _dataSource.count / cols + 1;
    CGFloat headHei = 30 + rows * (40 + 5) + 25;
    CGRect headRec = _sendHeaderView.frame;
    if (headHei == headRec.size.height) {
        return;
    }
    
    CGRect downRec = _sendTextView.frame;
    CGRect butRec = _sendButton.frame;
    
    [_sendHeaderView setFrame:CGRectMake(headRec.origin.x, headRec.origin.y, headRec.size.width, 30 + rows * (40 + 5) + 25)];
    [_sendTextView setFrame:CGRectMake(downRec.origin.x, headRec.origin.y + _sendHeaderView.frame.size.height, downRec.size.width, downRec.size.height)];
    [_sendButton setFrame:CGRectMake(butRec.origin.x, _sendTextView.frame.origin.y + _sendTextView.frame.size.height, butRec.size.width, butRec.size.height)];
    
    CGFloat conHei = MAX(_sendButton.frame.origin.y + _sendButton.frame.size.height, _scrollView.frame.size.height);
    [_scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, conHei)];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    /*
    BOOL emoji = [NSString isContainsEmoji:text];

    return !emoji;
     */
    
    return YES;
}


- (void)textViewDidBeginChange:(NSNotification *)notification
{
    UITextView *textView = (UITextView *)notification.object;
    if (textView != _contentTextView) {
        return;
    }
    
    NSString *toBeString = textView.text;
    NSString *lang = textView.textInputMode.primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            [self emojiStrSplit:toBeString];
            
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        [self emojiStrSplit:toBeString];
    }
}

- (void)emojiStrSplit:(NSString *)str
{
    int emoji = -1;
    NSString *lastStr = str;
    while ((lastStr && [lastStr length] > 0) && ((emoji = [NSString containsEmoji:lastStr]) != -1)) {
        int lenght = emoji % 10000;
        int location = emoji / 10000;
        lastStr = [lastStr stringByReplacingCharactersInRange:NSMakeRange(location,lenght) withString:@""];
    }
    if (lastStr != str) {
        [_contentTextView setText:lastStr];
    }
    
}

@end
