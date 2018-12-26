//
//  RTLbs3DWebService.h
//  maps
//
//  Created by zhaoyubin on 15/4/22.
//  Copyright (c) 2015年 rtmap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol RTLbs3DWebServiceDelegate;

/*!
 @class
 @abstract 地图网络访问类
 */
@interface RTLbs3DWebService : NSObject
/*!
 @property
 @abstract 地图网络访问类协议指针。
 */
@property (nonatomic,weak) id<RTLbs3DWebServiceDelegate>delegate;
/*!
 @property
 @abstract 服务器地址。
 */
@property (nonatomic,assign) NSString *serverUrl;


/*!
 @method
 @abstract licese验证
 @param requestData license验证消息体
 */
-(void)licenseRequest:(id)requestData;

/*!
 @method
 @abstract 获取license绑定的城市列表
 @result BOOL 返回结果
 */
-(BOOL)getServiceCityList;

/*!
 @method
 @abstract 获取license下某个城市的建筑物列表(分地区)
 @param cityName 城市名称
 @result BOOL 返回结果
 */
-(BOOL)getDistrictBuildListOfCity:(NSString *)cityName;

/*!
 @method
 @abstract 获取地图imap数据
 @discussion 获取建筑物的楼层信息。
 @param buildingID  建筑物ID
 @param floorID  楼层
 */
- (void) getMapDataWhithBuildid:(NSString *)buildingID floorId:(NSString*)floorID;

/*!
 @method
 @abstract 地图导航(支持多点导航接口－2)
 @param buildingId  建筑物ID
 @param pointAndFloorList  数组里面放字典 字典的key值分别为 :floor(楼层) x(x坐标) y(y坐标)。
 */
- (void) getNavigationRouteInMarketBuildingID: (NSString *) buildingId navigationPointandFloor:(NSMutableArray*)pointAndFloorList;

/*!
 @method
 @abstract 关键字搜索
 @param word 搜索关键字
 @param buildID 建筑物ID
 @param floor 楼层,若为nil,则返回建筑物内结果
 */
-(BOOL)getKeywordSearch:(NSString*)word buildID:(NSString *)buildID Floor:(NSString *)floor;

/*!
 @method
 @abstract 分类搜索
 @discussion
 @param buildId 建筑物Id
 @param floor 楼层,若为nil,则返回建筑物内结果
 @param classIds 分类Id数组
 @param pageindex 第几页
 @param pagesize  分页数量
 @result BOOL 返回结果
 */
-(BOOL)getClassifySearchWithBuildId:(NSString *)buildId Floor:(NSString *)floor ClassIds:(NSArray *)classIds pageindex:(NSInteger)pageindex pagesize:(NSInteger)pagesize;


/*!
 @method
 @abstract 获取建筑物下的楼层信息
 @param buildId 建筑物ID
 @result BOOL 返回结果
 */
-(BOOL)getBuildFloorInfo:(NSString *)buildId;


@end





@protocol RTLbs3DWebServiceDelegate<NSObject>

@optional

/*!
 @method
 @abstract 获取license 下的城市列表成功回调
 */
- (void) getCityListFinish:(NSArray*)cityList;

/*!
 @method
 @abstract 获取license 下的城市列表失败回调
 @param error 失败后的错误信息
 */
- (void) getCityListFail:(NSString*)error;

/*!
 @method
 @abstract 获取license 下的城市列表成功回调
 */
- (void) getCityListWithCityNameFinish:(NSArray*)cityList;

/*!
 @method
 @abstract 获取license 下的城市列表失败回调
 @param error 失败后的错误信息
 */
- (void) getCityListWithCityNameFail:(NSString*)error;

/*!
 @method
 @abstract 获取地图数据成功后的代理 将保存好的路径返回
 */
- (void) getMapDataFinish:(NSString*)filePath;
/*!
 @method
 @abstract 获取地图数据失败
 @param error 失败后的错误信息
 */
- (void) getMapDataFail:(NSString*)error;

/*!
 @method
 @abstract 导航成功后调用该方法
 @param distance 导航总路线
 @param navigationInfo 成功后返回导航路线坐标（绘制导航线时，传该数组）
 @param InflectionArrays 导航拐点
 */
- (void) navigationRequestFinish:(NSMutableArray*)navigationInfo  navigationRountInflection:(NSMutableArray*)InflectionArrays    routeStringArrays:(NSMutableArray*)routeString poiIndexArray:(NSMutableArray *)poiIndexArray totalDistance:(NSString*)distance;

/*!
 @method
 @abstract 导航失败
 @param error 错误信息
 */
- (void) navigationRequestFail:(NSString *)error;

/*!
 @method
 @abstract 关键字搜索成功后调用该方法
 @param poiMessageArray 成功后返回的RTLbs3DPOIMessageClass对象数组
 */
- (void) searchRequestFinish:(NSArray *)poiMessageArray;

/*!
 @method
 @abstract 关键字搜索失败后调用该方法
 @param  error 错误信息
 */
- (void) searchRequestFail:(NSString*)error;

/*!
 @method
 @abstract 获取建筑物分类信息成功后调用该方法
 @param classTypeList 成功后返回的分类信息数组
 
 */
-(void)getBuildClassifyFinish:(NSArray *)classTypeList;
/*!
 @method
 @abstract 获取建筑物分类信息成功后调用该方法
 @param error 失败后的错误信息
 
 */
-(void)getBuildClassifyFail:(NSString *)error;


/*!
 @method
 @abstract 获取建筑物楼层信息成功后的回调
 @param floorInfo 返回的楼层信息
 */
-(void) getFloorInfoFinish:(NSDictionary *)floorInfo;
/*!
 @method
 @abstract 获取建筑物楼层信息失败后的回调
 @param error 错误码信息
 */
-(void) getFloorInfoFail:(NSString *)error;

/*!
 @method
 @abstract 获取license验证成功后调用该代理
 @param jsonData 返回json数据

 */
- (void) getLicenseVerify:(NSData *)jsonData;
/*!
 @method
 @abstract 获取license验证失败后调用该代理
 @param errorCode 失败后的错误码
 */
-(void) getLicenseVerifyFail:(NSInteger)errorCode;

@end
