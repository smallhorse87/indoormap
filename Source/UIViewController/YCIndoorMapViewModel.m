//
//  YCIndoorMapViewModel.m
//  youngcity
//
//  Created by chenxiaosong on 2018/4/17.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import "YCIndoorMapViewModel.h"

#import "RTLbsMapView.h"
#import "RTLbs3DWebService.h"
#import "YCMapLocationService.h"
#import "RTLbs3DAnnotation.h"
#import "RTLbsLocPoiInfo.h"
#import "RTLbs3DNavigationInfo.h"

#import "RtmapApi.h"

#import "RealtimeGuide.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "ISWCategory.h"

@interface YCIndoorMapViewModel() <CBCentralManagerDelegate>
{
    RtmapApi    *_myapi;
    
    NSString    *_initedKeyword;
    NSString    *_initedFloor;
    
    NSArray     *_toiletPOIs;
    NSArray     *_elevatorPOIs;
    NSArray     *_escalatorPOIs;
    NSArray     *_stairPOIs;
    NSArray     *_informationPOIs;
    NSArray     *_gatePOIs;
    NSMutableDictionary *_POIsFloorDic;
    
    YCMapLocationService *locService;
    
    RTLbsMapView    *_mapView;
    
    //debug purpose
    IbeaconLocation *_currentSimulatingLocation;
    NSMutableArray  *_simulatingLocations;
    int             _simulatingLocIdx;
    
    CBCentralManager *_bluetoothManager;
    
    RealtimeGuide    *_realtimeGuide;
}

@property (nonatomic, strong) NSNumber   *ntReqPhase;
@property (nonatomic, strong) NSString   *ntReqPrompt;

@property (nonatomic, strong) NSArray   *floorArr;

@property (nonatomic, strong) NSArray   *quickPOIs;

@property (nonatomic, strong) IbeaconLocation *location;
@property (nonatomic, strong) NSString         *locationErrCode;

@property (nonatomic, strong) NSString    *currentFloor;

@property (nonatomic, strong) RTLbs3DAnnotation  *pinAnnotation;

@property (nonatomic, strong) RTLbs3DPOIMessageClass *retInitedPoiMsg;

@property (nonatomic, assign) YCGuideMode      guideMode;

@property (nonatomic, strong) NSArray          *navigationInfo;
@property (nonatomic, strong) NSString         *navigationInstruct;
@property (nonatomic, assign) BOOL             inDifferentBuilding;

@property (nonatomic, assign) BOOL             flagRealTimeGuidingTriggerred;
@property (nonatomic, strong) RTLbs3DAnnotation  *preEndAnnotation;
@property (nonatomic, strong) RTLbs3DAnnotation  *preStartAnnotation;

@property (nonatomic, assign) BOOL             blueToothEnabled;

@end

@implementation YCIndoorMapViewModel

- (instancetype)init
{
    self = [self initWithKeyword:nil floor:@"F1" map:nil];
    if (self) {
        NSAssert(NO, @"wrong call");
    }
    return self;
}

- (instancetype)initWithKeyword:(NSString*)keyword floor:(NSString*)floor map:(RTLbsMapView*)map
{
    self = [super init];
    if (self) {
        _myapi = [[RtmapApi alloc]init];

        _initedKeyword  = keyword;
        _initedFloor    = floor;
        
        if(isEmptyString(floor))
            _currentFloor   = @"F1";
        else
            _currentFloor   = floor;
        
        _mapView        = map;

        _guideMode      = YCGuideModeInit;
        
        _POIsFloorDic = [[NSMutableDictionary alloc] init];
        
        [self setupBluetoothManager];

        //stony debug begin
        _currentSimulatingLocation = [[IbeaconLocation alloc] init];
        _currentSimulatingLocation.floorID    = @"F1";
        _currentSimulatingLocation.location_x = 117.0969375;
        _currentSimulatingLocation.location_y = -78.134500000000003;
        //debug end
        
        [self startLocating];
        

    }
    return self;
}


- (void)onSelectedFloorChanged:(NSString*)floor
{
    self.currentFloor = floor;
}

- (void)onSearchedPinAnnotationChanged:(RTLbs3DAnnotation*)searchedPoint
{
    self.pinAnnotation = searchedPoint;
}

- (void)onQuitGuideCmd
{
    [self onGuideModeState:YCGuideModeInit];
}

- (void)onStartGuidingCmd
{
    if(_location != nil)
    {
        [self onRoutePlanReq];
    }
    else
    {
        [self ntRequesting];
        
        WEAKSELF

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(_location!=nil) {
                [weakSelf onRoutePlanReq];
            } else {
                //stony debug [weakSelf ntRequestFail:LocalErr(@"定位失败，换个地方试试。")];
            }
        });
    }
    
}

- (void)onTappedPointChanged:(RTLbs3DAnnotation*)tappedPoint
{

    if(isEmptyString(tappedPoint.annoTitle)) {
        self.pinAnnotation = nil;

    } else {
        if(tappedPoint.location.x==_pinAnnotation.location.x &&
           tappedPoint.location.y==_pinAnnotation.location.y)
        {
            self.pinAnnotation = nil;
        }
        else
        {
            self.pinAnnotation = tappedPoint;
        }
    }

}

- (void)onInitSearchReq
{
    if(isEmptyString(_initedKeyword))
        return;

    WEAKSELF

    _myapi = [[RtmapApi alloc]init];

    [_myapi requestPOIsWithkeyword:_initedKeyword
                           buildId:Bodimall_BuildId
                             floor:_initedFloor
    sucBlock:^(NSArray *poiArr)
    {
        if(poiArr==nil || poiArr.count == 0 ) {
            return;
        }

        weakSelf.retInitedPoiMsg = poiArr[0];
        
    }
    failBlock:^(NSString *error){

    }];

    //用完即丢，只用一次
    _initedKeyword = nil;
    _initedFloor   = nil;

}

- (void)onQuickPOIsReq
{
    if([_POIsFloorDic objectForKey:_currentFloor] != nil)
        return;

    //清空
    [self resetQuickPOIs];

    [self searchToiletPOI];
    [self searchElevatorPOI];
    [self searchEscalatorPOI];
    [self searchStairPOI];
    [self searchGatePOI];
    [self searchInformationPOI];
}

- (void)onFetchContinuousLocReq
{
    if(_location != nil)
        return;

    [self ntRequesting];
    
    WEAKSELF

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(_location==nil) {
            //stony debug [weakSelf ntRequestFail:LocalErr(@"定位失败，换个地方试试。")];
        } else {
            //stony debug [weakSelf ntRequestSuc:@"定位成功。"];
        }
    });

}

- (void)onFloorInfosReq
{
    NSArray *floorArr = nil;//stony debug [AppContext retriveFloorList:Bodimall_BuildId];
    
    if(floorArr.count!=0) {
        self.floorArr = floorArr;
        return;
    }
    
    WEAKSELF
    
    static RtmapApi *floorsApi;
    
    floorsApi = [[RtmapApi alloc]init];
    
    [floorsApi requestFloorInfo:^(NSArray *floors) {
        
        NSMutableArray *floorArr = [[NSMutableArray alloc] init];

        for(NSDictionary *floorInfo in floors) {
            [floorArr addObject:floorInfo[@"floor"]];
        }

        weakSelf.floorArr = floorArr;
        floorsApi = nil;

        //stony debug [AppContext cacheFloorList:Bodimall_BuildId floorArr:floorArr];

    } fail:^(NSString *error) {
        floorsApi = nil;
        
    }];
}

- (void)onNextSimualtingLocationReq
{
    if(_simulatingLocations==nil)
        return;

    if(_simulatingLocIdx<_simulatingLocations.count) {
        _currentSimulatingLocation = _simulatingLocations[_simulatingLocIdx];
        _simulatingLocIdx++;
    } else {
        _currentSimulatingLocation = _simulatingLocations.lastObject;
    }

}

#pragma mark - route plan

- (void)onRoutePlanReq
{
    if(_location==nil) {
        return;
    }

    [self ntRequesting];
    
    //操作地图
    RTLbs3DAnnotation* myLocationAnnotation = [self locationToAnnotation:_location];

    [_mapView mapViewNavgationStartPoint:myLocationAnnotation.location
                              buildingID:Bodimall_BuildId
                                 floorID:[myLocationAnnotation.annotationFloor uppercaseString]
                                delegate:self];
    
    [_mapView mapViewNavgationEndPoint:_pinAnnotation.location
                            buildingID:Bodimall_BuildId
                               floorID:[_pinAnnotation.annotationFloor uppercaseString]
                              delegate:self];
    
}

- (void) navigationRequestFail:(NSString *)error
{
    //stony debug [self ntRequestFail:LocalErr(error)];
}

- (void) navigationRequestFinish:(NSMutableArray*)navigationInfo
       navigationRountInflection:(NSMutableArray*)InflectionArrays
               routeStringArrays:(NSMutableArray*)routeString
                   poiIndexArray:(NSMutableArray *)poiIndexArray
                   totalDistance:(NSString*)distance
{
    [self ntRequestSuc:@"路线规划成功"];
    
    self.navigationInfo = navigationInfo;
    
    _realtimeGuide = [[RealtimeGuide alloc] initWithKeyNavigationInfo:InflectionArrays];
    
    [_realtimeGuide addObserver:self forKeyPath:@"navigationInstruct" options:NSKeyValueObservingOptionNew context:nil];
    
    self.inDifferentBuilding    = [_realtimeGuide pass3rdFloorPlatform:navigationInfo];
    
    //切换到预备导航模式
    [self onGuideModeState:YCGuideModeRealtimeGuiding];
    
    [self navigationInfoToSimulatingLocations:navigationInfo];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context
{
    if ([keyPath isEqualToString:@"navigationInstruct"]){
        self.navigationInstruct = _realtimeGuide.navigationInstruct;
    }
}
    
#pragma mark - utilities
- (void)searchToiletPOI
{
    NSString *keyword = @"卫生间";

    WEAKSELF
    
    static RtmapApi *poiapi;
    poiapi = [[RtmapApi alloc]init];

    [poiapi requestPOIsWithkeyword:keyword
                          buildId:Bodimall_BuildId
                            floor:_currentFloor
                         sucBlock:^(NSArray * poiArr)
     {
         [weakSelf catQuickPOIs:poiArr keyword:keyword];

         poiapi = nil;
         
     } failBlock:^(NSString *error){
         
         poiapi = nil;

     }];
}

- (void)searchElevatorPOI
{
    NSString *keyword = @"电梯";
    
    WEAKSELF
    
    static RtmapApi *poiapi;
    poiapi = [[RtmapApi alloc]init];
    
    [poiapi requestPOIsWithkeyword:keyword
                           buildId:Bodimall_BuildId
                             floor:_currentFloor
                          sucBlock:^(NSArray * poiArr)
     {
         [weakSelf catQuickPOIs:poiArr keyword:keyword];
         
         poiapi = nil;
         
     } failBlock:^(NSString *error){
         
         poiapi = nil;
         
     }];
}

- (void)searchEscalatorPOI
{
    NSString *keyword = @"自动扶梯";

    WEAKSELF
    
    static RtmapApi *poiapi;
    poiapi = [[RtmapApi alloc]init];
    
    [poiapi requestPOIsWithkeyword:keyword
                           buildId:Bodimall_BuildId
                             floor:_currentFloor
                          sucBlock:^(NSArray * poiArr)
     {
         [weakSelf catQuickPOIs:poiArr keyword:keyword];
         
         poiapi = nil;
         
     } failBlock:^(NSString *error){
         
         poiapi = nil;
         
     }];
}

- (void)searchStairPOI
{
    NSString *keyword = @"楼梯";
    
    WEAKSELF
    
    static RtmapApi *poiapi;
    poiapi = [[RtmapApi alloc]init];
    
    [poiapi requestPOIsWithkeyword:keyword
                           buildId:Bodimall_BuildId
                             floor:_currentFloor
                          sucBlock:^(NSArray * poiArr)
     {
         [weakSelf catQuickPOIs:poiArr keyword:keyword];
         
         poiapi = nil;
         
     } failBlock:^(NSString *error){
         
         poiapi = nil;
         
     }];
}

- (void)searchGatePOI
{
    NSString *keyword = @"出入口";
    
    WEAKSELF
    
    static RtmapApi *poiapi;
    poiapi = [[RtmapApi alloc]init];
    
    [poiapi requestPOIsWithkeyword:keyword
                           buildId:Bodimall_BuildId
                             floor:_currentFloor
                          sucBlock:^(NSArray * poiArr)
     {
         [weakSelf catQuickPOIs:poiArr keyword:keyword];
         
         poiapi = nil;
         
     } failBlock:^(NSString *error){
         
         poiapi = nil;
         
     }];
}

- (void)searchInformationPOI
{
    NSString *keyword = @"服务台";

    WEAKSELF
    
    static RtmapApi *poiapi;
    poiapi = [[RtmapApi alloc]init];
    
    [poiapi requestPOIsWithkeyword:keyword
                           buildId:Bodimall_BuildId
                             floor:_currentFloor
                          sucBlock:^(NSArray * poiArr)
     {
         [weakSelf catQuickPOIs:poiArr keyword:keyword];
         
         poiapi = nil;
         
     } failBlock:^(NSString *error){
         
         poiapi = nil;
         
     }];
}

- (void)catQuickPOIs:(NSArray*)POIs keyword:(NSString*)keyword
{
    if([keyword isEqualToString:@"卫生间"]) {
        _toiletPOIs   = (POIs==nil) ? @[] : POIs;
        
    } else if ([keyword isEqualToString:@"电梯"]) {
        _elevatorPOIs = (POIs==nil) ? @[] : POIs;

    } else if ([keyword isEqualToString:@"自动扶梯"]) {
        _escalatorPOIs = (POIs==nil) ? @[] : POIs;
        
    } else if ([keyword isEqualToString:@"楼梯"]) {
        _stairPOIs = (POIs==nil) ? @[] : POIs;
        
    } else if ([keyword isEqualToString:@"出入口"]) {
        _gatePOIs = (POIs==nil) ? @[] : POIs;
        
    } else if ([keyword isEqualToString:@"服务台"]) {
        _informationPOIs = (POIs==nil) ? @[] : POIs;
        
    } else {
        return;
    }

    //当集齐了6种类型poi，就赋值
    if(_toiletPOIs!=nil &&
       _elevatorPOIs!=nil &&
       _escalatorPOIs!=nil &&
       _stairPOIs!=nil &&
       _gatePOIs!=nil &&
       _informationPOIs!=nil)
    {
        
        NSMutableArray *catArr  = [[NSMutableArray alloc] initWithArray:_toiletPOIs];
        [catArr addObjectsFromArray:_elevatorPOIs];
        [catArr addObjectsFromArray:_escalatorPOIs];
        [catArr addObjectsFromArray:_stairPOIs];
        [catArr addObjectsFromArray:_gatePOIs];
        [catArr addObjectsFromArray:_informationPOIs];

        self.quickPOIs = catArr;
        
        [_POIsFloorDic setObject:@"YES" forKey:_currentFloor];
    }

}

- (void)resetQuickPOIs
{
    _toiletPOIs      = nil;
    _elevatorPOIs    = nil;
    _escalatorPOIs   = nil;
    _stairPOIs       = nil;
    _gatePOIs        = nil;
    _informationPOIs = nil;

    self.quickPOIs = nil;
}

#pragma mark - 导航模式状态机
- (void)onGuideModeState:(YCGuideMode)mode
{
    switch (mode) {
        case YCGuideModeInit:
            _pinAnnotation = nil;
            _navigationInfo   = nil;
            _navigationInstruct    = nil;
            _inDifferentBuilding   = NO;
            break;
            

        case YCGuideModeRealtimeGuiding:
            _flagRealTimeGuidingTriggerred = YES;
            break;
            
        default:
            break;
    }
    
    self.guideMode = mode;
}

- (RTLbs3DAnnotation*)locationToAnnotation:(IbeaconLocation*)loc
{
    if(loc==nil)
        return nil;

    CGPoint pt = CGPointMake(loc.location_x, loc.location_y);
    
    RTLbs3DAnnotation * anno = [[RTLbs3DAnnotation alloc] initWithMapPoint:pt
                                                                 annoTitle:@"我的位置"
                                                                    annoId:@"我的位置"
                                                                 iconImage:nil
                                                                   floorID:loc.floorID];

    return anno;
}

- (void)navigationInfoToSimulatingLocations:(NSArray*)navInfos
{
    _simulatingLocations = [[NSMutableArray alloc] init];
    _simulatingLocIdx    = 0;
    
    for(NSDictionary *item in navInfos) {
        CGFloat navPoint_x = [item[@"x"] floatValue];
        CGFloat navPoint_y = [item[@"y"] floatValue];
        NSString *floor    = item[@"floor"];
        
        IbeaconLocation *location = [[IbeaconLocation alloc] init];
        location.floorID    = floor;
        location.location_x = navPoint_x;
        location.location_y = navPoint_y;
        
        [_simulatingLocations addObject:location];
    }
}

#pragma mark - utilities
- (void)ntRequesting
{
    self.ntReqPrompt = nil;
    //stony debug self.ntReqPhase  = @(NtPhaseRequesting);
}

- (void)ntRequestSuc:(NSString*)str
{
    self.ntReqPrompt = str;
    //stony debug self.ntReqPhase  = @(NtPhaseResponseSuc);
}

- (void)ntRequestFail:(NSError *)err
{
    if (err.code==-1009) {
        self.ntReqPrompt = @"网络未连接";
        //stony debug self.ntReqPhase  = @(NtPhaseNoConnection);
    } else if(err.code<0) {
        self.ntReqPrompt = @"网络连接超时";
        //stony debug self.ntReqPhase  = @(NtPhaseConnectionTimeout);
    } else {
        self.ntReqPrompt = err.domain;
        //stony debug self.ntReqPhase  = @(NtPhaseResponseFail);
    }
    
}

-(void)setupBluetoothManager
{
    if (_bluetoothManager == nil) {
        _bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            self.blueToothEnabled = YES;
            break;

        case CBCentralManagerStatePoweredOff:
        case CBCentralManagerStateResetting:
        case CBCentralManagerStateUnauthorized:
        case CBCentralManagerStateUnknown:
        case CBCentralManagerStateUnsupported:
            self.blueToothEnabled = NO;
            break;

        default:
            break;
    }
}

- (void)startLocating
{
    WEAKSELF
    
    if(locService==nil) {
        locService =
        [[YCMapLocationService alloc] init];
    }
    
    [locService start:
     ^(IbeaconLocation *location) {
         weakSelf.location = location;
         
         if(_guideMode != YCGuideModeRealtimeGuiding)
             return;

//         [_realtimeGuide checkApproachingKeyNavInfo:_location];
         
     } failure:^(NSError *error) {
//         static int dbg_retry_times = 0;
//
//         if(dbg_retry_times>=6){
//             //[weakSelf ntRequestSuc:@"定位成功。"];
//
             weakSelf.location = _currentSimulatingLocation;

             if(_guideMode != YCGuideModeRealtimeGuiding)
                 return;

         NSLog(@"松松：%@", [_realtimeGuide retTxtGuide:_location]);
//
//         } else {
//
//             weakSelf.location = nil;
//             self.locationErrCode = error.domain;
//
//
//             dbg_retry_times++;
//
//         }
         
     }];
}

@end

