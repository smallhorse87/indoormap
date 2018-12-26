//
//  YCFloorPicker.h
//  youngcity
//
//  Created by chenxiaosong on 2018/5/25.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IndoorMapDefines.h"

@interface YCFloorPicker : UIView

@property (nonatomic, strong) InputCompleted floorPickerClicked;

- (void)setupContent:(NSArray*)floorArr defaultFloor:(NSString*)defaultFloor;

- (void)changeToFloor:(NSString*)toFloor;

- (void)locateToFloor:(NSString*)toFloor;

@end
