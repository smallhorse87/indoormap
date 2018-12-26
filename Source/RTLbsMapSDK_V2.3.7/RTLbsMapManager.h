//
//  RTLbsMapManager.h
//  SDK
//
//  Created by zhaoyubin on 15/6/23.
//  Copyright (c) 2015年 rtmap. All rights reserved.
//


/*!
 @header RTLbsMapManager
 @abstract  地图引擎管理
 @author rtmap
 @version 2.0
 */
#import <Foundation/Foundation.h>

@protocol RTLbsVerifyDelegate;

///地图引擎管理类
@interface RTLbsMapManager : NSObject
/*!
 @property
 @abstract 服务器地址。
 */
@property (nonatomic,copy) NSString *apiServerUrl;
/**
 *启动引擎
 *@param key 申请的有效key
 *@param delegate
 */
-(void)startVerifyLicense:(NSString*)key delegate:(id<RTLbsVerifyDelegate>)delegate;

/**
 *停止引擎
 */
-(void)stop;
@end

///通知Delegate
@protocol RTLbsVerifyDelegate <NSObject>
@optional
/**
 *返回授权验证错误
 *@param iError 错误号 : 为0时验证通过
 */
- (void)RTLbsGetPermissionState:(int)iError;
@end
