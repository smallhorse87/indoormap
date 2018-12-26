//
//  YCPinBottomView.h
//  youngcity
//
//  Created by chenxiaosong on 2018/4/23.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IndoorMapDefines.h"

@interface YCPinBottomView : UIView

@property (nonatomic, strong)Clicked toGuideSettingBtnClicked;

@property (nonatomic, strong)Clicked addressBtnClicked;

- (void)setupContent:(NSString*)address floor:(NSString*)floor;

- (void)cleanContent;

@end
