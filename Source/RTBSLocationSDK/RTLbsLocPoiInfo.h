//
//  RTLbsLocPoiInfo.h
//  BeaconLocation
//
//  Created by zhaoyubin on 15/12/24.
//  Copyright © 2015年 zhaoyubin. All rights reserved.
//

#import <Foundation/Foundation.h>
///Poi信息类
@interface RTLbsLocPoiInfo : NSObject
///建筑物名称
@property(nonatomic,copy)NSString *build_name;
///楼层
@property(nonatomic,copy)NSString *floor;
///POI名称
@property(nonatomic,copy)NSString *poi_name;
///POI标号
@property(nonatomic,copy)NSString *poi_id;
///是否在POI内
@property(nonatomic,assign)BOOL is_inside;
@end
