//
//  BZlocation.h
//  BZAssistant
//
//  Created by liangzhen on 2017/12/23.
//  Copyright © 2017年 liangzhen. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^ResultBlock)(void);
@interface BZlocation : NSObject
+ (id)shareBZlocation;
- (void)startLocation:(ResultBlock)resultBlock;
- (void)stopLocation;
@end
