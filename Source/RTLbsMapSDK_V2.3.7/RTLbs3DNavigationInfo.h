//
//  RTLbs3DNavigationInfo.h
//
//  RtMap wdSDK copyright (c) 2013, RtMap. All rights reserved.



/*!
 @header RTLbs3DNavigationInfo.h
 @abstract  导航路线模型
 @author rtmap
 @version 2.0
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

///路线规划节点信息
@interface RTLbs3DPlanNode : NSObject

//节点坐标
@property(nonatomic,assign)CGPoint point;
//节点楼层
@property(nonatomic,strong) NSString *floor;
//poi名称
@property(nonatomic,strong) NSString *poiName;
@end

/*!
 @class
 @abstract 导航路线模型类
 */
@interface RTLbs3DNavigationInfo : NSObject

/*!
 @property
 @abstract 直线距离
 */
@property (nonatomic,strong) NSString *distance;
/*!
 @property
 @abstract poi名字
 */
@property (nonatomic,strong) NSString *poiName;

/*!
 @property
 @abstract 导航分段路线描述
 */
@property (nonatomic,strong) NSString *poiRouteDesc;


/*!
 @property
 @abstract 楼层
 */
@property (nonatomic,strong) NSString *navFloor;
/*!
 @property
 @abstract 左转还是右转
 */
@property (nonatomic,strong) NSString *leftORright;
/*!
 @property
 @abstract 地图坐标X
 */
@property (nonatomic,assign) float navPoint_x;
/*!
 @property
 @abstract 地图坐标Y
 */
@property (nonatomic,assign) float navPoint_y;

/*!
 @property
 @abstract 地图poi类型
 */

@property (nonatomic,strong) NSString *type_poi;

/*!
 @property
 @abstract 导航角标
 */
@property (nonatomic,assign) NSInteger navIndex;

@end
