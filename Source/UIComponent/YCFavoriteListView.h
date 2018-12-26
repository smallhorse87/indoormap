//
//  YCFavoriteListView.h
//  youngcity
//
//  Created by chenxiaosong on 2018/4/22.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YCDefines.h"

@interface YCFavoriteListView : UIView

- (void)setupContent:(NSArray*)poiArr;

@property (nonatomic, strong) InputCompleted inputCompleted;

@end
