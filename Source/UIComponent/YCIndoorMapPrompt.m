//
//  YCIndoorMapPrompt.m
//  youngcity
//
//  Created by chenxiaosong on 2018/5/29.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import "YCIndoorMapPrompt.h"

#import "Masonry.h"

#import "ISWCategory.h"

#import "YCDefines.h"

@interface YCIndoorMapPrompt()
{
    UILabel *promptLabel;
}
@end

@implementation YCIndoorMapPrompt

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
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor     = kColorBlack;
    bgView.alpha               = 0.9;
    bgView.layer.cornerRadius  = kLargeCorner;
    bgView.layer.masksToBounds = YES;
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];

    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_map_record"]];
    icon.contentMode = UIViewContentModeScaleAspectFill;
    icon.clipsToBounds = YES;
    [self addSubview:icon];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@24);
        make.leading.equalTo(self).offset(20);
        make.centerY.equalTo(self);
    }];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn isw_imageForAllState:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_map_delete"]];
    [closeBtn isw_addClickAction:@selector(closeBtnPressed) target:self];
    [self addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@44);
        make.trailing.equalTo(self).offset(-9);
        make.centerY.equalTo(self);
    }];

    UILabel *promptLabel  = [[UILabel alloc] init];
    promptLabel.textColor = kColorWhite;
    promptLabel.font      = [UIFont isw_Pingfang:18];
    promptLabel.numberOfLines = 1;
    [self addSubview:promptLabel];
    [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(55);
        make.centerY.equalTo(self);
    }];
    promptLabel.text = @"您上回找花漫里小镇";

}

- (void)closeBtnPressed
{
    
}

@end
