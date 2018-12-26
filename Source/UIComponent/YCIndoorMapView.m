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

#define kColor_d3d3d3   UIColorFromRGB(0xd3d3d3)
#define kColor_E9E9E9   UIColorFromRGB(0xE9E9E9)
#define kColor_E7F1F9   UIColorFromRGB(0xE7F1F9)
#define kColor_FEBFD7   UIColorFromRGB(0xFEBFD7)
#define kColor_F8F6F2   UIColorFromRGB(0xF8F6F2)


#define kScale 1500

//self.millimetersPerPixel -> 就是zoomlevel，在scale为1500时，其范围是396~40
int zoomLevels[11] = {396,314,250,199,158,125,100,79,63,50,40};

@interface YCIndoorMapView()
{
    RTLbs3DAnnotation *_currentAnnotation;
    
    IbeaconLocation *_myLocation;
    
    int             zoomLevel;
    CGPoint         centerPoint;

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
}

#pragma mark - map
- (void) mapViewZoomLevelCriticalStraight:(NSInteger)zoom
{

}

- (void) mapViewDidTapOnMapPoint:(CGPoint)point poiName:(NSString*)poiName poiID:(NSString*)ID shapType:(NSInteger)type
{
    NSLog(@"松：didTapOnMapPoint type:%@",poiName);
    //电梯 7，问讯处 6，门 12，5
    RTLbs3DAnnotation * anno = [[RTLbs3DAnnotation alloc] initWithMapPoint:point
                                                                 annoTitle:poiName
                                                                    annoId:poiName
                                                                 iconImage:nil
                                                                   floorID:self.floor];
    
    if(_mapDidTap) _mapDidTap(anno);
}

- (UIView*)mapViewWithAnnotationPopView:(RTLbs3DAnnotation *)anno
{
    NSLog(@"松：mapViewWithAnnotationPopView");
    
    return nil;
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

    NSLog(@"松：mapViewLoadedSuccess");

}

//- (void) mapViewInflectionPoint:(RTLbs3DNavigationInfo*)inflection allDistance:(float)distance isEndPoi:(BOOL)endPoi
//{
//    NSLog(@"松：mapViewInflectionPoint %@ %lf %@",inflection, distance, endPoi?@"YES":@"NO");
//}

- (void) mapViewLoadedFailed:(RTLbsMapView*)rtmapView error:(NSString *)errorInfo
{
    if(_mapDidLoadFail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _mapDidLoadFail();
        });
    }
}

- (void)cleanAll
{
    if(_currentAnnotation!=nil)
        [self removeAnnotationWith:_currentAnnotation];

    [self removeNavAnnotationsAndNavLine];
}

- (void)drawRoutes:(NSArray*)navigationInfo targetFloor:(NSString*)floor
{
    if(navigationInfo.count==0)
        return;
    
    NSDictionary *item = navigationInfo[0];
    CGFloat navPoint_x = [item[@"navPoint_x"] floatValue];
    CGFloat navPoint_y = [item[@"navPoint_y"] floatValue];
    centerPoint  = CGPointMake(navPoint_x,navPoint_y);
    
    //移除pin点
    if(_currentAnnotation!=nil) {
        [self removeAnnotationWith:_currentAnnotation];
    }

    //调整视图
    [self reloadMapWithBuilding:Indoormap_BuildId
                       andFloor:item[@"floor"]];
    
    [self adjustView];
    
    if(_floorDidChange) _floorDidChange(item[@"floor"]);

    //绘制新的规划线路
    [self removeAnnotations];

    self.navStartImage      = [UIImage imageNamed:@"YCIndoorMap.bundle/map_start"];
    self.navEndImage        = [UIImage imageNamed:@"YCIndoorMap.bundle/map_end"];

    [self drawNavigationLine:(NSMutableArray*)navigationInfo floorId:floor];
}

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

- (void)drawMyLocation:(IbeaconLocation*)location
{
    _myLocation = location;

    [self drawMyLocationIfNeeded];
}

- (void)adjustToMyLocation
{
    //还未获取点
    if(_myLocation==nil)
        return;
    
    if(![self.floor isEqualToString:_myLocation.floorID]) {
        [self moveToMyLocation];

    } else {

        centerPoint = CGPointMake(_myLocation.location_x, _myLocation.location_y);
        
        [self adjustView];
    }
    
}

- (void)moveToMyLocation
{
    //还未获取点
    if(_myLocation==nil)
        return;

    //已移动到位 //stony debug ：出现一个问题，手动滑过了，怎么记录当前中心点？

    if([self.floor isEqualToString:_myLocation.floorID])
        return;

    centerPoint = CGPointMake(_myLocation.location_x, _myLocation.location_y);

    [self reloadMapWithBuilding:Indoormap_BuildId
                       andFloor:_currentAnnotation.annotationFloor];

    [self adjustView];

    if(_floorDidChange) _floorDidChange(_myLocation.floorID);
}

- (void)moveToPinAnnotatin
{
    if(_currentAnnotation==nil)
        return;
    
    centerPoint = _currentAnnotation.location;
    
    //已移动到位 //stony debug ：出现一个问题，手动滑过了，怎么记录当前中心点？
    if(![self.floor isEqualToString:_myLocation.floorID]) {
        [self reloadMapWithBuilding:Indoormap_BuildId
                           andFloor:_currentAnnotation.annotationFloor];

        if(_floorDidChange) _floorDidChange(_currentAnnotation.annotationFloor);
    }
    
    [self adjustView];

}


- (void)drawPinAnnotation:(RTLbs3DAnnotation*)annotation
{
    NSLog(@"松：drawPinAnnotation");

    if(_currentAnnotation!=nil)
        [self removeAnnotationWith:_currentAnnotation];

    _currentAnnotation = annotation;
    
    [self addAnnotation:annotation isShowPopView:YES setMapCenter:YES];
    
    centerPoint = annotation.location;

    if(![self.floor isEqualToString:annotation.annotationFloor]) {
        
        [self reloadMapWithBuilding:Indoormap_BuildId
                           andFloor:annotation.annotationFloor];
        
        if(_floorDidChange) _floorDidChange(annotation.annotationFloor);

    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self adjustView];
    });

}

- (void)reload:(NSString*)floor
{
    if([self.floor isEqualToString:floor])
        return;
    
    if(centerPoint.x == 0) {
        [self reloadMapWithBuilding:Indoormap_BuildId
                           andFloor:floor];
        
    } else {
        [self reloadMapWithBuilding:Indoormap_BuildId
                           andFloor:floor];
        
    }

    [self adjustView];
}

#pragma mark - utilities

- (void)adjustView
{

    if(zoomLevel==0 && centerPoint.x == 0) {
        return;

    } else if(zoomLevel==0 && centerPoint.x != 0) {
        [self setMapviewZoomLevel:3 duration:3];

    } else if(zoomLevel!=0 && centerPoint.x == 0) {
        [self setMapviewZoomLevel:3 duration:3];
        
    } else if(zoomLevel!=0 && centerPoint.x != 0) {
        [self setMapviewZoomLevel:3 duration:3];
    }
    
}

@end
