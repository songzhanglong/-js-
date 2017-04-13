//
//  BabyPhotoAlbumCell.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/25.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "BabyPhotoAlbumCell.h"
#import "StudentAlbumModel.h"
#import "StudentModel.h"
#import "DJTGlobalManager.h"
#import "UIImage+Caption.h"

@implementation BabyPhotoAlbumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier imageSize:(CGSize)imageSize numberOfAssets:(NSUInteger)numberOfAssets margin:(CGFloat)margin
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _gImageSize = imageSize;
        _nNumberOfAssets = numberOfAssets;
        _fMargin = margin;
        [self addSelectedImages];
    }
    return self;
}

/**
 *	添加子视图
 */
- (void)addSelectedImages
{
    //添加SelectedImage
    for (NSUInteger i = 0; i < _nNumberOfAssets; i++) {
        CGFloat offset = (_fMargin + _gImageSize.width) * i;
        CGRect imageFrame = CGRectMake(offset + _fMargin, 2, _gImageSize.width, _gImageSize.height);
        
        UIImageView *selectedImg = [[UIImageView alloc] initWithFrame:imageFrame];
        selectedImg.contentMode = UIViewContentModeScaleAspectFill;
        selectedImg.clipsToBounds = YES;
        selectedImg.tag = i + 1;
        selectedImg.backgroundColor = [UIColor clearColor];
        selectedImg.userInteractionEnabled = YES;
        [self.contentView addSubview:selectedImg];
        
        //手势
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [singleTapGesture setNumberOfTapsRequired:1];
        [selectedImg addGestureRecognizer:singleTapGesture];
        
        
        //video
        UIImageView *videoImg = [[UIImageView alloc] initWithFrame:CGRectMake((selectedImg.frame.size.width - 30) / 2, (selectedImg.frame.size.height - 30) / 2, 30, 30)];
        [videoImg setImage:CREATE_IMG(@"mileageVideo")];
        [videoImg setTag:10];
        [videoImg setBackgroundColor:[UIColor clearColor]];
        videoImg.translatesAutoresizingMaskIntoConstraints = NO;
        [selectedImg addSubview:videoImg];
        
        [selectedImg addConstraints:[NSArray arrayWithObjects:[NSLayoutConstraint constraintWithItem:videoImg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:selectedImg attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],[NSLayoutConstraint constraintWithItem:videoImg attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:selectedImg attribute:NSLayoutAttributeCenterY multiplier:1 constant:0], nil]];
    }
}

/**
 *	@brief	图片单击手势
 *
 *	@param 	gesture 	手势
 */
- (void)handleSingleTap:(UIGestureRecognizer *)gesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectCell:At:)]) {
        NSInteger index = [[gesture view] tag] - 1;
        [_delegate didSelectCell:self At:index];
    }
}

/**
 *	刷新数据
 *
 *	@param 	asserts 	数组
 */
- (void)setAsserts:(id)asserts
{
    // Set assets
    for(NSUInteger i = 0; i < _nNumberOfAssets; i++) {
        UIImageView *selectedImg = (UIImageView *)[self.contentView viewWithTag:(1 + i)];
        
        NSArray *array = (NSArray *)asserts;
        if (array && [array count] > 0)
        {
            if(i < array.count) {
                selectedImg.hidden = NO;
                BOOL mp4 = NO;
                
                id object = [array objectAtIndex:i];
                if ([object isKindOfClass:[BabyPhoto class]]) {
                    BabyPhoto *photo = object;
                    NSString *fileName = [photo.photo_path lastPathComponent];
                    mp4 = [[[fileName pathExtension] lowercaseString] isEqualToString:@"mp4"];
                    if (mp4)
                    {
                        //[selectedImg setImage:[UIImage thumbnailImageForVideo:[NSURL URLWithString:photo.photo_path] atTime:1]];
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:[photo.photo_path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] atTime:1];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [selectedImg setImage:image];
                            });
                        });
                    }
                    else
                    {
                        [selectedImg setImageWithURL:[NSURL URLWithString:[photo.photo_thumb stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    }
                }
                else if ([object isKindOfClass:[BabyGrow class]])
                {
                    BabyGrow *grow = object;
                    [selectedImg setImageWithURL:[NSURL URLWithString:[grow.image_thumb stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                }
                else if ([object isKindOfClass:[StudentItem class]])
                {
                    StudentItem *item = object;
                    NSString *fileName = [item.path lastPathComponent];
                    mp4 = [[[fileName pathExtension] lowercaseString] isEqualToString:@"mp4"];
                    if (mp4)
                    {
                        //[selectedImg setImage:[UIImage thumbnailImageForVideo:[NSURL URLWithString:item.path] atTime:1]];
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:[item.path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] atTime:1];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [selectedImg setImage:image];
                            });
                        });
                    }
                    else
                    {
                        NSString *url = [item.type isEqualToString:@"0"] ? item.thumb : @"";
                        NSString *str = url;
                        if ([url rangeOfString:@"{"].length > 0) {
                            str = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        }
                        
                        [selectedImg setImageWithURL:[NSURL URLWithString:str]];
                    }
                    
                }
                
                //video
                UIImageView *video = (UIImageView *)[selectedImg viewWithTag:10];
                video.hidden = !mp4;
            } else {
                selectedImg.hidden = YES;
            }
        }
        else
        {
            selectedImg.hidden = YES;
        }
    }
}

@end
