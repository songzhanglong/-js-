//
//  TumblrLikeMenuItem.h
//  TumblrLikeMenu
//
//  Created by Tu You on 12/18/13.
//  Copyright (c) 2013 Tu You. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TumblrLikeMenuItem;

typedef void (^TumblrLikeMenuItemSelectBlock)(TumblrLikeMenuItem *item);

@interface TumblrLikeMenuItem : UIView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *highlightedImage;
@property (nonatomic, assign) BOOL solidBounds;
@property (nonatomic, copy) TumblrLikeMenuItemSelectBlock selectBlock;

- (id)initWithImage:(UIImage *)image
   highlightedImage:(UIImage *)highlightedImage
               text:(NSString *)text;

- (id)initWithFrame:(CGRect)frame Img:(NSString *)img Text:(NSString *)text;

@end
