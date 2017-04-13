//
//  StickyNoteModel.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/12.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StickyNoteModel : NSObject

@property (nonatomic,strong)NSString *content;
@property (nonatomic,strong)NSString *time;

@property (nonatomic,assign)CGFloat contHei;

- (void)calculateContentHeight;

@end
