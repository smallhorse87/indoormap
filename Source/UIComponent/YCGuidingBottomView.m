//
//  YCGuidingBottomView.m
//  youngcity
//
//  Created by chenxiaosong on 2018/5/22.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import "YCGuidingBottomView.h"

#import "ISWCategory.h"

#import <Masonry/Masonry.h>

#import "IndoorMapDefines.h"

@interface YCGuidingBottomView()
{
    UILabel *_roughPromptLable;
    UILabel *_detailedPromptLabel;
}

@end

@implementation YCGuidingBottomView

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
    self.backgroundColor    = kColorDeepDark;
    self.layer.cornerRadius = kLargeCorner;

    WEAKSELF

    _detailedPromptLabel = [[UILabel alloc] init];
    _detailedPromptLabel.textColor = kColorMajorMap;
    _detailedPromptLabel.font      = [UIFont isw_Pingfang:13 weight:UIFontWeightSemibold];
    _detailedPromptLabel.numberOfLines = 1;
    [self addSubview:_detailedPromptLabel];
    [_detailedPromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf);
        make.top.equalTo(weakSelf).offset(12);
    }];
    _detailedPromptLabel.text = @"开始导航";

    _roughPromptLable = [[UILabel alloc] init];
    _roughPromptLable.textColor = kColorWhite;
    _roughPromptLable.font      = [UIFont isw_Pingfang:28 weight:UIFontWeightRegular];
    _roughPromptLable.numberOfLines = 1;
    [self addSubview:_roughPromptLable];
    [_roughPromptLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf);
        make.top.equalTo(_detailedPromptLabel.mas_bottom);
    }];
    _roughPromptLable.text = @"路径规划成功";
    
}

- (void)updateContent:(NSString*)content
{
    if(isEmptyString(content))
        return;

    NSArray *contents = [content componentsSeparatedByString:@"|"];
    
    if(contents.count!=2)
        return;
    
    _detailedPromptLabel.text = contents[0];
    
    _roughPromptLable.text    = contents[1];
}

@end
