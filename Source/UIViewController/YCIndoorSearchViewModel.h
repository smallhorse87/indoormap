//
//  YCIndoorSearchViewModel.h
//  youngcity
//
//  Created by chenxiaosong on 2018/4/21.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YCDefines.h"

@class RTLbs3DPOIMessageClass;

@interface YCIndoorSearchViewModel : NSObject

@property (nonatomic, readonly) NSNumber        *ntReqPhase;
@property (nonatomic, readonly) NSString        *ntReqPrompt;

@property (nonatomic, readonly)NSArray  *searchedPoiArray;

@property (nonatomic, readonly)NSArray  *favoritePoiArray;

@property (nonatomic, readonly)NSArray  *historyPoiArray;

@property (nonatomic, readonly)RTLbs3DPOIMessageClass  *specificPoiMc;

@property (nonatomic, readonly)NSString *keyword;

- (void)onPOISearchReq:(NSString*)name floor:(NSString*)floor;

- (void)onKeywordChanged:(NSString*)keyword;

- (void)onSaveSearchHistoryReq:(NSString*)title floor:(NSString*)floor;

- (void)onCleanHistoryReq;

- (instancetype)initWithKeyword:(NSString*)keyword;

@end
