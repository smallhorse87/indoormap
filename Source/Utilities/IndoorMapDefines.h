//
//  IndoorMapDefines.h
//  indoormap
//
//  Created by chenxiaosong on 2018/12/26.
//  Copyright © 2018年 chenxiaosong. All rights reserved.
//

#ifndef IndoorMapDefines_h
#define IndoorMapDefines_h

/*
 *  常用颜色
 */
#define UIColorFromRGB(rgbValue)                            \
[UIColor                                                    \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0   \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0             \
blue:((float)(rgbValue & 0xFF))/255.0                       \
alpha:1.0]

#define kColorNone                      [UIColor clearColor]
#define kColorBlack                     [UIColor blackColor]
#define kColorWhite                     [UIColor whiteColor]
#define kColorGray                      UIColorFromRGB(0x989898)
#define kColorMajorMap                  UIColorFromRGB(0xFF6565)

#define kColorDeepDark                  UIColorFromRGB(0x333333)
#define kColorLightGray                 UIColorFromRGB(0xb2b2b2)
#define kColor_B6B6B6                   UIColorFromRGB(0xB6B6B6)
#define kOutlineColor                   UIColorFromRGB(0xd8d8d8)
#define kColorSeparator                 UIColorFromRGB(0xe6e6e6)
#define kColorPageBg                    UIColorFromRGB(0xf2f2f2)

/*
 *  手机相关尺寸定义
 */
#define kOnePixel (1.0f/[UIScreen mainScreen].scale)
#define kOnePoint 1.0f

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

/*
 *  倒角大小
 */
#define kLargeCorner 4.0f

typedef void(^Clicked)(void);
typedef void(^InputCompleted)  (NSString *str);

#define WEAKSELF   typeof(self) __weak weakSelf = self;

#define Indoormap_ServerAddress @"http://lbsapi.rtmap.com"

typedef enum : NSUInteger {
    YcNtPhaseNone,
    YcNtPhaseRequesting,
    YcNtPhaseResponseSuc,
    YcNtPhaseResponseFail,
    YcNtPhaseNoConnection,
    YcNtPhaseConnectionTimeout
} YcNtPhaseType;

#define YCLocalErr(domain) [[NSError alloc] initWithDomain:domain code:0 userInfo:nil]

#endif /* IndoorMapDefines_h */
