//
//  ProgressLayer.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/7.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ProgressLayer.h"

@implementation ProgressLayer

- (void)setTheProgress:(CGFloat)theProgress{
    _theProgress =theProgress;
    [self setNeedsDisplay];
}

-(void)drawInContext:(CGContextRef)ctx{
    
    UIGraphicsPushContext(ctx);
    if (_theProgress >= 0) {
        
        CGFloat h = self.bounds.size.height;
        CGFloat w = self.bounds.size.width;
        CGContextMoveToPoint(ctx, 0, h);
        CGFloat l = h * (1 - self.theProgress);
        CGContextAddLineToPoint(ctx, w, h);
        CGContextAddLineToPoint(ctx, w, l);
        CGContextAddLineToPoint(ctx, 0, l);
        CGContextAddLineToPoint(ctx, 0, h);
        
        CGContextClosePath(ctx);
        
        CGFloat red,green,blue,alpha;
        [_drawColor getRed:&red green:&green blue:&blue alpha:&alpha];
        CGContextSetRGBFillColor(ctx, red, green, blue, alpha);
        CGContextDrawPath(ctx, kCGPathFill);
    }
    UIGraphicsPopContext();
}

@end
