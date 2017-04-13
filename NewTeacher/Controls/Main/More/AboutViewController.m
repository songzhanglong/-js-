//
//  AboutViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/12.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "AboutViewController.h"
#import "Toast+UIView.h"
#import "DJTSeviceViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.showBack = YES;
    self.titleLable.text = @"关于";
    self.view.backgroundColor = [UIColor colorWithRed:239/255.0 green:241/255.0 blue:237/255.0 alpha:1.0];
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    CGFloat yOri = 5;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 105)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    //image
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon@2x" ofType:@"png"]]];
    [imageView setFrame:CGRectMake((winSize.width - 57) / 2, yOri, 57, 57)];
    [imageView.layer setMasksToBounds:YES];
    imageView.layer.cornerRadius = 10;
    [bgView addSubview:imageView];
    
    yOri += 57 + 5;
    //tip
    UILabel *tip2 = [[UILabel alloc] initWithFrame:CGRectMake((winSize.width - 117) / 2, yOri, 117, 36)];
    [tip2 setTextAlignment:1];
    [tip2 setFont:[UIFont systemFontOfSize:12]];
    tip2.numberOfLines = 2;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [tip2 setText:[NSString stringWithFormat:@"童印iPhone版\n%@",app_Version]];
    [tip2 setTextColor:[UIColor darkGrayColor]];
    [tip2 setBackgroundColor:[UIColor clearColor]];
    [bgView addSubview:tip2];
    
    yOri += 38 + 5;

    //content
    NSString *content = @"       童印教师版致力于联手校园为儿童做一份真正的成长档案。可以拍照上传建立班级相册，个性定制我的成长档案；画面优美，做工精细，多种模板还可随心调节。您可以随时随地记录学生成长的点点滴滴，与家长一起分享。让我们一起用指尖见证宝贝成长的快乐与感动。\n";
    CGSize lastSize = CGSizeZero;
    UIFont *font = [UIFont systemFontOfSize:12];
    NSDictionary *attribute = @{NSFontAttributeName: font};
    lastSize = [content boundingRectWithSize:CGSizeMake(winSize.width - 20, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    UIView *bgLabel = [[UIView alloc] initWithFrame:CGRectMake(0, yOri, winSize.width, lastSize.height+10+20)];
    bgLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgLabel];
    
    UILabel *contLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, winSize.width - 20, lastSize.height)];
    [contLab setFont:font];
    [contLab setText:content];
    [contLab setBackgroundColor:[UIColor clearColor]];
    [contLab setNumberOfLines:0];
    [contLab setTextColor:[UIColor darkGrayColor]];
    [bgLabel addSubview:contLab];
    
    //更多关注文字
    UILabel *more = [[UILabel alloc] initWithFrame:CGRectMake(10, lastSize.height, 112, 20)];
    more.text = @"       更多关注请访问";
    more.font = [UIFont systemFontOfSize:12.0];
    more.textColor = [UIColor darkGrayColor];
    more.backgroundColor = [UIColor clearColor];
    [bgLabel addSubview:more];
    
    //go on baby  网址访问
    UIButton *goOnBabyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    goOnBabyBtn.frame = CGRectMake(more.frame.origin.x + more.frame.size.width, lastSize.height, 180, 20);
    [goOnBabyBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [goOnBabyBtn setTitle:@"www.goonbaby.com" forState:UIControlStateNormal];
    goOnBabyBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    goOnBabyBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [goOnBabyBtn addTarget:self action:@selector(goOn) forControlEvents:UIControlEventTouchUpInside];
    [bgLabel addSubview:goOnBabyBtn];
    
    yOri += lastSize.height+40;
    
    UIButton *itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    itemBtn.frame = CGRectMake((winSize.width - 185) / 2, winSize.height-105-64, 185, 20);
    itemBtn.backgroundColor = [UIColor clearColor];
    [itemBtn setTitle:@"使用条款" forState:UIControlStateNormal];
    [itemBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [itemBtn addTarget:self action:@selector(useClause) forControlEvents:UIControlEventTouchUpInside];
    itemBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [self.view addSubview:itemBtn];
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake((winSize.width - 48) / 2, winSize.height-85-64, 48, 1)];
    line2.backgroundColor = [UIColor blueColor];
    [self.view addSubview:line2];
    
    //us
    UILabel *us1 = [[UILabel alloc] initWithFrame:CGRectMake(10, line2.frame.origin.y + line2.frame.size.height + 5, winSize.width - 20, 15)];
    [us1 setTextAlignment:1];
    [us1 setBackgroundColor:[UIColor clearColor]];
    [us1 setFont:[UIFont systemFontOfSize:10]];
    [us1 setTextColor:[UIColor lightGrayColor]];
    [us1 setText:@"江苏迪杰特教育科技股份有限公司 版权所有"];
    [self.view addSubview:us1];
    
    UILabel *us2 = [[UILabel alloc] initWithFrame:CGRectMake(10, us1.frame.origin.y + us1.frame.size.height, winSize.width - 20, 15)];
    [us2 setTextAlignment:1];
    [us2 setBackgroundColor:[UIColor clearColor]];
    [us2 setFont:[UIFont systemFontOfSize:10]];
    [us2 setTextColor:[UIColor lightGrayColor]];
    [us2 setText:@"Copyright © 2010-2013 All Rights Reserved"];
    [self.view addSubview:us2];
    
    yOri += 30 + 10;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, winSize.height-40-64, winSize.width, 40)];
    footerView.backgroundColor = [UIColor whiteColor];
    footerView.userInteractionEnabled = YES;
    [self.view addSubview:footerView];
    
    UIButton *callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    callBtn.frame = CGRectMake((winSize.width - 200) / 2, 5, 200, 30);
    [callBtn setTitle:@"客服电话：400-025-0188" forState:UIControlStateNormal];
    [callBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [callBtn addTarget:self action:@selector(callSevice) forControlEvents:UIControlEventTouchUpInside];
    callBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [footerView addSubview:callBtn];
}

//访问  go on baby
- (void)goOn
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.goonbaby.com"]];
}

- (void)useClause
{
    DJTSeviceViewController *vc = [[DJTSeviceViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)callSevice
{
    NSString *number = @"400-025-0188";
    NSURL *telUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",number]];
    [[UIApplication sharedApplication]openURL:telUrl];
}

@end
