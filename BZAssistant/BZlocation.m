//
//  BZlocation.m
//  BZAssistant
//
//  Created by liangzhen on 2017/12/23.
//  Copyright © 2017年 liangzhen. All rights reserved.
//

#import "BZlocation.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
@interface BZlocation()<CLLocationManagerDelegate>
@property(nonatomic,strong)CLLocationManager *lomanger;
@property(nonatomic,copy)ResultBlock resultBlock;
@end
static BZlocation *_bzLocation;
@implementation BZlocation
+ (id)shareBZlocation {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_bzLocation == nil) {
            _bzLocation = [[BZlocation alloc] init];
        }
    });
    return _bzLocation;
}

- (void)startLocation:(ResultBlock)resultBlock {
    self.resultBlock = resultBlock;
    _lomanger = [[CLLocationManager alloc] init];
    _lomanger.delegate = self;
    _lomanger.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    _lomanger.distanceFilter = 1.0;
//    [_lomanger requestWhenInUseAuthorization];
    [_lomanger requestAlwaysAuthorization];
    [_lomanger startUpdatingLocation];
}
- (void)stopLocation {
    [_lomanger stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (self.resultBlock) {
        self.resultBlock();
    }
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        NSLog(@"在前台");
    } else {
        NSLog(@"在后台");
    }
}

@end
