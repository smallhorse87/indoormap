//
//  RTLbs3DPOIMessageClass.h
//  rtmapSDK
//
//  Created by rtmap on 13-11-26.
//  Copyright (c) 2013年 客人用户. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/*!
 @class
 @abstract POI信息类
 */

@interface RTLbs3DPOIMessageClass : NSObject<NSCoding>

/*!
@property
@abstract poi名字
*/
@property (nonatomic,strong) NSString *POI_Name;

/*!
 @property
 @abstract poi所在楼层
 */
@property (nonatomic,strong) NSString *POI_Floor;

/*!
 @property
 @abstract POI_ID POI ID
 */
@property (nonatomic,strong) NSString *POI_ID;

/*!
 @property
 @abstract POIClassId POI分类ID
 */
@property (nonatomic,strong) NSString *POI_ClassId;

/*!
 @property
 @abstract POI_type POI类型
 */
@property (nonatomic,assign) NSInteger POI_type;


/*!
 @property
 @abstract POI_point POI坐标
 */
@property (nonatomic,assign) CGPoint POI_point;

/*!
 @property
 @abstract distance 查询周边时最近点的距离，查询周边使用,单位为米
 */
@property (nonatomic,assign) CGFloat  distance;
@end
