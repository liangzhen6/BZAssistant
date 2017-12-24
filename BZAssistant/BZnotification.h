//
//  BZnotification.h
//  BZAssistant
//
//  Created by liangzhen on 2017/12/23.
//  Copyright © 2017年 liangzhen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BZnotification : NSObject

+ (id)shareNotification;

- (void)sendNotification:(NSString *)bodystr;

@end
