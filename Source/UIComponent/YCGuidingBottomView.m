//
//  YCGuidingBottomView.m
//  youngcity
//
//  Created by chenxiaosong on 2018/5/22.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import "YCGuidingBottomView.h"

#import "ISWCategory.h"

#import <AVFoundation/AVFoundation.h>

#import "Masonry.h"

#import "IndoorMapDefines.h"

@interface YCGuidingBottomView()
{
    UILabel *_roughPromptLable;
    
    // 合成器 控制播放，暂停
    AVSpeechSynthesizer    *_synthesizer;
    // 实例化说话的语言，说中文、英文
    AVSpeechSynthesisVoice *_voice;
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
        [self prepareVoice];
        [self buildUI];
    }
    return self;
}

- (void)prepareVoice
{
    _voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh_CN"];
    _synthesizer = [[AVSpeechSynthesizer alloc] init];

}

- (void)buildUI
{
    self.backgroundColor    = kColorDeepDark;
    self.layer.cornerRadius = kLargeCorner;

    WEAKSELF

    UILabel *detailedPromptLabel = [[UILabel alloc] init];
    detailedPromptLabel.textColor = kColorMajorMap;
    detailedPromptLabel.font      = [UIFont isw_Pingfang:13 weight:UIFontWeightSemibold];
    detailedPromptLabel.numberOfLines = 1;
    [self addSubview:detailedPromptLabel];
    [detailedPromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf);
        make.top.equalTo(weakSelf).offset(12);
    }];
    detailedPromptLabel.text = @"您当前在F1层，距离目标120米";

    _roughPromptLable = [[UILabel alloc] init];
    _roughPromptLable.textColor = kColorWhite;
    _roughPromptLable.font      = [UIFont isw_Pingfang:28 weight:UIFontWeightRegular];
    _roughPromptLable.numberOfLines = 1;
    [self addSubview:_roughPromptLable];
    [_roughPromptLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf);
        make.top.equalTo(detailedPromptLabel.mas_bottom);
    }];
    _roughPromptLable.text = @"顺着路线方向走";
    
    UIButton *voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [voiceBtn setImage:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_voice_open"] forState:UIControlStateNormal];
    [voiceBtn isw_addClickAction:@selector(voiceBtnPressed) target:self];
    [self addSubview:voiceBtn];
    [voiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@34);
        make.left.equalTo(detailedPromptLabel.mas_right).offset(-7);
        make.centerY.equalTo(detailedPromptLabel);
    }];
}

- (void)voiceBtnPressed
{
    static int times = 0;
    
    NSString *txt;
    
    if(times%3==0) {
        txt = @"距离目标120米";
        
    } else if(times%3==1) {
        txt = @"您当前在F1层";
        
    } else if (times%3==2) {
        txt = @"您当前在F1层，距离目标120米";
    }

    times++;

    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:txt];
    utterance.voice = _voice;
    utterance.rate = 0.5;
    [_synthesizer speakUtterance:utterance];
}

- (void)updateContent:(NSString*)content
{
    if(isEmptyString(content))
        return;

    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:content];
    utterance.voice = _voice;
    utterance.rate = 0.5;
    [_synthesizer speakUtterance:utterance];
}

@end
