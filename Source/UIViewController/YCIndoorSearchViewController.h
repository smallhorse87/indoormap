//
//  YCIndoorSearchViewController.h
//  youngcity
//
//  Created by zhitian on 2017/9/7.
//  Copyright © 2017年 Zhitian Network Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTLbs3DPOIMessageClass;

typedef void(^selectedPoiBlock)(RTLbs3DPOIMessageClass *info);

@interface YCIndoorSearchViewController : UIViewController

@property (nonatomic,copy) selectedPoiBlock selectedPoi;

- (instancetype)initWithKeyword:(NSString*)keyword;

@end
