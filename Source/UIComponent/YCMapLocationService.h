//
//  YCMapLocationService.h
//  youngcity
//
//  Created by chenxiaosong on 2017/10/11.
//  Copyright © 2017年 Zhitian Network Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RTMapLocationManager.h"

@interface YCMapLocationService : NSObject

- (void)start:(void (^)(IbeaconLocation *location))success failure : (void(^)(NSError *error))failure;

@end
