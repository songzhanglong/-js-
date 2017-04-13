//
//  ScreeningFamilyView.m
//  NewTeacher
//
//  Created by zhangxs on 16/5/12.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "ScreeningFamilyView.h"

@interface ScreeningFamilyView ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
}

@end

@implementation ScreeningFamilyView

- (id)initWithFrame:(CGRect)frame TabHei:(CGFloat)hei
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -hei, frame.size.width, hei) style:UITableViewStylePlain];
        [_tableView setBackgroundColor:[UIColor whiteColor]];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self addSubview:_tableView];
    }
    return self;
}

- (void)showInView
{
    [self superview].userInteractionEnabled = NO;
    [UIView animateWithDuration:0.35 animations:^{
        [_tableView setFrameY:0];
    } completion:^(BOOL finished) {
        [self superview].userInteractionEnabled = YES;
    }];
}

- (void)hiddenInView
{
    CGRect butRec = _tableView.frame;
    [self superview].userInteractionEnabled = NO;
    [UIView animateWithDuration:0.35 animations:^{
        [_tableView setFrameY:-butRec.size.height];
    } completion:^(BOOL finished) {
        [self superview].userInteractionEnabled = YES;
        [self removeFromSuperview];
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hiddenInView];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *phoneCell = @"channelListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:phoneCell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:phoneCell];
        cell.textLabel.textColor = CreateColor(40, 123, 229);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    }
    
    cell.textLabel.text = _dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CGRect butRec = _tableView.frame;
    [self superview].userInteractionEnabled = NO;
    [UIView animateWithDuration:0.35 animations:^{
        [_tableView setFrameY:-butRec.size.height];
    } completion:^(BOOL finished) {
        if (_delegate && [_delegate respondsToSelector:@selector(screeningActionIndex:)]) {
            [_delegate screeningActionIndex:indexPath.row];
        }
        [self superview].userInteractionEnabled = YES;
        [self removeFromSuperview];
    }];
}

@end
