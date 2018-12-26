//
//  RTLbsLocationVersion.h
//  BeaconLocation
//
//  Created by zhaoyubin on 15/8/12.
//  Copyright (c) 2015年 zhaoyubin. All rights reserved.
//

#import <UIKit/UIKit.h>
/*****更新日志：*****
 SDK V2.0.1   so库 V6.4.1
 【 新 增 】
 在线定位数据包添加licenseKey
-------------------------------
 SDK V2.1.0     so库 V6.4.1
 【 优 化 】
 优化定位逻辑
 【 新 增 】
 添加设置定位频率的属性
 @property(nonatomic,assign)NSInteger  locationFreq;
 添加手动更新建筑物判断和指纹数据接口
 -(void) updateBuildJudge;
 -(void) updateFinger:(NSString *) buildid;
------------------------------------------------------
 SDK V2.2.0     so库 V6.4.1
 【 优 化 】
 优化定位初始化逻辑，缩短初始化时间
 提高定位稳定性
--------------------------------------------------------
 SDK V2.3.0     so库 V6.4.1
 【 新 增 】
 定位出错信息中添加beacon数量、蓝牙及网络状态信息
 增加地图约束功能
--------------------------------------------
 SDK V2.4.0     so库 V6.6.3
 【 新 增 】
 增加多UUID支持
 增加气压测高，提高楼层判断的准确度
---------------------------------------------
 SDK V2.4.1   so库 V6.6.3
 【 新 增 】
 添加场景API接口
 -(void) updateFinger:(NSString *) buildid;
--------------------------------------------
 SDK V2.5.0   so库 V6.7.2
 【 优 化 】
 优化PDR推算逻辑，提高定位稳定性
 优化beacon加解密算法
--------------------------------------------
 SDK V2.5.1   so库 V6.7.3
 【 优 化 】
 定位算法优化
--------------------------------------------
 SDK V2.5.2   so库 V6.7.6
 【 优 化 】
 so库算法优化
--------------------------------------------
 SDK V2.6.0   so库 V6.7.6
 【 优 化 】
 优化定位加载数据逻辑
 【 修 复 】
 修复内存问题
--------------------------------------------
 SDK V2.7.0   so库 V6.8.3
 【 优 化 】
 优化设备唯一性机制
 去除读取IDFA操作
  so库算法优化
 【 新 增 】
 增加获取设备UDID接口
 -(NSString *) getRTLbsUDID;
 
 定位点类IbeaconLocation添加精度属性
 ///定位精确度(单位为m)
 @property (nonatomic,assign) int   accuracy;
--------------------------------------------
 SDK V2.7.2   so库 V6.8.3
 【 优 化 】
 优化定位请求逻辑，提高首次定位速度及定位跟随速度
 【 新 增 】
 增加获取当前建筑物偏转角接口，需定位成功后调用
 -(void)getCurrentBuildMapAngle;
 通过代理方法返回偏转角信息
 -(void)getCurrentBuildMapAngleSuccess:(NSInteger)buildMapAngle;
 -(void)getCurrentBuildMapAngleFail:(NSString *)error;
 增加地理围栏信息模型类RLFenceInfo
 增加建筑物楼层地理围栏信息，建筑物或楼层变动通过代理方法返回
 -(void)beaconManager:( RTMapLocationManager *)manager didEnterFence:(RLFenceInfo *)fenceInfo;
 【 修 复 】
 修复针对加密beacon的解密问题
 --------------------------------------------
 SDK V2.7.4 20160829   so库 V6.8.3
 【 新 增 】
 增加以指定UUID组初始化方法
 +(RTMapLocationManager *)sharedInstanceWithUUIDList:(NSArray *)uuidlist;
 增加自动更新定位数据开关，默认为YES
 @property(nonatomic,assign)BOOL isAutoUpdateLocationData;
 通过代理方法返回扫描的原始beacon信息
 - (void)rllocationManager:( RTMapLocationManager *)manager didRangeBeacons:(NSArray *)beacons;
 
 --------------------------------------------
SDK V2.7.6 20161118  so库 V6.15.1
 【 优 化 】
 优化定位源数据结构，生成并记录lbsId
 优化在线定位请求，提高在线定位成功率及稳定性。
 【 新 增 】
 IbeaconLocation类下增加lbsId属性
  @property (nonatomic,copy) NSString  *lbsId;
 
 *********************/

/**
 *获取当前定位API的版本号
 *return  返回当前API的版本号
 */
UIKIT_STATIC_INLINE NSString * RtmapGetLocationApiVersion()
{
    return @"2.7.6";
}
