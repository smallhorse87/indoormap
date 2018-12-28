//
//  YCIndoorMapView.m
//  youngcity
//
//  Created by chenxiaosong on 2018/4/23.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import "YCIndoorMapView.h"

#import "RTLbs3DAnnotation.h"
#import "RTMapLocationManager.h"

#import "Masonry.h"
#import "ISWCategory.h"

#import "IndoorMapDefines.h"

#define kScale 1500

@interface YCIndoorMapView()
{
    RTLbs3DAnnotation *_currentAnnotation;
    IbeaconLocation   *_myLocation;

    int               zoomLevel;
}
@end

@implementation YCIndoorMapView

- (instancetype)init
{
    NSString *targetFloor = @"F1";

    self = [super initWithFrame:CGRectMake(0,0, kScreenWidth, kScreenHeight)
                       building:Indoormap_BuildId
                          floor:targetFloor
                      serverUrl:Indoormap_ServerAddress
                          scale:kScale
                       delegate:self];
    if (self) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI
{
    self.compassPosition   = CGPointMake(33, 96);
    self.navLineWide       = 30;
    self.navigationMode    = RTLbsRoutePlanningModeNone;
}

#pragma mark - delegate
- (void) mapViewDidTapOnMapPoint:(CGPoint)point poiName:(NSString*)poiName poiID:(NSString*)ID shapType:(NSInteger)type
{
    RTLbs3DAnnotation * anno = [[RTLbs3DAnnotation alloc] initWithMapPoint:point
                                                                 annoTitle:poiName
                                                                    annoId:poiName
                                                                 iconImage:nil
                                                                   floorID:self.floor];
    
    if(_mapDidTap) _mapDidTap(anno);
}

- (void) mapViewLoadedSuccess:(RTLbsMapView*)rtmapView
{
    WEAKSELF
    
    if(_mapDidLoadSuc) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.mapDidLoadSuc();
        });
    }

    [self drawMyLocationIfNeeded];

}

- (void) mapViewLoadedFailed:(RTLbsMapView*)rtmapView error:(NSString *)errorInfo
{
    if(_mapDidLoadFail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _mapDidLoadFail();
        });
    }
}

#pragma mark - extern api

- (void)reload:(NSString*)floor
{
    if([self.floor isEqualToString:floor])
        return;
    
    if(_currentAnnotation!=nil) {
        
        if([_currentAnnotation.annotationFloor isEqualToString:floor]) {
            [self addAnnotation:_currentAnnotation isShowPopView:YES setMapCenter:YES];
            
        } else {
            [self removeAnnotations];
        }
        
    }
    
    [self reloadMapWithBuilding:Indoormap_BuildId
                       andFloor:floor];
    
}

- (void)drawMyLocation:(IbeaconLocation*)location
{
    _myLocation = location;
    
    [self drawMyLocationIfNeeded];
}

- (void)moveToMyLocation
{
    //还未获取点
    if(_myLocation==nil)
        return;
    
    [self reloadMapWithBuilding:Indoormap_BuildId
                       andFloor:_myLocation.floorID];
    
}

- (void)drawPinAnnotation:(RTLbs3DAnnotation*)annotation
{
    if(_currentAnnotation!=nil)
        [self removeAnnotations];
    
    _currentAnnotation = annotation;
    
    [self addAnnotation:annotation isShowPopView:YES setMapCenter:YES];
    
    if(![self.floor isEqualToString:annotation.annotationFloor]) {
        
        [self reloadMapWithBuilding:Indoormap_BuildId
                           andFloor:annotation.annotationFloor];
        
    }
    
}

- (void)moveToPinAnnotatin
{
    if(_currentAnnotation==nil)
        return;
    
    if(![self.floor isEqualToString:_currentAnnotation.annotationFloor]) {

        [self addAnnotation:_currentAnnotation isShowPopView:YES setMapCenter:YES];
        
        [self reloadMapWithBuilding:Indoormap_BuildId
                           andFloor:_currentAnnotation.annotationFloor];
        
    } else {

        [self mapViewPointMoveToScreenCenter:_currentAnnotation.location duration:0.2];
    }
    
}

- (void)cleanAll
{
    if(_currentAnnotation!=nil)
        [self removeAnnotations];

    [self removeNavAnnotationsAndNavLine];
}

- (void)drawRoutes:(NSArray*)navigationInfo targetFloor:(NSString*)floor
{
    if(navigationInfo.count==0)
        return;
    
    NSDictionary *item = navigationInfo[0];

    //移除pin点
    if(_currentAnnotation!=nil) {
        [self removeAnnotations];
    }

    //调整视图
    [self reloadMapWithBuilding:Indoormap_BuildId
                       andFloor:item[@"floor"]];
    
    //绘制新的规划线路
    [self removeAnnotations];

    self.navStartImage      = [UIImage imageNamed:@"YCIndoorMap.bundle/map_start"];
    self.navEndImage        = [UIImage imageNamed:@"YCIndoorMap.bundle/map_end"];

    [self drawNavigationLine:(NSMutableArray*)navigationInfo floorId:floor];
}

#pragma mark - utilities

- (void)drawMyLocationIfNeeded
{
    if(_myLocation==nil) {
        [self removeMapViewLocationPoint];
        
    }

    if([_myLocation.floorID isEqualToString:self.floor]) {
        [self drawMobilePositioningPoint:CGPointMake(_myLocation.location_x, _myLocation.location_y)
                                AndBuild:Indoormap_BuildId
                                AndFloor:_myLocation.floorID
                       locationImageName:@"YCIndoorMap.bundle/foot_navi_direction_normal"];
    } else {
        [self removeMapViewLocationPoint];;
    }

}




@end
