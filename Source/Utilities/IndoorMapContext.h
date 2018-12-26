//
//  IndoorMapContext.h
//  indoormap
//
//  Created by chenxiaosong on 2018/12/26.
//  Copyright © 2018年 chenxiaosong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IndoorMapContext : NSObject

//地图评论
+(void)cleanMapCommented;
+(void)setMapCommented;
+(BOOL)getMapCommented;

//室内地图历史收藏
+(void)    addIndoorSearchHistory:(NSString*)title floor:(NSString*)floor;
+(NSArray*)retriveIndoorSearchHistoryList;
+(void)    clearIndoorSearchHistoryList;

//室内地图楼层数据缓存
+(void)cacheFloorList:(NSString*)buildId floorArr:(NSArray*)floorArr;
+(NSArray*)retriveFloorList:(NSString*)buildId;

@end

NS_ASSUME_NONNULL_END
