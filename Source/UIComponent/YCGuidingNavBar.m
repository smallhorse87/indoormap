//
//  YCGuidingNavBar.m
//  youngcity
//
//  Created by chenxiaosong on 2018/5/22.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import "YCGuidingNavBar.h"

#import <Masonry.h>

@implementation YCGuidingNavBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI
{
    UIButton *navBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [navBtn setImage:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_back_two"] forState:UIControlStateNormal];
    [navBtn addTarget:self action:@selector(backBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:navBtn];
    
    [navBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@44);
        make.centerX.centerY.equalTo(self);
    }];
    
}

- (void)backBtnPressed
{
    if(_backBtnClicked) _backBtnClicked();
}

@end
