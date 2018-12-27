//
//  YCIndoorMapView.h
//  youngcity
//
//  Created by chenxiaosong on 2018/4/23.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import "RTLbsMapView.h"

@class IbeaconLocation;

typedef void(^MapDidLoad)(void);

typedef void(^MapDidTap)(RTLbs3DAnnotation*);

@interface YCIndoorMapView : RTLbsMapView

- (void)reload:(NSString*)floor;

- (void)drawMyLocation:(IbeaconLocation*)location;

- (void)adjustToMyLocation;

- (void)drawPinAnnotation:(RTLbs3DAnnotation*)annotation;

- (void)moveToPinAnnotatin;

- (void)drawRoutes:(NSArray*)navigationInfo targetFloor:(NSString*)floor;

- (void)cleanAll;

@property (nonatomic,strong) MapDidLoad     mapDidLoadSuc;

@property (nonatomic,strong) MapDidLoad     mapDidLoadFail;

@property (nonatomic,strong) MapDidTap      mapDidTap;

@end
