//
//  RtmapApi.h
//  youngcity
//
//  Created by chenxiaosong on 2017/9/26.
//  Copyright © 2017年 Zhitian Network Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RtmapApi : NSObject

// 关键字搜索
- (void) requestPOIsWithkeyword:(NSString *)keyword
                        buildId:(NSString*)buildId
                          floor:(NSString*)floorId
                       sucBlock:(void(^)(NSArray *))sucBlock
                      failBlock:(void(^)(NSString *error))failBlock;

- (void)requestFloorInfo:(void(^)(NSArray *))sucBlock
                    fail:(void(^)(NSString *error))failBlock;

@end
