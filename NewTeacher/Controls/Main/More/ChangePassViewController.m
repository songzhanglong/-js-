//
//  ChangePassViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/12.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ChangePassViewController.h"
#import "Toast+UIView.h"

@interface ChangePassViewController ()<UITextFieldDelegate>

@end

@implementation ChangePassViewController
{
    UITextField *_oldField,*_newField,*_newAgainField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"修改密码";
    [self createRightBarButton];
    
    CGFloat yOri = 5;
    NSArray *array = @[@"请先输入原密码",@"请输入新密码",@"请再次输入新密码"];
    for (NSInteger i = 0; i < 3; i++) {
        //label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(2, yOri, self.view.frame.size.width - 4, 24)];
        [label setFont:[UIFont systemFontOfSize:16]];
        [label setText:[NSString stringWithFormat:@"%@:",array[i]]];
        [label setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:label];
        
        //textfield
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(2, yOri + 25, self.view.frame.size.width - 4, 40)];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [textField setBackgroundColor:[UIColor clearColor]];
        //textField.placeholder = array[i];
        textField.textAlignment = 0;
        textField.textColor = [UIColor blackColor];
        textField.contentVerticalAlignment = 0 ;
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        textField.layer.borderColor = [UIColor darkGrayColor].CGColor;
        textField.layer.borderWidth = 0.5;
        textField.secureTextEntry = YES;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.returnKeyType = UIReturnKeyDone;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.delegate = self;
        [self.view addSubview:textField];
        
        if (i == 0) {
            _oldField = textField;
        }
        else if (i == 1)
        {
            _newField = textField;
        }
        else if (i == 2)
        {
            _newAgainField = textField;
        }
        
        yOri += 30 + 40;
    }
}

- (void)createRightBarButton
{
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
    saveBtn.backgroundColor = [UIColor clearColor];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveUserImage:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

- (void)saveUserImage:(id)sender
{
    if (self.httpOperation) {
        return;
    }
    
    if (_oldField.text && [_oldField.text length] > 0) {
        NSString *oldStr = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_PASSWORD];
        if (([oldStr length] > 0) && ![_oldField.text isEqualToString:oldStr]) {
            [self.view makeToast:@"旧密码输入错误" duration:1.0 position:@"center"];
            return;
        }
    }
    else
    {
        [self.view makeToast:@"请输入旧密码" duration:1.0 position:@"center"];
        return;
    }
    
    if (!_newField || _newField.text.length <= 0) {
        [self.view makeToast:@"请输入新密码" duration:1.0 position:@"center"];
        return;
    }
    
    if (!_newAgainField || _newAgainField.text.length <= 0) {
        [self.view makeToast:@"请再次输入新密码" duration:1.0 position:@"center"];
        return;
    }
    
    if (![_newField.text isEqualToString:_newAgainField.text]) {
        [self.view makeToast:@"两次新密码输入不一致" duration:1.0 position:@"center"];
        return;
    }
    
    if (_newField.text.length < 6) {
        [self.view makeToast:@"密码长度必须大于或等于6位" duration:1.0 position:@"center"];
        return;
    }
    
    if (_oldField.isFirstResponder) {
        [_oldField resignFirstResponder];
    }
    else if (_newField.isFirstResponder)
    {
        [_newField resignFirstResponder];
    }
    else if (_newAgainField.isFirstResponder)
    {
        [_newAgainField resignFirstResponder];
    }
    
    [self requestChangePass];
}

#pragma mark - 修改密码
- (void)requestChangePass
{
    //start
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self.view makeToastActivity];
    self.view.userInteractionEnabled = NO;
    __weak __typeof(self)weakSelf = self;
    NSString *url = [URLFACE stringByAppendingString:@"public:edit_password"];
    NSDictionary *dic = @{@"userid":[DJTGlobalManager shareInstance].userInfo.userid,@"userpwd":_newField.text};
    self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf changePassFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf changePassFinish:NO Data:nil];
    }];
}

- (void)changePassFinish:(BOOL)success Data:(id)result
{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    NSString *tip = nil;
    if (success) {
        tip = @"密码修改成功";
        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
        NSString *oldStr = [userDef objectForKey:LOGIN_PASSWORD];
        if ([oldStr length] > 0) {
            [userDef setObject:_newField.text forKey:LOGIN_PASSWORD];
            [userDef synchronize];
        }

    }
    else
    {
        tip = @"密码修改失败";
    }
    [self.view makeToast:tip duration:1.0 position:@"center"];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
