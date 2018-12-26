//
//  RTLbsMapView.h
//  3DMap_new
//
//  Created by wang jinchang on 2017/9/4.
//  Copyright © 2017年 wang jinchang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLbs3DAnnotation.h"
#import "RTLbs3DNavigationInfo.h"


typedef enum {
    RLUserTrackingModeNone = 0,             /// 普通定位模式
    RLUserTrackingModeFollow,              /// 定位跟随模式
    RLUserTrackingModeFollowWithHeading,    /// 定位罗盘模式
} RLUserTrackingMode;

typedef enum {
    RTLbsRoutePlanningModeNone = 0,             /// 路径模式
    RTLbsRoutePlanningModeNavigation,           /// 导航模式

} RTLbsRoutePlanningMode;


typedef enum {
    RTLbsRouteNodeModeEndPoint = 0,             /// 导航本层终点信息
    RTLbsRouteNodeModeInflectionPoint,          /// 导航过程中下一个拐点信息
    
} RTLbsRouteNodeType;


@protocol RTLbsMapViewDelegate;
@interface RTLbsMapView : UIView

@property (nonatomic,assign) id<RTLbsMapViewDelegate> delegate;


/*!
 @property
 @abstract 设定定位模式。
 */
@property (nonatomic,assign) RLUserTrackingMode userTrackingMode;


/*!
 @property
 @abstract 设定路线规划模式。
 */
@property (nonatomic,assign) RTLbsRoutePlanningMode navigationMode;

/*!
 @property
 @abstract 设定导航节点类型。
 */
@property (nonatomic,assign) RTLbsRouteNodeType navigationNodeType;


/*!
 @property
 @abstract 当前建筑物ID。
 */
@property (nonatomic,strong)NSString *build;

/*!
 @property
 @abstract 当前地图楼层。
 */
@property (nonatomic,strong)NSString *floor;


/*!
 @property
 @abstract 地图罗盘的位置。
 */
@property(nonatomic,assign)CGPoint compassPosition;


/*!
 @property
 @abstract 建筑物与正北的夹角。
 */
@property (nonatomic,assign)CGFloat northAngle;

/*!
 @property
 @abstract 导航开始点的图片。
 */
@property(nonatomic,strong) UIImage *navStartImage;

/*!
 @property
 @abstract 导航结束点的图片。
 */
@property(nonatomic,strong) UIImage *navEndImage;

/*!
 @property
 @abstract 导航线宽。
 */
@property(nonatomic,assign) NSInteger navLineWide;


/*!
 @property
 @abstract 是否允许地图旋转 默认YES。
 */
@property(nonatomic,assign) BOOL mapRotate;


/*!
 @property
 @abstract 是否允许地图俯视 默认YES。
 */
@property(nonatomic,assign) BOOL mapPitch;


/*!
 @property
 @abstract 是否允许地图缩放 默认YES。
 */
@property(nonatomic,assign) BOOL mapZoom;


/*!
 @property
 @abstract 是否允许地图移动 默认YES。
 */
@property(nonatomic,assign) BOOL mapMove;

/*!
 @property
 @abstract 是否允许地图操作（手势） 默认YES。
 */
@property (nonatomic,assign) BOOL mapGesture;

/*!
 @property
 @abstract 是否显示橡皮筋 默认NO。
 */
@property (nonatomic,assign) BOOL showRubberBand;


/*!
 @property
 @abstract 围栏区域填充色。
 */
@property (nonatomic,assign) UIColor *regionFillColor;

/*!
 @property
 @abstract 围栏区域边线色。
 */
@property (nonatomic,assign) UIColor *regionLineColor;




/*!
 @method
 @abstract 初始化地图view
 @discussion 暂不支持init其他方法初始化
 @param frame frame
 @param build 建筑物ID
 @param floor 楼层
 @param url   服务器地址
 @param meter 比例尺(30 - 1500内的float数)
 @param delegate 代理对象
 @result id 返回结果
 */
- (id)initWithFrame:(CGRect)frame building:(NSString*)build floor:(NSString*)floor serverUrl:(NSString*)url scale:(float)meter delegate:(id)delegate;


/*!
 @method
 @abstract 切换楼层
 @discussion null。
 @param build 建筑物Id
 @param floor 楼层Id
 */
- (void) reloadMapWithBuilding: (NSString *) build andFloor: (NSString*) floor;


/*!
 @property
 @abstract 地图外边矩形。
 */
- (CGRect)getMapViewRect;

/*!
 @method
 @abstract 设置地图的俯视角度
 @discussion null。
 @param angle 增量角度 (单位:角度)
 @remarks 俯仰角度有限制, 默认区间[30 - 90]度
 */
- (void) setMapViewPitchAngleOffset:(float)angle;

/*!
 @method
 @abstract 切换地图的配色
 @discussion null。
 @param fileName 配色文件名字
 
 */
- (void) setMapViewColor:(NSString*)fileName;


/*!
 @method
 @abstract 获取地图缩放级别
 */
- (float) getMapviewZoomLevel;

/**
 @abstract 设置地图缩放
 @param level 地图级别. (0 - 10级)
 @param duration_milliSecond 完成缩放动画时长. (单位:毫秒)
 */
- (void) setMapviewZoomLevel:(float)level duration:(int)duration_milliSecond;


/**
 @abstract 控制标注是否显示
 @param allow 打开/关闭
 */
-(void)mapViewShowLabelsAllow:(BOOL)allow;


/**
 @abstract 控制标注优先显示图标或文字
 @param iconFirst YES:图标优先  NO:文字优先
 */
-(void)mapViewShowLabelsIconFirst:(BOOL)iconFirst;


/*!
 @method
 @abstract 将point移动到屏幕中心
 @param point 坐标
 @param animationTime 动画时长. 如果设置0，则无动画效果. (单位:毫秒)
 @discussion null。

 */
- (void) mapViewPointMoveToScreenCenter:(CGPoint)point duration:(int)animationTime;


/*!
 @method
 @abstract 地图坐标转换成屏幕坐标
 @param projectedPoint 地图坐标
 @result CGPoint  返回屏幕坐标
 */
-(CGPoint)projectedPointToPixel:(CGPoint)projectedPoint;


/*!
 @method
 @abstract 屏幕坐标转换成地图坐标
 @param pixelPoint 屏幕坐标
 @result CGPoint 返回地图坐标
 */
- (CGPoint)mapPointFromPixelPoint:(CGPoint)pixelPoint;


/*!
 @method
 @abstract 添加图钉
 @discussion null。
 @param annotation RTLbs3DAnnotation的对象
 @param isShowPopView 是否显示图钉上的气泡
 @param isCenter 是否显示在地图中心
 */
- (void)addAnnotation:(RTLbs3DAnnotation *)annotation  isShowPopView:(BOOL)isShowPopView setMapCenter:(BOOL)isCenter;


/*!
 @method
 @abstract 添加地理围栏
 @discussion null。
 @param buildid 建筑ID
 @param showLayer 是否显示layer
 */
- (void)mapViewAddGeographyEnclosureWithBuildID:(NSString*)buildid isShowLayer:(BOOL)showLayer;

/*!
 @method
 @abstract 移除地理围栏
 @discussion null。
 */
- (void)removeGeographyEnclosure;


/*!
 @method
 @abstract 移除地图上的图钉
 @discussion null。
 */
- (void)removeAnnotations;

/*!
 @method
 @abstract 移除地图上的指定图钉
 @discussion null。
 */
- (void)removeAnnotationWith:(RTLbs3DAnnotation *)annotation;

/*!
 @method
 @abstract 从地图上移除图钉气泡
 @discussion null。
 */
- (void) removeAnnotationWithPopView;


/*!
 @method
 @abstract 两点导航起始点
 @discussion null。
 @param startPoint 导航起始点
 @param build       建筑物ID
 @param floor       楼层ID
 @param mapDelegate 地图代理对象
 */

- (void) mapViewNavgationStartPoint:(CGPoint)startPoint buildingID:(NSString*)build floorID:(NSString*)floor delegate:(id)mapDelegate;


/*!
 @method
 @abstract 两点导航终点（如果起点选中过  会自动导航）
 @discussion null。
 @param endPoint 导航终点
 @param build       建筑物ID
 @param floor       楼层ID
 @param mapViewDelegate 地图代理对象
 */
- (void) mapViewNavgationEndPoint:(CGPoint)endPoint buildingID:(NSString*)build floorID:(NSString*)floor delegate:(id)mapViewDelegate;


/*!
 @method
 @abstract 绘制地图的导航线
 @discussion null。
 @param navigationArr 导航线
 @param floor 楼层
 */
- (void) drawNavigationLine:(NSMutableArray*)navigationArr floorId:(NSString*)floor;


/**
 @abstract 使地图导航线可以恰好全览
 @param duration_milliSecond 完成平移动画时长. (单位:毫秒)
 */
- (void)overallViewMapDuration:(int)duration_milliSecond;


/*!
 @method
 @abstract 从地图上移除导航线和所经过的POI点
 @discussion null。
 */
- (void)removeNavAnnotationsAndNavLine;

/*!
 @method
 @abstract 路书分段高亮
 @param poiIndexArray 导航点数组
 @param selectIndex   高亮线段下标
 */
-(void)uploadNavigitionDataWithSelectPoint:(NSInteger)selectIndex poiIndexArray:(NSArray *)poiIndexArray;


/*!
 @method
 @abstract 绘制地图上面的定位点
 @discussion null。
 @param point 定位点坐标
 @param floor 定位楼层
 @param build 建筑物ID
 @param imageName 定位的图片
 
 */
- (void)drawMobilePositioningPoint:(CGPoint)point AndBuild:(NSString*)build  AndFloor:(NSString*)floor locationImageName:(NSString*)imageName;

/*!
 @method
 @abstract 移除地图上定位点
 */
- (void) removeMapViewLocationPoint;

/*!
 @method
 @abstract 获取地图上面的所有poi信息 （当前楼层）
 @discussion null。
 */
- (NSArray*)getMapViewAllPoiMessage;


/*!
 @method
 @abstract 获取指定区域上的poi
 @param point 定位点坐标
 @param startMeter 开始米数
 @param endMeter   结束米数
 @discussion null。
 */
- (NSArray*)getRegionPoiWithLocation:(CGPoint)point startMeter:(NSInteger)startMeter endMeter:(NSInteger)endMeter;

@end



#pragma mark - mapView  delegate
@protocol RTLbsMapViewDelegate <NSObject>

@optional

/*!
 @method
 @abstract 点击地图上POI触发的方法
 @discussion null。
 @param point 地图坐标
 @param poiName poi中文名称
 @param ID      poiID
 */
- (void) mapViewDidTapOnMapPoint:(CGPoint)point poiName:(NSString*)poiName poiID:(NSString*)ID shapType:(NSInteger)type;

/*!
 @method
 @abstract 自定义气泡视图
 @discussion null。
 @result view 返回自定义好的视图
 */

- (UIView*)mapViewWithAnnotationPopView:(RTLbs3DAnnotation *)anno;


/*!
 @method
 @abstract 开始加载地图
 @param floor 当前楼层
 */
- (void) startLoadMapViewWithFloor:(NSString*)floor;

/*!
 @method
 @abstract 地图加载成功
 @param rtmapView mapView对象
 */
- (void) mapViewLoadedSuccess:(RTLbsMapView*)rtmapView;


/*!
 @method
 @abstract 地图加载失败
 @param rtmapView mapView对象
 */
- (void) mapViewLoadedFaile:(RTLbsMapView*)rtmapView;

/*!
 @method
 @abstract 用户操作地图的回调
 */
- (void) mapViewWithUserActionMap:(RTLbsMapView*)rtmapView;


/*!
 @method
 @abstract 用户进入地理围栏
 @param   dic 围栏信息
 */
- (void) mapViewEnterGeographyEnclosure:(NSDictionary*)dic;


/*!
 @method
 @abstract 用户退出地理围栏
 @param   dic 围栏信息
 */
- (void) mapViewExitGeographyEnclosure:(NSDictionary*)dic;


/*!
 @method
 @abstract 导航过程中返回定位点后面的拐点数组
 */
- (void) mapViewInflectionPoint:(RTLbs3DNavigationInfo*)inflection allDistance:(float)distance isEndPoi:(BOOL)endPoi;

@end



