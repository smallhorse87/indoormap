//
//  YCFloorPicker.m
//  youngcity
//
//  Created by chenxiaosong on 2018/5/25.
//  Copyright © 2018年 Zhitian Network Tech. All rights reserved.
//

#import "YCFloorPicker.h"

#import <Masonry/Masonry.h>

#import "ISWCategory.h"

#import "IndoorMapDefines.h"

@interface YCFloorCell:UITableViewCell
{
    UILabel     *_floorLabel;
    
    UIImageView *_locatedFlag;
    
    UIView      *_separatorLine;
}
@end

@implementation YCFloorCell

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
    WEAKSELF
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _floorLabel = [[UILabel alloc] init];
    _floorLabel.textColor = kColorLightGray;
    _floorLabel.font      = [UIFont isw_Pingfang:13 weight:UIFontWeightSemibold];
    _floorLabel.numberOfLines = 1;
    [self addSubview:_floorLabel];
    [_floorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(weakSelf);
    }];
    _floorLabel.text = @"F1";

    _locatedFlag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_sanjiao"]];
    _locatedFlag.contentMode = UIViewContentModeScaleAspectFill;
    _locatedFlag.clipsToBounds = YES;
    [self addSubview:_locatedFlag];
    [_locatedFlag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@8);
        make.height.equalTo(@6);

        make.centerX.equalTo(weakSelf.contentView);
        make.bottom.equalTo(weakSelf.contentView).offset(-5);
    }];
    _locatedFlag.hidden = YES;

    _separatorLine = [[UIView alloc] initWithFrame:CGRectZero];
    _separatorLine.backgroundColor     = kColorSeparator;
    [self.contentView addSubview:_separatorLine];
    [_separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(weakSelf.contentView).offset(7);
        make.trailing.equalTo(weakSelf.contentView).offset(-7);
        make.bottom.equalTo(weakSelf.contentView);
        make.height.equalTo(@1);
    }];
}

- (void)setupContent:(NSString*)floor
{
    _floorLabel.text = floor;
}

- (void)matchSelectedFloor:(NSString*)floor
{
    if([_floorLabel.text isEqualToString:floor]) {
        _floorLabel.textColor = kColorMajorMap;
    } else {
        _floorLabel.textColor = kColorLightGray;
    }
}

- (void)matchLocatedFloor:(NSString*)floor
{
    if([_floorLabel.text isEqualToString:floor]) {
        _locatedFlag.hidden = NO;
    } else {
        _locatedFlag.hidden = YES;
    }
}

- (void)noSeparator
{
    _separatorLine.hidden = YES;
}

@end

@interface YCFloorPicker () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView                     *_floorTable;
    
    NSMutableArray<YCFloorCell*>    *_floorCellArr;
    NSArray<NSString*>              *_floorArr;
    
    NSString    *_selectedFloor;
    NSString    *_locatedFloor;
    
    UIButton    *_topBtn;
    UIButton    *_downBtn;

}
@end

@implementation YCFloorPicker

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.hidden = YES;

        [self buildUI];
        
    }
    return self;
}

#pragma mark - build UI

- (void)buildUI
{
    self.backgroundColor    = kColorWhite;
    
    self.layer.cornerRadius = kLargeCorner;
    self.layer.borderColor  = kOutlineColor.CGColor;
    self.layer.borderWidth  = 1;
    
    self.clipsToBounds       =  NO;
    self.layer.shadowOffset  =  CGSizeMake(0, 1);
    self.layer.shadowOpacity =  0.5;
    self.layer.shadowColor   =  kColor_B6B6B6.CGColor;
    
    WEAKSELF
    _floorTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _floorTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _floorTable.showsVerticalScrollIndicator = NO;
    [self addSubview:_floorTable];
    [_floorTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(weakSelf);
        make.top.equalTo(weakSelf).offset(5);
        make.bottom.equalTo(weakSelf).offset(-5);
    }];
    
    _floorTable.dataSource = self;
    _floorTable.delegate   = self;
    
    _topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_topBtn isw_imageForAllState:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_top"]];
    [_topBtn isw_addClickAction:@selector(topBtnPressed) target:self];
    [self addSubview:_topBtn];
    [_topBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@40);
        make.top.equalTo(self);
        make.centerX.equalTo(self);
    }];
    
    _downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_downBtn isw_imageForAllState:[UIImage imageNamed:@"YCIndoorMap.bundle/icon_down"]];
    [_downBtn isw_addClickAction:@selector(downBtnPressed) target:self];
    [self addSubview:_downBtn];
    [_downBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@40);
        make.bottom.equalTo(self);
        make.centerX.equalTo(self);
    }];
}

#pragma mark - update UI

//选择的楼层
- (void)setupSelectedFloor:(NSString*)selectedFloor
{
    _selectedFloor = selectedFloor;
    
    for(YCFloorCell *cellItem in _floorCellArr) {
        [cellItem matchSelectedFloor:selectedFloor];
    }

}

//定位所在的楼层
- (void)setupLocatedFloor:(NSString*)locatedFloor
{
    _locatedFloor = locatedFloor;

    for(YCFloorCell *cellItem in _floorCellArr) {
        [cellItem matchLocatedFloor:locatedFloor];
    }
}

#pragma mark - ui event

- (void)topBtnPressed
{
    NSInteger floorIdx = [self currentSelectedFloorIdx];
    
    if(floorIdx-1<0) return;
    
    [self floorCellClickedAt:floorIdx-1];
}

- (void)downBtnPressed
{
    NSInteger floorIdx = [self currentSelectedFloorIdx];
    
    if(floorIdx<0) return;
    
    if(floorIdx+1>_floorArr.count) return;
    
    [self floorCellClickedAt:floorIdx+1];
}

- (void)floorCellClickedAt:(NSInteger)idx
{
    NSString *clickedFloor = _floorArr[idx];

    if([clickedFloor isEqualToString:_selectedFloor])
        return;
    
    [self changeToFloor:clickedFloor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(_floorPickerClicked) _floorPickerClicked(clickedFloor);
    });

}

- (void)reachTableTop
{
    _topBtn.hidden = YES;
}

- (void)leaveTableTop
{
    _topBtn.hidden = NO;
}

- (void)reachTableBottom
{
    _downBtn.hidden = YES;
}

- (void)leaveTableBottom
{
    _downBtn.hidden = NO;
}

#pragma mark - external call

- (void)setupContent:(NSArray*)floorArr defaultFloor:(NSString*)defaultFloor
{
    if(floorArr==nil)
        return;
    
    if(floorArr.count==0)
        return;
    
    self.hidden = NO;
    
    [self constructTable:floorArr];
    [_floorTable reloadData];

    [self setupSelectedFloor:defaultFloor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToIdx:[self currentSelectedFloorIdx]];
    });

}

- (void)locateToFloor:(NSString*)toFloor
{
    [self setupLocatedFloor:toFloor];
}

- (void)changeToFloor:(NSString*)toFloor
{
    [self setupSelectedFloor:toFloor];
    
    [self scrollToIdx:[self currentSelectedFloorIdx]];

}

#pragma mark - table

- (void)constructTable:(NSArray*)floorArr
{
    _floorArr      = floorArr;
    
    _floorCellArr = [[NSMutableArray alloc] init];
    
    for(NSString *floorItem in _floorArr) {
        YCFloorCell *floorCell = [[YCFloorCell alloc] init];
        [floorCell setupContent:floorItem];
        
        [_floorCellArr addObject:floorCell];
        
    }
    
    YCFloorCell *lastCell = [_floorCellArr lastObject];
    [lastCell noSeparator];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _floorCellArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _floorCellArr[indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self floorCellClickedAt:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(indexPath.row==0){
        [self leaveTableTop];
    } else if (indexPath.row==_floorCellArr.count-1) {
        [self leaveTableBottom];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0){
        [self reachTableTop];
    } else if (indexPath.row==_floorCellArr.count-1) {
        [self reachTableBottom];
    }
}

#pragma mark - utilities

- (NSInteger)currentSelectedFloorIdx
{
    int i = -1;
    
    for(i = 0; i<_floorArr.count; i++) {
        if([_selectedFloor isEqualToString:_floorArr[i]])
            return i;
    }

    return i;
}

- (void)scrollToIdx:(NSInteger)floorIdx
{
    if(floorIdx<0) return;
    
    [_floorTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:floorIdx inSection:0]
                       atScrollPosition:UITableViewScrollPositionMiddle
                               animated:YES];
}

@end
