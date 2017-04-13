//
//  SelectTemplateCell.h
//  NewTeacher
//
//  Created by zhangxs on 16/1/26.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectTemplateCell : UITableViewCell
{
    UIImageView *_imgView;
    UIImageView *_checkImgView;
}

- (void)resetDataSource:(id)source;

@end
