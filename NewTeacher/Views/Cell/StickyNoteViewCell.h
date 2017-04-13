//
//  StickyNoteViewCell.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/11.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StickyNoteViewCellDelegate <NSObject>

@optional
- (void)deleteCell:(UITableViewCell *)cell;

@end

@interface StickyNoteViewCell : UITableViewCell

@property (nonatomic,assign)id<StickyNoteViewCellDelegate> delegate;

- (void)setStickyNoteData:(id)data;

@end
