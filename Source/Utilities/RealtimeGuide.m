//
//  RealtimeGuide.m
//  youngcity
//
//  Created by chenxiaosong on 2018/6/22.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import "RealtimeGuide.h"

#import "RTLbsMapView.h"
#import "RTLbs3DAnnotation.h"
#import "RTLbs3DWebService.h"
#import "YCMapLocationService.h"
#import "RTLbsLocPoiInfo.h"
#import "RTLbs3DNavigationInfo.h"

#import <AVFoundation/AVFoundation.h>

@interface RealtimeGuide()

@property (nonatomic, strong) NSArray          *keyNavigationInfo;

@property (nonatomic, strong) NSString         *navigationInstruct;

@end

@implementation RealtimeGuide


- (instancetype)initWithKeyNavigationInfo:(NSArray*)info
{
    self = [super init];
    if (self) {
        [self formateKeyPaths:info];
    }
    return self;
}

- (NSString*)floorToTxt:(NSString*)floorStr
{
    NSString *floorNumStr = [floorStr stringByReplacingOccurrencesOfString:@"F" withString:@""];
    
    NSInteger floorNumInt = [floorNumStr integerValue];
    
    if(floorNumInt<0) {
        floorNumStr = [floorNumStr stringByReplacingOccurrencesOfString:@"-" withString:@"地下"];
        return [floorNumStr stringByAppendingString:@"层"];
        
    } else {
        return [floorNumStr stringByAppendingString:@"楼"];
        
    }
}

- (NSString*)retTxtGuide:(IbeaconLocation *)location
{
    if(_keyNavigationInfo.count==0)
        return nil;
    
    for(RTLbs3DNavigationInfo *item in _keyNavigationInfo) {
        
        if([item.type_poi isEqualToString:@"REACHED"])
            continue;
        
        if(![item.navFloor isEqualToString:location.floorID])
            continue;

        if(![self isNearBy:CGPointMake(item.navPoint_x     , item.navPoint_y)
                      with:CGPointMake(location.location_x , location.location_y)])
            continue;
        
        NSLog(@"松松 approching detected");
        
        for(int i=0;i<=[_keyNavigationInfo indexOfObject:item];i++) {
            RTLbs3DNavigationInfo *tmpNode = _keyNavigationInfo[i];
            tmpNode.type_poi = @"REACHED";
        }

        //到达了终点
        if(_keyNavigationInfo.lastObject==item) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        
        self.navigationInstruct = item.poiRouteDesc;

        return item.poiRouteDesc;
    }
    
    return nil;
    
}

- (BOOL)isNearBy:(CGPoint)pt1 with:(CGPoint)pt2
{
    CGFloat deltaX = pt1.x - pt2.x;
    
    CGFloat deltaY = pt1.y - pt2.y;
    
    return (deltaX*deltaX + deltaY*deltaY)<220;
}

- (BOOL)pass1stFloorPlatform:(NSArray*)navigationInfos
{
    CGFloat minX = 154.0;
    CGFloat maxX = 236.0;
    
    CGFloat minY = 99.0;
    CGFloat maxY = 148.0;
        
    for(NSDictionary *itemNav in navigationInfos) {
        
        if(![itemNav[@"floor"] isEqualToString:@"F3"])
            continue;
        
        CGPoint pt = CGPointMake([itemNav[@"x"] floatValue], [itemNav[@"y"] floatValue]);
        
        if(pt.x>minX && pt.x<maxX && pt.y>minY && pt.y<maxY) {
            return YES;
        }
        
    }
    
    return NO;
}

- (BOOL)pass3rdFloorPlatform:(NSArray*)navigationInfos
{
    CGFloat minX = 154.0;
    CGFloat maxX = 236.0;
    
    CGFloat minY = 99.0;
    CGFloat maxY = 148.0;
    
    
    for(NSDictionary *itemNav in navigationInfos) {
        
        if(![itemNav[@"floor"] isEqualToString:@"F3"])
            continue;
        
        CGPoint pt = CGPointMake([itemNav[@"x"] floatValue], [itemNav[@"y"] floatValue]);
        
        if(pt.x>minX && pt.x<maxX && pt.y>minY && pt.y<maxY) {
            return YES;
        }
        
    }
    
    return NO;
}

- (void)formateKeyPaths:(NSArray*)rawKeyPaths
{
    for(RTLbs3DNavigationInfo *navItemInfo in rawKeyPaths) {
        navItemInfo.poiRouteDesc = [NSString stringWithFormat:@"直行约%@米|在%@处%@",
                                    navItemInfo.distance,
                                    navItemInfo.poiName,
                                    navItemInfo.leftORright];

        if(rawKeyPaths.lastObject == navItemInfo ) {
            navItemInfo.poiRouteDesc = [NSString stringWithFormat:@"直行约%@米|到达终点",
                                        navItemInfo.distance];
        }
        
    }
    
    _keyNavigationInfo = rawKeyPaths;

}

+ (NSString*)formateInstruction:(RTLbs3DNavigationInfo*)inflection allDistance:(float)distance
{
    if(inflection==nil)
        return nil;

    if(distance==0) {
        return @"导航结束|已到达终点附近";
    }

    return [NSString stringWithFormat:@"直行约%ld米|在%@处%@",
            (long)distance,
            inflection.poiName,
            inflection.leftORright];

}

@end
