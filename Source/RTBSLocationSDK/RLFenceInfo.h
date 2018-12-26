//
//  RLFenceInfo.h
//  BeaconLocation
//
//  Created by zhaoyubin on 16/6/22.
//  Copyright © 2016年 zhaoyubin. All rights reserved.
//

#import <Foundation/Foundation.h>
///地理围栏信息类
@interface RLFenceInfo : NSObject
///建筑物Id
@property(nonatomic,strong)NSString *buildId;
///楼层
@property(nonatomic,strong)NSString *floor;
@end
