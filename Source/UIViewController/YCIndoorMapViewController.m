//
//  YCIndoorMapViewController.m
//  youngcity
//
//  Created by chenxiaosong on 2018/4/17.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import "YCIndoorMapViewController.h"

#import "IndoorMapContext.h"
#import "KVOController.h"
#import "YCIndoorMapViewModel.h"

#import "ISWCategory.h"
#import "ISWToast.h"

#import "YCFloorPicker.h"
#import "YCPinNavBar.h"
#import "YCPinBottomView.h"
#import "YCIndoorMapView.h"
#import "YCGuidingNavBar.h"
#import "YCGuidingBottomView.h"
#import "YCIndoorMapPrompt.h"
#import "YCNoBlueToothView.h"

//地图相关
#import "RTLbs3DAnnotation.h"
#import "YCMapLocationService.h"
#import "RTLbs3DPOIMessageClass.h"

#import "YCIndoorSearchViewController.h"

#import <Masonry.h>

@interface YCIndoorMapViewController ()<UINavigationControllerDelegate>
{
    YCFloorPicker       *_floorPickView;
    YCPinNavBar         *_pinNavBar;
    YCPinBottomView     *_pinBottomView;
    YCGuidingNavBar     *_guidingNavBar;
    YCGuidingBottomView *_guidingBottomView;
    YCNoBlueToothView   *_noBlueToothView;
    UILabel             *_mapLoadToast;
    UILabel             *_floorIndicator;
    UIView              *_floorIndicatorBg;
    UIButton            *_toLocateBtn;
}

@property (nonatomic,strong) YCIndoorMapViewModel   *viewModel;

@property (nonatomic,strong) YCIndoorMapView        *mapView;

@end

@implementation YCIndoorMapViewController

#pragma mark - viewcontroller life cycle

- (instancetype)initWithKeyword:(NSString*)keyword floor:(NSString*)floor
{
    self = [super init];

    if (self) {
        [self bindWithViewModel:keyword floor:floor];
    }

    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    self.view.backgroundColor = kColorPageBg;

    [self bindWithViewModel:nil floor:nil];

    //构建视图
    [self buildIndoorMap];
    [self buildGuidingNavBar];
    [self buildGuidingBottomView];
    [self buildSimulatingLocBtn];
    [self buildPinNavBar];
    [self buildLeftToolBar];
    [self buildPinBottomView];
    [self buildMapLoadToast];
    [self buildNoBlueToothView];

    //按情况显示视图
    [self showUIs];

    //初始请求
    [_viewModel onFloorInfosReq];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - bind with viewmodel

- (void)bindWithViewModel:(NSString*)keyword floor:(NSString*)floor
{
    if(self.viewModel)
        return;

    self.viewModel = [[YCIndoorMapViewModel alloc] initWithKeyword:keyword floor:floor map:self.mapView];

    WEAKSELF
    FBKVOController *KVOController = [FBKVOController controllerWithObserver:self];
    self.KVOController = KVOController;
    [self.KVOController observe:self.viewModel
                       keyPaths:@[@"ntReqPhase",
                                  @"floorArr",
                                  @"retInitedPoiMsg",
                                  @"location",
                                  @"pinAnnotation",
                                  @"guideMode",
                                  @"navigationInstruct",
                                  @"blueToothEnabled"]
                        options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                          block:
     ^(id observer, YCIndoorMapViewModel *viewModel, NSDictionary *change) {
         
         NSString *key = [change objectForKey:@"FBKVONotificationKeyPathKey"];

         if([key isEqualToString:@"ntReqPhase"]) {
             [weakSelf popToast:[viewModel.ntReqPhase unsignedIntegerValue] title:viewModel.ntReqPrompt];

         } else if ([key isEqualToString:@"floorArr"]) {
             [weakSelf floorArrValueUpdated];
   
         } else if ([key isEqualToString:@"location"]) {
             [weakSelf locationValueUpdated];
             
         } else if ([key isEqualToString:@"retInitedPoiMsg"]) {
             [weakSelf retInitedPoiMsgValueUpdated];

         } else if ([key isEqualToString:@"pinAnnotation"]) {
             [weakSelf pinAnnotationValueUpdated];

         } else if ([key isEqualToString:@"guideMode"]) {
             [weakSelf guideModeValueUpdated];
             
         } else if ([key isEqualToString:@"navigationInstruct"]) {
             [weakSelf navigationInstructValueUpdated];
             
         } else if ([key isEqualToString:@"blueToothEnabled"]) {
             [weakSelf blueToothEnabledValueUpdated];

         }
         
     }];
}

#pragma mark - build UI
- (void)buildSimulatingLocBtn
{
    UIButton *simulatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [simulatingBtn isw_titleForAllState:@"下一个点"];
    simulatingBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [simulatingBtn isw_titleColorForAllState:kColorBlack];
    [simulatingBtn isw_addClickAction:@selector(testTrackingBtnPressed) target:self];
    [self.view addSubview:simulatingBtn];
    [simulatingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@60);
        make.height.equalTo(@44);
        make.trailing.equalTo(self.view);
        if (@available(iOS 11.0, *))
        {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-90);
        }
        else
        {
            make.bottom.equalTo(self.view).offset(-90);
        }
    }];
}

- (void)buildGuidingNavBar
{
    WEAKSELF

    _guidingNavBar = [[YCGuidingNavBar alloc] init];
    [self.view addSubview:_guidingNavBar];
    [_guidingNavBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(weakSelf.view).offset(10);
        if (@available(iOS 11.0, *))
        {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }
        else
        {
            make.top.equalTo(weakSelf.view).offset(20);
        }
        
        make.height.width.equalTo(@(44));
    }];

    _guidingNavBar.backBtnClicked = ^{
        [weakSelf quitGuideModeBtnPressed];
    };
    
    _guidingNavBar.hidden = YES;

}

- (void)buildIndoorMap
{
    [self.view addSubview:self.mapView];
}

- (void)buildGuidingBottomView
{
    WEAKSELF

    _guidingBottomView = [[YCGuidingBottomView alloc] init];
    [self.view addSubview:_guidingBottomView];
    [_guidingBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(weakSelf.view).offset(12);
        make.trailing.equalTo(weakSelf.view).offset(-12);
        make.bottom.equalTo(weakSelf.view).offset(-11);
        
        if (@available(iOS 11.0, *))
        {
            make.bottom.equalTo(weakSelf.view.mas_safeAreaLayoutGuideBottom).offset(-11);
        }
        else
        {
            make.bottom.equalTo(weakSelf.view).offset(-11);
        }
        
        make.height.equalTo(@(77));
    }];

    _guidingBottomView.hidden = YES;
}

- (void)buildPinNavBar
{
    WEAKSELF

    //搜索输入框
    _pinNavBar = [[YCPinNavBar alloc] init];
    [self.view addSubview:_pinNavBar];
    [_pinNavBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(weakSelf.view).offset(12);
        make.trailing.equalTo(weakSelf.view).offset(-12);
        if (@available(iOS 11.0, *))
        {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }
        else
        {
            make.top.equalTo(weakSelf.view).offset(20);
        }
        make.height.equalTo(@(44));
    }];

    _pinNavBar.searchBtnClicked = ^{
        [weakSelf pickingForPinAnnotationBtnPressed];
    };
    
    _pinNavBar.backBtnClicked = ^{
        [weakSelf navBackBtnPressed];
    };

}

- (void)buildLeftToolBar
{
    _toLocateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _toLocateBtn.backgroundColor     = kColorWhite;
    _toLocateBtn.layer.cornerRadius  = kLargeCorner;
    _toLocateBtn.layer.borderColor   = kOutlineColor.CGColor;
    _toLocateBtn.layer.borderWidth   = 1;
    _toLocateBtn.layer.shadowOffset  =  CGSizeMake(0, 1);
    _toLocateBtn.layer.shadowOpacity =  0.5;
    _toLocateBtn.layer.shadowColor   =  kColor_B6B6B6.CGColor;
    [_toLocateBtn setImage:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_location_default"] forState:UIControlStateNormal];
    [_toLocateBtn isw_addClickAction:@selector(toolbarLocationBtnPressed) target:self];
    [self.view addSubview:_toLocateBtn];
    [_toLocateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(12);
        if (@available(iOS 11.0, *))
        {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-130);
        }
        else
        {
            make.bottom.equalTo(self.view).offset(-130);
        }
        make.width.height.equalTo(@(42));
    }];

    WEAKSELF

    _floorPickView = [[YCFloorPicker alloc]init];
    _floorPickView.floorPickerClicked = ^(NSString *floor) {
        [weakSelf pickerFloorDidChange:floor];
    };
    [self.view addSubview:_floorPickView];
    [_floorPickView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(12);
        make.bottom.equalTo(_toLocateBtn.mas_top).offset(-11);
        make.height.equalTo(@168);
        make.width.equalTo(@42);
    }];
    
    _floorIndicatorBg = [[UIView alloc] initWithFrame:CGRectZero];
    _floorIndicatorBg.backgroundColor    = kColorWhite;
    _floorIndicatorBg.layer.cornerRadius = kLargeCorner;
    _floorIndicatorBg.layer.borderColor  = kOutlineColor.CGColor;
    _floorIndicatorBg.layer.borderWidth  = 1;
    _floorIndicatorBg.clipsToBounds       =  NO;
    _floorIndicatorBg.layer.shadowOffset  =  CGSizeMake(0, 1);
    _floorIndicatorBg.layer.shadowOpacity =  0.5;
    _floorIndicatorBg.layer.shadowColor   =  kColor_B6B6B6.CGColor;
    [self.view addSubview:_floorIndicatorBg];
    [_floorIndicatorBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(12);
        make.bottom.equalTo(_toLocateBtn.mas_top).offset(-11);
        make.width.height.equalTo(@42);
    }];
    
    _floorIndicator           = [[UILabel alloc] init];
    _floorIndicator.textColor = kColorMajorMap;
    _floorIndicator.font      = [UIFont isw_Pingfang:13 weight:UIFontWeightSemibold];
    _floorIndicator.textAlignment = NSTextAlignmentCenter;
    _floorIndicator.numberOfLines = 1;
    [_floorIndicatorBg addSubview:_floorIndicator];
    [_floorIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(_floorIndicatorBg);
    }];

    _floorIndicator.text = @"";
}

- (void)buildPinBottomView
{
    WEAKSELF

    _pinBottomView = [[YCPinBottomView alloc] init];
    [self.view addSubview:_pinBottomView];
    [_pinBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(weakSelf.view).offset(12);
        make.trailing.equalTo(weakSelf.view).offset(-12);
        if (@available(iOS 11.0, *))
        {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-11);
        }
        else
        {
            make.bottom.equalTo(self.view).offset(-11);
        }
        make.height.equalTo(@109);
    }];

    _pinBottomView.toGuideSettingBtnClicked = ^{
        [weakSelf realtimeGuideBtnPressed];
    };
    
    _pinBottomView.addressBtnClicked = ^{
        [weakSelf pinAddressBtnPressed];
    };
}

- (void)buildMapLoadToast
{
    _mapLoadToast = [[UILabel alloc] init];
    _mapLoadToast.backgroundColor = kColorBlack;
    _mapLoadToast.clipsToBounds       = YES;
    _mapLoadToast.layer.cornerRadius  = kLargeCorner;
    _mapLoadToast.alpha           = 0.68;
    _mapLoadToast.textColor       = kColorWhite;
    _mapLoadToast.font            = [UIFont isw_Pingfang:28];
    _mapLoadToast.textAlignment   = NSTextAlignmentCenter;
    _mapLoadToast.numberOfLines   = 1;
    [self.view addSubview:_mapLoadToast];
    [_mapLoadToast mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.centerX.equalTo(self.view);
        make.width.height.equalTo(@60);
    }];
    _mapLoadToast.hidden = YES;
    _mapLoadToast.text = @"";
}

- (void)buildNoBlueToothView
{
    _noBlueToothView = [[YCNoBlueToothView alloc] init];
    
    [self.view addSubview:_noBlueToothView];
    [_noBlueToothView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.view);
    }];

}

#pragma mark - update UI
- (void)lostLocationSignal
{
    [_toLocateBtn setImage:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_location_default"] forState:UIControlStateNormal];
}

- (void)receiveLocationSignal
{
    [_toLocateBtn setImage:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_location_selected"] forState:UIControlStateNormal];
}

#pragma mark - pop/dismiss UI

- (void)popNoBlueToothView
{
    [_noBlueToothView show];
}

- (void)dismissNoBlueToothView
{
    [_noBlueToothView dismiss];
}

- (void)popMapLoadToast:(NSString*)txt
{
    _mapLoadToast.text   = txt;
    _mapLoadToast.hidden = NO;

    static NSTimer  *toastTimer;
    [toastTimer invalidate];
    toastTimer = [NSTimer timerWithTimeInterval:1.2 target:self selector:@selector(dismissMapLoadToast) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop]addTimer:toastTimer forMode:NSRunLoopCommonModes];

}

- (void)dismissMapLoadToast
{
    _mapLoadToast.hidden = YES;
}

- (void)popIndoorMapPrompt
{
    WEAKSELF

    YCIndoorMapPrompt *indoorMapPrompt = [[YCIndoorMapPrompt alloc] init];
    
    [self.view addSubview:indoorMapPrompt];
    [indoorMapPrompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(weakSelf.view).offset(12);
        make.trailing.equalTo(weakSelf.view).offset(-12);
        make.top.equalTo(_pinNavBar.mas_bottom).offset(15);
        make.height.equalTo(@50);
    }];
}

- (void)popCommentAlert
{
    //提示进行评论
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"谈谈您对广场导航的评价"
                                                                             message:@"您的反馈对我们改进产品帮助很大。"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"去评价"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action)
    {
        [self commentBtnPressed];
    }];
    [alertController addAction:cancelAction];
    
    UIAlertAction *confirmActions = [UIAlertAction actionWithTitle:@"下次再说"
                                                             style:UIAlertActionStyleDestructive
                                                           handler:^(UIAlertAction *action)
    {
        [self navBack];
    }];
    [alertController addAction:confirmActions];

    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)popToast:(YcNtPhaseType)type title:(NSString*)title
{
    switch (type) {
        case YcNtPhaseNone:
            [ISWToast dismissToast];
            break;

        case YcNtPhaseResponseSuc:
            [ISWToast dismissToast];
            break;

        case YcNtPhaseConnectionTimeout:
        case YcNtPhaseNoConnection:
        case YcNtPhaseResponseFail:
            [ISWToast showFailToast:title];
            break;

        case YcNtPhaseRequesting:
            [ISWToast showLoadingToast];
            break;

        default:
            break;
    }
}

- (void)popInDifferentBuildingAlert
{
    WEAKSELF

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"当经过3楼露天平台时，信号将会会暂时丢失，进入馆内自动重新定位。" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];

    UIAlertAction *confirmActions = [UIAlertAction actionWithTitle:@"确定"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action)
    {
        [weakSelf confirmToRealtimeGuideBtnPressed];
    }];
    [alertController addAction:confirmActions];

    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)popGuidingBottomView
{
    _guidingBottomView.hidden = NO;
}

- (void)dismissGuidingBottomView
{
    _guidingBottomView.hidden = YES;
}

- (void)popGuidingNavBar
{
    _guidingNavBar.hidden = NO;
}

- (void)dismissGuidingNavBar
{
    _guidingNavBar.hidden = YES;
}

- (void)popPinNavBar
{
    _pinNavBar.hidden = NO;
}

- (void)dismissPinNavBar
{
    _pinNavBar.hidden = YES;
}

- (void)dismissPinBottomView
{
    _pinBottomView.hidden = YES;
}

- (void)popPinBottomView
{
    _pinBottomView.hidden = NO;
}

- (void)popFloorIndicator
{
    _floorIndicatorBg.hidden = NO;
}

- (void)dismissFloorIndicator
{
    _floorIndicatorBg.hidden = YES;
}

- (void)popFloorPickView
{
    _floorPickView.hidden = NO;
}

- (void)dismissFloorPickView
{
    _floorPickView.hidden = YES;
}



#pragma mark - ui event

- (void)commentBtnPressed
{
    [self navToComment];
    [IndoorMapContext setMapCommented];
}

- (void)testTrackingBtnPressed
{
    [_viewModel onNextSimualtingLocationReq];
}

- (void)toolbarLocationBtnPressed
{
    if(_viewModel.blueToothEnabled)
    {
        if(_viewModel.location) {
            [_mapView moveToMyLocation];
        } else {
            [_viewModel onFetchContinuousLocReq];
        }

    }
    else
    {
        [self popNoBlueToothView];
    }

}

- (void)navBackBtnPressed
{

    if([self pendingForComment]){
        [self popCommentAlert];
    } else {
        [self navBack];
    }
    
}

- (void)mapDidTap:(RTLbs3DAnnotation*)tappedAnnotation
{
    if(_viewModel.guideMode==YCGuideModeRealtimeGuiding)
        return;

    tappedAnnotation.iconImage = [UIImage imageNamed:@"YCIndoorMap.bundle/icon_poi"];
    [_viewModel onTappedPointChanged:tappedAnnotation];
}

- (void)mapDidLoadSuc
{
    [_viewModel onInitSearchReq];

    [self popMapLoadToast:_mapView.floor];
    
    [_floorPickView changeToFloor:_mapView.floor];

    _floorIndicator.text = _mapView.floor;
}

- (void)mapDidLoadFail
{
    [self popMapLoadToast:@"地图加载失败"];
}

- (void)pickerFloorDidChange:(NSString*)floor
{
    [_mapView reload:floor];
    _floorIndicator.text = floor;
}

- (void)confirmToRealtimeGuideBtnPressed
{
    [_viewModel onStartGuidingCmd];
}

- (void)realtimeGuideBtnPressed
{
    if(_viewModel.pinAnnotation==nil)
        return;
    
    [_viewModel onStartGuidingCmd];
    
}

- (void)pickingForPinAnnotationBtnPressed
{
    WEAKSELF

    [self navToSearch:nil
             poiBlock:
         ^(RTLbs3DPOIMessageClass *info)
         {
             RTLbs3DAnnotation *anno = [self buildAnnotationWithPOIWithMsg:info];
             anno.iconImage = [UIImage imageNamed:@"YCIndoorMap.bundle/icon_poi"];
             [weakSelf.viewModel onSearchedPinAnnotationChanged:anno];
         }];

}

- (void)quitGuideModeBtnPressed
{
    [_viewModel onQuitGuideCmd];
}

- (void)pinAddressBtnPressed
{
    if(_viewModel.pinAnnotation==nil)
        return;

    [_mapView moveToPinAnnotatin];
}

#pragma mark - viewmodel event

- (void)navigationInstructValueUpdated
{
    if(_viewModel.guideMode!=YCGuideModeRealtimeGuiding)
        return;

    [_guidingBottomView updateContent:_viewModel.navigationInstruct];

}

- (void)guideModeValueUpdated
{
    [self showUIs];

    switch (_viewModel.guideMode) {
        case YCGuideModeRealtimeGuiding:
            [_mapView drawRoutes:_viewModel.navigationInfo
                     targetFloor:_viewModel.location.floorID];

            break;

        case YCGuideModeInit:
            [_pinBottomView cleanContent];
            [_mapView cleanAll];
            break;

        default:
            break;
    }
}

- (void)pinAnnotationValueUpdated
{
    if(_viewModel.pinAnnotation)
    {
        [_pinBottomView setupContent:_viewModel.pinAnnotation.annoTitle
                               floor:_viewModel.pinAnnotation.annotationFloor];
        
        [_mapView drawPinAnnotation:_viewModel.pinAnnotation];

        [_floorPickView changeToFloor:_viewModel.pinAnnotation.annotationFloor];
    }
    else
    {
        [_pinBottomView cleanContent];
        [_mapView cleanAll];
    }

}

- (void)retInitedPoiMsgValueUpdated
{
    RTLbs3DAnnotation *anno = [self buildAnnotationWithPOIWithMsg:_viewModel.retInitedPoiMsg];
    anno.iconImage = [UIImage imageNamed:@"YCIndoorMap.bundle/icon_poi"];

    [_viewModel onSearchedPinAnnotationChanged:anno];
}

- (void)locationValueUpdated
{
    [_mapView drawMyLocation:_viewModel.location];

    [_floorPickView locateToFloor:_viewModel.location.floorID];

    //实时导航过程中，如果走到了其他楼层，则切换地图
    if(_viewModel.guideMode == YCGuideModeRealtimeGuiding
       && _viewModel.location != nil
       && ![_mapView.floor isEqualToString:_viewModel.location.floorID]
       )
    {
        [_mapView moveToMyLocation];
    }

    if(_viewModel.location!=nil){
        [self receiveLocationSignal];
    } else {
        [self lostLocationSignal];
    }
    
}

- (void)floorArrValueUpdated
{
    [_floorPickView setupContent:_viewModel.floorArr
                    defaultFloor:@"F1"];
}

- (void)blueToothEnabledValueUpdated
{
    //启动定位
    if(_viewModel.blueToothEnabled == YES && _noBlueToothView.hidden == NO) {
        [self dismissNoBlueToothView];
        [_viewModel onFetchContinuousLocReq];
    }

}

#pragma mark - router

- (void)navToComment
{

}

- (void)navBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navToSearch:(NSString*)keyword
           poiBlock:(selectedPoiBlock)poiBlock
{
    YCIndoorSearchViewController  *searchVc = [[YCIndoorSearchViewController alloc]initWithKeyword:keyword];
    searchVc.selectedPoi  = poiBlock;

    [self.navigationController pushViewController:searchVc animated:YES];
}

#pragma mark - setter/getter

- (YCIndoorMapView*) mapView
{
    if(_mapView==nil) {
        
        WEAKSELF

        _mapView = [[YCIndoorMapView alloc] init];
        _mapView.mapDidLoadSuc = ^{
            [weakSelf mapDidLoadSuc];
        };

        _mapView.mapDidLoadFail = ^{
            [weakSelf mapDidLoadFail];
        };

        _mapView.mapDidTap = ^(RTLbs3DAnnotation *anno) {
            [weakSelf mapDidTap:anno];
        };        
    }

    return _mapView;
}

#pragma mark - utilities

- (void)showUIs
{
    if (_viewModel.guideMode == YCGuideModeInit) {
        [self popPinNavBar];
        [self popPinBottomView];
        [self popFloorPickView];
        
        [self dismissGuidingNavBar];
        [self dismissGuidingBottomView];
        [self dismissFloorIndicator];
        
    } else if (_viewModel.guideMode == YCGuideModeRealtimeGuiding) {
        [self dismissPinNavBar];
        [self dismissPinBottomView];
        [self dismissFloorPickView];

        [self popGuidingNavBar];
        [self popGuidingBottomView];
        [self popFloorIndicator];
    }

}

- (RTLbs3DAnnotation *)buildAnnotationWithPOIWithMsg:(RTLbs3DPOIMessageClass*)poiMsg
{
    RTLbs3DAnnotation *anno = [[RTLbs3DAnnotation alloc]init];

    anno.annoTitle       = poiMsg.POI_Name;
    anno.annoId          = poiMsg.POI_Name;
    anno.location        = poiMsg.POI_point;
    anno.annotationFloor = poiMsg.POI_Floor;
    
    return anno;
}

- (BOOL)pendingForComment
{
    //没有记录到一个完整的导航
    if(!_viewModel.flagRealTimeGuidingTriggerred)
        return NO;

    if([IndoorMapContext getMapCommented])
        return NO;
    
    if(_commentVC == nil)
        return NO;

    return YES;
}

@end
