//
//  RealtimeGuide.h
//  youngcity
//
//  Created by chenxiaosong on 2018/6/22.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IbeaconLocation;

@interface RealtimeGuide : NSObject

- (instancetype)initWithKeyNavigationInfo:(NSArray*)info;

- (NSString*)floorToTxt:(NSString*)floorStr;

- (NSString*)retTxtGuide:(IbeaconLocation *)location;

- (BOOL)isNearBy:(CGPoint)pt1 with:(CGPoint)pt2;

- (BOOL)pass1stFloorPlatform:(NSArray*)navigationInfos;

- (BOOL)pass3rdFloorPlatform:(NSArray*)navigationInfos;

@property (nonatomic, readonly) NSString         *navigationInstruct;

@end
