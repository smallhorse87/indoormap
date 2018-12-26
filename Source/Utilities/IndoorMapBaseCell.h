//
//  IndoorMapBaseCell.h
//  youngcity
//
//  Created by chenxiaosong on 2017/2/22.
//  Copyright © 2017年 Zhitian Network Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ClickedAction)(UITableViewCell *cell);

@interface IndoorMapBaseCell : UITableViewCell

@property (nonatomic, strong) ClickedAction clickecBlock;
@property (nonatomic,assign)  CGFloat       iswHeight;

@end
