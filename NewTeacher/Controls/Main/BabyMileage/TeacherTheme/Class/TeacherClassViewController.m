//
//  TeacherClassViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/4.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "TeacherClassViewController.h"
#import "MyThemeManagerController.h"
#import "MileageModel.h"
#import "NSString+Common.h"

@interface TeacherClassViewController ()

@end

@implementation TeacherClassViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getClassPhotoList"];
    [param setObject:self.mileage.album_id ?: @"" forKey:@"album_id"];
    [param setObject:@"2" forKey:@"mileage_type"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
    self.action = @"photo";
}

#pragma mark - 重载
- (void)createTableHeaderView{
    if ([self.mileage.digst length] > 0) {
        if (!_tableView.tableHeaderView) {
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            
            UIFont *font = [UIFont systemFontOfSize:12];
            CGSize textSize = [NSString calculeteSizeBy:self.mileage.digst Font:font MaxWei:winSize.width - 50];
            CGFloat textHei = MAX(14, textSize.height);
            UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 20 + textHei + 8 + 8)];
            [headView setBackgroundColor:_tableView.backgroundColor];
            
            UIView *midView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, winSize.width, 20 + textHei)];
            [midView setBackgroundColor:[UIColor whiteColor]];
            [headView addSubview:midView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25, 10, winSize.width - 50, textHei)];
            [label setText:self.mileage.digst];
            [label setFont:font];
            [label setNumberOfLines:0];
            [midView addSubview:label];
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 29.5, 22.5)];
            [imgView setBackgroundColor:[UIColor clearColor]];
            [imgView setImage:CREATE_IMG(@"leftTrangle")];
            [midView addSubview:imgView];
            UILabel *myLay = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
            [myLay setBackgroundColor:[UIColor clearColor]];
            [myLay setTextAlignment:1];
            [myLay setFont:[UIFont systemFontOfSize:10]];
            [myLay setText:@"教"];
            [myLay setTextColor:CreateColor(82, 78, 128)];
            [midView addSubview:myLay];
            
            [_tableView setTableHeaderView:headView];
        }
    }
    else{
        [_tableView setTableHeaderView:nil];
    }
}

- (void)createTableFooterView{
    if ([self.dataSource count] > 0) {
        [_tableView setTableFooterView:[[UIView alloc] init]];
    }
    else{
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 30 + 100 + 30 + 18 + 15 + 14 + 15 + 14 + 30)];
        [footView setBackgroundColor:[UIColor whiteColor]];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 100) / 2, 30, 100, 100)];
        imgView.image = CREATE_IMG(@"contact_a");
        [footView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, imgView.frameBottom + 30, winSize.width - 80, 18)];
        [label setTextAlignment:1];
        [label setTextColor:[UIColor blackColor]];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setText:@"无照片或小视频"];
        [footView addSubview:label];
        
        UIFont *font = [UIFont systemFontOfSize:10];
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(5, label.frameBottom + 15, winSize.width, 14)];
        [label1 setTextColor:[UIColor darkGrayColor]];
        [label1 setFont:font];
        [label1 setText:@"您可以通过点击  "];
        [label1 sizeToFit];
        [footView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:label1.frame];
        [label2 setTextColor:[UIColor darkGrayColor]];
        [label2 setFont:font];
        [label2 setText:@"  添加照片或小视频"];
        [label2 sizeToFit];
        [footView addSubview:label2];
        
        UIImageView *addView = [[UIImageView alloc] initWithFrame:CGRectMake(0, label1.frameY - 3, 20, 20)];
        [addView setImage:CREATE_IMG(@"addMileageN")];
        [footView addSubview:addView];
        [label1 setFrameX:(winSize.width - label1.frameWidth - label2.frameWidth - addView.frameWidth) / 2];
        [addView setFrameX:label1.frameRight];
        [label2 setFrameX:addView.frameRight];
        
        UILabel *lastLabel = [[UILabel alloc] initWithFrame:CGRectMake(label1.frameX, label1.frameBottom + 15, winSize.width - label1.frameX * 2, 14)];
        [lastLabel setTextColor:[UIColor darkGrayColor]];
        [lastLabel setFont:font];
        [lastLabel setText:@"记录班级里程的点滴"];
        [lastLabel setTextAlignment:1];;
        [footView addSubview:lastLabel];
        
        [_tableView setTableFooterView:footView];
    }
}

@end
