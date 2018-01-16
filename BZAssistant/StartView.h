//
//  StartView.h
//  BZAssistant
//
//  Created by shenzhenshihua on 2018/1/16.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartView : UIView
@property(nonatomic,copy)NSDictionary *userMessage;
+ (id)shareStartView;
- (BOOL)chickUserLogin;

- (void)deleteUser;
@end
