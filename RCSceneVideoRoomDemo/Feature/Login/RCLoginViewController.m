//
//  RCLoginViewController.m
//  RCLiveVideoDemo
//
//  Created by 彭蕾 on 2022/5/27.
//

#import "RCLoginViewController.h"
#import <Masonry/Masonry.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "LoginResponseModel.h"
#import "RCSceneVideoRoomDemo-Swift.h"

__attribute__((unused)) static NSString * _deviceID() {
    
    static NSString *did = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        did = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    });

    return did;
}

@interface RCLoginViewController ()

@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UIButton *loginBtn;

@end

@implementation RCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"登录";
    self.view.backgroundColor = [UIColor whiteColor];
    [self buildLayout];
}

- (void)buildLayout {
    [self.view addSubview:self.phoneTextField];
    [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(200);
        make.leading.equalTo(self.view.mas_leading).offset(100);
        make.trailing.equalTo(self.view.mas_trailing).offset(-100);
        make.height.mas_equalTo(44);
    }];
    
    [self.view addSubview:self.loginBtn];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phoneTextField.mas_bottom).offset(40);
        make.size.mas_equalTo(CGSizeMake(80, 44));
        make.centerX.equalTo(self.phoneTextField);
    }];
}

#pragma mark - lazy load
- (UITextField *)phoneTextField {
    if (!_phoneTextField) {
        _phoneTextField = [[UITextField alloc] init];
        _phoneTextField.placeholder = @"请输入手机号";
        _phoneTextField.layer.masksToBounds = YES;
        _phoneTextField.layer.cornerRadius = 4;
        _phoneTextField.layer.borderColor = [UIColor systemPinkColor].CGColor;
        _phoneTextField.layer.borderWidth = 1.0;
        _phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    }
    return _phoneTextField;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loginBtn.backgroundColor = [UIColor systemPinkColor];
        _loginBtn.layer.masksToBounds = YES;
        _loginBtn.layer.cornerRadius = 4;
        
        [_loginBtn addTarget:self action:@selector(loginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginBtn;
}


- (void)loginBtnClick:(UIButton *)btn {
    NSString *phone = self.phoneTextField.text;
    
    if (phone.length != 11) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号"];
        return ;
    }
    
    btn.enabled = NO;
    [SVProgressHUD show];
    NSString *userName = [NSString stringWithFormat:@"用户%@", phone];
  
    [LoginBridge loginWithPhone:phone name:userName completion:^(BOOL success, NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (!success) {
            return ;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
        btn.enabled = YES;
    }];
}

@end
