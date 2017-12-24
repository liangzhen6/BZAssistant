//
//  ViewController.h
//  BZAssistant
//
//  Created by liangzhen on 2017/12/23.
//  Copyright © 2017年 liangzhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property(nonatomic,copy)NSString *typeStr;
- (void)handleResult:(NSArray *)dataArr;
- (void)cancleTime;
- (void)backgroundRefresh;
@end

