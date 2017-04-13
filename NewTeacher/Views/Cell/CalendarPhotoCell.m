//
//  CalendarPhotoCell.m
//  NewTeacher
//
//  Created by szl on 15/11/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "CalendarPhotoCell.h"
#import "CalendarModel.h"
#import "UIImage+Caption.h"

@implementation CalendarPhotoCell
{
    UIImageView *_photoImg;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //left
        UIImageView *leftImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 2, 72)];
        [leftImg setBackgroundColor:[UIColor greenColor]];
        [self.contentView addSubview:leftImg];
        
        //line
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, 2, 72)];
        [line setBackgroundColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:line];
        
        //tip
        UIImageView *tipImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 21, 30, 30)];
        [tipImg setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rl5" ofType:@"png"]]];
        [self.contentView addSubview:tipImg];
        
        CGFloat winWei = [UIScreen mainScreen].bounds.size.width;
        
        //>箭头
        UIImageView *indictor = [[UIImageView alloc] initWithFrame:CGRectMake(winWei - 45, 26, 20, 20)];
        [indictor setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rl9" ofType:@"png"]]];
        [self.contentView addSubview:indictor];
        
        //images
        UIImageView *photoImg = [[UIImageView alloc] initWithFrame:CGRectMake(55, 12, winWei - 65, 48)];
        _photoImg = photoImg;
        [self.contentView addSubview:photoImg];
        
        for (NSInteger i = 0; i < 3; i++) {
            UIImageView *tmpImg = [[UIImageView alloc] initWithFrame:CGRectMake(i * (photoImg.frame.size.height + 5), 0, photoImg.frame.size.height, photoImg.frame.size.height)];
            [tmpImg setTag:i + 10];
            [tmpImg setBackgroundColor:BACKGROUND_COLOR];
            [tmpImg setUserInteractionEnabled:YES];
            [tmpImg setClipsToBounds:YES];
            [tmpImg setContentMode:UIViewContentModeScaleAspectFill];
            [photoImg addSubview:tmpImg];
            
            //视频
            UIImageView *videoImg = [[UIImageView alloc] initWithFrame:CGRectMake((photoImg.frame.size.height - 30) / 2, (photoImg.frame.size.height - 30) / 2, 30, 30)];
            [videoImg setImage:CREATE_IMG(@"mileageVideo")];
            [videoImg setBackgroundColor:[UIColor clearColor]];
            [videoImg setTag:100];
            videoImg.hidden = YES;
            [tmpImg addSubview:videoImg];
        }
    }
    return self;
}

- (void)resetDataSource:(id)object
{
    NSArray *array = (NSArray *)object;
    NSInteger count = array.count;
    for (NSInteger i = 0; i < 3; i++) {
        UIImageView *subImg = (UIImageView *)[_photoImg viewWithTag:i + 10];
        if (i >= count) {
            subImg.hidden = YES;
        }
        else
        {
            subImg.hidden = NO;
            PhotoItem *item = array[i];
            
            NSString *fileName = [item.path lastPathComponent];
            BOOL mp4 = [[[fileName pathExtension] lowercaseString] isEqualToString:@"mp4"];
            NSString *url = mp4 ? item.path : item.thumb;
            if (![url hasPrefix:@"http"]) {
                url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
            }
            UIImageView *videoImg = (UIImageView *)[subImg viewWithTag:100];
            if (mp4) {
                videoImg.hidden = NO;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] atTime:1];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [subImg setImage:image];
                    });
                });
            }
            else
            {
                videoImg.hidden = YES;
                [subImg setImageWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            }
        }
    }
}

@end
