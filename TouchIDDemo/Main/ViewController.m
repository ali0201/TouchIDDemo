//
//  ViewController.m
//  TouchIDDemo
//
//  Created by Kevin on 14/12/31.
//  Copyright (c) 2014年 HGG. All rights reserved.
//

#import "ViewController.h"
#import <SVProgressHUD.h>
@import LocalAuthentication;

@interface ViewController () <UIAlertViewDelegate>

- (IBAction)btnClick:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Method

- (void)doSomeAuth
{
    LAContext *myContext = [[LAContext alloc] init];
    myContext.localizedFallbackTitle = @"输入密码";                // 用于设置左边的按钮的名称，默认是Enter Password.
    NSError *authError = nil;
    NSString *myLocalizedReasonString = @"用于解除系统锁定！";       // 用于设置提示语，表示为什么要使用TouchID
    
    __weak __typeof(&*self)weakSelf = self;
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:myLocalizedReasonString
                            reply:^(BOOL success, NSError *error) {
                                
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    if (success) {
                                        [SVProgressHUD showSuccessWithStatus:@"处理验证成功" maskType:SVProgressHUDMaskTypeBlack];
                                    } else {
                                        NSString *errorMsg = [weakSelf getAuthErrorDescription:error.code];
                                        NSLog(@"%@", errorMsg);
                                    }
                                });
            
        }];
        
    } else {
        [SVProgressHUD showErrorWithStatus:@"不支持TouchID验证" maskType:SVProgressHUDMaskTypeBlack];
    }
}

/**
 *  验证错误码描述
 *
 *  @param code 错误码
 *
 *  @return NSString
 */
- (NSString *)getAuthErrorDescription:(NSInteger)code
{
    NSString *msg = @"";
    switch (code) {
        case LAErrorTouchIDNotEnrolled:
            // 认证不能开始,因为touch id没有录入指纹.
            msg = @"此设备未录入指纹信息!";
            break;
        case LAErrorTouchIDNotAvailable:
            // 认证不能开始,因为touch id在此台设备尚是无效的.
            msg = @"此设备不支持Touch ID!";
            break;
        case LAErrorPasscodeNotSet:
            // 认证不能开始,因为此台设备没有设置密码.
            msg = @"未设置密码,无法开启认证!";
            break;
        case LAErrorSystemCancel:
            // 认证被系统取消了,例如其他的应用程序到前台了
            msg = @"系统取消认证";
            break;
        case LAErrorUserFallback:
        {
            // 认证被取消,因为用户点击了fallback按钮(输入密码).
            msg = @"选择输入密码!";
            [self pwdAlertView];
        }
            break;
        case LAErrorUserCancel:
            // 认证被用户取消,例如点击了cancel按钮.
            msg = @"取消认证!";
            break;
        case LAErrorAuthenticationFailed:
            // 认证没有成功,因为用户没有成功的提供一个有效的认证资格
            msg = @"认证失败!";
            break;
        default:
            break;
    }
    
    return msg;
}

/**
 *  弹出密码输入框
 */
- (void)pwdAlertView
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请输入密码" message:@"输入正确密码用于解锁" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *password = alertVC.textFields.lastObject;
        
        NSLog(@"%@",password);
    }];
    [alertVC addAction:okAction];
    
    UIAlertAction *resetAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
    [alertVC addAction:resetAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - User Action

- (IBAction)btnClick:(UIButton *)sender
{
    [self doSomeAuth];
}

@end
