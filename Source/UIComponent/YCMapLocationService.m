//
//  YCMapLocationService.m
//  youngcity
//
//  Created by chenxiaosong on 2017/10/11.
//  Copyright © 2017年 Zhitian Network Tech. All rights reserved.
//

#import "YCMapLocationService.h"

@interface YCMapLocationService ()<RTMapLocationManagerDelegate>
{
    void (^sucBlock) (IbeaconLocation *location);
    void (^failBlock)(NSError *error);
    
    RTMapLocationManager *location;
}
@end

@implementation YCMapLocationService

- (void)start:(void (^)(IbeaconLocation *location))success failure : (void(^)(NSError *error))failure
{
    [location startUpdatingLocation];
    sucBlock          = success;
    failBlock         = failure;
}

- (void)stop
{
    [location stopUpdatingLocation];
}

- (instancetype)init
{
    self = [super init];

    if(self) {
        location          = [RTMapLocationManager sharedInstance];
        location.delegate = self;
    }
    
    return self;
}

- (void)dealloc
{
    [location stopUpdatingLocation];
    location = nil;
}

#pragma mark iBeacon delegate
- (void)beaconManager:(RTMapLocationManager *)manager
  didUpdateToLocation:(IbeaconLocation *)newLocation
          withBeacons:(NSArray *) beacons
{
    NSLog(@"定位成功 (%f,%f) floor = %@\n-------------------",newLocation.location_x,newLocation.location_y,newLocation.floorID);

    sucBlock(newLocation);
}

-(void)beaconManager:(RTMapLocationManager *)manager didFailLocation:(NSDictionary *)result withBeacons:(NSArray *)beacons
{
    NSLog(@"定位出错 \n result = %@",result);

    NSString  *errMsg = @"定位失败";
    NSInteger errCode = 1;

    //stony bug : 数据类型不一致
    if([[result objectForKey:@"bluetoothState"] integerValue] == 0) {
        errMsg  = @"蓝牙未打开";
        errCode = 2;
    } else if([[result objectForKey:@"beaconCount"] isEqualToString:@"0"]) {
        errMsg  = @"未扫描到定位信号";
        errCode = 3;
    }

    NSError   *error  = [[NSError alloc] initWithDomain:errMsg code:errCode userInfo:nil];

    failBlock(error);

}

@end
