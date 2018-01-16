//
//  StartView.m
//  BZAssistant
//
//  Created by shenzhenshihua on 2018/1/16.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "StartView.h"
#import <AFNetworking.h>
#import <SVProgressHUD.h>
#define Screen_Frame     [[UIScreen mainScreen] bounds]
#define Screen_Width     [[UIScreen mainScreen] bounds].size.width
#define Screen_Height    [[UIScreen mainScreen] bounds].size.height
#define MP_KeyWindow [[[UIApplication sharedApplication] delegate] window]
@interface StartView ()
@property (weak, nonatomic) IBOutlet UITextField *usemess;

@end
static StartView * _startView = nil;
static NSString * useKey = @"useKey669";
@implementation StartView

+ (id)shareStartView {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_startView == nil) {
            NSString *className = NSStringFromClass([self class]);
            UINib * nib = [UINib nibWithNibName:className bundle:nil];
            _startView = [nib instantiateWithOwner:nil options:nil].firstObject;
        }
    });
    return _startView;
}

- (BOOL)chickUserLogin {
    if ([[self readValueForKey:useKey] isKindOfClass:[NSDictionary class]]) {
        _userMessage = [self readValueForKey:useKey];
        [self postNotifi:nil];
        return YES;
    }
    [self startViewShow];
    return NO;
}
- (void)startViewShow {
    UIWindow * window = [[UIApplication sharedApplication] delegate].window;
    [window.rootViewController.view addSubview:_startView];
    _startView.frame = Screen_Frame;

}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

- (void)dissmiss {
    [self removeFromSuperview];
}
- (IBAction)loginBtn:(UIButton *)sender {
    if (_usemess.text.length) {
        AFHTTPSessionManager * manger = [AFHTTPSessionManager manager];
        manger.requestSerializer = [AFHTTPRequestSerializer serializer];
        manger.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSDictionary * dic = @{
                @"useId":_usemess.text,
                };
        [manger POST:@"http://127.0.0.1:8000/chickUser" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary * resp = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            if ([resp[@"success"] isEqualToString:@"1"]) {
                _userMessage = resp[@"use"];
                [self postNotifi:nil];
                [self write:_userMessage forKey:useKey];
                [self dissmiss];
            } else {
                [SVProgressHUD showErrorWithStatus:@"用户名错误！"];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [SVProgressHUD showErrorWithStatus:@"网络链接错误"];
        }];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的useid！"];
    }
}

- (void)postNotifi:(NSDictionary *)info {
    NSDictionary * infos = @{@"usename":_userMessage[@"name"]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:nil userInfo:infos];
}
- (void)deleteUser {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:useKey];
    BOOL isok = [userDefaults synchronize];
    NSLog(@"----写入结果%d",isok);
    self.userMessage = nil;
    [self startViewShow];
}

//写本地缓存的内容
- (void)write:(id)value forKey:(NSString *)key {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    BOOL isok = [userDefaults synchronize];
    NSLog(@"----写入结果%d",isok);
}
//读本地缓存的内容
- (id)readValueForKey:(NSString *)key {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:key];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
