//
//  RtmapApi.m
//  youngcity
//
//  Created by chenxiaosong on 2017/9/26.
//  Copyright © 2017年 Zhitian Network Tech. All rights reserved.
//

#import "RtmapApi.h"

#import "RTLbs3DWebService.h"

#import "RTLbsMapManager.h"

#import "YCDefines.h"

RTLbs3DWebService *webService;

@interface RtmapApi() <RTLbs3DWebServiceDelegate>
{
    void (^poiSearchSucBlock) (NSArray *);
    void (^poiSearchFailBloc) (NSString *error) ;

    void (^floorinfosSucBlock) (NSArray *);
    void (^floorinfosFailBloc) (NSString *error) ;
}
@end

@implementation RtmapApi

// 关键字搜索
- (void) requestPOIsWithkeyword:(NSString *)keyword
                        buildId:(NSString*)buildId
                          floor:(NSString*)floorId
                       sucBlock:(void(^)(NSArray *))sucBlock
                      failBlock:(void(^)(NSString *error))failBlock
{
    RTLbs3DWebService *webService = [[RTLbs3DWebService alloc] init];
    webService.delegate = self;
    webService.serverUrl = RTLbs_ServerAddress;

    poiSearchSucBlock = sucBlock;
    poiSearchFailBloc = failBlock;
    
    BOOL isSuccess =  [webService getKeywordSearch:keyword buildID:buildId Floor:floorId];

    if (isSuccess)
    {
        NSLog(@"关键词检索发送成功");
    }
    else
    {
        NSLog(@"关键词检索发送失败");
        failBlock(@"关键词检索发送失败");
    }
}

- (void)requestFloorInfo:(void(^)(NSArray *))sucBlock
                    fail:(void(^)(NSString *error))failBlock
{
    webService = [[RTLbs3DWebService alloc] init];
    webService.delegate = self;
    webService.serverUrl = RTLbs_ServerAddress;
    
    floorinfosSucBlock = sucBlock;
    floorinfosFailBloc = failBlock;

    BOOL isSuccess = [webService getBuildFloorInfo:Bodimall_BuildId];
    if (isSuccess)
    {
        NSLog(@"获取建筑物楼层发送成功");
    }
    else
    {
        NSLog(@"获取建筑物楼层发送失败");
        failBlock(@"获取建筑物楼层发送失败");
    }
    
}

//  搜索成功后调用该方法
#pragma mark - RTLbsWebServiceDelegate
- (void) searchRequestFail:(NSString*)error
{
    poiSearchFailBloc(error);
}

- (void) searchRequestFinish:(NSArray *)poiMessageArray
{
    poiSearchSucBlock(poiMessageArray);
}


#pragma --mark 4. 获取楼层信息成功返回的代理
-(void)getBuildFloorInfoFail:(NSString *)error;
{
    floorinfosFailBloc(error);
}

-(void) getFloorInfoFinish:(NSDictionary *)buildDetail
{
    floorinfosSucBlock(buildDetail[@"floorinfo"]);
}
@end
