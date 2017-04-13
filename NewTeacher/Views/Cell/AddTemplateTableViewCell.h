//
//  AddTemplateTableViewCell.h
//  NewTeacher
//
//  Created by zhangxs on 16/1/26.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddTemplateTableViewCell : UITableViewCell
{
    UIImageView *_bgImgView;
    UILabel *_nameLabel;
    UILabel *_classLabel;
}

@property (nonatomic, strong) UIImageView *checkImgView;

- (void)resetDataSource:(id)source;
@end
