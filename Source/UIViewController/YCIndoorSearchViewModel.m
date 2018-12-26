//
//  YCIndoorSearchViewModel.m
//  youngcity
//
//  Created by chenxiaosong on 2018/4/21.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import "YCIndoorSearchViewModel.h"

#import "RTLbsMapView.h"
#import "RTLbs3DAnnotation.h"
#import "RTLbs3DWebService.h"
#import "RtmapApi.h"

#import "ISWCategory.h"

#import "IndoorMapDefines.h"

#import "IndoorMapContext.h"

@interface YCIndoorSearchViewModel() <RTLbs3DWebServiceDelegate>
{
    NSTimer  *_delayTimer;
}

@property (nonatomic, strong) NSNumber   *ntReqPhase;
@property (nonatomic, strong) NSString   *ntReqPrompt;

@property (nonatomic, strong)NSArray  *searchedPoiArray;

@property (nonatomic, strong)NSString *keyword;

@property (nonatomic, strong)RTLbs3DPOIMessageClass *specificPoiMc;

@end

@implementation YCIndoorSearchViewModel

- (instancetype)initWithKeyword:(NSString*)keyword
{
    self = [super init];

    if (self) {
        _keyword = keyword;
        
        if(!isEmptyString(_keyword)) {
            [self searchWithKeyword];
        }
    }

    return self;
}

- (void)onKeywordChanged:(NSString*)keyword
{
    NSString *tmpKeyword = [keyword isw_trimWhitespace];
    
    if([tmpKeyword isEqualToString:_keyword])
        return;

    self.keyword = tmpKeyword;

    if(_delayTimer!=nil) {
        [_delayTimer invalidate];
        _delayTimer = nil;
    }

    if(isEmptyString(_keyword)) {
        _searchedPoiArray = nil;

    } else {
        _delayTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(searchWithKeyword) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop]addTimer:_delayTimer forMode:NSRunLoopCommonModes];

    }

}

// 关键字搜索
- (void) searchWithKeyword
{
    RTLbs3DWebService *webService = [[RTLbs3DWebService alloc] init];
    webService.delegate = self;
    webService.serverUrl = Indoormap_ServerAddress;
    BOOL isSuccess =  [webService getKeywordSearch:_keyword
                                           buildID:Indoormap_BuildId
                                             Floor:nil];
    
    if (isSuccess)
    {
        NSLog(@"关键词检索发送成功");
    }
    else
    {
        NSLog(@"关键词检索发送失败");
    }
    
}
//  搜索成功后调用该方法
#pragma mark - RTLbsWebServiceDelegate
- (void)onPOISearchReq:(NSString*)name floor:(NSString*)floor
{
    [self ntRequesting];
    
    WEAKSELF

    static RtmapApi *poiapi;
    poiapi = [[RtmapApi alloc]init];

    [poiapi requestPOIsWithkeyword:name
                           buildId:Indoormap_BuildId
                             floor:floor
                          sucBlock:^(NSArray * poiArr)
     {
         
         if(poiArr.count==0) {
             [self ntRequestFail:YCLocalErr(@"没有搜索到")];
             return;
         }

         [self ntRequestSuc:@"搜索成功"];
         
         poiapi = nil;
         
         weakSelf.specificPoiMc = poiArr[0];
         
     } failBlock:^(NSString *error){

         [self ntRequestFail:YCLocalErr(error)];

         poiapi = nil;

         weakSelf.specificPoiMc = nil;
     }];
}

- (void) searchRequestFinish:(NSArray *)poiMessageArray
{
    self.searchedPoiArray = poiMessageArray;
}

- (void) searchRequestFail:(NSString*)error
{
    self.searchedPoiArray = nil;
}

- (void)onSaveSearchHistoryReq:(NSString*)title floor:(NSString*)floor
{
    [IndoorMapContext addIndoorSearchHistory:title floor:floor];
}

- (void)onCleanHistoryReq
{
    [IndoorMapContext clearIndoorSearchHistoryList];

    self.keyword = nil;
}

- (NSArray*)favoritePoiArray
{
    //注：港通天下|F1 不在室内地图范围内
    NSArray *favList = @[@"HiBoom潮玩轰趴|F5",
                         @"海盛国际影城|F7",
                         @"超悦铜锣湾KTV|F5",
                         @"波拉猴成长乐园|F1",
                         @"彩色海蜡笔乐园|F2",
                         @"欧姆格精品生活馆|F4",
                         @"MVP Club|F1",
                         @"第九元素|F4",
                         @"跃无限蹦床乐园|F7"];
    
    return favList;
}

- (NSArray*)historyPoiArray
{
    return [IndoorMapContext retriveIndoorSearchHistoryList];
}

#pragma mark - utilities
- (void)ntRequesting
{
    self.ntReqPrompt = nil;
    self.ntReqPhase  = @(YcNtPhaseRequesting);
}

- (void)ntRequestSuc:(NSString*)str
{
    self.ntReqPrompt = str;
    self.ntReqPhase  = @(YcNtPhaseResponseSuc);
}

- (void)ntRequestFail:(NSError *)err
{
    if (err.code==-1009) {
        self.ntReqPrompt = @"网络未连接";
        self.ntReqPhase  = @(YcNtPhaseNoConnection);
    } else if(err.code<0) {
        self.ntReqPrompt = @"网络连接超时";
        self.ntReqPhase  = @(YcNtPhaseConnectionTimeout);
    } else {
        self.ntReqPrompt = err.domain;
        self.ntReqPhase  = @(YcNtPhaseResponseFail);
    }
    
}

@end
