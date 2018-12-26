//
//  YCPinNavBar.m
//  youngcity
//
//  Created by chenxiaosong on 2018/4/23.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import "YCPinNavBar.h"

#import "ISWCategory.h"

#import "Masonry.h"

@interface YCPinNavBar()
{
}
@end

@implementation YCPinNavBar

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
    //搜索输入框
    self.backgroundColor     = kColorNone;
    self.layer.masksToBounds = NO;

    UIView *searchBgView = [[UIView alloc] initWithFrame:CGRectZero];
    searchBgView.backgroundColor     = kColorWhite;
    searchBgView.layer.cornerRadius  = kLargeCorner;
    searchBgView.layer.borderWidth   = kOnePixel;
    searchBgView.layer.borderColor   = kColorSeparator.CGColor;
    searchBgView.layer.shadowOffset  =  CGSizeMake(0, 1);
    searchBgView.layer.shadowOpacity =  0.5;
    searchBgView.layer.shadowColor   =  kColor_B6B6B6.CGColor;
    [self addSubview:searchBgView];
    [searchBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.top.equalTo(self);
        make.height.equalTo(@44);
    }];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn isw_imageForAllState:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_back_one"]];
    [backBtn isw_addClickAction:@selector(backBtnPressed) target:self];
    [searchBgView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@36);
        make.leading.equalTo(searchBgView);
        make.centerY.equalTo(searchBgView);
    }];

    UIView *vSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    vSeparator.backgroundColor     = kColorPageBg;
    [searchBgView addSubview:vSeparator];
    [vSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(searchBgView).offset(36);
        make.width.equalTo(@(kOnePixel));
        make.top.equalTo(searchBgView).offset(10);
        make.bottom.equalTo(searchBgView).offset(-10);
    }];

    UILabel *searchLabel = [[UILabel alloc] init];
    searchLabel.text      = @"搜索店铺";
    searchLabel.textColor = kColorLightGray;
    searchLabel.font      = [UIFont isw_Pingfang:16.0 weight:UIFontWeightRegular];
    [searchBgView addSubview:searchLabel];
    [searchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(searchBgView).offset(49);
        make.trailing.top.bottom.equalTo(searchBgView);
    }];

    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn isw_addClickAction:@selector(searchBtnPressed) target:self];
    [searchBgView addSubview:searchBtn];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backBtn.mas_right);
        make.trailing.top.bottom.equalTo(searchBgView);
    }];
}

- (void)searchBtnPressed
{
    if(_searchBtnClicked) _searchBtnClicked();
}

- (void)backBtnPressed
{
    if(_backBtnClicked) _backBtnClicked();
}

@end
