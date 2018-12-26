//
//  RTLbs3DAnnotation.h
//  maps
//
//  Created by zhaoyubin on 15/4/23.
//  Copyright (c) 2015年 rtmap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, RTAnnoStyle)
{
    RTPlainAnno,  //普通的图针
    RTNavAnno,    //导航图针
};
/*!
 @class
 @abstract 地标类
 */
@interface RTLbs3DAnnotation : NSObject

/*!
 @property
 @abstract 图钉的title
 */
@property (nonatomic, copy) NSString * annoTitle;

/*!
 @property
 @abstract 图钉的唯一标识
 */
@property (nonatomic, copy) NSString * annoId;

/*!
 @property
 @abstract 在地图上显示的图标
 */
@property (nonatomic, copy) NSString *iconName;


/*!
 @property
 @abstract 在地图上显示的图标
 */
@property (nonatomic, copy) UIImage *iconImage;

/*!
 @property
 @abstract 楼层
 */
@property (nonatomic, copy) NSString *annotationFloor;

/*!
 @property
 @abstract Pop-up 地图坐标
 */
@property (nonatomic, assign) CGPoint location;
/*!
 @property
 @abstract 是否支持点击
 */
@property (nonatomic, assign) BOOL isCanClick;
/*!
 @property
 @abstract 图针类型
 */
@property (nonatomic, assign) RTAnnoStyle annoStyle;


/*!
 @method
 @abstract  初始化图钉
 @discussion null。
 @param mapPoint 图钉的坐标
 @param title 图钉的POI名字
 @param iconImage 图钉的样式
 @param floor 图钉显示的楼层
 @result id 返回结果
 */

- (id) initWithMapPoint:(CGPoint) mapPoint annoTitle:(NSString *)title annoId: (NSString *)idstr iconImage:(UIImage *) iconImage floorID:(NSString *)floor;

@end
