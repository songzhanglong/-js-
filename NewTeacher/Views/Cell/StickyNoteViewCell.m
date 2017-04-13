//
//  StickyNoteViewCell.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/11.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "StickyNoteViewCell.h"
#import "StickyNoteModel.h"

@implementation StickyNoteViewCell
{
    UILabel *_contentLabel,*_timeLabel;
    UIButton *_button;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //content
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];;
        [_contentLabel setTextColor:[UIColor blackColor]];
        [_contentLabel setNumberOfLines:0];
        [_contentLabel setFont:[UIFont systemFontOfSize:16]];
        [self.contentView addSubview:_contentLabel];
        [_contentLabel setBackgroundColor:[UIColor clearColor]];
        
        //time
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];;
        [_timeLabel setTextColor:[UIColor darkGrayColor]];
        [_timeLabel setFont:[UIFont systemFontOfSize:14]];
        [self.contentView addSubview:_timeLabel];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        
        //button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button = button;
        [button setImage:[UIImage imageNamed:@"sticknotedelete2.png"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"sticknotedelete.png"] forState:UIControlStateHighlighted];
        [button setFrame:CGRectMake(self.contentView.bounds.size.width - 10 - 30, self.contentView.bounds.size.height - 10 - 30, 30, 30)];
        [button setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
        [button addTarget:self action:@selector(deleteSelf:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];

    }
    return self;
}

- (void)deleteSelf:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(deleteCell:)]) {
        [_delegate deleteCell:self];
    }
}

- (void)setStickyNoteData:(id)data
{
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    StickyNoteModel *model = (StickyNoteModel *)data;
    [_contentLabel setText:model.content];
    [_contentLabel setFrame:CGRectMake(10, 5, winSize.width - 60, model.contHei)];
    [_timeLabel setFrame:CGRectMake(10, _contentLabel.frame.origin.y + _contentLabel.frame.size.height + 5, _contentLabel.frame.size.width, 18)];
    [_timeLabel setText:model.time];
}

@end
