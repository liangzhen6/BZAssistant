//
//  ViewController.m
//  BZAssistant
//
//  Created by liangzhen on 2017/12/23.
//  Copyright © 2017年 liangzhen. All rights reserved.
//

#import "ViewController.h"
#import "HttpRequest.h"
#import <SVProgressHUD.h>
#import "BZnotification.h"
#import "StartView.h"
@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *type;
@property (weak, nonatomic) IBOutlet UITextField *refreshTime;
@property (weak, nonatomic) IBOutlet UITextField *min;
@property (weak, nonatomic) IBOutlet UITextField *max;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (weak, nonatomic) IBOutlet UIButton *nameBtn;

@property(nonatomic,assign)NSInteger refreshTimeNum;
@property(nonatomic,assign)float minNum;
@property(nonatomic,assign)float maxNum;

@property(nonatomic,strong)NSTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [self setDelegate];
    [self initData];
    [self initTimer];
    [self addnotification];
    [[StartView shareStartView] chickUserLogin];

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)addnotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification:) name:@"login" object:nil];
}
- (void)notification:(NSNotification *)notifi {
    [_nameBtn setTitle:notifi.userInfo[@"usename"] forState:UIControlStateNormal];
}

- (void)setDelegate {
    _type.delegate = self;
    _refreshTime.delegate = self;
    _min.delegate = self;
    _max.delegate = self;
}
- (void)initData {
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [path objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"value.plist"];
    NSDictionary *dataDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    if (!dataDict.count) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"value" ofType:@"plist"];
        dataDict = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    _type.text = dataDict[@"typeStr"];
    _refreshTime.text = dataDict[@"refreshTimeNum"];
    _min.text = dataDict[@"min"];
    _max.text = dataDict[@"max"];

    _typeStr = dataDict[@"typeStr"];
    _refreshTimeNum = [dataDict[@"refreshTimeNum"] integerValue];
    _maxNum = [dataDict[@"max"] floatValue];
    _minNum = [dataDict[@"min"] floatValue];
}
- (void)initTimer {
    __weak typeof (self) ws = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_refreshTimeNum repeats:YES block:^(NSTimer * _Nonnull timer) {
        [ws getDatafromeZb];
    }];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    self.timer.fireDate = [NSDate distantFuture];
    
}

- (void)resetTimer {
    // 先销毁之前的
    if (self.timer.isValid) {
        [self.timer invalidate];
        self.timer = nil;
    }
    __weak typeof (self) ws = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_refreshTimeNum repeats:YES block:^(NSTimer * _Nonnull timer) {
        [ws getDatafromeZb];
    }];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [self.timer fire];
}
- (IBAction)btnAction:(UIButton *)sender {
    [self.view endEditing:YES];
    if (!sender.selected) {
        //开始监控
        if ([self chickAllData]) {
            [self writeDataToPlist];
            sender.selected = YES;
            sender.backgroundColor = [UIColor redColor];
            //可以发出请求
            if (self.timer.isValid) {
                self.timer.fireDate = [NSDate distantPast];
            } else {
                [self resetTimer];
            }
        }
    } else {
        sender.selected = NO;
        sender.backgroundColor = [UIColor greenColor];
        //取消监控
        self.timer.fireDate = [NSDate distantFuture];
    }
}

- (void)writeDataToPlist{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [path objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"value.plist"];


    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    dataDict[@"typeStr"] = _typeStr;
    dataDict[@"refreshTimeNum"] = [NSString stringWithFormat:@"%ld",(long)_refreshTimeNum];
    dataDict[@"max"] = [NSString stringWithFormat:@"%f",_maxNum];
    dataDict[@"min"] = [NSString stringWithFormat:@"%f",_minNum];

    BOOL is = [dataDict writeToFile:plistPath atomically:YES];
    NSLog(@"%d",is);

}

- (void)cancleTime {
    if (self.timer.isValid) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
- (void)backgroundRefresh {
    if (self.actionBtn.selected) {
        if (!self.timer.isValid) {
            [self resetTimer];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    
}

- (void)getDatafromeZb {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    double currtime = [[NSDate date] timeIntervalSince1970] - 5*60;//获取5分钟前的数据
    double time = currtime * 1000;
    [parameters setObject:_typeStr forKey:@"market"];
    [parameters setObject:@"1min" forKey:@"type"];
    [parameters setObject:[NSString stringWithFormat:@"%.f",time] forKey:@"since"];

    [[HttpRequest shareHttpRequest] GET:@"http://api.zb.com/data/v1/kline" parameters:parameters success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        NSArray * dataArr = [responseObject[@"data"] lastObject];
        [self handleResult:dataArr];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        NSLog(@"%@",error);
    }];
}

- (void)handleResult:(NSArray *)dataArr {
    float tall = [dataArr[2] floatValue];
    float low = [dataArr[3] floatValue];
    float cuttent = [dataArr[4] floatValue];
    float number = [dataArr[5] floatValue];
    NSString * string = [NSString stringWithFormat:@"成交价:%f,最高价:%f,最低价:%f,交易量:%f\n\n",cuttent,tall,low,number];
    NSString * allStr = [NSString stringWithFormat:@"%@%@",string,_textView.text];
    _textView.text = allStr;
    
    NSString * body;
    if (_minNum >= cuttent) {
        body = [NSString stringWithFormat:@"老哥，可以抄底了！%f",cuttent];
    } else if (_maxNum <= cuttent) {
        body = [NSString stringWithFormat:@"老哥，可以出手了！%f",cuttent];
    }
    if (body.length) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            UIAlertController * alertCon = [UIAlertController alertControllerWithTitle:@"通知" message:body preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alertCon addAction:action];
            [self presentViewController:alertCon animated:YES completion:nil];
        } else {
            if ([[NSThread currentThread] isMainThread]) {
                [[BZnotification shareNotification] sendNotification:body];
            } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[BZnotification shareNotification] sendNotification:body];
            });
            }
        }
    }
    
}
- (BOOL)chickAllData {
    if (![_typeStr containsString:@"_"]) {
        [SVProgressHUD showErrorWithStatus:@"请设置正确的监控类型！"];
        return NO;
    }
    
    if (_refreshTimeNum < 5) {
        [SVProgressHUD showErrorWithStatus:@"最少刷新时间为5s！"];
        return NO;
    }
    
    if (_maxNum <= 0 || _minNum <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请设置正确的监控阀值！"];
        return NO;
    } else {
        if (_minNum >= _maxNum) {
            [SVProgressHUD showErrorWithStatus:@"请设置正确的监控阀值！"];
            return NO;
        }
    }
    return YES;
}

#pragma mark  UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.textColor = [UIColor blackColor];
    if (textField == _min || textField == _max) {
        _min.textColor = [UIColor blackColor];
        _max.textColor = [UIColor blackColor];
    }
}
//结束编辑
- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString * text = textField.text;
    switch (textField.tag - 1000) {
        case 0:
        {//类型
            _typeStr = text;
            if (![text containsString:@"_"]) {
                //格式不对
                [self changeTextFiledColorShowSVP:textField];
            }
        }
            break;
        case 1:
        {//刷新时间
            if (text.length) {
                _refreshTimeNum = text.integerValue;
                //是整数
                if (_refreshTimeNum < 5) {
                    [SVProgressHUD showErrorWithStatus:@"最少刷新时间为5s！"];
                    textField.textColor = [UIColor redColor];
                } else {
                //重新设置timer  只有在运行中才能 重置
                    if (self.actionBtn.selected) {
                        [self resetTimer];
                    }
                }
            } else {
                //不是整数
                [self changeTextFiledColorShowSVP:textField];
                _refreshTimeNum = 0;
            }
        }
            break;
        case 2:
        {//min值
            if ([self chickNumberValue:text]) {
                //数字
                _minNum = text.floatValue;
                if ([self chickEnterMinValue:text]) {
//                    _minNum = text.floatValue;
                } else {
                    [self changeTextFiledColorShowSVP:textField];
                }
                
            } else {
            //其他
                [self changeTextFiledColorShowSVP:textField];
            }
        }
            break;
        case 3:
        {//max 值
            if ([self chickNumberValue:text]) {
                //数字
                _maxNum = text.floatValue;
                if ([self chickEnterMaxValue:text]) {
//                    _maxNum = text.floatValue;
                } else {
                    [self changeTextFiledColorShowSVP:textField];
                }
            } else {
                //其他
                [self changeTextFiledColorShowSVP:textField];
            }

            
        }
            break;

        default:
            break;
    }
}

- (BOOL)chickEnterMinValue:(NSString *)text {
    if (_maxNum > 0 && text.floatValue >= _maxNum) {
        return NO;
    }
    return YES;
}

- (BOOL)chickEnterMaxValue:(NSString *)text {
    if (_minNum > 0 && text.floatValue <= _minNum) {
        return NO;
    }
    return YES;
}
- (BOOL)chickNumberValue:(NSString *)text {
    if ([self isPureInt:text] || [self isPureFloat:text]) {
        return YES;
    } else {
        return NO;
    }
}

//判断字符串是否为浮点数
- (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}
//判断是否为整形：
- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (void)changeTextFiledColorShowSVP:(UITextField *)textField {
    textField.textColor = [UIColor redColor];
    [self showSVP];
}

- (void)showSVP {
    [SVProgressHUD showErrorWithStatus:@"数据填写错误"];
    [SVProgressHUD dismissWithDelay:2.0];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"login" object:nil];
}
- (IBAction)nameBtnAction:(UIButton *)sender {
    if ([[StartView shareStartView] userMessage]) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"是否退出登录？" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction * actiony = [UIAlertAction actionWithTitle:@"是的" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[StartView shareStartView] deleteUser];
        }];
        UIAlertAction * actionn = [UIAlertAction actionWithTitle:@"闹着玩呢" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:actiony];
        [alert addAction:actionn];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
