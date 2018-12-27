//
//  YCIndoorMapViewController.h
//  youngcity
//
//  Created by chenxiaosong on 2018/4/17.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YCIndoorMapViewController : UIViewController

- (instancetype)initWithKeyword:(NSString*)keyword floor:(NSString*)floor;

@property (nonatomic, strong)UIViewController *commentVC;

@end
