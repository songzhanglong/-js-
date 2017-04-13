//
//  GrowPrintRecordCell.h
//  NewTeacher
//
//  Created by szl on 16/5/11.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermPrintRecord.h"

@protocol GrowPrintRecordCellDelegate <NSObject>

@optional
- (void)expandPrintRecordCell:(UITableViewCell *)cell;
- (void)undoPrintRecordCell:(UITableViewCell *)cell;
@end

@interface GrowPrintRecordCell : UITableViewCell

@property (nonatomic,assign)id<GrowPrintRecordCellDelegate> delegate;

- (void)resetDataSource:(TermPrintRecord *)printRecord;

@end
