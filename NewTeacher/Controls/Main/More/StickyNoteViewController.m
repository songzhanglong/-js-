//
//  StickyNoteViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/11.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "StickyNoteViewController.h"
#import "StickyNoteModel.h"
#import "NSString+Common.h"
#import "Toast+UIView.h"
#import "NSObject+Reflect.h"
#import "StickyNoteViewCell.h"

@interface StickyNoteViewController ()<StickyNoteViewCellDelegate>

@end

@implementation StickyNoteViewController
{
    UIView *_publishView;
    UITextView *_textView;
    BOOL _isShow;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"便利贴";
    [self createRightBarButton];
    
    //发布视图
    _publishView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    [_publishView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_publishView];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, _publishView.frame.size.width - 20, 130)];
    [_textView setBackgroundColor:[UIColor colorWithRed:245.0 / 255 green:245.0 / 255 blue:245.0 / 255 alpha:1]];
    UIToolbar *inputView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, _publishView.frame.size.width, 30)];
    [inputView setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
    [inputView setItems:@[space,done]];
    [_textView setInputAccessoryView:inputView];
    [_publishView addSubview:_textView];
    
    UIButton *pulishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pulishBtn setFrame:CGRectMake(_publishView.frame.size.width - 10 - 110, 150, 110, 30)];
    [pulishBtn setTitle:@"发布" forState:UIControlStateNormal];
    [pulishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [pulishBtn setBackgroundColor:[UIColor colorWithRed:225.0 / 255 green:82.0 / 255 blue:84.0 / 255 alpha:1]];
    [pulishBtn addTarget:self action:@selector(publishNote:) forControlEvents:UIControlEventTouchUpInside];
    [_publishView addSubview:pulishBtn];
    
    NSString *filePath = [APPDocumentsDirectory stringByAppendingPathComponent:@"tickNote.plist"];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSMutableArray *array = [NSMutableArray array];
    if ([manager fileExistsAtPath:filePath]) {
        NSArray *tips = [NSArray arrayWithContentsOfFile:filePath];
        for (NSDictionary *dic in tips) {
            StickyNoteModel *node = [[StickyNoteModel alloc] init];
            [node reflectDataFromOtherObject:dic];
            [array addObject:node];
        }
    }
    
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    [_tableView setBackgroundColor:[UIColor whiteColor]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    self.dataSource = array;
}

- (void)backToPreControl:(id)sender
{
    NSMutableArray *array = [NSMutableArray array];
    for (StickyNoteModel *model in self.dataSource) {
        [array addObject:@{@"content":model.content,@"time":model.time}];
    }
    if (array.count > 0) {
        NSString *filePath = [APPDocumentsDirectory stringByAppendingPathComponent:@"tickNote.plist"];
        [array writeToFile:filePath atomically:NO];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createRightBarButton
{
    //返回按钮
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
    sureBtn.backgroundColor = [UIColor clearColor];
    [sureBtn setImage:[UIImage imageNamed:@"icon31.png"] forState:UIControlStateNormal];
    [sureBtn setImage:[UIImage imageNamed:@"icon31_1.png"] forState:UIControlStateHighlighted];
    [sureBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(addStickyNote:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sureBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

#pragma mark - privites
- (void)controlTextViewShow:(BOOL)show
{
    CGRect tabRec = _tableView.frame;
    CGRect textRec = _publishView.frame;
    
    CGFloat hei = show ? (tabRec.size.height - textRec.size.height) : (tabRec.size.height + textRec.size.height);
    CGFloat yOri = show ? textRec.size.height : (tabRec.origin.y - textRec.size.height);
    [UIView animateWithDuration:0.35 animations:^{
        [_tableView setFrame:CGRectMake(tabRec.origin.x, yOri, tabRec.size.width, hei)];
    }];
    
}

#pragma mark - actions
- (void)addStickyNote:(id)sender
{
    _isShow = !_isShow;
    [self controlTextViewShow:_isShow];
}

- (void)dismissKeyBoard
{
    [_textView resignFirstResponder];
}

- (void)publishNote:(id)sender
{
    if (_textView.text && [_textView.text length] > 0) {
        NSString *newStr = [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([newStr length] <= 0) {
            [self.view makeToast:@"内容不能全为空" duration:1.0 position:@"center"];
        }
        else
        {
            StickyNoteModel *model = [[StickyNoteModel alloc] init];
            model.content = _textView.text;
            model.time = [NSString stringByDate:@"yyyy年MM月dd日 HH:mm" Date:[NSDate date]];
            if (!self.dataSource) {
                self.dataSource = [NSMutableArray array];
            }
            [self.dataSource insertObject:model atIndex:0];
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [_textView setText:@""];
            [_textView resignFirstResponder];
            [self addStickyNote:nil];
        }
    }
    else
    {
        [self.view makeToast:@"请先输入内容" duration:1.0 position:@"center"];
    }
}

#pragma mark - StickyNoteViewCellDelegate
- (void)deleteCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    [self.dataSource removeObjectAtIndex:indexPath.row];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *stickyCell = @"StickyNoteCell";
    StickyNoteViewCell *cell = [tableView dequeueReusableCellWithIdentifier:stickyCell];
    if (cell == nil) {
        cell = [[StickyNoteViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stickyCell];
        cell.delegate = self;
    }
    
    [cell setStickyNoteData:self.dataSource[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StickyNoteModel *model = self.dataSource[indexPath.row];
    [model calculateContentHeight];
    
    return model.contHei + 5 + 5 + 18 + 5;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:245.0 / 255 green:245.0 / 255 blue:245.0 / 255 alpha:1];
}

@end
