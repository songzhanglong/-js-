//
//  HomeCardTemplateModel.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/27.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeCardTemplateModel : NSObject

@property (nonatomic,strong)NSString *card_template_id;
@property (nonatomic,strong)NSString *card_title;

@property (nonatomic,strong)NSString *home;   //家长打分
@property (nonatomic,strong)NSString *school; //学校打分,0-未评论，1-优秀，2-良好

@property (nonatomic,assign)CGSize carSize;

- (void)calculateSizeBy:(UIFont *)font Wei:(CGFloat)maxWei;

@end
