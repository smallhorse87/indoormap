//
//  YCSearchNavBar.h
//  youngcity
//
//  Created by chenxiaosong on 2018/4/26.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YCDefines.h"

@interface YCSearchNavBar : UIView

@property (nonatomic, strong)Clicked        favBtnClicked;
@property (nonatomic, strong)Clicked        pinBtnClicked;
@property (nonatomic, strong)Clicked        backBtnClicked;

@property (nonatomic, strong)InputCompleted inputDidChange;

@end
