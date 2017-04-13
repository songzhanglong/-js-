//
//  MailListCell.h
//  NewTeacher
//
//  Created by mac on 15/7/29.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainListModel.h"

@protocol MailListCellDelegate <NSObject>

@optional
- (void)callPhoneMainListCell:(UITableViewCell *)cell Model:(MainListStudentItem *)model;

@end

@interface MailListCell : UITableViewCell
{
    UIImageView *imgView;
    UILabel *nameLabel;
    UILabel *contentLabel;
    UIButton *phoneButton;
    UIButton *messagebutton;
    UIButton *tjButton;
    
    id currModel;
    BOOL isTeacher;
}
@property (nonatomic,assign)id<MailListCellDelegate> delegate;

- (void)resetClassMainListData:(id)object isHidden:(BOOL)hidden isTeacher:(BOOL)teacher;
@end
