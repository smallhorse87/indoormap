//
//  RTLbsMapVersion.h
//  SDK
//
//  Created by zhaoyubin on 15/7/18.
//  Copyright (c) 2015年 rtmap. All rights reserved.
//

#import <UIKit/UIKit.h>

/*****更新日志：*****
 V2.0:正式发布版
 地图浏览操作
 关键字搜索
 分类搜索
 路线规划
 定位图层
 标注点，弹出气泡
 ---------------------------
 V2.3
 增加多点导航
 增加导航动画接口
 定位点平滑移动
 建筑物列表添加全拼、简拼字段
 ---------------------------
 V2.3.1
 【 新 增 】
 增加获取POI详情接口(机场使用)
 -(void)getPoiDesc:(NSString *)poiID;
 【 优 化 】
 优化地图加载逻辑
 ---------------------------
 V2.3.2 20160325
 【 变 更 】
 基础地图RTLbsMapView类中
 更改跟随模式实现逻辑，画定位点方法：
 - (void)drawMobilePositioningPoint:(CGPoint)point  locationImageName:(NSString*)imageName flickerColor:(UIColor*)flickerColor  setMapCenter:(BOOL)mapCenter
 改为：
- (void)drawLocationPoint:(CGPoint)point  locationImageName:(NSString*)imageName flickerColor:(UIColor*)flickerColor flickerRadius:(NSInteger)radius
 说明：参数radius为闪烁半径，可调整定位点闪烁的最大半径
 
 【 新 增 】
 基础地图RTLbsMapView.h中
 typedef enum {
 RTLbsUserTrackingModeNone = 0,             /// 普通定位模式
 RTLbsUserTrackingModeFollow                /// 定位跟随模式
 } RTLbsUserTrackingMode;
 /// 设定定位模式
 @property (nonatomic) RTLbsUserTrackingMode userTrackingMode;
 说明：设定定位模式为跟随后，开启跟随，若移动地图，则自动转为普通模式
 
 【 优 化 】
 优化定位点闪烁动画
 【 修 复 】
 修复罗盘调整位置后，点击罗盘地图未恢复初始角度的问题
 ---------------------------
 V2.3.3 20160627
 【 变 更 】
 基础地图RTLbsMapView类中
 更改比例尺属性
 @property(nonatomic,assign)double metersPerPixel;
 改为
 @property(nonatomic,assign)double millimetersPerPixel;
 【 修 复 】
 修复初始化地图方法中传入地图比例尺参数不生效的问题
 ---------------------------
 V2.3.4 20160829
 【 新 增 】
 基础地图RTLbsMapView类中
 是否显示比例尺图层（YES显示，默认为不显示）
 @property (nonatomic,assign)BOOL isShowMapScaleView;
 比例尺图层显示位置，默认为左下角
 @property (nonatomic,assign)CGPoint mapScaleViewPosition;
 
 RTLbsUserTrackingMode添加
 RTLbsUserTrackingModeFollowWithHeading,    /// 定位罗盘模式
 【 修 复 】
 修复路径规划同一楼层有两条线路时第二条线路未显示的问题
 
 ---------------------------
 V2.3.5 20161118  so 1.1.2
 【 新 增 】
 基础地图RTLbsMapView.h中
 typedef enum{
 RTLbsMapLoadedLocalORFirstDownload = 1, //地图数据读取本地或首次下载
 RTLbsMapLoadedFromUpdate  //地图数据更新完成
 }RTLbsMapLoadedSuccessType;
 ///自定义poi注记属性
 @property (nonatomic,strong) NSArray *poiListArray;
 ///离线路径规划imap文件路径
 @property (nonatomic,strong) NSString *navImapFilePath;
 ///优先显示的level数组
 @property (nonatomic,strong) NSArray *priorityShowLevels;
 地图图钉RTLbs3DAnnotation.h中
 ///图钉标号(自定义poi注记时作为id使用)
 @property (nonatomic, assign) NSInteger annoNumber;
 【 变 更 】
 基础地图RTLbsMapView类中
 更改地图加载成功代理方法
 - (void) mapViewLoadedSuccess:(RTLbsMapView*)rtmapView;
 改为
 - (void) mapViewLoadedSuccess:(RTLbsMapView*)rtmapView loadedType:(RTLbsMapLoadedSuccessType)type;
 更改地图加载失败代理方法
 - (void) mapViewLoadedFaile:(RTLbsMapView*)rtmapView;
 改为
 - (void) mapViewLoadedFailed:(RTLbsMapView*)rtmapView error:(NSString *)errorInfo;
 【 优 化 】
 地图加载成功、更新成功及加载失败代理方法添加状态参数
 ---------------------------
 V2.3.6 20161220  so 1.1.2
 【 修 复 】
 修复路径规划设置绘制其他楼层虚线时，路径结束楼层地图自动计算比例尺错误问题
 
 ---------------------------
 V2.3.7 20170504  so 1.1.2
 【 新 增 】
 基础地图RTLbsMapView.h中添加通过Poi名字获取poi对象方法
 - (RTLbsPOIMessageClass *) getMapPoiWithName:(NSString *)poiName;
 RTLbsPOIMessageClass类中添加POI_Level属性
 *********************/

/**
 *获取当前地图API的版本号
 *return  返回当前API的版本号
 */
UIKIT_STATIC_INLINE NSString * RtmapGetMapApiVersion()
{
    return @"2.3.7";
}
