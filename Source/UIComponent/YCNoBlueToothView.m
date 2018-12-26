//
//  YCNoBlueToothView.m
//  youngcity
//
//  Created by chenxiaosong on 2018/5/29.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import "YCNoBlueToothView.h"

#import "Masonry.h"

#import "YCDefines.h"

@interface YCNoBlueToothView()
{
    MASConstraint *topCon;
}
@end

@implementation YCNoBlueToothView

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
    UIView *_bgView = [[UIView alloc] initWithFrame:CGRectZero];
    _bgView.backgroundColor     = kColorBlack;
    _bgView.alpha               = 0.4;
    _bgView.layer.masksToBounds = YES;
    [self addSubview:_bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];

    UIImageView *_noBlueToothPic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"YCIndoorMap.bundle/bg_lanya_ios"]];
    _noBlueToothPic.contentMode = UIViewContentModeScaleAspectFill;
    _noBlueToothPic.clipsToBounds = YES;
    [self addSubview:_noBlueToothPic];
    [_noBlueToothPic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(4);
        make.trailing.equalTo(self).offset(-4);
        topCon = make.top.equalTo(self.mas_bottom);
        make.height.equalTo(@([YCNoBlueToothView heightOfPic]));
    }];
    
    self.hidden = YES;
}

- (void)show
{
    self.hidden = NO;

    [UIView animateWithDuration:0.2 animations:^{
        topCon.offset(-[YCNoBlueToothView heightOfPic]);
        [self layoutIfNeeded];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
}

- (void)dismiss
{
    self.hidden = YES;
    topCon.offset(0);
}

+ (CGFloat)heightOfPic
{
    return (kScreenWidth - 8)*630.0/734.0;
}

@end
