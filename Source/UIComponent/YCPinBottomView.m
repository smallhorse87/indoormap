//
//  YCPinBottomView.m
//  youngcity
//
//  Created by chenxiaosong on 2018/4/23.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import "YCPinBottomView.h"

#import "ISWCategory.h"

#import <Masonry.h>

@interface YCPinBottomView()
{
    UILabel     *_addressLable;
    UILabel     *_floorLable;
    
    UIButton    *_navBtn;
    UIView      *_bgView;
    UILabel     *_promptLabel;
}
@end

@implementation YCPinBottomView

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
    self.backgroundColor  = kColorNone;

    _bgView = [[UIView alloc] initWithFrame:CGRectZero];
    _bgView.backgroundColor     = kColorDeepDark;
    _bgView.layer.shadowOffset  =  CGSizeMake(0, 1);
    _bgView.layer.shadowOpacity =  0.5;
    _bgView.layer.shadowColor   =  kColor_B6B6B6.CGColor;
    _bgView.layer.cornerRadius  =  kLargeCorner;
    [self addSubview:_bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.leading.trailing.equalTo(self);
        make.height.equalTo(@(64));
    }];
    
    _promptLabel = [[UILabel alloc] init];
    _promptLabel.textColor = kColorMajorMap;
    _promptLabel.font      = [UIFont isw_Pingfang:19 weight:UIFontWeightRegular];
    _promptLabel.numberOfLines = 1;
    [_bgView addSubview:_promptLabel];
    [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_bgView).offset(12);
        make.centerY.equalTo(_bgView);
    }];

    _promptLabel.text = @"请在地图上选择终点或直接搜索";
    
    _addressLable               = [[UILabel alloc] init];
    _addressLable.textColor     = kColorMajorMap;
    _addressLable.font          = [UIFont isw_Pingfang:20 weight:UIFontWeightSemibold];
    _addressLable.numberOfLines = 1;
    _addressLable.text = @"请在地图上选择起点";
    _addressLable.hidden = YES;
    [_bgView addSubview:_addressLable];
    [_addressLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_bgView).offset(12);
        make.top.equalTo(_bgView).offset(7);
    }];

    _floorLable      = [[UILabel alloc] init];
    _floorLable.textColor     = kColorDeepDark;
    _floorLable.font          = [UIFont isw_Pingfang:12 weight:UIFontWeightSemibold];
    _floorLable.textAlignment = NSTextAlignmentCenter;
    _floorLable.layer.borderWidth = kOnePoint;
    _floorLable.layer.borderColor = kColorDeepDark.CGColor;
    _floorLable.layer.cornerRadius= kLargeCorner;
    _floorLable.numberOfLines = 1;
    _floorLable.text = @"";
    _floorLable.hidden = YES;
    [_bgView addSubview:_floorLable];
    [_floorLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_bgView).offset(13);
        make.top.equalTo(_addressLable.mas_bottom).offset(3);
        make.width.equalTo(@34);
        make.height.equalTo(@17);
    }];

    _navBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_navBtn isw_imageForAllState:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_navigation_selected"]];
    [_navBtn isw_addClickAction:@selector(toGuideSettingBtnPressed) target:self];
    [self addSubview:_navBtn];
    [_navBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@72);
        make.trailing.equalTo(self).offset(-9);
        make.top.equalTo(self);
    }];
    
    UIButton *addressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addressBtn isw_addClickAction:@selector(addressBtnPressed) target:self];
    [_bgView addSubview:addressBtn];
    [addressBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(_bgView);
        make.leading.equalTo(_bgView);
        make.right.equalTo(_navBtn.mas_left).offset(-9);
    }];

}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *viewReturn =[super hitTest:point withEvent:event];

    if (viewReturn == self)
        return nil;
    else
        return viewReturn;
}


- (void)toGuideSettingBtnPressed
{
    if(_toGuideSettingBtnClicked) _toGuideSettingBtnClicked();
}

- (void)addressBtnPressed
{
    if(_addressBtnClicked) _addressBtnClicked();
}

- (void)cleanContent
{
    [self setupContent:@"请在地图上选择起点" floor:nil];
    
    [_navBtn isw_imageForAllState:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_navigation_selected"]];
    _bgView.backgroundColor = kColorDeepDark;
    _addressLable.hidden    = YES;
    _promptLabel.hidden     = NO;
}

- (void)setupContent:(NSString*)address floor:(NSString*)floor
{
    _addressLable.text = address;
    
    if(isEmptyString(floor)){
        _floorLable.hidden = YES;
    } else {
        _floorLable.hidden = NO;
    }

    _floorLable.text   = floor;

    [_navBtn isw_imageForAllState:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_navigation_default"]];
    _bgView.backgroundColor     = kColorWhite;
    _addressLable.hidden        = NO;
    _promptLabel.hidden         = YES;
}

@end
