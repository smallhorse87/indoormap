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

#import "YCDefines.h"

//stony debug #import "AppContext.h"

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
    webService.serverUrl = RTLbs_ServerAddress;
    BOOL isSuccess =  [webService getKeywordSearch:_keyword
                                           buildID:Bodimall_BuildId
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
                           buildId:Bodimall_BuildId
                             floor:floor
                          sucBlock:^(NSArray * poiArr)
     {
         
         if(poiArr.count==0) {
             //stony debug [self ntRequestFail:LocalErr(@"没有搜索到")];
             return;
         }

         [self ntRequestSuc:@"搜索成功"];
         
         poiapi = nil;
         
         weakSelf.specificPoiMc = poiArr[0];
         
     } failBlock:^(NSString *error){

         //stony debug [self ntRequestFail:LocalErr(error)];

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
    //stony debug [AppContext addIndoorSearchHistory:title floor:floor];
}

- (void)onCleanHistoryReq
{
    //stony debug [AppContext clearIndoorSearchHistoryList];

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
    //stony debug return [AppContext retriveIndoorSearchHistoryList];
    return nil;
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
//stony debug         self.ntReqPhase  = @(NtPhaseNoConnection);
    } else if(err.code<0) {
        self.ntReqPrompt = @"网络连接超时";
        //stony debug self.ntReqPhase  = @(NtPhaseConnectionTimeout);
    } else {
        self.ntReqPrompt = err.domain;
        //stony debug self.ntReqPhase  = @(NtPhaseResponseFail);
    }
    
}

@end
