//
//  TemplateBaseViewController.m
//  NewTeacher
//
//  Created by zhangxs on 16/1/26.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "TemplateBaseViewController.h"

@implementation TemplateBaseViewController
{
    UIImageView *navBarHairlineImageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showBack = YES;
    if (!self.dataSource) {
        self.dataSource = [NSMutableArray array];
    }
    
    UIImageView *bgImgView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"grow_bg@2x")];
    bgImgView.frame = self.view.bounds;
    [self.view addSubview:bgImgView];
    
    UIButton *leftBut = (UIButton *)((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView;
    [leftBut setFrame:CGRectMake(0, 0, 40, 30)];
    [leftBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backL@2x" ofType:@"png"]] forState:UIControlStateNormal];
    
    [self setRightNavButton];
    
    self.useNewInterface = NO;
}

- (void)setRightNavButton
{
    //right
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    rightView.backgroundColor = [UIColor clearColor];
    rightView.userInteractionEnabled = YES;
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, 0, 50.0, 30.0);
    addBtn.backgroundColor = [UIColor clearColor];
    [addBtn setTag:1];
    [addBtn setTitle:@"确定" forState:UIControlStateNormal];
    [addBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(rightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:addBtn];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightButtonItem];
}

#pragma mark-
#pragma mark- Right btton action
- (void)rightBtnAction:(UIButton *)btn
{
    if (btn.tag == 1) {
        //add
    }else {
        //edit
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = CreateColor(70, 57, 53);
    }
    else
    {
        navBar.tintColor = CreateColor(70, 57, 53);
    }
    
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    navBarHairlineImageView.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = [UIColor whiteColor];
    }
    else
    {
        navBar.tintColor = CreateColor(233.0, 233.0, 233.0);
    }
    
    navBarHairlineImageView.hidden = NO;
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
