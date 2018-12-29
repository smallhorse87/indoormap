//
//  ViewController.m
//  indoormap
//
//  Created by chenxiaosong on 2018/12/26.
//  Copyright © 2018年 chenxiaosong. All rights reserved.
//

#import "ViewController.h"

#import "YCIndoorMapViewController.h"

#import <Masonry/Masonry.h>
#import "ISWCategory.h"

#import "IndoorMapContext.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self buildUI];
}

- (void)buildUI
{
    self.title = @"举个🌰";

    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *poiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [poiBtn isw_addClickAction:@selector(poiBtnPressed) target:self];
    [poiBtn isw_titleForAllState:@"打开室内地图，并定位到指定商铺"];
    poiBtn.titleLabel.font = [UIFont isw_Pingfang:18];
    [poiBtn isw_titleColorForAllState:[UIColor blackColor]];
    [self.view addSubview:poiBtn];
    [poiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.centerX.centerY.equalTo(self.view);
    }];

    UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [mapBtn isw_addClickAction:@selector(mapBtnPressed) target:self];
    [mapBtn isw_titleForAllState:@"直接打开室内地图"];
    mapBtn.titleLabel.font = [UIFont isw_Pingfang:18];
    [mapBtn isw_titleColorForAllState:[UIColor blackColor]];
    [self.view addSubview:mapBtn];
    [mapBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view);
        make.top.equalTo(poiBtn.mas_bottom).offset(20);
    }];
}

- (void)poiBtnPressed
{
    if(isEmptyString([IndoorMapContext getBuildingId])||isEmptyString([IndoorMapContext getLicense])) {
        NSLog(@"请设置授权号和商场id");
        return;
    }
    
    YCIndoorMapViewController *vc = [[YCIndoorMapViewController alloc] initWithKeyword:@"一点点" floor:@"B1"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)mapBtnPressed
{
    if(isEmptyString([IndoorMapContext getBuildingId])||isEmptyString([IndoorMapContext getLicense])) {
        NSLog(@"请设置授权号和商场id");
        return;
    }

    YCIndoorMapViewController *vc = [[YCIndoorMapViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
