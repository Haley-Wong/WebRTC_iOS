//
//  ViewController.m
//  ChatDemo
//
//  Created by Joker on 15/7/19.
//  Copyright (c) 2015年 Mac. All rights reserved.
//

#import "ViewController.h"
#import "HLIMCenter.h"
#import "HLIMClient.h"

@interface ViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;    /**< 用户名输入框 */
@property (weak, nonatomic) IBOutlet UITextField *passwordField;    /**< 密码输入框 */
@end

@implementation ViewController

#pragma mark - life circle method
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBlackBoard)];
    [self.view addGestureRecognizer:tapGesture];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:kLOGIN_SUCCESS object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - click event
/** 登录事件 */
- (IBAction)loginClick:(id)sender {
    NSString *username = _usernameField.text;
    NSString *password = _passwordField.text;
    
//    username = @"10458"; // 10458  28  10447 10453 510
    password = @"e10adc3949ba59abbe56e057f20f883e";
    
    NSString *message = nil;
    if (username.length <= 0) {
        message = @"用户名未填写";
    } else if (password.length <= 0) {
        message = @"密码未填写";
    }
    
    if (message.length > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
        [alertView show];
    } else {
        [[HLIMClient shareClient] login:username password:password success:^(NSString *userId) {
            [self loginSuccess];
        } failure:^(NSDictionary *errorDict) {
            NSLog(@"登录失败:%@",errorDict);
        }];
    }
}

/** 忘记密码事件 */
- (IBAction)forgetClick:(id)sender {
    
}

/** 注册事件 */
- (IBAction)registClick:(id)sender {
    
}

- (void)hideBlackBoard
{
    [self.view endEditing:YES];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideBlackBoard];
    
    return YES;
}

#pragma mark - notification event
- (void)loginSuccess
{
    NSLog(@"loginSuccess");
    
    [self performSegueWithIdentifier:@"loginSegue" sender:self];
}

@end
