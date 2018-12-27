//
//  YCIndoorMapViewModel.h
//  youngcity
//
//  Created by chenxiaosong on 2018/4/17.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IndoorMapDefines.h"

typedef enum : NSUInteger {
    YCGuideModeInit,
    YCGuideModeRealtimeGuiding
} YCGuideMode;

@class IbeaconLocation, RTLbs3DAnnotation, RTLbs3DPOIMessageClass, RTLbsMapView;

@interface YCIndoorMapViewModel : NSObject

@property (nonatomic, readonly) NSNumber        *ntReqPhase;
@property (nonatomic, readonly) NSString        *ntReqPrompt;

@property (nonatomic, readonly) NSArray          *floorArr;

@property (nonatomic, readonly) IbeaconLocation  *location;
@property (nonatomic, readonly) NSString         *locationErrCode;

@property (nonatomic, readonly) NSString         *currentFloor;

@property (nonatomic, readonly) RTLbs3DAnnotation  *pinAnnotation;

@property (nonatomic, readonly) NSArray          *navigationInfo;
@property (nonatomic, readonly) NSString         *navigationInstruct;
@property (nonatomic, readonly) BOOL             inDifferentBuilding;

@property (nonatomic, readonly) YCGuideMode      guideMode;

@property (nonatomic, readonly) BOOL               flagRealTimeGuidingTriggerred;
@property (nonatomic, readonly) RTLbs3DAnnotation  *preEndAnnotation;
@property (nonatomic, readonly) RTLbs3DAnnotation  *preStartAnnotation;

@property (nonatomic, readonly) RTLbs3DPOIMessageClass *retInitedPoiMsg;

@property (nonatomic, readonly) BOOL             blueToothEnabled;


//一次性获取信息
- (void)onFloorInfosReq;

- (void)onInitSearchReq;

//不断更新的信息
- (void)onFetchContinuousLocReq;

- (void)onSelectedFloorChanged:(NSString*)floor;

- (void)onNextSimualtingLocationReq;

//导航状态相关操作：回初始状态，开始实时导航
- (void)onQuitGuideCmd;

- (void)onStartGuidingCmd;

//选点相关操作
- (void)onTappedPointChanged:(RTLbs3DAnnotation*)tappedPoint;

- (void)onSearchedPinAnnotationChanged:(RTLbs3DAnnotation*)searchedPoint;

//初始化
- (instancetype)initWithKeyword:(NSString*)keyword floor:(NSString*)floor map:(RTLbsMapView*)map;

@end
