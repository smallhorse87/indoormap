//
//  YCDefines.h
//  indoormap
//
//  Created by chenxiaosong on 2018/12/26.
//  Copyright © 2018年 chenxiaosong. All rights reserved.
//

#ifndef YCDefines_h
#define YCDefines_h

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
#define kColorGreen                     UIColorFromRGB(0x18BC40)
#define kColorGreenButtonHighLightBG    UIColorFromRGB(0x6FD287)

#define kColorMajorNormal               UIColorFromRGB(0xF64040)
#define kColorMajorHighlight            UIColorFromRGB(0xEF856F)

#define kColorOrange                    UIColorFromRGB(0xf64e27)

#define kColorDeepDark                  UIColorFromRGB(0x333333)
#define kColorLittleDeepDark            UIColorFromRGB(0x2a2a2a)
#define kColorDark                      UIColorFromRGB(0x4d4d4d)
#define kColorLightDark                 UIColorFromRGB(0x666666)
#define kColorGray                      UIColorFromRGB(0x989898)
#define kColorLightGray                 UIColorFromRGB(0xb2b2b2)
#define kColorLight                     UIColorFromRGB(0xcccccc)
#define kColorHighlightGray             UIColorFromRGB(0xdbdbdb)

#define kColorPageBg                    UIColorFromRGB(0xf2f2f2)
#define kColorSeparator                 UIColorFromRGB(0xe6e6e6)
#define kColorTagText                   UIColorFromRGB(0xFB6F35)
#define kColorTagBG                     UIColorFromRGB(0xfeeae1)
#define kColorMoreText                  UIColorFromRGB(0x5085B4)
#define kColorFeedbackBg                UIColorFromRGB(0xf8f8f8)
#define kColorSearchBarBg               UIColorFromRGB(0xeeeeee)
#define kColorNavBarShadow              UIColorFromRGB(0xdadada)
#define kColorPwdFieldBorderColor       UIColorFromRGB(0x6FACE3)

#define kColor_B6B6B6                   UIColorFromRGB(0xB6B6B6)

//地图导航
#define kColorBrightBlue            UIColorFromRGB(0x4287FF)
#define kColorMajorMap              UIColorFromRGB(0xFF6565)
#define kOutlineColor                   UIColorFromRGB(0xd8d8d8)
/*
 *  手机相关尺寸定义
 */
#define kOnePixel (1.0f/[UIScreen mainScreen].scale)
#define kOnePoint 1.0f

#define kScreenBounds [UIScreen mainScreen].bounds
#define kScreenSize   [UIScreen mainScreen].bounds.size
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

/*
 *  倒角大小
 */
#define kSmallCorner 2.0f
#define kLargeCorner 4.0f
#define kHugeCorner  5.0f

typedef void(^Clicked)();
typedef void(^InputCompleted)  (NSString *str);

#define WEAKSELF typeof(self) __weak weakSelf = self;
#define STRONGSELF typeof(self) __strong strongSelf = self;

//这个是影秀城
//#define Bodimall_BuildId    @"862700020040300001"

//这个是来福士
#define Bodimall_BuildId    @"862700010030300032"

#define RTLbs_ServerAddress @"http://lbsapi.rtmap.com"

#endif /* YCDefines_h */
