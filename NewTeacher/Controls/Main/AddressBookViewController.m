
//
//  AddressBookViewController.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/6/2.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "AddressBookViewController.h"

@interface AddressBookViewController ()

@end

@implementation AddressBookViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showBack = YES;
    self.titleLable.text = @"通讯录";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
