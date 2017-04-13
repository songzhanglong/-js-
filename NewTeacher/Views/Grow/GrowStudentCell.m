//
//  GrowStudentCell.m
//  NewTeacher
//
//  Created by szl on 16/5/10.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "GrowStudentCell.h"

@implementation GrowStudentCell
{
    NSArray *_studentArr;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //line
        UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.contentView.bounds.size.height - 1, SCREEN_WIDTH - 20, 1)];
        [lineView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [lineView setImage:CREATE_IMG(@"growLine")];
        lineView.clipsToBounds = YES;
        [lineView setContentMode:UIViewContentModeScaleAspectFill];
        [self.contentView addSubview:lineView];
        
        //
        CGFloat numPerRow = 4,width = 54,height = 54;
        CGFloat margin = (SCREEN_WIDTH - numPerRow * width) / (numPerRow * 2);
        for (NSInteger i = 0; i < numPerRow; i++) {
            CGFloat xOri = margin + (width + margin * 2) * i;
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(xOri, 10, width, height + 20)];
            [button setBackgroundColor:self.backgroundColor];
            [button addTarget:self action:@selector(checkStudent:) forControlEvents:UIControlEventTouchUpInside];
            [button setTag:i + 1];
            [self.contentView addSubview:button];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOri, button.frameY, width, height)];
            [imageView.layer setMasksToBounds:YES];
            [imageView.layer setCornerRadius:width / 2];
            imageView.clipsToBounds = YES;
            [imageView setTag:100 + i];
            [self.contentView addSubview:imageView];
            
            //阴影图片
            UIView *shadowView = [[UIView alloc] initWithFrame:imageView.bounds];
            shadowView.backgroundColor = rgba(67, 154, 215, 0.5);
            [imageView addSubview:shadowView];
            
            UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frameX, imageView.frameY + (imageView.frameHeight - 18) / 2, imageView.frameWidth, 18)];
            [numLabel setTextAlignment:1];
            [numLabel setTag:200 + i];
            [numLabel setBackgroundColor:[UIColor clearColor]];
            [numLabel setFont:[UIFont boldSystemFontOfSize:14]];
            [numLabel setTextColor:[UIColor whiteColor]];
            [self.contentView addSubview:numLabel];
            
            UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(numLabel.frameX, imageView.frameBottom + 4, imageView.frameWidth, 16)];
            [nameLab setTag:300 + i];
            [nameLab setTextAlignment:NSTextAlignmentCenter];
            [nameLab setFont:[UIFont systemFontOfSize:12]];
            [nameLab setTextColor:[UIColor darkGrayColor]];
            [nameLab setBackgroundColor:[UIColor clearColor]];
            [self.contentView addSubview:nameLab];
        }
    }
    return self;
}

- (void)checkStudent:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(selectGrowStudentCell:At:)]) {
        NSInteger index = [sender tag] - 1;
        [_delegate selectGrowStudentCell:self At:_studentArr[index]];
    }
}

- (void)resetDataSource:(NSArray *)array
{
    _studentArr = array;
    NSInteger count = [array count];
    for (NSInteger i = 0; i < 4; i++) {
        UIImageView *imageView = (UIImageView *)[self.contentView viewWithTag:100 + i];
        UILabel *numLabel = (UILabel *)[self.contentView viewWithTag:200 + i];
        UILabel *nameLab = (UILabel *)[self.contentView viewWithTag:300 + i];
        UIButton *button = (UIButton *)[self.contentView viewWithTag:i + 1];
        if (i < count) {
            imageView.hidden = NO;
            numLabel.hidden = NO;
            nameLab.hidden = NO;
            button.hidden = NO;
            
            TermStudent *student = array[i];
            NSString *face = student.face;
            if (![face hasPrefix:@"http"]) {
                face = [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
            }
            [imageView setImageWithURL:[NSURL URLWithString:[face stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"s21.png"]];
            [numLabel setText:[NSString stringWithFormat:@"%@/%@",student.finish_count.stringValue,student.total_count.stringValue]];
            [nameLab setText:student.student_name];
        }
        else{
            imageView.hidden = YES;
            numLabel.hidden = YES;
            nameLab.hidden = YES;
            button.hidden = YES;
        }
    }
}

@end
