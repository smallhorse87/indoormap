//
//  YCSearchNavBar.m
//  youngcity
//
//  Created by chenxiaosong on 2018/4/26.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import "YCSearchNavBar.h"

#import "ISWCategory.h"

#import "Masonry.h"

@implementation YCSearchNavBar

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
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(48+18+40));
    }];

    UIView *searchBgView = [[UIView alloc] initWithFrame:CGRectZero];
    searchBgView.backgroundColor     = kColorWhite;
    searchBgView.layer.cornerRadius  = kLargeCorner;
    searchBgView.layer.shadowOffset  =  CGSizeMake(0, 1);
    searchBgView.layer.shadowOpacity =  0.5;
    searchBgView.layer.shadowColor   =  kColor_B6B6B6.CGColor;

    [self addSubview:searchBgView];
    [searchBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.top.equalTo(self);
        make.height.equalTo(@48);
    }];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_route_edit_back_normal"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_route_edit_back_pressed"] forState:UIControlStateHighlighted];
    [backBtn isw_addClickAction:@selector(backBtnPressed) target:self];
    [searchBgView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@44);
        make.leading.equalTo(searchBgView).offset(1);
        make.centerY.equalTo(searchBgView);
    }];

    UITextField *searchInput = [[UITextField alloc] init];
    [searchInput addTarget:self action:@selector(keywordInputDidChange:) forControlEvents:UIControlEventEditingChanged];
    searchInput.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchInput.placeholder  = @"找店铺、公共设施、标签";
    searchInput.text         = @"";
    searchInput.textColor    = kColorDeepDark;
    searchInput.font         = [UIFont isw_Pingfang:15.0];
    [searchBgView addSubview:searchInput];
    [searchInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(searchBgView).offset(51);
        make.trailing.top.bottom.equalTo(searchBgView);
    }];
    
    UIView *btnsBgView = [[UIView alloc] initWithFrame:CGRectZero];
    btnsBgView.backgroundColor     = kColorWhite;
    btnsBgView.layer.cornerRadius  = kLargeCorner;
    btnsBgView.layer.shadowOffset  =  CGSizeMake(0, 1);
    btnsBgView.layer.shadowOpacity =  0.5;
    btnsBgView.layer.shadowColor   =  kColor_B6B6B6.CGColor;

    [self addSubview:btnsBgView];
    [btnsBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(searchBgView.mas_bottom).offset(18);
        make.height.equalTo(@40);
    }];
    
    UIButton *pinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pinBtn setImage:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_search_local"] forState:UIControlStateNormal];
    [pinBtn setImage:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_search_local"] forState:UIControlStateHighlighted];
    [pinBtn isw_titleForAllState:@"地图选点"];
    [pinBtn isw_titleColorForAllState:kColorDeepDark];
    pinBtn.titleLabel.font = [UIFont isw_Pingfang:12];
    [pinBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -8.0, 0.0, 0.0)];
    [pinBtn isw_addClickAction:@selector(pinBtnPressed) target:self];
    [btnsBgView addSubview:pinBtn];
    [pinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(btnsBgView);
        make.right.equalTo(btnsBgView.mas_centerX);
        make.top.bottom.equalTo(btnsBgView);
    }];

    UIButton *favBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [favBtn setImage:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_search_collect"] forState:UIControlStateNormal];
    [favBtn setImage:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_search_collect"] forState:UIControlStateHighlighted];
    [favBtn isw_titleForAllState:@"收藏夹"];
    [favBtn isw_titleColorForAllState:kColorDeepDark];
    favBtn.titleLabel.font = [UIFont isw_Pingfang:12];
    [favBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -8.0, 0.0, 0.0)];
    [favBtn isw_addClickAction:@selector(favBtnPressed) target:self];
    [btnsBgView addSubview:favBtn];
    [favBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(btnsBgView);
        make.left.equalTo(btnsBgView.mas_centerX);
        make.top.bottom.equalTo(btnsBgView);
    }];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectZero];
    separator.backgroundColor     = kColorSeparator;

    [btnsBgView addSubview:separator];
    [separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(btnsBgView);
        make.width.equalTo(@(kOnePixel));
        make.top.equalTo(btnsBgView).offset(11);
        make.bottom.equalTo(btnsBgView).offset(-9);
    }];
}

- (void)favBtnPressed
{
    if(_favBtnClicked) _favBtnClicked();
}

- (void)pinBtnPressed
{
    if(_pinBtnClicked) _pinBtnClicked();
}

- (void)backBtnPressed
{
    if(_backBtnClicked) _backBtnClicked();
}

-(void)keywordInputDidChange:(UITextField *)textField
{
    if(_inputDidChange) _inputDidChange(textField.text);
}


@end
